///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_web/src/utils/annotation_color_web_mapping.dart';

void main() {
  // The colour fields each Web SDK annotation record declares.
  String fieldFor(Set<String> fields, [String? type]) =>
      strokeColorWebField(type, fields.contains);

  group('strokeColorWebField', () {
    test('uses color for annotations without a strokeColor field', () {
      // Notes, text markup (highlight, underline, strikeout, squiggly) and
      // stamps.
      expect(fieldFor({'color'}), 'color');
      // Redactions, whose color is the overlay text colour.
      expect(fieldFor({'color', 'fillColor', 'outlineColor'}), 'color');
    });

    test('uses strokeColor for annotations that have one', () {
      // Shapes: rectangle, ellipse, line, polygon, polyline.
      expect(fieldFor({'strokeColor', 'fillColor'}), 'strokeColor');
      // Ink.
      expect(fieldFor({'strokeColor', 'backgroundColor'}), 'strokeColor');
      // Both fields, which no annotation has today.
      expect(fieldFor({'strokeColor', 'color'}), 'strokeColor');
    });

    test('uses fontColor for free text', () {
      expect(
          fieldFor(
              {'fontColor', 'backgroundColor', 'borderColor'}, 'pspdfkit/text'),
          'fontColor');
    });

    test('keeps strokeColor for other annotations with neither field', () {
      // Widgets.
      expect(fieldFor({'borderColor', 'backgroundColor', 'fontColor'}),
          'strokeColor');
    });
  });

  group('reportStrokeColorFrom', () {
    test('copies the field into strokeColor', () {
      final json = <String, dynamic>{'color': '#ff0000'};
      reportStrokeColorFrom(json, 'color');
      expect(json, {'color': '#ff0000', 'strokeColor': '#ff0000'});
    });

    test('leaves annotations that keep it in strokeColor unchanged', () {
      final json = <String, dynamic>{'strokeColor': '#00ff00'};
      reportStrokeColorFrom(json, 'strokeColor');
      expect(json, {'strokeColor': '#00ff00'});

      final widget = <String, dynamic>{'borderColor': '#0000ff'};
      reportStrokeColorFrom(widget, 'strokeColor');
      expect(widget, {'borderColor': '#0000ff'});
    });

    test('adds no strokeColor when the field is missing', () {
      final json = <String, dynamic>{'text': 'Note'};
      reportStrokeColorFrom(json, 'color');
      expect(json.containsKey('strokeColor'), isFalse);
    });
  });
}
