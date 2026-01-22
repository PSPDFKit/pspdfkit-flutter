///
///  Copyright © 2023-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Utility class for manipulating colors in XHTML content.
///
/// This is primarily used for TextAnnotation font color preservation when
/// updating annotations through the Web SDK. The Web SDK strips complex XHTML
/// structures, so colors need to be embedded in span elements.
class XhtmlColorUtils {
  // Pre-compiled RegExp patterns for XHTML color manipulation (performance optimization)
  static final _xmlDeclarationPattern = RegExp(r'<\?xml[^?]*\?>');
  static final _bodyTagPattern =
      RegExp(r'<body[^>]*>(.*?)</body>', dotAll: true);
  static final _spanWithColorPattern =
      RegExp(r'<span\s+style="[^"]*color:[^"]*"[^>]*>', caseSensitive: false);
  // Pattern to match and update color values in span styles
  // Handles hex (#fff, #ffffff), rgb(), rgba(), and named colors
  static final _spanColorUpdatePattern = RegExp(
      r'(<span\s+style="[^"]*?)color:\s*(?:#[a-fA-F0-9]+|rgb\([^)]*\)|rgba\([^)]*\)|[a-zA-Z]+)([;"])',
      caseSensitive: false);
  static final _pTagPattern = RegExp(r'<p(\s[^>]*)?>(.+?)</p>', dotAll: true);
  static final _spanTagPattern = RegExp(r'<span(\s+style="([^"]*)")?([^>]*)>');
  static final _colorStylePattern = RegExp(r'color:[^;]+;?');
  static final _htmlTagPattern = RegExp(r'<[^>]+>');

  /// Maximum input length to prevent performance issues with regex processing.
  static const maxInputLength = 50000; // 50KB should be more than enough

  /// Converts a color map with r, g, b keys to a hex color string.
  ///
  /// Example:
  /// ```dart
  /// colorMapToHex({'r': 255, 'g': 0, 'b': 128}); // Returns '#ff0080'
  /// ```
  static String colorMapToHex(Map colorMap) {
    final r = (colorMap['r'] ?? 0) as int;
    final g = (colorMap['g'] ?? 0) as int;
    final b = (colorMap['b'] ?? 0) as int;
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// Updates the color styles in rich text XHTML content.
  ///
  /// The Web SDK strips complex XHTML structures (<?xml?>, <body>, etc.) on update,
  /// leaving only the content inside <p> tags. This method ensures color is embedded
  /// in <span> elements within the content, not in body/xml attributes.
  ///
  /// Input examples:
  /// - Complex: `<?xml version="1.0"?><body xmlns="..." style="...color:#430083..."><p>Hello</p></body>`
  /// - Simple: `<p>Hello</p>`
  /// - With span: `<p><span style="color:#430083">Hello</span></p>`
  ///
  /// Output: `<p><span style="color:#hexColor">content</span></p>`
  static String updateRichTextColor(String xhtml, String hexColor) {
    // Input validation to prevent ReDoS attacks with crafted inputs
    if (xhtml.length > maxInputLength) {
      // For oversized content, strip HTML and return a simple fallback
      final truncated =
          xhtml.replaceAll(_htmlTagPattern, '').substring(0, 1000);
      return '<p><span style="color:$hexColor">$truncated...</span></p>';
    }

    // First, extract the actual text content from any XHTML structure
    String textContent = xhtml;

    // Remove XML declaration if present
    textContent = textContent.replaceAll(_xmlDeclarationPattern, '');

    // Extract content from body tag if present (handles complex PDF XHTML)
    final bodyMatch = _bodyTagPattern.firstMatch(textContent);
    if (bodyMatch != null) {
      textContent = bodyMatch.group(1) ?? textContent;
    }

    // Now textContent should be like: <p>Hello</p> or <p><span ...>Hello</span></p>

    // Check if there's already a span with color style
    if (_spanWithColorPattern.hasMatch(textContent)) {
      // Update existing span color
      return textContent.replaceAllMapped(
        _spanColorUpdatePattern,
        (match) => '${match.group(1)}color:$hexColor${match.group(2)}',
      );
    }

    // No span with color - we need to wrap content in spans
    // Handle <p> tags by wrapping their content in colored spans
    if (textContent.contains('<p>') || textContent.contains('<p ')) {
      final result = textContent.replaceAllMapped(_pTagPattern, (match) {
        final pAttrs = match.group(1) ?? '';
        var content = match.group(2) ?? '';

        // If content already has spans without color, add color to them
        if (content.contains('<span')) {
          // Add color to existing spans that don't have it
          content = content.replaceAllMapped(
            _spanTagPattern,
            (spanMatch) {
              final existingStyle = spanMatch.group(2) ?? '';
              final otherAttrs = spanMatch.group(3) ?? '';
              if (existingStyle.contains('color:')) {
                // Already has color, update it
                final newStyle = existingStyle.replaceAll(
                    _colorStylePattern, 'color:$hexColor;');
                return '<span style="$newStyle"$otherAttrs>';
              } else if (existingStyle.isNotEmpty) {
                // Has style but no color, add color
                return '<span style="color:$hexColor;$existingStyle"$otherAttrs>';
              } else {
                // No style at all, add it
                return '<span style="color:$hexColor"$otherAttrs>';
              }
            },
          );
          return '<p$pAttrs>$content</p>';
        }

        // No spans, wrap entire content in a colored span
        return '<p$pAttrs><span style="color:$hexColor">$content</span></p>';
      });
      return result;
    }

    // No <p> tags, just wrap everything in p and span
    // Strip any remaining HTML tags to get plain text
    final plainText = textContent.replaceAll(_htmlTagPattern, '').trim();
    if (plainText.isNotEmpty) {
      return '<p><span style="color:$hexColor">$plainText</span></p>';
    }

    // Fallback - return as-is with color wrapper
    return '<p><span style="color:$hexColor">$textContent</span></p>';
  }
}
