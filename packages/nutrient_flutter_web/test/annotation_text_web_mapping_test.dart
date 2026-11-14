///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_web/src/utils/annotation_text_web_mapping.dart';

void main() {
  group('contentsFromWebText', () {
    test('reads plain text as is', () {
      expect(
          contentsFromWebText({'format': 'plain', 'value': 'Line 1\nLine 2'}),
          'Line 1\nLine 2');
    });

    test('reduces XHTML to its text', () {
      expect(
          contentsFromWebText({
            'format': 'xhtml',
            'value': '<p><span style="color: #ff0000">Tom &amp; Jerry</span>'
                '</p><p>&lt;b&gt;<b>bold</b><br/>next&#33;&#x21;</p>',
          }),
          'Tom & Jerry\n<b>bold\nnext!!');
    });

    test('takes the body of a full XHTML document', () {
      expect(
          contentsFromWebText({
            'format': 'xhtml',
            'value': '<?xml version="1.0"?><html><body><p>Hi</p></body></html>',
          }),
          'Hi');
    });

    test('leaves numeric entities that name no character as they are', () {
      expect(
          contentsFromWebText({
            'format': 'xhtml',
            'value': '<p>&#9999999; &#x110000; &#xFFFFFFFFFFFF; &#xD800;</p>',
          }),
          '&#9999999; &#x110000; &#xFFFFFFFFFFFF; &#xD800;');
    });

    test('is null without a {format, value} text', () {
      expect(contentsFromWebText(null), isNull);
      expect(contentsFromWebText('plain string'), isNull);
      expect(contentsFromWebText({'format': 'plain'}), isNull);
    });
  });

  group('reportContentsFrom', () {
    test('reports text as contents', () {
      final json = <String, dynamic>{
        'text': {'format': 'plain', 'value': 'Note'},
      };
      reportContentsFrom(json);
      expect(json['contents'], 'Note');
    });

    test('adds no contents to annotations without text', () {
      final json = <String, dynamic>{'note': 'A comment'};
      reportContentsFrom(json);
      expect(json.containsKey('contents'), isFalse);
    });
  });

  group('xhtmlFromPlainText', () {
    test('writes a paragraph per line and escapes markup', () {
      expect(xhtmlFromPlainText('a < b & c\n\nend'),
          '<p>a &lt; b &amp; c</p><p></p><p>end</p>');
    });

    test('colours non-empty lines', () {
      expect(
          xhtmlFromPlainText('a\n\nb', color: '#FF0000'),
          '<p><span style="color:#FF0000">a</span></p><p></p>'
          '<p><span style="color:#FF0000">b</span></p>');
    });

    test('round-trips through contentsFromWebText', () {
      const text = 'Tom & "Jerry"\n<tag>\n\nlast';
      expect(
          contentsFromWebText({
            'format': 'xhtml',
            'value': xhtmlFromPlainText(text, color: '#123456'),
          }),
          text);
    });
  });

  group('textColorInXhtml', () {
    test('finds the text colour, not the background colour', () {
      expect(
          textColorInXhtml('<p><span style="background-color: #000000; '
              'color: rgb(1, 2, 3)">x</span></p>'),
          'rgb(1, 2, 3)');
      expect(textColorInXhtml('<p>x</p>'), isNull);
    });
  });
}
