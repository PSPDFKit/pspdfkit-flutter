import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Extension on [AnnotationType] to provide additional functionality
extension AnnotationTypeExtension on AnnotationType {
  /// Returns the annotation type in the format "pspdfkit/type/variant"
  String get fullName {
    switch (this) {
      case AnnotationType.all:
        return 'pspdfkit/all';
      case AnnotationType.none:
        return 'pspdfkit/none';
      case AnnotationType.undefined:
        return 'pspdfkit/undefined';
      case AnnotationType.link:
        return 'pspdfkit/link';
      case AnnotationType.highlight:
        return 'pspdfkit/markup/highlight';
      case AnnotationType.strikeout:
        return 'pspdfkit/markup/strikeout';
      case AnnotationType.underline:
        return 'pspdfkit/markup/underline';
      case AnnotationType.squiggly:
        return 'pspdfkit/markup/squiggly';
      case AnnotationType.freeText:
        return 'pspdfkit/text';
      case AnnotationType.ink:
        return 'pspdfkit/ink';
      case AnnotationType.square:
        return 'pspdfkit/shape/rectangle';
      case AnnotationType.circle:
        return 'pspdfkit/shape/ellipse';
      case AnnotationType.line:
        return 'pspdfkit/shape/line';
      case AnnotationType.note:
        return 'pspdfkit/note';
      case AnnotationType.stamp:
        return 'pspdfkit/stamp';
      case AnnotationType.caret:
        return 'pspdfkit/caret';
      case AnnotationType.file:
        return 'pspdfkit/file';
      case AnnotationType.sound:
        return 'pspdfkit/sound';
      case AnnotationType.polygon:
        return 'pspdfkit/shape/polygon';
      case AnnotationType.polyline:
        return 'pspdfkit/shape/polyline';
      case AnnotationType.screen:
        return 'pspdfkit/screen';
      case AnnotationType.widget:
        return 'pspdfkit/widget';
      case AnnotationType.watermark:
        return 'pspdfkit/watermark';
      case AnnotationType.trapNet:
        return 'pspdfkit/trapnet';
      case AnnotationType.type3d:
        return 'pspdfkit/3d';
      case AnnotationType.redact:
        return 'pspdfkit/markup/redaction';
      case AnnotationType.image:
        return 'pspdfkit/image';
      case AnnotationType.media:
        return 'pspdfkit/media';
      case AnnotationType.popup:
        return 'pspdfkit/popup';
    }
  }
}

AnnotationType annotationTypeFromString(String annotationString) {
  switch (annotationString) {
    case 'pspdfkit/all':
      return AnnotationType.all;
    case 'pspdfkit/none':
      return AnnotationType.none;
    case 'pspdfkit/undefined':
      return AnnotationType.undefined;
    case 'pspdfkit/link':
      return AnnotationType.link;
    case 'pspdfkit/markup/highlight':
      return AnnotationType.highlight;
    case 'pspdfkit/markup/strikeout':
      return AnnotationType.strikeout;
    case 'pspdfkit/markup/underline':
      return AnnotationType.underline;
    case 'pspdfkit/markup/squiggly':
      return AnnotationType.squiggly;
    case 'pspdfkit/text':
      return AnnotationType.freeText;
    case 'pspdfkit/ink':
      return AnnotationType.ink;
    case 'pspdfkit/shape/rectangle':
      return AnnotationType.square;
    case 'pspdfkit/shape/ellipse':
      return AnnotationType.circle;
    case 'pspdfkit/shape/line':
      return AnnotationType.line;
    case 'pspdfkit/note':
      return AnnotationType.note;
    case 'pspdfkit/stamp':
      return AnnotationType.stamp;
    case 'pspdfkit/caret':
      return AnnotationType.caret;
    case 'pspdfkit/file':
      return AnnotationType.file;
    case 'pspdfkit/sound':
      return AnnotationType.sound;
    case 'pspdfkit/shape/polygon':
      return AnnotationType.polygon;
    case 'pspdfkit/shape/polyline':
      return AnnotationType.polyline;
    case 'pspdfkit/screen':
      return AnnotationType.screen;
    case 'pspdfkit/widget':
      return AnnotationType.widget;
    case 'pspdfkit/watermark':
      return AnnotationType.watermark;
    case 'pspdfkit/media':
      return AnnotationType.media;
    case 'pspdfkit/3d':
      return AnnotationType.type3d;
    case 'pspdfkit/trapnet':
      return AnnotationType.trapNet;
    case 'pspdfkit/popup':
      return AnnotationType.popup;
    case 'pspdfkit/markup/redaction':
      return AnnotationType.redact;
    case 'pspdfkit/image':
      return AnnotationType.image;
  }

  return AnnotationType.none;
}
