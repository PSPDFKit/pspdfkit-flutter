///  Copyright © 2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

void main() {
  group('PdfConfiguration.toMap()', () {
    // Regression test for the bug where PdfConfiguration.toMap() emitted only
    // 'pageLayoutMode' but the iOS converter reads the 'pageMode' key. Without
    // this serialization, setting pageLayoutMode on iOS was silently ignored.
    test('emits both pageMode and pageLayoutMode when pageLayoutMode is set',
        () {
      final config = PdfConfiguration(pageLayoutMode: PageLayoutMode.single);
      final map = config.toMap();
      expect(map['pageMode'], 'single',
          reason: 'iOS converter reads pageMode; must be emitted');
      expect(map['pageLayoutMode'], 'single',
          reason: 'Android accepts both; keep the legacy key too');
    });

    test('omits pageMode when pageLayoutMode is not set', () {
      final map = PdfConfiguration().toMap();
      expect(map.containsKey('pageMode'), isFalse);
      expect(map.containsKey('pageLayoutMode'), isFalse);
    });

    // androidShowStylusButton is not a PdfActivityConfiguration builder
    // property, so it reaches Android only as this map key. A serialization
    // regression would silently drop it and leave the button visible.
    test('emits androidShowStylusButton when set', () {
      final map = PdfConfiguration(androidShowStylusButton: false).toMap();
      expect(map['androidShowStylusButton'], isFalse);
    });

    test('omits androidShowStylusButton when not set', () {
      final map = PdfConfiguration().toMap();
      expect(map.containsKey('androidShowStylusButton'), isFalse);
    });
  });
}
