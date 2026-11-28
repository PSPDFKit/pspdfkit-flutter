///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:nutrient_flutter_web/src/utils/signature_web_mapping.dart';

void main() {
  group('webCreationModeString', () {
    test('maps each SignatureCreationMode to its Web SDK string id', () {
      expect(webCreationModeString(SignatureCreationMode.draw), 'DRAW');
      expect(webCreationModeString(SignatureCreationMode.image), 'IMAGE');
      expect(webCreationModeString(SignatureCreationMode.type), 'TYPE');
    });

    test('covers every SignatureCreationMode value (no enum drift)', () {
      for (final mode in SignatureCreationMode.values) {
        expect(
          () => webCreationModeString(mode),
          returnsNormally,
          reason: '$mode needs to be added to the switch in '
              'webCreationModeString',
        );
      }
    });

    test('every returned mode is a SCREAMING_SNAKE_CASE identifier', () {
      final identifierPattern = RegExp(r'^[A-Z][A-Z0-9_]*$');
      for (final mode in SignatureCreationMode.values) {
        final value = webCreationModeString(mode);
        expect(
          identifierPattern.hasMatch(value),
          isTrue,
          reason: '$mode maps to "$value" which is not a valid '
              'ElectronicSignatureCreationMode identifier',
        );
      }
    });
  });

  group('colorToWebBytes', () {
    test('converts 0.0-1.0 channels to 0-255 bytes', () {
      expect(colorToWebBytes(const Color(0xFFFF0000)), (255, 0, 0));
      expect(colorToWebBytes(const Color(0xFF00FF00)), (0, 255, 0));
      expect(colorToWebBytes(const Color(0xFF0000FF)), (0, 0, 255));
      expect(colorToWebBytes(const Color(0xFF000000)), (0, 0, 0));
      expect(colorToWebBytes(const Color(0xFFFFFFFF)), (255, 255, 255));
    });

    test('drops alpha (Web SDK Color has no alpha channel)', () {
      // Same RGB with a different alpha should produce identical bytes.
      expect(
        colorToWebBytes(const Color(0x80336699)),
        colorToWebBytes(const Color(0xFF336699)),
      );
    });
  });

  group('buildColorPresetShape', () {
    test('uses the preset id when present', () {
      final preset = SignatureColorPreset(
        color: const Color(0xFFFF0000),
        id: 'red',
        defaultMessage: 'Red',
        description: 'Red color',
      );
      final shape = buildColorPresetShape(preset, 'option1');

      expect(shape.localizationId, 'red');
      expect(shape.defaultMessage, 'Red');
      expect(shape.description, 'Red color');
      expect(shape.r, 255);
      expect(shape.g, 0);
      expect(shape.b, 0);
    });

    test('falls back to the option slot id when preset.id is null', () {
      final preset = SignatureColorPreset(color: const Color(0xFF00FF00));
      final shape = buildColorPresetShape(preset, 'option2');

      expect(shape.localizationId, 'option2');
    });

    test('leaves defaultMessage/description null when not provided', () {
      final preset = SignatureColorPreset(color: const Color(0xFF0000FF));
      final shape = buildColorPresetShape(preset, 'option3');

      expect(shape.defaultMessage, isNull);
      expect(shape.description, isNull);
    });
  });

  group('buildColorPresetShapes', () {
    test('produces 3 shapes in option1/option2/option3 order', () {
      final options = SignatureColorOptions(
        option1: SignatureColorPreset(color: const Color(0xFFFF0000)),
        option2: SignatureColorPreset(
          color: const Color(0xFF00FF00),
          id: 'green',
        ),
        option3: SignatureColorPreset(color: const Color(0xFF0000FF)),
      );

      final shapes = buildColorPresetShapes(options);

      expect(shapes, hasLength(3));
      expect(shapes[0].localizationId, 'option1');
      expect(shapes[0].r, 255);
      expect(shapes[1].localizationId, 'green');
      expect(shapes[1].g, 255);
      expect(shapes[2].localizationId, 'option3');
      expect(shapes[2].b, 255);
    });
  });

  group('WebColorPresetShape equality', () {
    test('two shapes with the same fields are equal', () {
      final a = WebColorPresetShape(
        r: 1,
        g: 2,
        b: 3,
        localizationId: 'id',
        defaultMessage: 'msg',
        description: 'desc',
      );
      final b = WebColorPresetShape(
        r: 1,
        g: 2,
        b: 3,
        localizationId: 'id',
        defaultMessage: 'msg',
        description: 'desc',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('shapes differing in any field are not equal', () {
      final base = WebColorPresetShape(r: 1, g: 2, b: 3, localizationId: 'id');
      expect(
        base,
        isNot(equals(
          WebColorPresetShape(r: 9, g: 2, b: 3, localizationId: 'id'),
        )),
      );
      expect(
        base,
        isNot(equals(
          WebColorPresetShape(r: 1, g: 2, b: 3, localizationId: 'other'),
        )),
      );
    });
  });
}
