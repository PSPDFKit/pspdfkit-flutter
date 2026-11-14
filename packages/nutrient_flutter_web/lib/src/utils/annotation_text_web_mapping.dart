///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// The cross-platform `AnnotationProperties.contents` on web.
//
// The Web SDK keeps the text of notes (`pspdfkit/note`) and free text
// (`pspdfkit/text`) in a `text` field shaped `{format, value}`, where `format`
// is `plain` or, for free text only, `xhtml`. Other annotation types have no
// `text` field.

/// The plain text of a Web SDK `text` value ([text], `{format, value}`), or
/// null when [text] isn't one.
///
/// XHTML is reduced to its text: paragraphs and line breaks become newlines,
/// tags are dropped and entities are decoded.
String? contentsFromWebText(Object? text) {
  if (text is! Map) return null;
  final value = text['value'];
  if (value is! String) return null;
  return text['format'] == 'xhtml' ? plainTextFromXhtml(value) : value;
}

/// Reports the text of a serialized Web SDK annotation ([json]) as its
/// `contents`, when it has a `text` field.
void reportContentsFrom(Map<String, dynamic> json) {
  final contents = contentsFromWebText(json['text']);
  if (contents != null) json['contents'] = contents;
}

/// The Web SDK `text` value that holds [contents] as plain text.
Map<String, String> plainWebText(String contents) =>
    {'format': 'plain', 'value': contents};

final _xmlDeclaration = RegExp(r'<\?xml[^>]*\?>');
final _body = RegExp(r'<body[^>]*>(.*?)</body>', dotAll: true);
final _paragraphBreak = RegExp(r'</p>\s*<p(\s[^>]*)?>', caseSensitive: false);
final _lineBreak = RegExp(r'<br\s*/?>', caseSensitive: false);
final _tag = RegExp(r'<[^>]+>');
final _entity = RegExp(r'&(#x[0-9a-fA-F]+|#[0-9]+|[a-zA-Z]+);');
const _namedEntities = {
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
};

/// The text of the XHTML [xhtml], with paragraphs and line breaks as
/// newlines.
String plainTextFromXhtml(String xhtml) {
  var text = xhtml.replaceAll(_xmlDeclaration, '');
  text = _body.firstMatch(text)?.group(1) ?? text;
  text = text
      .trim()
      .replaceAll(_paragraphBreak, '\n')
      .replaceAll(_lineBreak, '\n')
      .replaceAll(_tag, '');
  return text.replaceAllMapped(_entity, (match) {
    final name = match.group(1)!;
    if (name.startsWith('#')) {
      final code = name.startsWith('#x')
          ? int.tryParse(name.substring(2), radix: 16)
          : int.tryParse(name.substring(1));
      // Leave entities that name no character, such as `&#9999999;` or a
      // lone surrogate, as they are: String.fromCharCode throws on the first.
      final isCharacter =
          code != null && code <= 0x10FFFF && (code < 0xD800 || code > 0xDFFF);
      return isCharacter ? String.fromCharCode(code) : match.group(0)!;
    }
    return _namedEntities[name] ?? match.group(0)!;
  });
}

/// XHTML for the plain text [text]: one paragraph per line, escaped, in
/// [color] (a CSS colour) if given.
///
/// The Web SDK takes a rich free text annotation's colour from the XHTML's
/// `<span>` styles, so the colour goes on a span in each paragraph.
String xhtmlFromPlainText(String text, {String? color}) =>
    text.split('\n').map((line) {
      final escaped = _escapeXml(line);
      return color == null || line.isEmpty
          ? '<p>$escaped</p>'
          : '<p><span style="color:$color">$escaped</span></p>';
    }).join();

String _escapeXml(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

final _cssColor = RegExp(
    r'color:\s*(#[0-9a-fA-F]{3,8}|rgba?\([^)]*\)|[a-zA-Z]+)',
    caseSensitive: false);

/// The first CSS text colour in the XHTML [xhtml], or null if it sets none.
///
/// Matches `color:` only, not `background-color:`.
String? textColorInXhtml(String xhtml) {
  for (final match in _cssColor.allMatches(xhtml)) {
    final before = match.start > 0 ? xhtml[match.start - 1] : '';
    if (before == '-') continue;
    return match.group(1);
  }
  return null;
}
