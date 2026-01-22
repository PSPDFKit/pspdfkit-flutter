# Headless Document API

Open and manipulate PDF documents without displaying a viewer. This is useful for batch processing, annotation copying, and server-side operations.

## Basic Usage

```dart
// Open a document without displaying a viewer
final document = await Nutrient.openDocument('/path/to/document.pdf');

try {
  // Perform operations...
  final pageCount = await document.getPageCount();
  final annotations = await document.getAnnotations(0, AnnotationType.all);

  // Save changes
  await document.save();
} finally {
  // Always close headless documents to release resources
  await document.close();
}
```

## Opening Documents

**Basic:**

```dart
final document = await Nutrient.openDocument('/path/to/document.pdf');
```

**Password-protected:**

```dart
final document = await Nutrient.openDocument(
  '/path/to/encrypted.pdf',
  password: 'secret',
);
```

**From assets (extract first):**

```dart
// Copy asset to temporary directory
final bytes = await rootBundle.load('assets/document.pdf');
final tempDir = await Nutrient.getTemporaryDirectory();
final tempFile = File('${tempDir.path}/document.pdf');
await tempFile.writeAsBytes(bytes.buffer.asUint8List());

final document = await Nutrient.openDocument(tempFile.path);
```

## Reading Annotations

**Get annotations from a page:**

```dart
// Get all annotations on page 0
final annotations = await document.getAnnotations(0, AnnotationType.all);

// Get specific annotation types
final inkAnnotations = await document.getAnnotations(0, AnnotationType.ink);
final highlights = await document.getAnnotations(0, AnnotationType.highlight);
```

**Iterate through all pages:**

```dart
final pageCount = await document.getPageCount();
final allAnnotations = <Annotation>[];

for (int i = 0; i < pageCount; i++) {
  final pageAnnotations = await document.getAnnotations(i, AnnotationType.all);
  allAnnotations.addAll(pageAnnotations);
}

print('Found ${allAnnotations.length} annotations');
```

## Adding Annotations

**Add a single annotation:**

```dart
final inkAnnotation = InkAnnotation(
  pageIndex: 0,
  bbox: [100, 100, 300, 200],
  lines: InkLines(points: [
    [100, 150],
    [150, 100],
    [200, 150],
    [250, 100],
    [300, 150],
  ]),
  lineWidth: 3,
  strokeColor: Colors.blue,
  createdAt: DateTime.now().toIso8601String(),
);

await document.addAnnotation(inkAnnotation);
```

**Add multiple annotations:**

```dart
final annotations = [
  NoteAnnotation(
    pageIndex: 0,
    bbox: [50, 50, 80, 80],
    contents: 'This is a note',
    createdAt: DateTime.now().toIso8601String(),
  ),
  HighlightAnnotation(
    pageIndex: 0,
    bbox: [100, 200, 400, 220],
    rects: [[100, 200, 400, 220]],
    createdAt: DateTime.now().toIso8601String(),
  ),
];

await document.addAnnotations(annotations);
```

## Removing Annotations

```dart
// Get an annotation first
final annotations = await document.getAnnotations(0, AnnotationType.ink);

if (annotations.isNotEmpty) {
  await document.removeAnnotation(annotations.first);
}
```

## Processing Annotations

Process annotations to flatten, embed, or remove them from the document.

**Flatten all annotations:**

```dart
await document.processAnnotations(
  AnnotationType.all,
  AnnotationProcessingMode.flatten,
  '/path/to/flattened.pdf',
);
```

**Remove specific annotation types:**

```dart
// Remove all ink annotations
await document.processAnnotations(
  AnnotationType.ink,
  AnnotationProcessingMode.remove,
  '/path/to/output.pdf',
);
```

**Embed annotations:**

```dart
await document.processAnnotations(
  AnnotationType.all,
  AnnotationProcessingMode.embed,
  '/path/to/embedded.pdf',
);
```

## Copying Annotations Between Documents

Copy annotations from one document to another using XFDF export/import.

```dart
final sourceDoc = await Nutrient.openDocument('/path/to/source.pdf');
final targetDoc = await Nutrient.openDocument('/path/to/target.pdf');

try {
  // Export annotations from source as XFDF
  final tempDir = await Nutrient.getTemporaryDirectory();
  final xfdfPath = '${tempDir.path}/annotations.xfdf';
  await sourceDoc.exportXfdf(xfdfPath);

  // Import annotations to target
  final xfdfContent = await File(xfdfPath).readAsString();
  await targetDoc.importXfdf(xfdfContent);

  // Save target document
  await targetDoc.save(outputPath: '/path/to/output.pdf');

  // Cleanup
  await File(xfdfPath).delete();
} finally {
  await sourceDoc.close();
  await targetDoc.close();
}
```

**Alternative: Using Instant JSON:**

```dart
final sourceDoc = await Nutrient.openDocument('/path/to/source.pdf');
final targetDoc = await Nutrient.openDocument('/path/to/target.pdf');

try {
  // Export annotations as Instant JSON
  final instantJson = await sourceDoc.exportInstantJson();

  if (instantJson != null) {
    // Apply to target document
    await targetDoc.applyInstantJson(instantJson);
    await targetDoc.save();
  }
} finally {
  await sourceDoc.close();
  await targetDoc.close();
}
```

## Working with Form Fields

**Get form field value:**

```dart
final value = await document.getFormFieldValue('form_field_name');
```

**Set form field value:**

```dart
await document.setFormFieldValue('New Value', 'form_field_name');
```

**Get all form fields:**

```dart
final formFields = await document.getFormFields();
for (final field in formFields) {
  print('${field.name}: ${field.value}');
}
```

## Saving Documents

**Save to original location:**

```dart
await document.save();
```

**Save to new location:**

```dart
await document.save(outputPath: '/path/to/output.pdf');
```

**Save with options:**

```dart
await document.save(
  outputPath: '/path/to/output.pdf',
  options: DocumentSaveOptions(
    incremental: true,
    flatten: false,
  ),
);
```

## Exporting PDF Data

**Export as bytes:**

```dart
final pdfBytes = await document.exportPdf();
await File('/path/to/output.pdf').writeAsBytes(pdfBytes);
```

## Document Information

**Get page count:**

```dart
final pageCount = await document.getPageCount();
```

**Get page info:**

```dart
final pageInfo = await document.getPageInfo(0);
print('Page size: ${pageInfo.width} x ${pageInfo.height}');
print('Rotation: ${pageInfo.rotation}');
```

## Error Handling

```dart
try {
  final document = await Nutrient.openDocument('/path/to/document.pdf');

  try {
    // Operations that might fail
    await document.processAnnotations(
      AnnotationType.all,
      AnnotationProcessingMode.flatten,
      '/path/to/output.pdf',
    );
  } catch (e) {
    print('Processing failed: $e');
  } finally {
    await document.close();
  }
} catch (e) {
  print('Failed to open document: $e');
}
```

## Complete Example: Watermark Removal

A common use case is copying annotations from a watermarked document to a clean document.

```dart
Future<void> removeWatermarkKeepAnnotations({
  required String watermarkedPath,
  required String cleanPath,
  required String outputPath,
}) async {
  final watermarkedDoc = await Nutrient.openDocument(watermarkedPath);
  final cleanDoc = await Nutrient.openDocument(cleanPath);

  try {
    // Export annotations from watermarked document
    final tempDir = await Nutrient.getTemporaryDirectory();
    final xfdfPath = '${tempDir.path}/annotations_transfer.xfdf';
    await watermarkedDoc.exportXfdf(xfdfPath);

    // Import to clean document
    final xfdfContent = await File(xfdfPath).readAsString();
    await cleanDoc.importXfdf(xfdfContent);

    // Save result
    await cleanDoc.save(outputPath: outputPath);

    // Cleanup
    await File(xfdfPath).delete();

    print('Successfully created clean document with annotations at: $outputPath');
  } finally {
    await watermarkedDoc.close();
    await cleanDoc.close();
  }
}
```

## Platform Support

| Feature | Android | iOS | Web |
|---------|---------|-----|-----|
| Open document | Yes | Yes | Yes |
| Read annotations | Yes | Yes | Yes |
| Add annotations | Yes | Yes | Yes |
| Remove annotations | Yes | Yes | Yes |
| Process annotations | Yes | Yes | No |
| Export XFDF | Yes | Yes | Yes |
| Import XFDF | Yes | Yes | Yes |
| Export Instant JSON | Yes | Yes | Yes |
| Apply Instant JSON | Yes | Yes | Yes |
| Form fields | Yes | Yes | Yes |
| Save document | Yes | Yes | Yes |
| Password protection | Yes | Yes | Yes |

## Best Practices

1. **Always close documents** - Headless documents hold native resources that must be released.

2. **Use try-finally** - Ensure documents are closed even when errors occur.

3. **Prefer XFDF for annotation transfer** - More reliable across different document versions.

4. **Check for null** - Some operations may return null if they fail.

5. **Handle errors gracefully** - Document operations can fail for various reasons (file not found, permissions, corrupted files).

## See Also

- [Example: headless_document_example.dart](../example/lib/headless_document_example.dart)
- [Dirty State Tracking](dirty-state-tracking-guide.md) - Track unsaved changes
- [Updating Annotation Properties](updating-annotation-properties-guide.md)
- [Annotation Preset Configuration](annotation-preset-configuration-guide.md)
