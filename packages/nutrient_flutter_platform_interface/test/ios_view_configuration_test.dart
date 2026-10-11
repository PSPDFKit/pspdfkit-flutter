///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

void main() {
  test('IOSViewConfiguration carries fileConflictResolution', () {
    const config = IOSViewConfiguration(
      fileConflictResolution: IOSFileConflictResolution.reload,
    );
    expect(config.fileConflictResolution, IOSFileConflictResolution.reload);
    expect(const IOSViewConfiguration().fileConflictResolution, isNull);
  });

  test('IOSFileConflictResolution enum names are the wire contract', () {
    // The iOS configuration builder serializes `.name` and the native side
    // string-matches these exact values (mirroring the legacy converter) —
    // renaming a value silently breaks conflict handling.
    expect(
      IOSFileConflictResolution.values.map((v) => v.name),
      ['defaultBehavior', 'close', 'save', 'reload'],
    );
  });
}
