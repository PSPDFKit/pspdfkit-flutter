# Bindings API Friendliness — Field Notes

Collected while porting the **Comprehensive Platform Adapter** example
(catalog row 35) and refactoring the `nutrient_flutter` import shape. All
notes are about the *bindings developer experience* — the `Nutrient` /
`NutrientPlatformAdapter` / `NutrientController` / `NutrientDocumentView`
surface that a third-party SDK consumer interacts with.

Captured opportunistically during real implementation; each entry includes a
file/line pointer where useful, the symptom we hit, and a concrete
improvement direction. Not all of them have to be addressed in any single
PR — file accordingly.

---

## Adapter surface

### 1. No per-`NutrientDocumentView` adapter override

**Symptom.** `Nutrient.initialize(androidAdapter: ...)` registers a single
adapter per platform globally. Every `NutrientDocumentView<T>` in the app
resolves the same instance via `Nutrient.currentAdapter`. To let *one*
screen (the Platform Adapter example) receive native-only callbacks that
other screens don't care about, we invented an `attachListeners` /
`detachListeners` setter pair on a custom `CatalogAdapterController`
interface — and pages are responsible for paying back the attach in
`dispose`. If two pages forget to detach, callbacks fire on a stale
`State`.

**Improvement.** Accept an `adapter:` override on `NutrientDocumentView<T>`:

```dart
NutrientDocumentView<MyController>(
  documentPath: '...',
  adapter: MyScreenAdapter(),     // scoped to this view only
)
```

Internally fall back to `Nutrient.currentAdapter` when null, so existing
code keeps working. This is also how the legacy `NutrientView` worked.

### 2. Adapter-bound listeners are global to the platform, not the view

**Symptom.** Today's `AndroidAdapter` wires its `DocumentListener` /
annotation listener / etc. in `onPdfFragmentReady`. With one adapter
instance, the listeners fire for whichever `NutrientDocumentView` is
currently mounted — they survive across screens. State management (e.g.
"which page index am I on") therefore has to be reset on every
`onFragmentDetached`/`onFragmentReady` cycle, and any callbacks the page
attached have to be cleaned up manually.

**Improvement.** Either (a) instantiate one adapter per view (related to
#1), or (b) make `addEventListener`-style APIs that return a subscription
the user disposes alongside the view.

### 3. Inconsistent lifecycle vocabulary across platforms

**Symptom.** Writing a cross-platform adapter family means learning three
overlapping vocabularies:

| Android | iOS | Web |
| --- | --- | --- |
| `onPlatformViewCreated` | `onPlatformViewCreated` | `onPlatformViewCreated` |
| `configureFragment(builder, ctx)` | `configureView(builder)` | `configureLoad(Map<String, dynamic>)` |
| `onFragmentAttached(fragment, ctx)` | — | — |
| `onPdfFragmentReady` / `onFragmentReady` | `onViewControllerReady` | `onInstanceLoaded(instance)` |
| `onFragmentDetached` | `onViewControllerDetached` | `dispose` |

Three different "the native view is up" hooks, three different
"configure me before construction" hooks, three different "tear down"
hooks. A user copying their Android adapter to iOS rewrites every
override.

**Improvement.** Normalize on common verbs:

```dart
abstract class NutrientPlatformAdapter {
  Future<void> onViewReady(NutrientViewHandle handle);   // Android: fragment ready
                                                         // iOS:     vc ready
                                                         // Web:     instance loaded
  Future<void> onViewDetached();
  void configureView(/* platform-specific builder via T */);
}
```

The platform-specific builder type is fine to keep (`PdfActivityConfigurationBuilder`
vs. `PSPDFConfigurationBuilder` vs. `Map<String, dynamic>`); the *verb*
just needs to match.

### 4. `onFragmentReady` doesn't enforce `super.onFragmentReady(...)`

**Symptom.** [nutrient_flutter_android/lib/src/android_platform_adapter.dart:458](../../nutrient_flutter_android/lib/src/android_platform_adapter.dart#L458)
is a `@protected Future<void> onFragmentReady(PdfFragment) async {}`
no-op. The doc says "override this for custom initialization" but doesn't
mark it `@mustCallSuper`. If a future SDK release adds real work to this
method, every existing subclass that didn't `await super.onFragmentReady(...)`
silently skips it. (We *did* call super out of habit, but there's no
compiler help.)

**Improvement.** Add `@mustCallSuper` to all subclass-overridable lifecycle
hooks that have non-empty default behaviour, or that are likely to grow
non-empty default behaviour.

### 5. `JNI overload suffix` (`$1`) bleeds into adapter code

**Symptom.** [catalog_android_adapter.dart:158](../../nutrient_flutter/catalog/lib/adapters/catalog_android_adapter.dart#L158)
calls `nativePdfFragment?.setPageIndex$1(pageIndex, true)`. The `$1` is a
jnigen overload-disambiguation artefact, not a documented part of the
Android SDK API. A user looking at the Kotlin docs sees
`setPageIndex(int, boolean)`; jnigen renames it to `setPageIndex$1` because
the no-arg overload sits in the same class.

**Improvement.** Either (a) the generator exposes friendlier overload
aliases (`setPageIndexAnimated`), or (b) the platform package's public
documentation includes a "jnigen naming cheatsheet" pointing at the
`$N` numbering. The current state is "go read the generated bindings to
find the right name," which isn't friendly.

### 6. Cross-platform event classes aren't re-exported from the per-platform packages

**Symptom.** `IOSAdapter.events` returns `Stream<NutrientEvent>`, where
`NutrientEvent` is the platform-interface sealed class. To `switch` over
it in an iOS adapter you need a second import of
`nutrient_flutter_platform_interface` (annotated with
`// ignore: depend_on_referenced_packages`). Same on Android and Web.

**Improvement.** Each per-platform package should re-export at least
the event sealed-class hierarchy from `nutrient_flutter_platform_interface`,
so `import 'package:nutrient_flutter_ios/nutrient_flutter_ios.dart';` is
enough to name `DocumentLoadedEvent` etc.

Partially mitigated this PR by adding
`package:nutrient_flutter/bindings.dart` as a one-shot consumer entry —
but the per-platform packages themselves still have the gap.

### 7. iOS adapter has effectively nothing left to wire after HYB-957

**Symptom.** [ios_platform_adapter.dart:418-484](../../nutrient_flutter_ios/lib/src/ios_platform_adapter.dart#L418-L484)
already wires every interesting `PSPDFViewControllerDelegate` callback
and routes it to `events` or `iosEvents`. When porting the "comprehensive
platform adapter" example to iOS, the only thing the custom adapter
adds is a `goToPage` reach-through — the rest of the legacy example's
manual delegate wiring is now redundant.

By contrast, the same example on Android still needs explicit wiring for
`onDocumentClick` and the contextual-toolbar lifecycle, because those
aren't surfaced on the typed `events` stream yet.

**Improvement.** Either (a) align Android's typed event coverage with
iOS so the cross-platform contract is "everything you care about is on
`controller.events` + the platform-specific stream," or (b) document the
asymmetry so users know which platform requires which extra wiring.

### 8. `Nutrient.currentAdapter` returns the wrong adapter on desktop hosts

**Symptom.** [nutrient.dart:159-174](../../nutrient_flutter_platform_interface/lib/src/nutrient.dart#L159-L174)
falls through `linux`, `macos`, `windows`, `fuchsia` to `_webAdapter`.
The comment says "Web is handled by `kIsWeb` check" but there's no
`kIsWeb` guard. On Flutter web running on a Mac, `defaultTargetPlatform`
reports `TargetPlatform.macOS` — so the macOS case correctly returns
`_webAdapter`. But on native macOS (when desktop targets are added in
the future), the same case will return the web adapter erroneously.

**Improvement.**

```dart
static NutrientPlatformAdapter? get currentAdapter {
  if (!_initialized) return null;
  if (kIsWeb) return _webAdapter;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android: return _androidAdapter;
    case TargetPlatform.iOS:     return _iosAdapter;
    default:                     return null;       // desktop unsupported
  }
}
```

---

## Controller surface (`NutrientControllerInterface`)

### 9. No public page-navigation API

**Symptom.** The controller exposes zoom, viewport, and coordinate
conversion but no `goToPage(int)` or `currentPageIndex` getter. To
navigate, every adapter has to reach into the platform's native view
(`PdfFragment.setPageIndex$1`, `PSPDFViewController.setPageIndex_animated`,
`Instance.setViewState`) and re-implement the call. The catalog's
`CatalogAdapterController` did exactly this in three different ways.

**Improvement.** Add `goToPage(int pageIndex, {bool animated})` and a
`Future<int> getCurrentPageIndex()` to `NutrientControllerInterface`.
Implement on each platform once. Closes the gap that made `goToPage`
need to be re-invented as a custom controller interface.

### 10. No "is attached to a view" getter

**Symptom.** From inside an adapter method (e.g. `attachListeners` called
from a page's `initState`), there's no way to ask "do I currently have a
view attached?" The catalog adapter checks `nativePdfDocument != null` as
a proxy, but that's fragile (the document can be `null` for an attached
but not-yet-loaded view).

**Improvement.** Expose `bool get isAttached` on the platform adapter
that returns true between `onViewReady` and `onViewDetached`.

### 11. Many controller methods default to `throw UnimplementedError`

**Symptom.** [nutrient_controller.dart:117-183](../../nutrient_flutter_platform_interface/lib/src/nutrient_controller.dart#L117-L183)
defaults every viewer-level method (zoom, viewport, coord conversion,
annotation creation mode) to `throw UnimplementedError`. Each platform
adapter must override every method to no-op the feature, even when it
genuinely doesn't apply (e.g. web doesn't support all of them today). A
user adding a new method to the interface has to remember to override it
in three platforms or all existing apps start throwing.

**Improvement.** Either:

- Split the interface into capability-mixed traits (`ZoomCapable`,
  `AnnotationModeCapable`, …) and have the controller advertise what it
  supports.
- Or default each method to a `Future` that completes with a sensible
  no-op return value instead of throwing.

---

## Package layout

### 12. `nutrient_flutter` didn't re-export `nutrient_flutter_platform_interface` until this PR

**Symptom (now fixed by this PR).** Pre-bindings.dart, a user needed
three imports + `hide` clauses to get the bindings types without
clashing with the legacy pigeon types. Added
`package:nutrient_flutter/bindings.dart` as a sub-library.

**Follow-up.** Audit other per-platform packages (`nutrient_flutter_ios`,
`nutrient_flutter_web`) to apply the same sub-library pattern. Today
their public library exports the full FFI / JS interop binding surface
which has thousands of generated types that collide with
platform-interface names like `Nutrient`, `Bookmark`, `PageInfo`.

### 13. Per-platform packages re-export their full JNI/FFI bindings at the top level

**Symptom.** `import 'package:nutrient_flutter_android/nutrient_flutter_android.dart';`
pulls 22k+ lines of generated `nutrient_android_sdk_bindings.dart` into
the consumer's namespace — including `class Nutrient`, `class Bookmark`,
`class PageInfo` which collide with the cross-platform types. We can't
re-export the per-platform package from `bindings.dart` without
extensive `hide:` clauses.

**Improvement.** Move the raw bindings behind a deep import
(`package:nutrient_flutter_android/bindings.dart`) and have the public
top-level only export the user-facing extensibility surface
(`AndroidAdapter`, the adapter's lifecycle hooks, the document/annotation
manager interfaces). The catalog already takes this shape elsewhere — it
just doesn't propagate down to the federated platform packages yet.

### 14. Plugin federation requires `default_package` for transitive discovery (deferred)

**Symptom.** Without `default_package` entries on `nutrient_flutter`'s
plugin manifest, an app depending only on `nutrient_flutter` gets the
wrapper's plugin (`PspdfkitPlugin`, the legacy method-channel one)
registered but **not** `NutrientFlutterPlugin` from
`nutrient_flutter_android` (which registers the
`nutrient_fragment_container` platform-view factory). Apps therefore
must list every federated package explicitly in their `pubspec.yaml` for
the bindings to function at runtime.

**Status:** We tried adding `default_package` in this PR. Flutter's
plugin tool then registered *only* the federated plugin and **dropped
`PspdfkitPlugin`**, which hosts both the legacy raw method-channel
handlers (`Nutrient.frameworkVersion`, `Nutrient.present`, …) *and* the
Pigeon-generated handlers that the legacy `PdfDocument` / `NutrientView`
widget depend on. Every legacy example regressed (banner
`"Nutrient Failed to get platform version."`; `PdfDocument.save()` etc.
silently no-ops).

We reverted the change. The catalog still lists each federated package
as a direct dep (matching the legacy example's setup). The single-direct-
dep UX is tracked as a follow-up in
[`bindings-federation-cleanup.md`](bindings-federation-cleanup.md) —
which depends on removing the raw method-channel APIs and relocating
Pigeon handlers to the federated plugin first.

### 15. `FlutterAppCompatActivity` lived in the wrong module (fixed)

**Symptom (now fixed by this PR).** The workaround activity class lived
in `nutrient_flutter`'s Android module. Apps using the bindings *without*
the legacy plugin (i.e. apps that only registered `nutrient_flutter_android`
as their Android plugin) couldn't reference
`io.flutter.embedding.android.FlutterAppCompatActivity` from their
`AndroidManifest.xml` because the class wasn't on their runtime classpath.

**Improvement (landed in this PR).** Moved the class to
`nutrient_flutter_android`. Re-synced with upstream
`FlutterFragmentActivity` at flutter/flutter@0541913d8 (drops the
legacy `AiAssistantProvider` integration that depended on
`PSPDFKitView`). Documented the migration in
[`bindings-migration-guide.md`](bindings-migration-guide.md).

---

## Summary

Of the 15 findings above, **this PR landed concrete fixes for finding
#12 and finding #15** to unblock the catalog. Finding #14 was attempted
and reverted — see the finding itself for the regression details and
the follow-up plan in
[`bindings-federation-cleanup.md`](bindings-federation-cleanup.md). The
rest are filed as opportunities for future PRs — none are catalog-
blocking. The highest-leverage wins (in rough order of impact for a
third-party SDK consumer):

1. **#9** — public `goToPage` on the controller (eliminates the entire
   `CatalogAdapterController` workaround in user apps).
2. **#1** — per-`NutrientDocumentView` adapter override (eliminates the
   global-singleton + `attachListeners` dance for any app that wants
   per-screen adapter behaviour).
3. **#14** — collapse to a single direct dep via federation defaults
   (depends on removing the raw method-channel API and relocating
   Pigeon handlers — tracked in
   [`bindings-federation-cleanup.md`](bindings-federation-cleanup.md)).
4. **#3** — normalize lifecycle hook names across platforms.
5. **#13** — hide raw bindings behind deep imports on the per-platform
   packages.
6. **#7** — Android event-stream coverage parity with iOS.
