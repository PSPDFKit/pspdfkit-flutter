## Next Version

- Applies `AndroidViewConfiguration.showStylusButton` on `NutrientView` through `AnnotationToolbar.setShouldShowStylusButton()`. `NutrientInstantView` builds a plain `InstantPdfUiFragment` and ignores the option. (J#HYB-1023)

## 1.2.0 - 18 Jun 2026

- Populates `PageInfo.label` from `PdfDocument.getPageLabel(int, boolean)` on Android (was previously always `null`). Falls back to `null` when the PDF has no explicit label dictionary entry. (J#HYB-951)
- **BREAKING:** `io.flutter.embedding.android.FlutterAppCompatActivity` moved from `nutrient_flutter` to `nutrient_flutter_android`, and the class is re-synced with upstream `FlutterFragmentActivity` at flutter/flutter@0541913d8. The Nutrient-specific deltas are now limited to (a) extending `androidx.appcompat.app.AppCompatActivity` instead of `androidx.fragment.app.FragmentActivity`, and (b) the class rename. The previous `AiAssistantProvider` integration that delegated to `PSPDFKitView.Companion.getAiAssistant()` has been removed because it required reaching into the legacy `nutrient_flutter` Android module. Apps that need the legacy AI Assistant binding can subclass `FlutterAppCompatActivity` in their own module, `implements io.nutrient.domain.ai.AiAssistantProvider`, and register the subclass in their `AndroidManifest.xml` instead. See `nutrient_flutter`'s migration notes for details. (J#HYB-951)
- Implements seven view-scoped methods on `AndroidAdapter` via JNI (the `PdfFragment` and `ViewProjection` Kotlin SDK classes): `getVisibleRect`, `zoomToRect`, `getZoomScale`, `enterAnnotationCreationMode`, `exitAnnotationCreationMode`, `convertViewPointToPdfPoint`, `convertPdfPointToViewPoint`. (J#HYB-952)
- Adds `utils/annotation_tool_android_mapping.dart` with `androidAnnotationToolNameFor` (testable, JNI-free) and `toAndroidAnnotationTool` (FFI-touching) helpers, mapping the platform-interface `AnnotationTool` enum to the JNI-bound Java enum. (J#HYB-952)
- Adds `utils/jni_rect_f.dart`, a small raw-JNI helper that constructs and reads back `android.graphics.RectF` instances since jnigen does not bind it. (J#HYB-952)
- Wires `AndroidAdapter` to drive the cross-platform `events` stream via JNI listeners on `PdfFragment`: `DocumentListener` for load/save/page/zoom/click, `AnnotationProvider$OnAnnotationUpdatedListener` for annotation CRUD, `OnAnnotationSelectedListener` for selection/deselection, `FormManager$OnFormElementUpdatedListener` for form field updates, and `TextSelectionManager$OnTextSelectionChangeListener` for text selection. Listener wiring runs in `onPdfFragmentReady` before the new `onFragmentReady` subclass hook. (J#HYB-957)
- Adds `AndroidNutrientEvent` sealed class and `androidEvents` broadcast stream on `AndroidAdapter` for events that don't have a cross-platform equivalent: `AndroidAnnotationZOrderChangedEvent`, `AndroidDocumentZoomedEvent`, `AndroidDocumentSaveFailedEvent`, `AndroidDocumentSaveCancelledEvent`, `AndroidActivityPausedEvent`, `AndroidFragmentAddedEvent`, `AndroidFormEditingModeChangedEvent`, `AndroidAnnotationCreationModeChangedEvent`. Subclasses can call the protected `emitAndroidEvent(...)` helper to push their own platform-specific events. (J#HYB-957)
- Splits the `onPdfFragmentReady` lifecycle hook: the SDK now wires its built-in listeners in `onPdfFragmentReady` and calls a new `@protected onFragmentReady(PdfFragment)` hook for subclasses. Subclasses that previously overrode `onPdfFragmentReady` should switch to overriding `onFragmentReady` so the SDK's listeners stay registered. (J#HYB-957)
- Adds AI Assistant support to `NutrientInstantViewAndroid` via `NutrientViewConfiguration.aiAssistantConfiguration`.
- Honours `NutrientViewConfiguration.enableInstantComments` in `AndroidConfigurationBuilder` by appending `INSTANT_COMMENT_MARKER` and `INSTANT_HIGHLIGHT_COMMENT` to the enabled annotation tools.
- Implements `NutrientDocumentInterface.exportPdf` on the federated Android plugin via the synchronous `PdfProcessor.processDocument(task, file, saveOptions)` JNI overload. Honours `DocumentSaveOptions.flatten` and `DocumentSaveOptions.excludeAnnotations` via `PdfProcessorTask.changeAllAnnotations(FLATTEN | DELETE)`, and `DocumentSaveOptions.optimize` via `DocumentSaveOptions.setRewriteAndOptimizeFileSize`. The processor writes to a JVM temp file (via `java.io.File.createTempFile`), the Dart side reads it back as bytes and best-effort-deletes it. Password / permissions / pdf-version mapping is still defaults-only — track richer save-options support as a follow-up. (J#HYB-951)
- Adds `utils/jni_file.dart`, a small raw-JNI helper for `java.io.File` (constructor from path, `createTempFile`, `getAbsolutePath`, `delete`). jnigen doesn't bind `java.io.File` since it isn't part of the Nutrient SDK surface, but the sync `PdfProcessor.processDocument(...)` overload needs one. (J#HYB-951)
- Updates to Nutrient Android SDK 11.5.1, migrating to the 11.5 toolbar APIs and jni 1.0 bindings. (#54079)

## 1.1.0 - 09 Apr 2026

- Adds `NutrientInstantViewAndroid`, an Android implementation of the embedded Instant document widget using `InstantPdfUiFragment` via JNI. (J#HYB-988)
- Adds `AndroidConfigurationBuilder` to convert `NutrientViewConfiguration` into the native Android viewer configuration. (J#HYB-988)
- Sets Android `compileSdkVersion` and `targetSdkVersion` to 36. (J#HYB-990)

## 1.0.0 - 13 Feb 2026

- Initial release as standalone pub.dev package.
- Native Android bindings using JNI for direct Nutrient Android SDK integration.
- Provides platform adapter to extend `nutrient_flutter` with native bindings.
- Implements `nutrient_flutter_platform_interface` for the federated plugin architecture.
