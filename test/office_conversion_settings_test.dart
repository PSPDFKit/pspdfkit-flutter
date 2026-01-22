///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

void main() {
  group('OfficeConversionSettings', () {
    test('should serialize to Map correctly', () {
      const settings = OfficeConversionSettings(
        spreadsheetMaximumContentHeightPerSheet: 500,
        spreadsheetMaximumContentWidthPerSheet: 300,
      );

      final map = settings.toMap();

      expect(map['spreadsheetMaximumContentHeightPerSheet'], equals(500));
      expect(map['spreadsheetMaximumContentWidthPerSheet'], equals(300));
    });

    test('should omit null values from Map', () {
      const settings = OfficeConversionSettings(
        spreadsheetMaximumContentHeightPerSheet: 500,
        // spreadsheetMaximumContentWidthPerSheet is null
      );

      final map = settings.toMap();

      expect(map['spreadsheetMaximumContentHeightPerSheet'], equals(500));
      expect(
          map.containsKey('spreadsheetMaximumContentWidthPerSheet'), isFalse);
    });

    test('should handle all null values', () {
      const settings = OfficeConversionSettings();

      final map = settings.toMap();

      expect(map.isEmpty, isTrue);
    });
  });

  group('PdfWebConfiguration with OfficeConversionSettings', () {
    test('should include office conversion settings in configuration map', () {
      final webConfig = PdfWebConfiguration(
        officeConversionSettings: const OfficeConversionSettings(
          spreadsheetMaximumContentHeightPerSheet: 800,
          spreadsheetMaximumContentWidthPerSheet: 600,
        ),
        allowPrinting: true,
        showAnnotations: true,
      );

      final map = webConfig.toMap();

      expect(map['spreadsheetMaximumContentHeightPerSheet'], equals(800));
      expect(map['spreadsheetMaximumContentWidthPerSheet'], equals(600));
      expect(map['allowPrinting'], equals(true));
      expect(map['showAnnotations'], equals(true));
    });

    test('should flatten office conversion settings in map', () {
      final webConfig = PdfWebConfiguration(
        officeConversionSettings: const OfficeConversionSettings(
          spreadsheetMaximumContentHeightPerSheet: 1000,
        ),
      );

      final map = webConfig.toMap();

      // Settings should be flattened, not nested
      expect(map['spreadsheetMaximumContentHeightPerSheet'], equals(1000));
      expect(map.containsKey('officeConversionSettings'), isFalse);
    });
  });
}
