# Legacy MethodChannel removal

As part of the bindings migration (J#HYB-951) the SDK's original
`MethodChannel`-based bridge has been removed. All cross-platform communication
now goes through the Pigeon-generated APIs (`NutrientApi`,
`NutrientViewControllerApi`, `HeadlessDocumentApi`, and their callbacks) and the
JNI/FFI/JS platform-adapter bindings used by `NutrientDocumentView`.

This document records exactly what was removed so the change can be reviewed and
so consumers who reached into the legacy surface know where to go.

## Why

The SDK carried three parallel API generations:

1. **Legacy `MethodChannel`** — `invokeMethod` over `com.nutrient.global`
   (global) and `com.nutrient.widget.<id>` (per-view).
2. **Pigeon** — `NutrientApi` / `NutrientViewControllerApi` /
   `HeadlessDocumentApi` plus typed callbacks.
3. **Bindings** — `NutrientDocumentView` + `NutrientPlatformAdapter`
   (JNI/FFI/JS).

Generation 1 duplicated generation 2 method-for-method and was only reachable
through code paths that are themselves deprecated. It has been removed; the
Pigeon and bindings paths are unchanged.

## Channels that were kept

These channels are *transports* for Pigeon / the bindings, not part of the
removed API. They look like `MethodChannel` usage but never carry the legacy
`invokeMethod` request/response API, so they stay:

| Channel | Purpose |
| --- | --- |
| `com.nutrient.global` | Its `binaryMessenger` backs the Pigeon `NutrientApi` / `HeadlessDocumentApi`. |
| `com.nutrient.widget.<id>` | Its `binaryMessenger` backs the per-view Pigeon `NutrientViewControllerApi`, **and** it carries the adapter-bridge callbacks (`onPdfFragmentReady`, `onViewControllerReady`, `onDocumentLoaded`, `onPageChanged`) consumed by `AdapterBridge`. |
| `com.pspdfkit.document.<documentId>` | Its `binaryMessenger` backs the per-document Pigeon `PdfDocumentApi`. |

## Removed — Dart (`nutrient_flutter`)

- `MethodChannelNutrientFlutter` and `MethodChannelPspdfkitFlutter`
  (`lib/src/nutrient_flutter_method_channel.dart`,
  `lib/src/pspdfkit_flutter_method_channel.dart`). These
  `NutrientFlutterPlatform` implementations were never instantiated — the live
  platform instance is `NutrientFlutterApiImpl` (Pigeon) — and they targeted the
  `com.pspdfkit.global` channel, which was not registered on any platform.
- `PspdfkitWidgetControllerNative`
  (`lib/src/widgets/pspdfkit_widget_controller_native.dart`), the
  method-channel-backed widget controller. `PspdfkitWidget` now always uses the
  Pigeon-backed `PspdfkitFlutterWidgetControllerImpl`.

### Removed public API (BREAKING)

- **`Pspdfkit.useLegacy`** (field) and the **`useLegacy:` parameter on
  `Pspdfkit.initialize(...)`**. The flag only ever selected the now-removed
  `PspdfkitWidgetControllerNative`. Remove the argument; there is no
  replacement — the Pigeon-backed controller is always used.

  ```dart
  // Before
  await Pspdfkit.initialize(androidLicenseKey: '…', useLegacy: true);
  // After
  await Pspdfkit.initialize(androidLicenseKey: '…');
  ```

`Pspdfkit` and `PspdfkitWidget` themselves remain (still deprecated in favour of
`Nutrient` / `NutrientDocumentView`).

## Removed — Android (`nutrient_flutter/android`)

- `PspdfkitPluginMethodCallHandler.kt` — the `com.nutrient.global` handler.
- `PSPDFKitWidgetMethodCallHandler.kt` — the `com.nutrient.widget.<id>` handler.
- `PspdfkitPlugin`: the `com.nutrient.global` `MethodChannel`, the method-call
  handler, the permission-result listener, and the `ActivityLifecycleCallbacks`
  plumbing that only fed the legacy handler.
- `EventDispatcher`: the legacy `channel.invokeMethod` event path. Events are
  delivered through the Pigeon `PspdfkitApiCallbacks` only.
- `PSPDFKitView`: the legacy widget handler registration (the
  `com.nutrient.widget.<id>` channel is kept for the adapter bridge).

Behaviour ported to the Pigeon path: `PspdfkitApiImpl.present()` /
`presentInstant()` now apply `measurementValueConfigurations` from the
configuration map (via `FlutterPdfActivity` / `FlutterInstantPdfActivity`). The
legacy handler used to do this; previously it was dropped on the Pigeon path.

## Removed — iOS (`nutrient_flutter/ios`)

- `PspdfkitFlutterHelper`: the `+processMethodCall:result:forViewController:`
  dispatcher (and its header declaration). **The file is kept** — its
  document/annotation/XFDF/toolbar helper methods are called by the Swift Pigeon
  implementations (`PspdfkitApiImpl`, `PspdfkitPlatformViewImpl`,
  `HeadlessDocumentApiImpl`).
- `PspdfkitPlugin`: the `com.nutrient.global` channel, its `handleMethodCall:`
  dispatch, the `setupViewController` helper, and the
  `PSPDFViewControllerDelegate` / `PSPDFInstantClientDelegate` event forwarding
  (now delivered by `PspdfkitApiImpl` via `NutrientApiCallbacks`). The plugin
  instance is retained with `-publish:` now that `addMethodCallDelegate:` is
  gone, so `detachFromEngineForRegistrar:` still runs.
- `PspdfPlatformView`: the legacy `handleMethodCall:` handler and the unused
  `com.nutrient.global` broadcast channel. The per-view
  `com.nutrient.widget.<id>` channel is kept for the adapter-bridge callbacks.

## Web

Unaffected — the web platform uses JS interop, not method channels.

## Verification

- Dart: `flutter analyze` (0 errors/warnings) and `flutter test` (all pass).
- Android: `./gradlew :nutrient_flutter:compileDebugKotlin compileDebugJavaWithJavac`.
- iOS: `xcodebuild -project Pods/Pods.xcodeproj -target nutrient_flutter -sdk iphonesimulator`.
