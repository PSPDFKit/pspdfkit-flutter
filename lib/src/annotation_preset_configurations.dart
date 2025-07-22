import 'package:flutter/services.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

///
///  Copyright © 2019-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Annotation configuration class. Used to configure annotation presets.
///
abstract class AnnotationConfiguration {
  ///Available only on iOS
  BlendMode? blendMode;

  final Map<AnnotationConfigurationProperty, dynamic>? properties = {};

  /// Returns a map of properties.
  /// This method is used internally by the SDK.
  Map<String, Object> toMap();

  /// Specify more annotation properties which can be used to configure annotation presets. These may not be available on all platforms.
  /// AnnotationConfigurationProperty is an enum which contains all the available properties.
  /// The value of the property can be of any type.
  void setProperty(AnnotationConfigurationProperty property, dynamic value) {
    properties?[property] = value;
  }

  /// Returns the value of the specified property.
  Map<String, Object?> _getProperties() {
    return properties
            ?.map((key, value) => MapEntry(key.name, value as Object?)) ??
        {};
  }
}

/// Annotation configuration class for ink annotation. Ink annotations include: InkPen, MagicInk, Highlighter, Eraser and Signature.
class InkAnnotationConfiguration extends AnnotationConfiguration {
  final Color? color;
  final double? thickness;
  final Color? fillColor;
  final double? alpha;
  final List<Color>? availableColors;
  final List<Color>? availableFillColors;
  final double? minThickness;
  final double? maxThickness;
  final double? minAlpha;
  final double? maxAlpha;
  final bool? enableColorPicker;
  final bool? previewEnabled;

  InkAnnotationConfiguration({
    this.color,
    this.thickness,
    this.fillColor,
    this.alpha,
    this.availableColors,
    this.availableFillColors,
    this.minThickness,
    this.maxThickness,
    this.minAlpha,
    this.maxAlpha,
    this.enableColorPicker,
    this.previewEnabled,
  });

  @override
  Map<String, Object> toMap() {
    final map = _getProperties();
    map['color'] = color?.toHex();
    map['thickness'] = thickness;
    map['fillColor'] = fillColor?.toHex();
    map['alpha'] = alpha;
    map['availableColors'] = availableColors?.map((e) => e.toHex()).toList();
    map['availableFillColors'] =
        availableFillColors?.map((e) => e.toHex()).toList();
    map['minThickness'] = minThickness;
    map['maxThickness'] = maxThickness;
    map['minAlpha'] = minAlpha;
    map['maxAlpha'] = maxAlpha;
    map['enableColorPicker'] = enableColorPicker;
    map['previewEnabled'] = previewEnabled;
    map['blendMode'] = blendMode?.name;
    map.removeWhere((key, value) => value == null);
    return map.cast<String, Object>();
  }
}

/// Annotation configuration class for line annotation. Line annotations include: Line, Arrow, PolyLine and Distance Measurement.
class LineAnnotationConfiguration extends AnnotationConfiguration {
  final Color? color;
  final double? thickness;
  final Color? fillColor;
  final double? alpha;
  final LineEnd? lineEndingStyle;

  LineAnnotationConfiguration({
    this.color,
    this.thickness,
    this.fillColor,
    this.alpha,
    this.lineEndingStyle,
  });

  @override
  Map<String, Object> toMap() {
    Map<String, Object?> map = _getProperties();
    map['color'] = color?.toHex();
    map['thickness'] = thickness;
    map['fillColor'] = fillColor?.toHex();
    map['alpha'] = alpha;
    map['blendMode'] = blendMode?.name;
    if (lineEndingStyle != null) {
      map['lineEndStyle'] =
          '${lineEndingStyle?.start.name},${lineEndingStyle?.end.name}';
    }
    map.removeWhere((key, value) => value == null);
    return map.cast<String, Object>();
  }
}

/// Annotation configuration class for FreeText annotation. FreeText annotations include: FreeText and FreeTextCallOut.
class FreeTextAnnotationConfiguration extends AnnotationConfiguration {
  final Color? color;
  final double? thickness;
  final Color? fillColor;
  final String? fontName;
  final double fontSize;
  final String? text;
  final TextAlign? textAlignment;
  final double? alpha;

  FreeTextAnnotationConfiguration(
      {this.color,
      this.thickness,
      this.fillColor,
      this.fontName,
      this.fontSize = 0.0,
      this.text,
      this.textAlignment,
      this.alpha});

  @override
  Map<String, Object> toMap() {
    final map = _getProperties();
    map['color'] = color?.toHex();
    map['thickness'] = thickness;
    map['fillColor'] = fillColor?.toHex();
    map['alpha'] = alpha;
    map['fontName'] = fontName;
    map['fontSize'] = fontSize as Object;
    map['text'] = text;
    map['textAlignment'] = textAlignment?.name;
    map['blendMode'] = blendMode?.name;
    map.removeWhere((key, value) => value == null);
    return map.cast<String, Object>();
  }
}

/// Annotation configuration class for ShapeAnnotations annotation. Shape annotations include: Square, Circle, Polygon and Area Measurement.
class ShapeAnnotationConfiguration extends AnnotationConfiguration {
  final Color? color;
  final double? thickness;
  final Color? fillColor;
  final double? alpha;
  final BorderStyle? borderStyle;

  ShapeAnnotationConfiguration({
    this.color,
    this.thickness,
    this.fillColor,
    this.alpha,
    this.borderStyle,
  });

  @override
  Map<String, Object> toMap() {
    final map = _getProperties();
    map['color'] = color?.toHex();
    map['thickness'] = thickness;
    map['fillColor'] = fillColor?.toHex();
    map['alpha'] = alpha;
    map['borderStyle'] = borderStyle?.name;
    map['blendMode'] = blendMode?.name;
    map.removeWhere((key, value) => value == null);
    return map.cast<String, Object>();
  }
}

/// Annotation configuration class for TextMarkup annotation. TextMarkup annotations include: Highlight, Underline, StrikeOut and Squiggly.
class MarkupAnnotationConfiguration extends AnnotationConfiguration {
  final Color? color;
  final double? thickness;
  final Color? fillColor;
  final double? alpha;

  MarkupAnnotationConfiguration({
    this.color,
    this.thickness,
    this.fillColor,
    this.alpha,
  });

  @override
  Map<String, Object> toMap() {
    final map = _getProperties();
    map['color'] = color?.toHex();
    map['thickness'] = thickness;
    map['fillColor'] = fillColor?.toHex();
    map['alpha'] = alpha;
    map['blendMode'] = blendMode?.name;
    map.removeWhere((key, value) => value == null);
    return map.cast<String, Object>();
  }
}

/// Annotation configuration class for Stamp annotation. Stamp annotations include: Stamp and Image Annotation.
class StampAnnotationConfiguration extends AnnotationConfiguration {
  final List<String>? availableStampItems;

  StampAnnotationConfiguration({
    this.availableStampItems,
  });

  @override
  Map<String, Object> toMap() {
    final map = _getProperties();
    map['availableStampItems'] = availableStampItems;
    map.removeWhere((key, value) => value == null);
    return map.cast<String, Object>();
  }
}

/// Annotation configuration class for Redaction annotation.
class ReductionAnnotationConfigurations extends AnnotationConfiguration {
  final Color? color;
  final Color? fillColor;
  final Color? outlineColor;
  final String? overlayText;
  final String? repeatOverlayText;

  ReductionAnnotationConfigurations(
      {this.color,
      this.fillColor,
      this.outlineColor,
      this.overlayText,
      this.repeatOverlayText});

  @override
  Map<String, Object> toMap() {
    final map = _getProperties();
    map['color'] = color?.toHex();
    map['fillColor'] = fillColor?.toHex();
    map['outlineColor'] = outlineColor?.toHex();
    map['overlayText'] = overlayText;
    map['repeatOverlayText'] = repeatOverlayText;
    map['blendMode'] = blendMode?.name;
    map.removeWhere((key, value) => value == null);
    return map.cast<String, Object>();
  }
}

/// Annotation configuration class for Note annotation.
class NoteAnnotationConfiguration extends AnnotationConfiguration {
  final Color? color;
  final String? iconName;

  NoteAnnotationConfiguration({this.color, this.iconName});

  @override
  Map<String, Object> toMap() {
    final map = _getProperties();
    map['color'] = color?.toHex();
    map['iconName'] = iconName;
    map['blendMode'] = blendMode?.name;
    map.removeWhere((key, value) => value == null);
    return map.cast<String, Object>();
  }
}

class LineEnd {
  final LineEndingStyle start;
  final LineEndingStyle end;

  LineEnd({required this.start, required this.end});
}

/// Line ending style enum. Used to configure line ending style for line annotation.
enum LineEndingStyle {
  none,
  square,
  circle,
  diamond,
  openArrow,
  closedArrow,
  butt,
  reversedOpenArrow,
  reversedClosedArrow,
  slash,
}

/// Annotation configuration property enum. Used to configure annotation presets.
enum AnnotationConfigurationProperty {
  /// Annotation color.
  color,

  /// Annotation thickness.
  thickness,

  /// Annotation fill color.
  fillColor,

  /// Annotation alpha. Ranges from 0.0 to 1.0.
  alpha,

  /// Line annotation start and end line ending style.
  lineEndingStyle,

  /// FreeText annotation font name.
  fontName,

  /// FreeText annotation font size.
  fontSize,

  /// FreeText annotation text alignment.
  textAlignment,

  /// Stamp annotation name.
  stampName,

  /// Available only on iOS.
  blendMode,

  ///Annotation border style.
  borderStyle,

  /// Redaction Annotation overlay text.
  overlayText,

  /// Redaction Annotation repeat overlay text.
  repeatOverlayText,

  /// Annotation outline color.
  outlineColor,

  /// Note annotation icon name.
  iconName,

  /// Available annotation colors. Used to configure annotation color picker.
  availableColors,

  /// Available annotation fill colors. Used to configure annotation color picker. Available only on Android.
  availableFillColors,

  /// Minimum annotation thickness. Available only on Android.
  minThickness,

  /// Maximum annotation thickness. Available only on Android.
  maxThickness,

  /// Minimum annotation alpha. Available only on Android.
  minAlpha,

  /// Maximum annotation alpha. Available only on Android.
  maxAlpha,

  /// Available only on Android.
  enableColorPicker,

  /// Enable annotation preview. Available only on Android.
  previewEnabled,

  /// Available only on Android.
  forceDefaults,

  /// Available only on Android.
  audioSampleRate,
}
