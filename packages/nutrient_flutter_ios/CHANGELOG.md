## 1.2.0 - 18 Jun 2026

- Populates `PageInfo.label` from `PSPDFDocument.pageLabelForPageAtIndex(_, substituteWithPlainLabel:)` on iOS (was previously always `null`). Falls back to `null` when the PDF has no explicit label dictionary entry. (J#HYB-951)
- Fixes `BookmarkManagerIOS.toBookmark` emitting `actionJson` as `{"pageIndex": N}` without the `"type": "goTo"` discriminator. The `Bookmark.pageIndex` convenience getter on `nutrient_flutter/bindings.dart` gates on `action['type'] == 'goTo'` before reading `pageIndex`, so the getter always returned `null` on iOS-sourced bookmarks. Now matches the Android and Web impls, which both already emit the canonical GoTo-action shape. (J#HYB-951)
- Implements seven view-scoped methods on `IOSAdapter` via FFI (`PSPDFViewController`, `PSPDFDocumentViewController`, `PSPDFPageView`, `PSPDFAnnotationStateManager`): `getVisibleRect`, `zoomToRect`, `getZoomScale`, `enterAnnotationCreationMode`, `exitAnnotationCreationMode`, `convertViewPointToPdfPoint`, `convertPdfPointToViewPoint`. `getZoomScale` previously returned an error in the legacy plugin and is now functional via `PSPDFPageView.PDFScale`. (J#HYB-952)
- Adds `utils/annotation_tool_ios_mapping.dart` with `iosAnnotationStringNameFor` (testable, FFI-free) and `iosAnnotationStringFor` (FFI-touching) helpers, mapping the platform-interface `AnnotationTool` enum to the iOS `PSPDFAnnotationString*` constants. (J#HYB-952)
- Adds a `nativeViewController` accessor on `IOSAdapter` for subclasses that need direct `PSPDFViewController` access from outside the existing lifecycle callbacks.
- Wires `IOSAdapter` to drive the cross-platform `events` stream via a `PSPDFViewControllerDelegate` attached in `onPlatformViewCreated` (before `onViewControllerReady`): `didChangeDocument` → `DocumentLoadedEvent`, `willBeginDisplayingPageView` → `PageChangedEvent` (deduped via `_lastEmittedPageIndex`), `didSaveDocument:error:` → `DocumentSavedEvent` / `DocumentErrorEvent`, `didSelectAnnotations:onPageView:` → `AnnotationSelectedEvent` + `PageClickedEvent` + `IOSAnnotationTappedEvent`, `didDeselectAnnotations:onPageView:` → `AnnotationDeselectedEvent`, `didSelectText:withGlyphs:atRect:onPageView:` → `TextSelectionChangedEvent`. (J#HYB-957)
- Adds `IOSNutrientEvent` sealed class and `iosEvents` broadcast stream on `IOSAdapter` for iOS-only events: `IOSViewControllerWillDismissEvent`, `IOSViewControllerDidDismissEvent`, `IOSViewModeChangedEvent`, `IOSUserInterfaceShownEvent`, `IOSUserInterfaceHiddenEvent`, `IOSAnnotationTappedEvent`, `IOSInstantDownloadFinishedEvent`, `IOSInstantDownloadFailedEvent`. Subclasses can call the protected `emitIOSEvent(...)` helper. (J#HYB-957)
- Adds `NSNotificationCenter`, `NSNotification`, and `NSOperationQueue` to `ffigen_ios.yaml` and regenerates the iOS bindings to expose `addObserverForName:object:queue:usingBlock:`, the API needed to subscribe to PSPDFKit's annotation notifications (`PSPDFAnnotationsAddedNotification`, `PSPDFAnnotationChangedNotification`, `PSPDFAnnotationsRemovedNotification`). Previously only the notification *names* were `external`'d in the bindings; the subscription API itself was missing. (J#HYB-957)
- Subscribes to `PSPDFAnnotationsAdded` / `Changed` / `Removed` notifications on `NSNotificationCenter.default` to fire `AnnotationCreatedEvent` / `AnnotationUpdatedEvent` / `AnnotationDeletedEvent` on the cross-platform stream. Observer tokens are torn down in `dispose()` via `removeObserver:`. The observer blocks use `ObjCBlock_ffiVoid_NSNotification.listener(...)` (not `.fromFunction(...)`) so they can fire safely from PSPDFKit's background save queue without crashing in `dart::Assert::Fail` / `DLRT_GetFfiCallbackMetadata`. (J#HYB-957)
- Adds `UITapGestureRecognizer` to `ffigen_ios.yaml`, plus a small ObjC helper (`_NutrientPageTapTarget` + `nutrient_install_page_tap` C function in `NutrientFFI.{h,mm}`). Installs a permissive tap gesture recognizer on each `PSPDFPageView` from the `didConfigurePageView:forPageAtIndex:` delegate so empty-page taps fire `PageClickedEvent` with PDF-space coordinates, matching Android's `DocumentListener.onPageClick` contract. The Dart-side handler wraps a `NativeCallable.listener` so the callback can fire from UIKit's gesture-recognizer dispatch thread. (J#HYB-957)
- Adds AI Assistant support to `NutrientInstantViewIOS` via `NutrientViewConfiguration.aiAssistantConfiguration`.
- Honours `NutrientViewConfiguration.enableInstantComments` in `NutrientInstantViewIOS` by inserting `instantCommentMarker` into `editableAnnotationTypes` after the Instant view controller is initialised.

## 1.1.1 - 16 Apr 2026

- Pins `PSPDFKit` and `Instant` podspec dependencies to match `nutrient_flutter`.

## 1.1.0 - 09 Apr 2026

- Adds `NutrientInstantViewIOS`, an iOS implementation of the embedded Instant document widget using `PSPDFInstantViewController` via FFI. (J#HYB-988)
- Fixes Instant two-way sync by retaining the `PSPDFInstantDocumentDescriptor` for the lifetime of the view controller, preventing ARC from releasing it and discarding the sync configuration. (J#HYB-988)
- Fixes Instant sync not working on subsequent document opens by reauthenticating with the JWT when the document is already downloaded locally. (J#HYB-988)
- Adds `IOSConfigurationBuilder` to convert `NutrientViewConfiguration` into a `PSPDFConfigurationBuilder` JSON dict, supporting all major viewer options. (J#HYB-988)

## 1.0.2 - 24 Feb 2026

- Fixes a build error where `NutrientIOSBindings.m` failed to compile with `'PSPDFKit/PSPDFKit.h' file not found` when using the plugin from a third-party app. The native-assets hook now resolves the PSPDFKit Pods directory from the consuming app instead of the plugin's own example app. (#50888)
- Fixes `getViewController` thread safety by dispatching to the main thread when called from a background thread. (#50888)
- Improves build error reporting in `hook/build.dart` by replacing a silent `assert` with an explicit exception. (#50888)

## 1.0.1 - 22 Feb 2026

- Updates to Nutrient iOS SDK 26.5.0. (#50888)
- Regenerates FFI bindings for Nutrient iOS SDK 26.5.0. (#50888)
- Adds a native-assets build hook (`hook/build.dart`) to compile ObjC protocol trampolines into a bundled dylib, fixing the `No asset found` runtime error for FFI delegates. (#50888)
- Fixes an issue where `nutrient_get_view_controller` returned null when called from the `AdapterBridge` / `NutrientView` path. (#50888)
- Fixes AOT compilation errors caused by system opaque-struct globals (`_xpc_*`, `_dispatch_*`, `kDNSService*`) in the generated bindings. (#50888)
- Updates `objective_c` to 9.3.0, `ffi` to 2.2.0, `ffigen` to 20.1.1, `code_assets` to 1.0.0, `hooks` to 1.0.0, `native_toolchain_c` to 0.17.4. (#50888)

## 1.0.0 - 13 Feb 2026

- Initial release as standalone pub.dev package.
- Native iOS bindings using FFI for direct Nutrient iOS SDK integration.
- Provides platform adapter to extend `nutrient_flutter` with native bindings.
- Implements `nutrient_flutter_platform_interface` for the federated plugin architecture.
