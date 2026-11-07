## Next Version

- Updates to Nutrient Web SDK 1.24.0. Since Web SDK 1.23.0, `save()` throws when Document Engine refuses a change, where the Web SDK used to log a console warning and report the save as done. The `dart:js_interop` bindings are still generated from 1.17.0's TypeScript declarations, so APIs new since 1.17.0 aren't reachable through them yet, and some APIs they expose have been removed or deprecated since, such as the model classes' static `defaultValues`. (L#HYB-1127)
- Fixes `NutrientViewWeb` sometimes staying blank with `PSPDFKitError: The mounting container has no width.` in the console. It called `NutrientViewer.load()` a fixed 100 ms after creating its container, which wasn't always enough for Flutter to lay the container out, for example during a route transition or in a background tab. It now loads once the container is attached and has a size; a background tab waits until it's shown. If the container still has no size after 10 seconds on screen, `onDocumentLoadFailed` says so, and the view loads once the container gets one. Also fixes a view disposed while its document was loading keeping the loaded instance. (L#HYB-1122)
- Fixes `AnnotationSelectedEvent` and `AnnotationDeselectedEvent` never carrying the selected annotations. They were built from the Web SDK's `annotations.focus` and `annotations.blur`, whose payload is a focus event rather than annotations. They now come from `annotationSelection.change`, as on Android: `AnnotationDeselectedEvent` for the annotations that leave the selection, as they are when they leave it, then `AnnotationSelectedEvent` for the ones that join it. The selection is reported deselected when the view unloads its document, when another document loads, and when the adapter is disposed. `annotations.focus` and `annotations.blur` still reach `webEvents` with their payload, and `annotationSelection.change` now does too instead of `null`. (L#HYB-1124)
- Adds an `onDocumentLoadFailed` callback to `NutrientViewWeb`, invoked when `NutrientViewer.load()` rejects or the document source cannot be resolved, and emits the failure as a `DocumentErrorEvent` on the `events` stream. Both cases were previously logged to the console and otherwise dropped, leaving an empty viewer. (L#HYB-1050)

## 2.0.0 - 29 Jul 2026

- Implements `NutrientDocumentInterface.getPageInfo` on web via `Instance.pageInfoForIndex`, returning `PageInfo` with width, height (pixels at 100% zoom), rotation (degrees), and label. (J#HYB-951)
- Fixes `BookmarkOperations.removeBookmark` raising `PSPDFKitError: No object with id '<name>' found` on the legacy "match by name" fallback. The Web SDK's `instance.delete(...)` only resolves bookmarks by their SDK-assigned `pdfBookmarkId` or by passing the live `Immutable.Record` itself — the name string is not a valid id. We now keep matching by `pdfBookmarkId` / `name` / page index but always hand the matched live record to `delete(...)`, since `pdfBookmarkId` is not surfaced on freshly-created (unpersisted) bookmarks either. (J#HYB-951)
- Implements seven view-scoped methods on `NutrientWebAdapter`. `zoomToRect`, `getZoomScale`, `enterAnnotationCreationMode`, and `exitAnnotationCreationMode` have full JS-interop implementations; `getVisibleRect`, `convertViewPointToPdfPoint`, and `convertPdfPointToViewPoint` throw `UnimplementedError` (the Web SDK does not expose these at this layer), matching the legacy web controller. (J#HYB-952)
- Adds `utils/annotation_tool_web_mapping.dart` with `webInteractionModeFor` and `annotationPresetForTextMarkupTool` helpers, replacing the legacy `AnnotationToolWebExtension` lookups so the web adapter no longer depends on pigeon-generated enums. (J#HYB-952)
- Wires `NutrientWebAdapter` to drive the cross-platform `events` stream from the Web SDK's `instance.addEventListener(...)`. Cross-platform events fire from `annotations.create`/`update`/`delete`/`focus`/`blur`, `viewState.currentPageIndex.change`, `page.press`, `textSelection.change`, `formFieldValues.update`, and `document.saveStateChange`. `DocumentLoadedEvent` is emitted synchronously at the end of `onInstanceLoaded` since the Web SDK delivers a fully-loaded instance up front. (J#HYB-957)
- Adds `NutrientWebEventData(type, payload)` carrier and a `webEvents` broadcast stream on `NutrientWebAdapter` that mirrors all 73 events from the Web SDK's `NutrientViewer.EventName` enum (sourced canonically from `web/web/src/enums/EventName.ts` in the monorepo). Web-only events are registered with 0-arg JS callbacks because the Web SDK fires events with varying arity (0, 1, or 2 args) and Dart's `.toJS` enforces exact arity — a 1-arg listener crashes on annotation-save events that fire with no payload. (J#HYB-957)
- Updates to Nutrient Web SDK 1.17.0 and regenerates the `dart:js_interop` bindings from its TypeScript declarations.

## 1.1.0 - 09 Apr 2026

- Fixes `baseUrl` not being applied from the user's configuration before the first `NutrientViewer.load()` call, which caused an assertion error on subsequent loads. (J#HYB-910)
- Adds `WebConfigurationBuilder` to convert `NutrientViewConfiguration` into the Nutrient Web SDK configuration object. (J#HYB-988)

## 1.0.0 - 13 Feb 2026

- Initial release as standalone pub.dev package.
- Web platform bindings using `dart:js_interop` and `package:web` for Nutrient Web SDK integration.
- Provides platform adapter to extend `nutrient_flutter` with native bindings.
- Implements `nutrient_flutter_platform_interface` for the federated plugin architecture.
