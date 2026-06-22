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
  });
}
