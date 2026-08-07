# Working with Events

React to document lifecycle, navigation, annotation, form, and text-selection
changes through one typed stream — no string event names, no untyped payloads.

Every controller exposes `controller.events`, a broadcast
`Stream<NutrientEvent>`. [`NutrientEvent`](../../nutrient_flutter_platform_interface/lib/src/events/nutrient_event.dart)
is a **sealed class**, so a `switch` over it is exhaustive — when a new event
type is added, the analyzer points at every switch you need to extend.

```dart
import 'package:nutrient_flutter/bindings.dart';
```

## Subscribing

Subscribe to everything and pattern-match:

```dart
NutrientDocumentView(
  documentPath: 'assets/document.pdf',
  onControllerReady: (controller) {
    controller.events.listen((event) {
      switch (event) {
        case DocumentLoadedEvent(:final document):
          debugPrint('Loaded — ${document.getPageCount()} pages');
        case PageChangedEvent(:final pageIndex):
          debugPrint('Page → $pageIndex');
        case AnnotationCreatedEvent(:final annotations):
          debugPrint('Created ${annotations.map((a) => a.type.name)}');
        default:
          break;
      }
    });
  },
)
```

Or use the typed filter getters when you only care about one event:

```dart
controller.events.documentLoaded.listen((e) async {
  final pageCount = await e.document.getPageCount();
});
controller.events.pageChanged.listen((e) => setState(() => _page = e.pageIndex));
controller.events.annotationCreated.listen((e) => refresh(e.annotations));
```

Every event class has a matching filter getter: `documentLoaded`,
`documentError`, `documentSaved`, `pageChanged`, `pageClicked`,
`annotationCreated`, `annotationUpdated`, `annotationDeleted`,
`annotationSelected`, `annotationDeselected`, `textSelectionChanged`,
`formFieldUpdated`, `instantSyncStarted`, `instantSyncFinished`,
`instantSyncFailed`, `instantAuthFinished`, `instantAuthFailed`.

## You won't miss the load event

`DocumentLoadedEvent` can fire from the native layer *before* your
`onControllerReady` callback runs. The controller buffers events emitted before
the first listener attaches and flushes them (in order) once you subscribe — so
subscribing inside `onControllerReady` is always safe. Buffered events are
delivered to the **first** listener only; later listeners follow normal
broadcast semantics and see only what's emitted after they subscribe.

## Event reference

### Document lifecycle

| Event | Payload | Emitted when |
|-------|---------|--------------|
| `DocumentLoadedEvent` | `document` — the loaded [`NutrientDocumentInterface`](../../nutrient_flutter_platform_interface/lib/src/interfaces/nutrient_document_interface.dart) | The document is fully loaded and ready |
| `DocumentErrorEvent` | `error` — human-readable description | The document fails to load |
| `DocumentSavedEvent` | `path` — output path, or `null` when saving in-place | A save completes successfully |

`DocumentLoadedEvent` carries the document itself (the same instance as
`controller.document`), so handlers can act on it directly without closing
over the controller:

```dart
controller.events.documentLoaded.listen((event) async {
  final info = await event.document.getPageInfo(0);
  final fields = await event.document.forms.getFormFields();
});
```

### Navigation

| Event | Payload | Emitted when |
|-------|---------|--------------|
| `PageChangedEvent` | `pageIndex` (zero-based) | The viewer navigates to a different page |
| `PageClickedEvent` | `pageIndex`, `point` (PDF-space `Offset?`), `annotation` (typed, `null` on miss) | The user taps a page |

### Annotations

All five annotation events share the same payload shape: the raw
`annotationsJson` (Instant JSON, one string per annotation) plus two typed
getters parsed from it — `annotations` (full
[`Annotation`](../../nutrient_flutter_platform_interface/lib/src/models/annotations/annotation_models.dart)
models: `id`, `type`, `pageIndex`, `bbox`, `creatorName`, …) and `types`
(their `AnnotationType`s, handy for filtering).

| Event | Emitted when |
|-------|--------------|
| `AnnotationCreatedEvent` | Annotations are created |
| `AnnotationUpdatedEvent` | Annotations are modified |
| `AnnotationDeletedEvent` | Annotations are removed |
| `AnnotationSelectedEvent` | The user selects annotations |
| `AnnotationDeselectedEvent` | The user deselects annotations |

```dart
controller.events.annotationCreated.listen((event) {
  if (event.types.contains(AnnotationType.ink)) {
    for (final annotation in event.annotations) {
      debugPrint('${annotation.type.name} on page ${annotation.pageIndex}');
    }
  }
});
```

> `annotations` parses the JSON on each access — grab it into a local rather
> than reading it repeatedly. Unknown or malformed entries are skipped, never
> thrown; the raw string is always available in `annotationsJson`.

### Text selection and forms

| Event | Payload | Emitted when |
|-------|---------|--------------|
| `TextSelectionChangedEvent` | `selectedText` (`null` = cleared) | The user's text selection changes |
| `FormFieldUpdatedEvent` | `formFieldJson` + typed `formField` getter | A form field value changes |

### Instant

Fire only for Instant (collaboration) documents; never on Web.

| Event | Payload |
|-------|---------|
| `InstantSyncStartedEvent` | `documentId` |
| `InstantSyncFinishedEvent` | `documentId` |
| `InstantSyncFailedEvent` | `documentId`, `error` |
| `InstantAuthFinishedEvent` | `documentId`, `jwt` |
| `InstantAuthFailedEvent` | `documentId`, `error` |

## Platform-specific events

`controller.events` carries only the cross-platform surface. Each adapter
additionally exposes a platform-only stream for events that have no equivalent
elsewhere:

- `AndroidAdapter.androidEvents` → `AndroidNutrientEvent` (e.g. document
  zoomed, save failed/cancelled)
- `IOSAdapter.iosEvents` → `IOSNutrientEvent`
- `NutrientWebAdapter.webEvents` → `NutrientWebEventData`

See [Extending the Platform Adapter](extending-the-platform-adapter.md) for
how these are wired and how to add your own.

## Platform support

| Event | Android | iOS | Web |
|-------|---------|-----|-----|
| `DocumentLoadedEvent` | ✅ | ✅ | ✅ |
| `DocumentErrorEvent` | ✅ | ✅ | ❌ load errors throw instead |
| `DocumentSavedEvent` | ✅ | ✅ | ✅ |
| `PageChangedEvent` | ✅ | ✅ | ✅ |
| `PageClickedEvent` | ✅ with `point` | ✅ | ✅ without `point` |
| Annotation events | ✅ | ✅ | ✅ |
| `TextSelectionChangedEvent` | ✅ with text | ✅ with text | ✅ with text (async fetch — emitted a microtask later than on native) |
| `FormFieldUpdatedEvent` | ✅ | ✅ | ✅ |
| Instant sync/auth events | ❌ not yet wired | ✅ Instant views | ❌ by design |

Platform notes:

- **Web — document loaded**: the Web SDK instance is already fully loaded when
  the adapter receives it, so `DocumentLoadedEvent` fires synchronously during
  setup. Thanks to buffering (above) you still receive it from a listener
  attached in `onControllerReady`.
- **Web — saves**: the Web SDK reports a single `saveStateChange` in both
  directions; the adapter only emits `DocumentSavedEvent` on the
  dirty → clean transition, matching the Android/iOS "did save" semantics.

## See Also

- [Example: event_stream_example.dart](../catalog/lib/examples/event_stream_example.dart) — live log of every cross-platform event
- [Working with Annotations](annotations-api-guide.md) — the typed read/write API behind the annotation events
- [Working with Forms](forms-api-guide.md) — the typed API behind `FormFieldUpdatedEvent`
- [Extending the Platform Adapter](extending-the-platform-adapter.md) — emit custom events from your own adapter
