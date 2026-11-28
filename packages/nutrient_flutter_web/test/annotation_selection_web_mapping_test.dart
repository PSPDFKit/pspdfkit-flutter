///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:nutrient_flutter_web/src/utils/annotation_selection_web_mapping.dart';

void main() {
  const note = '{"id":"note","type":"pspdfkit/note","pageIndex":1}';
  const ink = '{"id":"ink","type":"pspdfkit/ink","pageIndex":1}';
  const SelectedAnnotation noteSelected = (id: 'note', json: note);
  const SelectedAnnotation inkSelected = (id: 'ink', json: ink);
  // An annotation that couldn't be converted to JSON, such as a widget.
  const SelectedAnnotation widgetSelected = (id: 'widget', json: null);

  // The events as `selected [json]` / `deselected [json]`, in order.
  List<String> describe(List<NutrientEvent> events) => events
      .map((event) => switch (event) {
            AnnotationSelectedEvent(:final annotationsJson) =>
              'selected $annotationsJson',
            AnnotationDeselectedEvent(:final annotationsJson) =>
              'deselected $annotationsJson',
            _ => 'unexpected $event',
          })
      .toList();

  group('AnnotationSelectionTracker', () {
    test('reports a selection, a replacement and a deselection', () {
      final tracker = AnnotationSelectionTracker();

      expect(describe(tracker.update([noteSelected])), ['selected [$note]']);
      expect(describe(tracker.update([inkSelected])),
          ['deselected [$note]', 'selected [$ink]']);
      expect(describe(tracker.update([])), ['deselected [$ink]']);
      expect(tracker.update([]), isEmpty);
    });

    test('reports only the annotations that join a selection', () {
      final tracker = AnnotationSelectionTracker()..update([noteSelected]);

      expect(describe(tracker.update([noteSelected, inkSelected])),
          ['selected [$ink]']);
      expect(describe(tracker.update([inkSelected])), ['deselected [$note]']);
    });

    test('reports a deselected annotation as it is now', () {
      const movedNote = '{"id":"note","type":"pspdfkit/note","pageIndex":2}';
      final tracker = AnnotationSelectionTracker()..update([noteSelected]);

      tracker.refresh([(id: 'note', json: movedNote)]);

      expect(describe(tracker.update([])), ['deselected [$movedNote]']);
    });

    test("ignores updates to annotations that aren't selected", () {
      final tracker = AnnotationSelectionTracker()..update([noteSelected]);

      tracker.refresh([inkSelected]);

      expect(describe(tracker.clear()), ['deselected [$note]']);
    });

    test("keeps an annotation it can't convert selected, without reporting it",
        () {
      final tracker = AnnotationSelectionTracker()..update([noteSelected]);

      expect(tracker.update([noteSelected, widgetSelected]), isEmpty);
      expect(
          describe(tracker.update([widgetSelected])), ['deselected [$note]']);
      expect(tracker.hasSelection, isTrue);
      expect(tracker.update([]), isEmpty);
      expect(tracker.hasSelection, isFalse);
    });

    test("keeps the last JSON when a report can't convert an annotation", () {
      final tracker = AnnotationSelectionTracker()..update([noteSelected]);

      expect(tracker.update([(id: 'note', json: null)]), isEmpty);
      expect(describe(tracker.update([])), ['deselected [$note]']);
    });

    test('deselects what was selected when the document goes', () {
      final tracker = AnnotationSelectionTracker()
        ..update([noteSelected, inkSelected]);

      expect(describe(tracker.clear()), ['deselected [$note, $ink]']);
      expect(tracker.clear(), isEmpty);
    });
  });
}
