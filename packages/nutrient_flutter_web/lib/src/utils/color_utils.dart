///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'namespace_utils.dart';

/// Utilities for converting between Dart color integers and Web SDK Color objects.
///
/// The Nutrient Web SDK uses `PSPDFKit.Color` (or `NutrientViewer.Color`)
/// objects with `r`, `g`, `b` properties. Flutter uses ARGB integer values.
class WebColorUtils {
  WebColorUtils._();

  /// Creates a Web SDK `Color` object from an ARGB integer.
  ///
  /// The Web SDK Color constructor expects `{r, g, b}` (0-255 range).
  /// Alpha is not supported by the Web SDK Color class.
  static JSObject colorIntToWebColor(int argb) {
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;

    final ns = NutrientNamespace.getAsJSObject();
    final colorClass = ns['Color'] as JSFunction?;

    if (colorClass == null) {
      throw StateError('Color class not found in Web SDK namespace');
    }

    return colorClass.callAsConstructor(
      <String, dynamic>{'r': r, 'g': g, 'b': b}.jsify(),
    ) as JSObject;
  }

  /// Extracts an ARGB integer from a Web SDK `Color` object.
  ///
  /// Returns fully opaque color (alpha = 0xFF).
  static int webColorToInt(JSObject color) {
    final r = ((color['r'] as JSNumber?)?.toDartInt) ?? 0;
    final g = ((color['g'] as JSNumber?)?.toDartInt) ?? 0;
    final b = ((color['b'] as JSNumber?)?.toDartInt) ?? 0;
    return 0xFF000000 | (r << 16) | (g << 8) | b;
  }

  /// Parses a color value from JSON (hex string or {r,g,b} map) to an ARGB integer.
  ///
  /// Handles:
  /// - Hex strings like `"#FF0000"` or `"#ff0000"`
  /// - Map objects like `{"r": 255, "g": 0, "b": 0}`
  /// - Returns null if the input cannot be parsed.
  static int? parseColorFromJson(dynamic color) {
    if (color == null) return null;

    if (color is String && color.startsWith('#')) {
      final hex = color.substring(1);
      if (hex.length == 6) {
        return 0xFF000000 | int.parse(hex, radix: 16);
      }
    }

    if (color is Map) {
      final r = (color['r'] as num?)?.toInt() ?? 0;
      final g = (color['g'] as num?)?.toInt() ?? 0;
      final b = (color['b'] as num?)?.toInt() ?? 0;
      return 0xFF000000 | (r << 16) | (g << 8) | b;
    }

    return null;
  }

  /// Converts an ARGB integer to a hex color string (e.g., `"#FF0000"`).
  static String colorIntToHex(int argb) {
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// Converts a color map `{r, g, b}` to a hex string `"#RRGGBB"`.
  static String colorMapToHex(Map colorMap) {
    final r = (colorMap['r'] as num?)?.toInt() ?? 0;
    final g = (colorMap['g'] as num?)?.toInt() ?? 0;
    final b = (colorMap['b'] as num?)?.toInt() ?? 0;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }
}
