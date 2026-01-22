///
///  Copyright © 2023-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter/src/web/xhtml_color_utils.dart';

void main() {
  group('XhtmlColorUtils', () {
    group('colorMapToHex', () {
      test('converts basic RGB values to hex', () {
        expect(
          XhtmlColorUtils.colorMapToHex({'r': 255, 'g': 0, 'b': 0}),
          equals('#ff0000'),
        );
        expect(
          XhtmlColorUtils.colorMapToHex({'r': 0, 'g': 255, 'b': 0}),
          equals('#00ff00'),
        );
        expect(
          XhtmlColorUtils.colorMapToHex({'r': 0, 'g': 0, 'b': 255}),
          equals('#0000ff'),
        );
      });

      test('converts mixed RGB values to hex', () {
        expect(
          XhtmlColorUtils.colorMapToHex({'r': 67, 'g': 0, 'b': 131}),
          equals('#430083'),
        );
        expect(
          XhtmlColorUtils.colorMapToHex({'r': 128, 'g': 128, 'b': 128}),
          equals('#808080'),
        );
      });

      test('pads single digit hex values with zeros', () {
        expect(
          XhtmlColorUtils.colorMapToHex({'r': 1, 'g': 2, 'b': 3}),
          equals('#010203'),
        );
        expect(
          XhtmlColorUtils.colorMapToHex({'r': 0, 'g': 0, 'b': 0}),
          equals('#000000'),
        );
      });

      test('handles missing color components as zero', () {
        expect(
          XhtmlColorUtils.colorMapToHex({'r': 255}),
          equals('#ff0000'),
        );
        expect(
          XhtmlColorUtils.colorMapToHex({'g': 255}),
          equals('#00ff00'),
        );
        expect(
          XhtmlColorUtils.colorMapToHex({}),
          equals('#000000'),
        );
      });

      test('ignores alpha component', () {
        expect(
          XhtmlColorUtils.colorMapToHex(
              {'r': 255, 'g': 128, 'b': 64, 'a': 0.5}),
          equals('#ff8040'),
        );
      });
    });

    group('updateRichTextColor', () {
      const testColor = '#ff0000';

      group('simple p tag content', () {
        test('wraps plain text in p tag with colored span', () {
          final result =
              XhtmlColorUtils.updateRichTextColor('<p>Hello</p>', testColor);
          expect(result,
              equals('<p><span style="color:#ff0000">Hello</span></p>'));
        });

        test('handles p tag with attributes', () {
          final result = XhtmlColorUtils.updateRichTextColor(
              '<p class="test">Hello</p>', testColor);
          expect(
              result,
              equals(
                  '<p class="test"><span style="color:#ff0000">Hello</span></p>'));
        });

        test('handles multiple p tags', () {
          final result = XhtmlColorUtils.updateRichTextColor(
              '<p>Hello</p><p>World</p>', testColor);
          expect(
              result,
              equals(
                  '<p><span style="color:#ff0000">Hello</span></p><p><span style="color:#ff0000">World</span></p>'));
        });
      });

      group('existing span with color', () {
        test('updates existing span color style', () {
          final result = XhtmlColorUtils.updateRichTextColor(
              '<p><span style="color:#000000">Hello</span></p>', testColor);
          expect(result,
              equals('<p><span style="color:#ff0000">Hello</span></p>'));
        });

        test('updates hex color with semicolon terminator', () {
          final result = XhtmlColorUtils.updateRichTextColor(
              '<p><span style="color:#000000;">Hello</span></p>', testColor);
          expect(result,
              equals('<p><span style="color:#ff0000;">Hello</span></p>'));
        });

        test('updates color in span with multiple styles', () {
          final result = XhtmlColorUtils.updateRichTextColor(
              '<p><span style="font-size:12px;color:#000000;font-weight:bold">Hello</span></p>',
              testColor);
          expect(
              result,
              equals(
                  '<p><span style="font-size:12px;color:#ff0000;font-weight:bold">Hello</span></p>'));
        });

        test('handles rgb color format', () {
          final result = XhtmlColorUtils.updateRichTextColor(
              '<p><span style="color:rgb(0,0,0)">Hello</span></p>', testColor);
          expect(result,
              equals('<p><span style="color:#ff0000">Hello</span></p>'));
        });
      });

      group('span without color', () {
        test('adds color to span with existing style', () {
          final result = XhtmlColorUtils.updateRichTextColor(
              '<p><span style="font-size:14px">Hello</span></p>', testColor);
          expect(
              result,
              equals(
                  '<p><span style="color:#ff0000;font-size:14px">Hello</span></p>'));
        });

        test('adds color to span without style attribute', () {
          final result = XhtmlColorUtils.updateRichTextColor(
              '<p><span>Hello</span></p>', testColor);
          expect(result,
              equals('<p><span style="color:#ff0000">Hello</span></p>'));
        });

        test('adds color to span with other attributes', () {
          final result = XhtmlColorUtils.updateRichTextColor(
              '<p><span class="highlight">Hello</span></p>', testColor);
          expect(
              result,
              equals(
                  '<p><span style="color:#ff0000" class="highlight">Hello</span></p>'));
        });
      });

      group('complex XHTML with XML declaration', () {
        test('extracts content from body tag and applies color', () {
          const complexXhtml =
              '<?xml version="1.0"?><body xmlns="http://www.w3.org/1999/xhtml" style="color:#430083"><p>Hello</p></body>';
          final result =
              XhtmlColorUtils.updateRichTextColor(complexXhtml, testColor);
          expect(result,
              equals('<p><span style="color:#ff0000">Hello</span></p>'));
        });

        test('handles body with multiple attributes', () {
          const complexXhtml =
              '<?xml version="1.0" encoding="UTF-8"?><body xmlns="http://www.w3.org/1999/xhtml" style="font-family:Arial;color:#430083;font-size:12px"><p>Test</p></body>';
          final result =
              XhtmlColorUtils.updateRichTextColor(complexXhtml, testColor);
          expect(
              result, equals('<p><span style="color:#ff0000">Test</span></p>'));
        });

        test('removes XML declaration', () {
          const xhtmlWithDeclaration = '<?xml version="1.0"?><p>Hello</p>';
          final result = XhtmlColorUtils.updateRichTextColor(
              xhtmlWithDeclaration, testColor);
          expect(result,
              equals('<p><span style="color:#ff0000">Hello</span></p>'));
        });
      });

      group('plain text without tags', () {
        test('wraps plain text in p and span', () {
          final result =
              XhtmlColorUtils.updateRichTextColor('Hello World', testColor);
          expect(result,
              equals('<p><span style="color:#ff0000">Hello World</span></p>'));
        });

        test('handles text with HTML entities', () {
          final result = XhtmlColorUtils.updateRichTextColor(
              'Hello &amp; World', testColor);
          expect(
              result,
              equals(
                  '<p><span style="color:#ff0000">Hello &amp; World</span></p>'));
        });
      });

      group('edge cases', () {
        test('handles empty string', () {
          final result = XhtmlColorUtils.updateRichTextColor('', testColor);
          expect(result, equals('<p><span style="color:#ff0000"></span></p>'));
        });

        test('handles whitespace only', () {
          final result = XhtmlColorUtils.updateRichTextColor('   ', testColor);
          expect(
              result, equals('<p><span style="color:#ff0000">   </span></p>'));
        });

        test('handles nested spans', () {
          final result = XhtmlColorUtils.updateRichTextColor(
              '<p><span style="font-weight:bold"><span>Hello</span></span></p>',
              testColor);
          // Should add color to both spans
          expect(result, contains('color:#ff0000'));
        });

        test('handles multiline content', () {
          const multiline = '<p>Line 1</p>\n<p>Line 2</p>';
          final result =
              XhtmlColorUtils.updateRichTextColor(multiline, testColor);
          expect(result, contains('<span style="color:#ff0000">Line 1</span>'));
          expect(result, contains('<span style="color:#ff0000">Line 2</span>'));
        });
      });

      group('input validation and security', () {
        test('truncates oversized input', () {
          // Create input larger than maxInputLength (50000)
          final oversizedInput = '<p>${'x' * 60000}</p>';
          final result =
              XhtmlColorUtils.updateRichTextColor(oversizedInput, testColor);
          // Should return truncated fallback
          expect(result.length, lessThan(oversizedInput.length));
          expect(result, contains('...'));
          expect(result, contains('color:#ff0000'));
        });

        test('handles special characters in content', () {
          final result = XhtmlColorUtils.updateRichTextColor(
              '<p>Test < > " \' &</p>', testColor);
          expect(result, contains('color:#ff0000'));
        });

        test('preserves content with unicode characters', () {
          final result = XhtmlColorUtils.updateRichTextColor(
              '<p>Hello 世界 🌍</p>', testColor);
          expect(result, contains('Hello 世界 🌍'));
          expect(result, contains('color:#ff0000'));
        });
      });

      group('color format variations', () {
        test('applies 3-character hex color', () {
          final result =
              XhtmlColorUtils.updateRichTextColor('<p>Test</p>', '#f00');
          expect(result, contains('color:#f00'));
        });

        test('applies 6-character hex color', () {
          final result =
              XhtmlColorUtils.updateRichTextColor('<p>Test</p>', '#ff0000');
          expect(result, contains('color:#ff0000'));
        });

        test('applies named color', () {
          final result =
              XhtmlColorUtils.updateRichTextColor('<p>Test</p>', 'red');
          expect(result, contains('color:red'));
        });
      });
    });
  });
}
