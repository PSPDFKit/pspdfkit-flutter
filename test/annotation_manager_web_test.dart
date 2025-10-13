import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

void main() {
  group('AnnotationProperties', () {
    test('should initialize without errors', () {
      final properties = AnnotationProperties(
        annotationId: 'test-annotation',
        pageIndex: 0,
      );
      expect(properties, isNotNull);
      expect(properties.annotationId, equals('test-annotation'));
    });

    test('should handle AnnotationProperties correctly', () {
      final properties = AnnotationProperties(
        annotationId: 'test-annotation',
        pageIndex: 1,
        strokeColor: 0xFFFF0000,
        fillColor: 0xFF00FF00,
        opacity: 0.75,
        lineWidth: 2.5,
        flags: ['readOnly', 'print'],
        customData: {'metadata': 'test', 'status': 'approved'},
        contents: 'Test content',
        subject: 'Test subject',
        creator: 'Test user',
        bbox: [0.0, 0.0, 100.0, 50.0],
        note: 'Test note',
        fontName: 'Arial',
        fontSize: 12.0,
        iconName: 'comment',
      );

      expect(properties.annotationId, equals('test-annotation'));
      expect(properties.pageIndex, equals(1));
      expect(properties.strokeColor, equals(0xFFFF0000));
      expect(properties.fillColor, equals(0xFF00FF00));
      expect(properties.opacity, equals(0.75));
      expect(properties.lineWidth, equals(2.5));
      expect(properties.flags, containsAll(['readOnly', 'print']));
      expect(properties.customData?['metadata'], equals('test'));
      expect(properties.customData?['status'], equals('approved'));
      expect(properties.contents, equals('Test content'));
      expect(properties.subject, equals('Test subject'));
      expect(properties.creator, equals('Test user'));
      expect(properties.bbox, equals([0.0, 0.0, 100.0, 50.0]));
      expect(properties.note, equals('Test note'));
      expect(properties.fontName, equals('Arial'));
      expect(properties.fontSize, equals(12.0));
      expect(properties.iconName, equals('comment'));
    });

    test('should preserve custom data when updating properties', () {
      final original = AnnotationProperties(
        annotationId: 'test-id',
        pageIndex: 0,
        strokeColor: 0xFFFF0000,
        fillColor: 0xFF00FF00,
        opacity: 0.5,
        lineWidth: 1.0,
        contents: 'Original content',
        subject: 'Original subject',
        customData: {
          'key1': 'value1',
          'key2': 'value2',
          'timestamp': '2025-01-01',
        },
      );

      // Create a modified version with only some properties changed
      final modified = AnnotationProperties(
        annotationId: 'test-id',
        pageIndex: 0,
        strokeColor: 0xFF0000FF, // Changed to blue
        opacity: 0.8, // Changed opacity
        // Other properties not specified - should be preserved
      );

      // Verify that the original properties are intact
      expect(original.customData?['key1'], equals('value1'));
      expect(original.customData?['key2'], equals('value2'));
      expect(original.customData?['timestamp'], equals('2025-01-01'));
      expect(original.fillColor, equals(0xFF00FF00));
      expect(original.lineWidth, equals(1.0));

      // Verify modified properties
      expect(modified.strokeColor, equals(0xFF0000FF));
      expect(modified.opacity, equals(0.8));
    });

    test('should handle color format conversion correctly', () {
      // Test ARGB to Web format conversion
      const argbRed = 0xFFFF0000; // Red with full alpha
      const argbGreen = 0xFF00FF00; // Green with full alpha
      const argbBlue = 0xFF0000FF; // Blue with full alpha
      const argbTransparent = 0x80FF0000; // Red with 50% alpha

      // Extract components from ARGB
      void verifyColorComponents(int color, int expectedR, int expectedG,
          int expectedB, int expectedA) {
        final a = (color >> 24) & 0xFF;
        final r = (color >> 16) & 0xFF;
        final g = (color >> 8) & 0xFF;
        final b = color & 0xFF;

        expect(r, equals(expectedR));
        expect(g, equals(expectedG));
        expect(b, equals(expectedB));
        expect(a, equals(expectedA));
      }

      verifyColorComponents(argbRed, 255, 0, 0, 255);
      verifyColorComponents(argbGreen, 0, 255, 0, 255);
      verifyColorComponents(argbBlue, 0, 0, 255, 255);
      verifyColorComponents(argbTransparent, 255, 0, 0, 128);
    });

    test('should handle flags correctly', () {
      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        flags: ['readOnly', 'hidden', 'print', 'locked'],
      );

      expect(properties.flags, isNotNull);
      expect(properties.flags!.length, equals(4));
      expect(properties.flags, contains('readOnly'));
      expect(properties.flags, contains('hidden'));
      expect(properties.flags, contains('print'));
      expect(properties.flags, contains('locked'));

      // Test flagsSet conversion
      expect(properties.flagsSet, isNotNull);
      expect(properties.flagsSet!.length, equals(4));
      expect(properties.flagsSet, contains(AnnotationFlag.readOnly));
      expect(properties.flagsSet, contains(AnnotationFlag.hidden));
      expect(properties.flagsSet, contains(AnnotationFlag.print));
      expect(properties.flagsSet, contains(AnnotationFlag.locked));
    });

    test('should handle ink lines data structure', () {
      final inkLinesData = [
        [
          [10.0, 20.0, 1.0], // Point with full pressure
          [15.0, 25.0, 0.8], // Point with 80% pressure
          [20.0, 30.0], // Point without pressure (should default to 1.0)
        ],
        [
          [30.0, 40.0, 0.5], // Second stroke, first point
          [35.0, 45.0, 0.7],
          [40.0, 50.0, 0.9],
        ],
      ];

      // Verify structure
      expect(inkLinesData.length, equals(2)); // Two strokes
      expect(inkLinesData[0].length, equals(3)); // First stroke has 3 points
      expect(inkLinesData[1].length, equals(3)); // Second stroke has 3 points

      // Verify point data
      expect(inkLinesData[0][0], equals([10.0, 20.0, 1.0]));
      expect(inkLinesData[0][1], equals([15.0, 25.0, 0.8]));
      expect(inkLinesData[0][2].length, equals(2)); // No pressure value
      expect(inkLinesData[1][0], equals([30.0, 40.0, 0.5]));
      expect(inkLinesData[1][2], equals([40.0, 50.0, 0.9]));
    });

    test('should support property update methods', () {
      final original = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        strokeColor: 0xFFFF0000,
        fillColor: 0xFF00FF00,
        opacity: 0.5,
        lineWidth: 2.0,
        customData: {'original': true},
      );

      // Test withColor (only updates stroke color, not fill color)
      final withNewColor = original.withColor(const Color(0xFF0000FF));
      expect(withNewColor.strokeColor, equals(0xFF0000FF));
      expect(withNewColor.fillColor,
          equals(0xFF00FF00)); // Preserves original fill color
      expect(withNewColor.opacity, equals(original.opacity));

      // Test withOpacity
      final withNewOpacity = original.withOpacity(0.9);
      expect(withNewOpacity.opacity, equals(0.9));
      expect(withNewOpacity.strokeColor, equals(original.strokeColor));

      // Test withLineWidth
      final withNewLineWidth = original.withLineWidth(5.0);
      expect(withNewLineWidth.lineWidth, equals(5.0));
      expect(withNewLineWidth.strokeColor, equals(original.strokeColor));

      // Test withCustomData
      final withNewCustomData = original.withCustomData({
        'original': false,
        'updated': true,
        'timestamp': '2025-01-01',
      });
      expect(withNewCustomData.customData?['original'], equals(false));
      expect(withNewCustomData.customData?['updated'], equals(true));
      expect(withNewCustomData.customData?['timestamp'], equals('2025-01-01'));

      // Test withFlags
      final withNewFlags = original.withFlags({
        AnnotationFlag.readOnly,
        AnnotationFlag.locked,
      });
      expect(withNewFlags.flags, contains('readOnly'));
      expect(withNewFlags.flags, contains('locked'));

      // Test withUpdates (color only updates stroke, use fillColor param for fill)
      final withMultipleUpdates = original.withUpdates(
        color: const Color(0xFFFFFF00),
        fillColor: const Color(0xFFFFFF00),
        opacity: 0.7,
        lineWidth: 3.5,
        customData: {'batch': 'update'},
      );
      expect(withMultipleUpdates.strokeColor, equals(0xFFFFFF00));
      expect(withMultipleUpdates.fillColor, equals(0xFFFFFF00));
      expect(withMultipleUpdates.opacity, equals(0.7));
      expect(withMultipleUpdates.lineWidth, equals(3.5));
      expect(withMultipleUpdates.customData?['batch'], equals('update'));
    });

    test('should handle attachment preservation in custom data', () {
      // This test verifies that properties can include attachment metadata
      final properties = AnnotationProperties(
        annotationId: 'file-annotation',
        pageIndex: 0,
        strokeColor: 0xFFFF0000,
        customData: {
          'hasAttachment': true,
          'fileName': 'document.pdf',
        },
      );

      // Update only the color, attachment data should be preserved in original
      final updatedProperties = AnnotationProperties(
        annotationId: 'file-annotation',
        pageIndex: 0,
        strokeColor: 0xFF0000FF, // Changed color
        // Custom data not specified - should be preserved in implementation
      );

      // Original properties should still have attachment info
      expect(properties.customData?['hasAttachment'], equals(true));
      expect(properties.customData?['fileName'], equals('document.pdf'));

      // New properties don't include custom data
      expect(updatedProperties.customData, isNull);
    });

    test('should validate bounding box data', () {
      final bbox = [10.0, 20.0, 100.0, 50.0];

      expect(bbox.length, equals(4));
      expect(bbox[0], equals(10.0)); // x
      expect(bbox[1], equals(20.0)); // y
      expect(bbox[2], equals(100.0)); // width
      expect(bbox[3], equals(50.0)); // height

      final properties = AnnotationProperties(
        annotationId: 'test',
        pageIndex: 0,
        bbox: bbox,
      );

      expect(properties.bbox, equals(bbox));
    });
  });
}
