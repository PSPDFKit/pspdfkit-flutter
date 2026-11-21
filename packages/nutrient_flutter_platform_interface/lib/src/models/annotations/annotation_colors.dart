import 'package:flutter/material.dart';

/// Extension to convert Color to hex string
extension ColorToHex on Color? {
  /// Converts a [Color] to a hex string in `#AARRGGBB` format.
  ///
  /// Fully opaque colors (alpha = 0xFF) are emitted as `#RRGGBB` for
  /// backwards compatibility with platform parsers that accept both forms.
  String toHex() {
    if (this == null) return '';
    final alpha = (this!.a * 255).round();
    final red = (this!.r * 255).round();
    final green = (this!.g * 255).round();
    final blue = (this!.b * 255).round();
    final rgb = '#${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
    if (alpha == 0xFF) return rgb;
    return '#${alpha.toRadixString(16).padLeft(2, '0')}${rgb.substring(1)}';
  }
}

/// Extension to convert hex string to Color
extension HexToColor on String {
  /// Convert hex string to Color
  Color toColor() {
    final buffer = StringBuffer();
    if (length == 6 || length == 7) buffer.write('ff');
    buffer.write(replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// Predefined colors for annotations
class AnnotationColors {
  static const Color yellow = Color(0xFFFFEB3B);
  static const Color red = Color(0xFFF44336);
  static const Color green = Color(0xFF4CAF50);
  static const Color blue = Color(0xFF2196F3);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
}
