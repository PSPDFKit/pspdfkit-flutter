///  Copyright © 2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

void main() {
  group('Annotation Flags', () {
    test('AnnotationProperties should handle flags correctly', () {
      // Create annotation properties with flags
      final properties = AnnotationProperties(
        annotationId: 'test-id',
        pageIndex: 0,
        flags: ['readOnly', 'locked', 'print'],
      );

      expect(properties.flags, isNotNull);
      expect(properties.flags, contains('readOnly'));
      expect(properties.flags, contains('locked'));
      expect(properties.flags, contains('print'));
    });

    test('AnnotationPropertiesGetters should convert flags to Set', () {
      final properties = AnnotationProperties(
        annotationId: 'test-id',
        pageIndex: 0,
        flags: ['readOnly', 'locked', 'print'],
      );

      final flagsSet = properties.flagsSet;
      expect(flagsSet, isNotNull);
      expect(flagsSet, contains(AnnotationFlag.readOnly));
      expect(flagsSet, contains(AnnotationFlag.locked));
      expect(flagsSet, contains(AnnotationFlag.print));
    });

    test('AnnotationPropertiesModification should update flags', () {
      final properties = AnnotationProperties(
        annotationId: 'test-id',
        pageIndex: 0,
        flags: ['readOnly'],
      );

      // Update flags
      final newFlags = {AnnotationFlag.locked, AnnotationFlag.hidden};
      final updated = properties.withFlags(newFlags);

      expect(updated.flags, isNotNull);
      expect(updated.flags, contains('locked'));
      expect(updated.flags, contains('hidden'));
      expect(updated.flags, isNot(contains('readOnly')));
    });

    test('All AnnotationFlag values should have valid names', () {
      // Verify each flag has a valid name that can be converted back
      for (final flag in AnnotationFlag.values) {
        expect(flag.name, isNotEmpty);

        // Verify roundtrip conversion
        final flagFromName = AnnotationFlag.values.byName(flag.name);
        expect(flagFromName, equals(flag));
      }
    });

    test('Flag names should match Android SDK conventions', () {
      // Verify flag names match expected format for Android SDK
      final expectedNames = {
        AnnotationFlag.invisible: 'invisible',
        AnnotationFlag.hidden: 'hidden',
        AnnotationFlag.print: 'print',
        AnnotationFlag.noZoom: 'noZoom',
        AnnotationFlag.noRotate: 'noRotate',
        AnnotationFlag.noView: 'noView',
        AnnotationFlag.readOnly: 'readOnly',
        AnnotationFlag.locked: 'locked',
        AnnotationFlag.toggleNoView: 'toggleNoView',
        AnnotationFlag.lockedContents: 'lockedContents',
      };

      expectedNames.forEach((flag, expectedName) {
        expect(flag.name, equals(expectedName));
      });
    });
  });
}
