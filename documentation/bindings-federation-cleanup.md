# Bindings Federation Cleanup — Follow-up

This document captures **work that was started, deferred, and needs to land
in a future PR** once the legacy method-channel surface is removed. It
exists so the next person doesn't re-discover the same trade-offs.

## ❌ Tried and reverted — dropping `implements:` breaks the native build

**Do not remove `implements: nutrient_flutter` from the platform packages.** It
was tried (commit `fca4ffb`, "let simple apps depend on only nutrient_flutter")
and reverted because it breaks every app that depends on `nutrient_flutter`.

The idea looked sound on the Dart side: `default_package` endorsement *replaces*
the app-facing plugin (which suppresses `PspdfkitPlugin` and breaks the legacy
app — see below), whereas a non-endorsed `implements:` impl registers only on a
**direct** dependency. So dropping `implements:` should make the platform package
a plain plugin that registers **transitively** via `nutrient_flutter` while
`PspdfkitPlugin` keeps registering. The Dart registration does work that way —
verified in an isolated app: `.flutter-plugins-dependencies` lists the federated
packages and the generated registrant calls `NutrientFlutterAndroid.registerWith()`.

**But `implements:` is also load-bearing on the NATIVE side.** It tells Flutter to
treat the platform package as *the* implementation of `nutrient_flutter` and
**suppress `nutrient_flutter`'s own native module**. Drop it and **both** native
modules link into the app, because `nutrient_flutter` and each platform package
ship the same native types (e.g. `io.flutter.embedding.android.FlutterAppCompatActivity`,
present in both `nutrient_flutter/android` and `nutrient_flutter_android/android`):

- **Android:** D8 dex-merge fails — *"Type `…FlutterAppCompatActivity$CachedEngineIntentBuilder`
  is defined multiple times."*
- **iOS:** linker fails — *"1 duplicate symbols."*

This hit the catalog **and** the legacy example (any app on `nutrient_flutter`),
not just a corner case. CI: build **#2890** (with `implements:`) was green; build
**#2892** (without it) failed both the Android catalog build and the iOS UI
tests. A minimal "only `nutrient_flutter`" smoke app happened to link on iOS
because it referenced none of the colliding symbols — a false positive; the real
catalog/example builds are the honest test.

So the four-direct-dependency shape stays. `implements:` can only be dropped once
`nutrient_flutter` no longer ships a native module of its own — i.e. after the
legacy plugin's native code (the duplicated `FlutterAppCompatActivity`, the
`MethodChannel('com.pspdfkit.global')` handlers, and the Pigeon handlers) is
relocated to the federated modules / a shared module. That is exactly the
deferred refactor described below.

The original analysis follows, for the record.

---

## What we wanted

Apps that use the **bindings-based** Nutrient Flutter SDK should only need
**one direct dependency** in their `pubspec.yaml`:

```yaml
dependencies:
  nutrient_flutter: ^X.Y.Z
```

`nutrient_flutter` would re-export the bindings API (via
[`package:nutrient_flutter/bindings.dart`](../lib/bindings.dart) — landed)
and pull in the federated platform implementations
(`nutrient_flutter_android` / `_ios` / `_web`) transitively. The native
plugins (`NutrientFlutterPlugin` for Android, similar for iOS / web)
would auto-register via Flutter's federated plugin discovery.

This is the shape every modern federated Flutter plugin uses.

## What's in the way

`nutrient_flutter` is currently a **classic** Flutter plugin — it declares
`flutter.plugin.platforms.android.pluginClass: PspdfkitPlugin` in its
pubspec, and `PspdfkitPlugin.kt` hosts **two responsibilities at once**:

1. The legacy raw `MethodChannel('com.pspdfkit.global')` handlers
   (`frameworkVersion`, `setLicenseKeys`, `present`, `presentInstant`,
   …). These are the method-channel APIs we want to delete.
2. The Pigeon-generated `*Api`/`*Callbacks` handlers used by the legacy
   `PdfDocument` / `NutrientView` widget. These are still in use by
   every legacy example and need to stay until those examples migrate
   to the bindings.

If we add `default_package: nutrient_flutter_android` to `nutrient_flutter`'s
pubspec, Flutter's plugin tool **stops registering `PspdfkitPlugin`** and
only registers the federated `NutrientFlutterPlugin`. That kills (2) along
with (1) — every legacy example breaks (we verified this: `frameworkVersion`
returned `PlatformException` and the example app's "Failed to get platform
version" banner appeared).

So we reverted the `default_package` change and restored the catalog's
direct dependencies on `nutrient_flutter_android` / `_ios` / `_web`. The
legacy example continues to work; the catalog continues to work; **but
bindings users still have to list four packages in `pubspec.yaml`** —
which is the friction we set out to remove.

## What landed in [the original PR]

- **[`package:nutrient_flutter/bindings.dart`](../lib/bindings.dart)** — one
  import covers the entire bindings API. (See
  [bindings-migration-guide.md](bindings-migration-guide.md).)
- **`FlutterAppCompatActivity` moved** from `nutrient_flutter`'s Android
  module to `nutrient_flutter_android`'s, and re-synced with upstream
  `FlutterFragmentActivity` at flutter/flutter@0541913d8. The
  `AiAssistantProvider` integration was removed (legacy users can re-add
  it via subclass).
- **API design findings** documented in
  [bindings-api-feedback.md](bindings-api-feedback.md), including this
  federation issue (finding #14).

## What was deferred (this doc)

### 1. Remove raw method-channel APIs from `Nutrient`

Currently in `nutrient_flutter/lib/src/pspdfkit_flutter_method_channel.dart`,
called via `Nutrient.frameworkVersion`, `Nutrient.setLicenseKeys`,
`Nutrient.present`, `Nutrient.presentInstant`, `Nutrient.setFormFieldValue`,
`Nutrient.getFormFieldValue`, `Nutrient.applyInstantJson`,
`Nutrient.exportInstantJson`, `Nutrient.addAnnotation`,
`Nutrient.processAnnotations`, `Nutrient.importXfdf`, etc.

These all route to `MethodChannel('com.pspdfkit.global').invokeMethod(...)`
and are answered by `PspdfkitPlugin.kt`'s method-channel handler. They
predate the bindings; bindings users don't reach them. The plan is to
remove them entirely, leaving only Pigeon-routed APIs.

### 2. Refactor `PspdfkitPlugin.kt` to only host Pigeon handlers

Once (1) is done, `PspdfkitPlugin` should only register Pigeon-generated
`*Api`/`*Callbacks` handlers. The `MethodChannel('com.pspdfkit.global')`
registration can go away. Same exercise on iOS.

### 3. Move Pigeon handlers from `PspdfkitPlugin` to `NutrientFlutterPlugin`

`PspdfkitPlugin` is in `nutrient_flutter`'s Android module;
`NutrientFlutterPlugin` is in `nutrient_flutter_android`'s. Move the
Pigeon registrations into the latter so the legacy `nutrient_flutter`
Android plugin can be dropped entirely.

(`NutrientView` — the legacy widget — also lives in `nutrient_flutter`'s
Android module today. If we want to keep the widget around alongside
`NutrientDocumentView`, its view-factory registration needs to follow the
Pigeon handlers into `NutrientFlutterPlugin` too. Or we deprecate the
legacy widget at the same time.)

### 4. Add `default_package` federation to `nutrient_flutter`

Now safe — `PspdfkitPlugin` is gone, so federation doesn't suppress
anything:

```yaml
flutter:
  plugin:
    platforms:
      android:
        default_package: nutrient_flutter_android
      ios:
        default_package: nutrient_flutter_ios
      web:
        default_package: nutrient_flutter_web
```

### 5. Trim catalog / migration-guide

- Catalog `pubspec.yaml`: drop the direct deps on
  `nutrient_flutter_platform_interface`, `nutrient_flutter_android`,
  `nutrient_flutter_ios`, `nutrient_flutter_web`, `jni`, `objective_c`.
- Catalog adapter source files: drop the
  `// ignore: depend_on_referenced_packages` comments now that the
  imports resolve transitively without warning.
- [bindings-migration-guide.md](bindings-migration-guide.md): the
  "federation defaults" section currently describes the *target* state —
  rewrite it as the *actual* state.

## Verification checklist (for the cleanup PR)

- [ ] `flutter pub get` in the catalog with only `nutrient_flutter`
      listed produces a `.flutter-plugins-dependencies` whose
      `plugins.android` / `plugins.ios` / `plugins.web` lists include
      `nutrient_flutter_android` / `_ios` / `_web` (not
      `nutrient_flutter`).
- [ ] Catalog launches on Android emulator without crash — confirms
      `FlutterAppCompatActivity` ships via the federated Android plugin's
      AAR (already proven once during this PR's investigation).
- [ ] Catalog launches on iOS simulator and web.
- [ ] Catalog's Maestro flows pass on all three.
- [ ] Legacy example (`nutrient_flutter/example`) compiles. (It will
      break at runtime if it calls any removed method-channel API — fix
      those call sites or drop the affected examples from the legacy
      app.)

## Owner / timing

Tracked in the same J#HYB-951 epic as the bindings work. Land when:

- The legacy `Nutrient.present()` smoke test is no longer the canonical
  way to ship a quick PDF viewer (i.e. the legacy example is either
  ported to the bindings or formally deprecated).
- Pigeon handlers can be relocated without breaking shipping apps.

If priorities shift and we want the "single direct dep" UX sooner, the
intermediate option is to add `default_package` *and* document
"bindings users get the federation default; legacy users must continue
listing `nutrient_flutter_android` as a direct dep" — i.e. the regression
becomes a documented constraint rather than a silent break. This was
option (3) in the original decision and rejected for shipping stability.

> **Empirically tested 2026-05-18 (does not work).** Adding
> `default_package: nutrient_flutter_android` to `nutrient_flutter`'s
> Android plugin manifest *and* listing `nutrient_flutter_android` as a
> direct dep in the consumer app's `pubspec.yaml` still produces a
> `.flutter-plugins-dependencies` whose `plugins.android` list contains
> **only** `nutrient_flutter_android` — `nutrient_flutter` itself is
> dropped. At runtime, every Pigeon call hosted by `PspdfkitPlugin`
> (`NutrientApi.setLicenseKeys`, `Nutrient.frameworkVersion`, etc.)
> fails with `PlatformException(channel-error, Unable to establish
> connection on channel: "dev.flutter.pigeon.nutrient_flutter.NutrientApi.*.nutrient"`.
> Confirmed against the legacy example app booted on emulator
> `emulator-5554`. The "documented constraint" framing only works if
> the consumer never reaches any legacy method-channel or Pigeon API
> hosted by `PspdfkitPlugin` — which is currently not true for any
> shipping app, since every `Nutrient.*` call routes through there.
>
> The real intermediate options, in order of practicality:
>
> 1. **Land the catalog port (step 0 in this doc) first**, so the
>    legacy example becomes a smoke-test-only artefact. Once it's
>    formally deprecated, removing the raw method-channel API + Pigeon
>    relocation can land without breaking a shipping demo.
>
> 2. **Move Pigeon handlers via a shared types module** rather than
>    in-place. Pigeon has no cross-config type-import mechanism and
>    Swift output is `internal`-only, so simply relocating Pigeon
>    impl files between modules without a shared types module
>    surface produces unbuildable Swift / namespace-clashing Kotlin.
>    A new `nutrient_flutter_pigeon_shared` package (or extending
>    `nutrient_flutter_platform_interface`) that holds the generated
>    types lets both legacy and federated plugin modules depend on it.
>    This is the architecturally clean version of step 3 in this doc.
>
> 3. **Wait.** If neither (1) nor (2) is bought down, the single-direct-dep
>    UX is genuinely deferred. Stay on the current four-dep shape and
>    revisit when catalog parity makes (1) cheap.
