# Updating Annotation Properties

Safely update annotation properties without losing attachment data or custom fields.

## Basic Usage

```dart
// Get annotation properties
final properties = await document.getAnnotationProperties(pageIndex, annotationId);

// Update properties (chain multiple updates)
final updated = properties
    ?.withColor(Colors.red)
    .withOpacity(0.7)
    .withLineWidth(3.0);

// Save changes
if (updated != null) {
  await document.saveAnnotationProperties(updated);
}
```

## Common Operations

**Update Color:**

```dart
final updated = properties?.withColor(Colors.blue);
await document.saveAnnotationProperties(updated);
```

**Update Opacity:**

```dart
final updated = properties?.withOpacity(0.5); // 0.0 to 1.0
await document.saveAnnotationProperties(updated);
```

**Update Line Width:**

```dart
final updated = properties?.withLineWidth(2.5);
await document.saveAnnotationProperties(updated);
```

**Toggle Flags:**

```dart
final flags = properties?.flagsSet ?? {};
final newFlags = Set<AnnotationFlag>.from(flags);
newFlags.contains(AnnotationFlag.readOnly)
    ? newFlags.remove(AnnotationFlag.readOnly)
    : newFlags.add(AnnotationFlag.readOnly);

final updated = properties?.withFlags(newFlags);
await document.saveAnnotationProperties(updated);
```

**Update Custom Data:**

```dart
final data = {
  ...(properties?.customData ?? {}),
  'key': 'value',
};

final updated = properties?.withCustomData(data);
await document.saveAnnotationProperties(updated);
```

## Available Methods

| Method | Parameter | Description |
|--------|-----------|-------------|
| `withColor()` | `Color` | Update color |
| `withOpacity()` | `double` | Update opacity (0.0-1.0) |
| `withLineWidth()` | `double` | Update line width |
| `withFlags()` | `Set<AnnotationFlag>` | Update flags |
| `withCustomData()` | `Map<String, String>` | Update custom data |
| `withBoundingBox()` | `Rect` | Update position/size |
| `withContents()` | `String` | Update text content |
| `withSubject()` | `String` | Update subject |

## Common Flags

```dart
AnnotationFlag.hidden        // Hidden from view
AnnotationFlag.print         // Printable
AnnotationFlag.readOnly      // No user interaction
AnnotationFlag.locked        // Cannot delete/modify
AnnotationFlag.lockedContents // Contents locked
```

## With Selection Events

```dart
controller.addEventListener(NutrientEvent.annotationsSelected, (event) async {
  final annotation = event?['annotation'];
  final annotationId = annotation?.id ?? annotation?.name;

  if (annotationId != null) {
    final properties = await document.getAnnotationProperties(
      annotation.pageIndex,
      annotationId,
    );

    final updated = properties?.withColor(Colors.red);
    if (updated != null) {
      await document.saveAnnotationProperties(updated);
    }
  }
});
```

## Migration from Deprecated API

**Old:**

```dart
final annotation = await document.getAnnotation(pageIndex, annotationId);
await document.updateAnnotation(annotation.copyWith(color: Colors.red));
// ❌ Loses metadata.
```

**New:**

```dart
final properties = await document.getAnnotationProperties(pageIndex, annotationId);
final updated = properties?.withColor(Colors.red);
if (updated != null) {
  await document.saveAnnotationProperties(updated);
}
// ✅ Preserves all data
```

## See Also

- [Example: nutrient_annotation_properties_example.dart](../example/lib/nutrient_annotation_properties_example.dart)
- [Annotation Preset Configuration](annotation-preset-configuration-guide.md)
