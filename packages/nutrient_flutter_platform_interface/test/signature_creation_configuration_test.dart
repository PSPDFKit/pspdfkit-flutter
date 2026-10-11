///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

// The toMap() wire format is the contract every platform configuration
// builder parses — these tests pin the keys and value shapes so a change
// here fails loudly instead of silently dropping options on one platform.
void main() {
  group('SignatureColorPreset.toMap', () {
    test('serializes opaque color as #RRGGBB and strips null fields', () {
      final map = SignatureColorPreset(
        color: const Color(0xFFFF0000),
      ).toMap();
      expect(map, {'color': '#ff0000'});
    });

    test('serializes non-opaque color as #AARRGGBB', () {
      final map = SignatureColorPreset(
        color: const Color(0x80FF0000),
      ).toMap();
      expect(map['color'], '#80ff0000');
    });

    test('includes localization fields when set', () {
      final map = SignatureColorPreset(
        color: const Color(0xFF0000FF),
        id: 'blue',
        defaultMessage: 'Blue',
        description: 'Blue ink',
      ).toMap();
      expect(map, {
        'color': '#0000ff',
        'id': 'blue',
        'defaultMessage': 'Blue',
        'description': 'Blue ink',
      });
    });
  });

  group('SignatureColorOptions.toMap', () {
    test('serializes the three presets under option1/2/3', () {
      final map = SignatureColorOptions(
        option1: SignatureColorPreset(color: const Color(0xFF000000)),
        option2: SignatureColorPreset(color: const Color(0xFF111111)),
        option3: SignatureColorPreset(color: const Color(0xFF222222)),
      ).toMap();
      expect(map.keys, ['option1', 'option2', 'option3']);
      expect(map['option1'], {'color': '#000000'});
    });
  });

  group('SignatureCreationConfiguration.toMap', () {
    test('serializes all fields with legacy-compatible keys', () {
      final map = SignatureCreationConfiguration(
        creationModes: [
          SignatureCreationMode.draw,
          SignatureCreationMode.type,
        ],
        colorOptions: SignatureColorOptions(
          option1: SignatureColorPreset(color: const Color(0xFF000000)),
          option2: SignatureColorPreset(color: const Color(0xFF111111)),
          option3: SignatureColorPreset(color: const Color(0xFF222222)),
        ),
        iosSignatureAspectRatio: const AspectRatio(aspectRatio: 1.5),
        androidSignatureOrientation:
            NutrientAndroidSignatureOrientation.landscape,
        fonts: ['Cookie'],
      ).toMap();

      expect(map['creationModes'], ['draw', 'type']);
      expect(map['colorOptions'], isA<Map<String, dynamic>>());
      expect(map['iosSignatureAspectRatio'], 1.5);
      expect(map['androidSignatureOrientation'], 'landscape');
      expect(map['fonts'], ['Cookie']);
    });

    test('strips unset fields', () {
      expect(SignatureCreationConfiguration().toMap(), isEmpty);
    });
  });

  test('NutrientViewConfiguration carries the signature fields', () {
    final config = NutrientViewConfiguration(
      signatureSavingStrategy: SignatureSavingStrategy.alwaysSave,
      signatureCreationConfiguration: SignatureCreationConfiguration(
        creationModes: [SignatureCreationMode.image],
      ),
    );
    expect(config.signatureSavingStrategy, SignatureSavingStrategy.alwaysSave);
    expect(config.signatureCreationConfiguration?.creationModes,
        [SignatureCreationMode.image]);
  });
}
