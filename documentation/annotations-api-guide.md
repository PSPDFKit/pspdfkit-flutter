# Working with Annotations

Read, create, search, and remove annotations with strongly-typed models — no
hand-built Instant JSON required.

The annotation API hangs off a loaded document's controller:
`controller.document.annotations`. The typed methods (`getAnnotations`,
`addAnnotation`, …) return and accept [`Annotation`](../../nutrient_flutter_platform_interface/lib/src/models/annotations/annotation_models.dart)
models; a raw-JSON escape hatch is available for advanced cases.

```dart
import 'package:nutrient_flutter/bindings.dart';
```

## Reading annotations

```dart
final annotations = controller.document.annotations;

// All annotations on page 0 (typed models).
final all = await annotations.getAnnotations(0);

// Filter by type — filtering is done on the parsed type so it behaves
// identically on Android, iOS, and Web.
final inkOnly = await annotations.getAnnotations(0, AnnotationType.ink);

for (final annotation in all) {
  print('${annotation.type} @ page ${annotation.pageIndex} (id: ${annotation.id})');
}
```

**Annotations with unsaved changes** (native only — see [Platform support](#platform-support)):

```dart
final unsaved = await annotations.getUnsavedAnnotations();
```

**Search** by text content (native only):

```dart
final matches = await annotations.searchAnnotations('invoice', pageIndex: 0);
```

## Adding annotations

Build a typed model and hand it to `addAnnotation`. Fields are strongly typed —
a `Color` and an `InkLines`, not a hex string and nested maps. Bounding boxes and
points are in **PDF coordinates** (origin bottom-left).

```dart
final ink = InkAnnotation(
  id: 'my-ink-1',
  name: 'my-ink-1',
  pageIndex: 0,
  bbox: const [60.0, 700.0, 80.0, 40.0],
  lines: InkLines(
    points: const [
      [
        [60.0, 720.0],
        [90.0, 740.0],
        [120.0, 720.0],
      ],
    ],
    intensities: const [
      [1.0, 1.0, 1.0],
    ],
  ),
  lineWidth: 3,
  strokeColor: const Color(0xFF2492FB),
);

final created = await controller.document.annotations.addAnnotation(ink);
```

`addAnnotation` returns the created annotation parsed back from the platform
(or `null` if the platform returned nothing parseable).

A few more of the common types:

```dart
// Note (comment pin)
NoteAnnotation(
  id: id, pageIndex: 0,
  bbox: const [160.0, 700.0, 32.0, 32.0],
  text: TextContent(format: TextFormat.plain, value: 'Review this'),
  icon: NoteIcon.comment,
  color: const Color(0xFFFFC107),
);

// Highlight (text markup)
HighlightAnnotation(
  id: id, pageIndex: 0,
  bbox: const [60.0, 640.0, 200.0, 20.0],
  rects: const [[60.0, 640.0, 200.0, 20.0]],
  color: const Color(0xFFFFF176),
);

// Free text
FreeTextAnnotation(
  id: id, pageIndex: 0,
  bbox: const [60.0, 580.0, 220.0, 40.0],
  text: TextContent(format: TextFormat.plain, value: 'Draft'),
  fontSize: 16,
  fontColor: const Color(0xFFF4502B),
);

// Rectangle
SquareAnnotation(
  id: id, pageIndex: 0,
  bbox: const [60.0, 500.0, 120.0, 60.0],
  strokeColor: const Color(0xFF2E7D32),
  strokeWidth: 2,
  fillColor: const Color(0x332E7D32),
);
```

## Image annotations and attachments

Image content isn't stored inline in the annotation JSON — it travels as a
binary attachment. Types that carry binary content mix in `HasAttachment`
(currently `ImageAnnotation` and `RichMediaAnnotation`). Attach the bytes as a
Base64-encoded `AnnotationAttachment` and `addAnnotation` forwards them to the
platform out-of-band so the image actually renders:

```dart
final image = ImageAnnotation(
  id: 'my-image-1',
  name: 'my-image-1',
  pageIndex: 0,
  bbox: const [60.0, 420.0, 64.0, 64.0],
  contentType: 'image/png',
  imageAttachmentId: 'my-image-1',
  attachment: const AnnotationAttachment(
    id: 'my-image-1',
    binary: base64Png,        // Base64-encoded PNG bytes
    contentType: 'image/png',
  ),
);

await controller.document.annotations.addAnnotation(image);
```

Malformed attachment data degrades gracefully on every platform: the annotation
is still added, the image just doesn't render — the call never throws.

## Removing annotations

```dart
await controller.document.annotations.removeAnnotation(pageIndex, annotationId);
```

To clear a page, read then remove:

```dart
for (final a in await annotations.getAnnotations(0)) {
  if (a.id != null) await annotations.removeAnnotation(0, a.id!);
}
```

## Whole-document import / export

Import and export every annotation at once with Instant JSON or XFDF:

```dart
// Instant JSON (whole document — on the document, not the annotation manager)
final ok = await controller.document.applyInstantJson(instantJsonString);
final json = await controller.document.exportInstantJson();

// XFDF (on the annotation manager)
final ok = await controller.document.annotations.importXfdf(xfdfString);
final xfdf = await controller.document.annotations.exportXfdf();
```

> `exportXfdf` returns the XFDF **content as a string** (v6.0.0 change — the
> Pigeon API wrote to a file path). Persist it yourself if you need a file.

## Reacting to annotation changes

`controller.events` is a `Stream<NutrientEvent>` with typed filters. The
annotation events expose both a typed `annotations` getter and the raw
`annotationsJson`:

```dart
controller.events.annotationCreated.listen((event) {
  for (final annotation in event.annotations) {
    print('Created: ${annotation.type} (${annotation.id})');
  }
});

controller.events.annotationUpdated.listen((e) => refresh());
controller.events.annotationDeleted.listen((e) => refresh());
controller.events.annotationSelected.listen((e) => inspect(e.annotations));
```

A tap on the page surfaces the hit annotation (if any):

```dart
controller.events.pageClicked.listen((e) {
  final Annotation? tapped = e.annotation;
});
```

For the full event catalogue — document lifecycle, navigation, buffering
semantics, and the platform-support matrix — see
[Working with Events](events-api-guide.md).

## Escape hatch: raw Instant JSON

When you need something the typed models don't cover yet — arbitrary
`customData`, or a not-yet-modelled annotation type — drop down to the JSON
transport the typed layer is built on:

```dart
// Read as an Instant JSON string.
final jsonString = await annotations.getAnnotationsJson(0, 'all');

// Write from an Instant JSON string. `attachment` optionally carries a
// Base64 image attachment (as AnnotationAttachment.toJson()).
final created = await annotations.addAnnotationJson(
  jsonEncode({
    'v': 2,
    'type': 'pspdfkit/ink',
    'pageIndex': 0,
    // …
    'customData': {'reviewer': 'alice'},
  }),
);
```

Every typed model also round-trips through `Annotation.fromJson` / `toJson`,
and `Annotation.tryFromJson` parses defensively (returns `null` on an
unknown/malformed entry instead of throwing).

## Annotation types

| Model | Instant JSON type |
|-------|-------------------|
| `InkAnnotation` | `pspdfkit/ink` |
| `NoteAnnotation` | `pspdfkit/note` |
| `HighlightAnnotation`, `UnderlineAnnotation`, `StrikeoutAnnotation`, `SquigglyAnnotation` | `pspdfkit/markup/*` |
| `FreeTextAnnotation` | `pspdfkit/text` |
| `SquareAnnotation`, `CircleAnnotation` | `pspdfkit/shape/{rectangle,ellipse}` |
| `LineAnnotation`, `PolylineAnnotation`, `PolygonAnnotation` | `pspdfkit/shape/*` |
| `ImageAnnotation` | `pspdfkit/image` |
| `StampAnnotation` | `pspdfkit/stamp` |
| `WidgetAnnotation` | `pspdfkit/widget` (form fields) |

## Platform support

| Operation | Android | iOS | Web |
|-----------|---------|-----|-----|
| `getAnnotations` / `addAnnotation` | ✅ | ✅ | ✅ |
| Image / stamp attachments | ✅ | ✅ | ✅ |
| `removeAnnotation` | ✅ | ✅ | ✅ |
| Instant JSON import / export | ✅ | ✅ | ✅ |
| XFDF import / export | ✅ | ✅ | ✅ |
| `getUnsavedAnnotations` | ✅ | ✅ | ⚠️ returns empty |
| `searchAnnotations` | ✅ | ✅ | ⚠️ returns empty |

## See Also

- [Example: annotations_example.dart](../catalog/lib/examples/annotations_example.dart)
- [Updating Annotation Properties](updating-annotation-properties-guide.md) — edit colour, opacity, flags, custom data
- [Annotation Preset Configuration](annotation-preset-configuration-guide.md)
- [Annotation Creation Mode](annotation-creation-mode.md) — activate the ink/shape/text tools
- [Working with Forms](forms-api-guide.md) — the parallel typed API for AcroForm fields
- [Working with Events](events-api-guide.md) — the full typed event stream, including the annotation events
- [Typed Annotations: cross-platform design](typed-annotations-cross-platform.md) — how the typed layer maps to each platform
