import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

void main() {
  group('AnnotationManager Feature Test', () {
    test('AnnotationProperties basic creation works', () {
      final properties = AnnotationProperties(
        annotationId: 'test-annotation-1',
        pageIndex: 0,
        strokeColor: 0xFFFF0000, // Red
        fillColor: 0xFF00FF00, // Green
        opacity: 0.75,
        lineWidth: 2.5,
        flagsJson: jsonEncode(['readOnly', 'print']),
        customDataJson: jsonEncode({
          'key': 'value',
          'nested': {'data': true}
        }),
      );

      expect(properties.annotationId, 'test-annotation-1');
      expect(properties.pageIndex, 0);
      expect(properties.strokeColor, 0xFFFF0000);
      expect(properties.fillColor, 0xFF00FF00);
      expect(properties.opacity, 0.75);
      expect(properties.lineWidth, 2.5);
      expect(properties.flags, containsAll(['readOnly', 'print']));
      expect(properties.customData?['key'], 'value');
    });

    test('Extension methods with Color work correctly', () {
      final properties = AnnotationProperties(
        annotationId: 'test-2',
        pageIndex: 1,
      );

      // Test withColor using Flutter Color
      final withColor = properties.withColor(Colors.blue);
      expect(withColor.strokeColor, Colors.blue.toARGB32());
      expect(withColor.fillColor,
          isNull); // fillColor not set by withColor when original was null

      // Test withFillColor
      final withFill = properties.withFillColor(Colors.green);
      expect(withFill.fillColor, Colors.green.toARGB32());
      expect(withFill.strokeColor, isNull); // Unchanged

      // Test chaining
      final chained =
          properties.withColor(Colors.red).withOpacity(0.5).withLineWidth(3.0);

      expect(chained.strokeColor, Colors.red.toARGB32());
      expect(chained.opacity, 0.5);
      expect(chained.lineWidth, 3.0);
    });

    test('Flag management works correctly', () {
      final properties = AnnotationProperties(
        annotationId: 'test-3',
        pageIndex: 0,
        flagsJson: jsonEncode(['readOnly']),
      );

      // Test withFlags - replaces all flags
      final withNewFlags = properties.withFlags({
        AnnotationFlag.print,
        AnnotationFlag.noZoom,
      });
      expect(withNewFlags.flags, containsAll(['print', 'noZoom']));
      expect(withNewFlags.flags, isNot(contains('readOnly')));

      // Verify original flags are preserved
      expect(properties.flags, contains('readOnly'));
    });

    test('Custom data preservation - THE CRITICAL BUG FIX', () {
      // This test verifies that custom data and attachments are preserved
      // when updating other properties - this was the critical bug

      final original = AnnotationProperties(
        annotationId: 'stamp-with-attachment',
        pageIndex: 2,
        customDataJson: jsonEncode({
          'attachment': 'base64-image-data-here',
          'metadata': {
            'author': 'John Doe',
            'timestamp': '2025-01-26T10:00:00Z',
            'version': 1,
          }
        }),
        strokeColor: 0xFF000000,
      );

      // Update only the color - custom data should be preserved
      final updated = original.withColor(Colors.red);

      // Verify custom data is completely preserved
      expect(updated.customData, isNotNull);
      expect(updated.customData?['attachment'], 'base64-image-data-here');
      expect(updated.customData?['metadata'], isNotNull);

      final metadata = updated.customData?['metadata'] as Map?;
      expect(metadata?['author'], 'John Doe');
      expect(metadata?['timestamp'], '2025-01-26T10:00:00Z');
      expect(metadata?['version'], 1);

      // Verify only color changed
      expect(updated.strokeColor, Colors.red.toARGB32());
      expect(updated.annotationId, 'stamp-with-attachment');
      expect(updated.pageIndex, 2);
    });

    test('Complex property updates maintain immutability', () {
      final original = AnnotationProperties(
        annotationId: 'test-4',
        pageIndex: 0,
        contents: 'Original content',
        subject: 'Original subject',
        creator: 'Original creator',
      );

      final updated1 = original.withContents('Updated content');
      final updated2 = original.withSubject('Updated subject');
      final updated3 = original.withCreator('Updated creator');

      // Verify original is unchanged
      expect(original.contents, 'Original content');
      expect(original.subject, 'Original subject');
      expect(original.creator, 'Original creator');

      // Verify each update only changed what was intended
      expect(updated1.contents, 'Updated content');
      expect(updated1.subject, 'Original subject');
      expect(updated1.creator, 'Original creator');

      expect(updated2.contents, 'Original content');
      expect(updated2.subject, 'Updated subject');
      expect(updated2.creator, 'Original creator');

      expect(updated3.contents, 'Original content');
      expect(updated3.subject, 'Original subject');
      expect(updated3.creator, 'Updated creator');
    });

    test('Null handling in properties', () {
      final properties = AnnotationProperties(
        annotationId: 'test-5',
        pageIndex: 0,
        // All optional properties are null
      );

      expect(properties.strokeColor, isNull);
      expect(properties.fillColor, isNull);
      expect(properties.opacity, isNull);
      expect(properties.lineWidth, isNull);
      expect(properties.flags, isNull);
      expect(properties.customData, isNull);
      expect(properties.contents, isNull);

      // Adding values to null properties
      final updated = properties
          .withOpacity(0.8)
          .withLineWidth(1.5)
          .withContents('New content');

      expect(updated.opacity, 0.8);
      expect(updated.lineWidth, 1.5);
      expect(updated.contents, 'New content');
    });

    test('Edge cases in opacity values', () {
      final properties = AnnotationProperties(
        annotationId: 'test-6',
        pageIndex: 0,
      );

      final minOpacity = properties.withOpacity(0.0);
      expect(minOpacity.opacity, 0.0);

      final maxOpacity = properties.withOpacity(1.0);
      expect(maxOpacity.opacity, 1.0);

      final midOpacity = properties.withOpacity(0.5);
      expect(midOpacity.opacity, 0.5);
    });

    test('AnnotationFlag enum values are correct', () {
      // Verify all flag values exist and have correct names
      expect(AnnotationFlag.hidden.name, 'hidden');
      expect(AnnotationFlag.invisible.name, 'invisible');
      expect(AnnotationFlag.locked.name, 'locked');
      expect(AnnotationFlag.lockedContents.name, 'lockedContents');
      expect(AnnotationFlag.print.name, 'print');
      expect(AnnotationFlag.readOnly.name, 'readOnly');
      expect(AnnotationFlag.noView.name, 'noView');
      expect(AnnotationFlag.noZoom.name, 'noZoom');
      expect(AnnotationFlag.noRotate.name, 'noRotate');
    });

    test('Note property updates', () {
      final properties = AnnotationProperties(
        annotationId: 'test-7',
        pageIndex: 0,
        note: 'Original note',
      );

      final updated = properties.withNote('Updated note');
      expect(updated.note, 'Updated note');
      expect(properties.note, 'Original note'); // Original unchanged
    });

    test('Font size property updates', () {
      final properties = AnnotationProperties(
        annotationId: 'test-8',
        pageIndex: 0,
        fontSize: 12.0,
      );

      // Font size is preserved through updates
      final updated = properties.withOpacity(0.5);
      expect(updated.fontSize, 12.0);
      expect(properties.fontSize, 12.0); // Original unchanged
    });
  });

  group('Color conversion helper', () {
    test('toARGB32 extension works correctly', () {
      const red = Colors.red;
      const transparentBlue = Color(0x800000FF); // 50% transparent blue

      // Colors.red might have different values in different Flutter versions
      // Just verify it's an opaque red color
      final redValue = red.toARGB32();
      expect((redValue >> 24) & 0xFF, 0xFF); // Alpha channel is fully opaque
      expect((redValue >> 16) & 0xFF, greaterThan(200)); // Red channel is high

      expect(transparentBlue.toARGB32(), 0x800000FF);
    });
  });
}
