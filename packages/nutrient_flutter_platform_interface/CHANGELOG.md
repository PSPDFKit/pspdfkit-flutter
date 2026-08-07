## Next Version

- Adds `AndroidViewConfiguration.showStylusButton` to hide or show the stylus tool button on the Android annotation toolbar independently of stylus auto-detection. (J#HYB-1023)

## 1.2.0 - 18 Jun 2026

- **BREAKING:** `AnnotationProperties.strokeColor` and `AnnotationProperties.fillColor` are now `int?` (ARGB, e.g. `0xFFFF0000`) instead of `String?` (hex, e.g. `"#FF0000"`). This aligns the platform-interface type with how its own extensions and the web layer already handled colors. Migration: replace hex strings with their ARGB equivalent, e.g. `Colors.red.toARGB32()` or a literal like `0xFFFF0000`. (J#HYB-951)
- Extends `DocumentSaveOptions` with the `permissions`, `pdfVersion`, `includeComments`, `outputFormat`, and `optimize` fields. Adds `DocumentPermissions` and `PdfVersion` enums. (J#HYB-951)
- Adds `AnnotationTool` enum so `NutrientControllerInterface` can express the annotation-creation tool without depending on pigeon-generated code. (J#HYB-952)
- Adds seven view-scoped methods to `NutrientControllerInterface`: `getVisibleRect`, `zoomToRect`, `getZoomScale`, `enterAnnotationCreationMode`, `exitAnnotationCreationMode`, `convertViewPointToPdfPoint`, `convertPdfPointToViewPoint`. The base `NutrientController` class throws `UnimplementedError` for each; the Android, iOS, and Web platform packages all override these. (J#HYB-952)
- Adds a unified typed event stream to `NutrientControllerInterface`: `Stream<NutrientEvent> get events`. `NutrientEvent` is a sealed class hierarchy covering 17 cross-platform events (document load/error/save, page change/click, annotation create/update/delete/select/deselect, text selection, form-field update, Instant sync/auth). The `NutrientEventStreamX` extension provides typed filter getters (`events.pageChanged`, `events.annotationCreated`, etc.) so consumers can subscribe to a specific event type without writing pattern matches by hand. (J#HYB-957)
- Adds `emitEvent(NutrientEvent)` as a `@protected` helper on the base `NutrientController` for platform adapters to push into the shared stream; `dispose()` closes the stream. (J#HYB-957)
- Adds the `aiAssistantConfiguration` field to `NutrientViewConfiguration`.
- Adds `enableInstantComments` field to `NutrientViewConfiguration`.

## 1.1.0 - 09 Apr 2026

- Adds `NutrientViewConfiguration`, a typed cross-platform viewer configuration with `IOSViewConfiguration`, `AndroidViewConfiguration`, shared enums (`PageLayoutMode`, `ThumbnailBarMode`, `SpreadFitting`, etc.), and a `PdfConfigurationBuilder` interface. Replaces `NutrientInstantConfiguration`. (J#HYB-988)

## 1.0.0 - 13 Feb 2026

- Initial release as standalone pub.dev package.
- Provides common platform interface for federated plugin architecture.
- Defines abstract APIs for native SDK integration across Android, iOS, and Web platforms.
- Enables extending `nutrient_flutter` with native bindings through platform adapters.
