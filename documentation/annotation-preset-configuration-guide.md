# Configuring Annotation Presets

## Basic Usage

Customize default annotation properties using `setAnnotationConfigurations` on your `PspdfkitWidgetController`:

```dart
// Call within onPdfDocumentLoaded
_controller?.setAnnotationConfigurations({
  AnnotationTool.inkPen: InkAnnotationConfiguration(
    color: Colors.purple,
    thickness: 2.0,
  ),
  AnnotationTool.highlight: MarkupAnnotationConfiguration(
    color: Colors.yellow.withOpacity(0.4),
  ),
});
```

## Available Configuration Types

- **`InkAnnotationConfiguration`**: For Pen, Highlighter, Magic Ink, Eraser, Signature
- **`LineAnnotationConfiguration`**: For Line, Arrow, Polyline, Distance Measurement
- **`FreeTextAnnotationConfiguration`**: For Free Text, Callout
- **`ShapeAnnotationConfiguration`**: For Square, Circle, Polygon, Area Measurement
- **`MarkupAnnotationConfiguration`**: For Highlight, Underline, Strikeout, Squiggly
- **`StampAnnotationConfiguration`**: For Stamp and Image annotations
- **`ReductionAnnotationConfigurations`**: For Redaction tools
- **`NoteAnnotationConfiguration`**: For Note annotations

## Platform Considerations

### Signature Configuration
Signatures require specific implementations:

- **iOS**: Uses `SignatureHelper` class. When a signature saving strategy is specified, PSPDFKit sets up `PSPDFKeychainSignatureStore` automatically.
- **Android**: Implement `DatabaseSignatureStorage` in your `FlutterPdfActivity` where `PdfFragment` is used.

### Platform-Specific Properties
- **iOS**: `blendMode`, `borderStyle`
- **Android**: `availableColors`, `min/maxThickness`, `min/maxAlpha`, `enableColorPicker`, etc.

For details, see [`AnnotationConfiguration`][].

[`annotationconfiguration`]: https://pub.dev/documentation/pspdfkit_flutter/latest/pspdfkit_flutter/AnnotationConfiguration-class.html
