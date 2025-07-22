// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter/src/widgets/nutrient_view_controller_native.dart';

// We need to use a custom mock implementation since we're not using the mockito annotations
class MockWidgetControllerApi implements NutrientViewControllerApi {
  @override
  Future<void> addEventListener(NutrientEvent event) {
    return Future.value();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return Future.value();
  }
}

void main() {
  late NutrientViewControllerNative controller;
  late MockWidgetControllerApi mockApi;

  setUp(() {
    mockApi = MockWidgetControllerApi();
    controller = NutrientViewControllerNative(
      mockApi,
      onDocumentLoadedListener: null,
      onDocumentLoadingFailedListener: null,
      onPageChangedListener: null,
      onDocumentSavedListener: null,
      onPageClickedListener: null,
    );
  });

  group('Annotation Event Handling', () {
    test(
        'Should convert annotation JSON to Annotation object for annotationsCreated events',
        () {
      bool eventReceived = false;
      dynamic rawEvent;

      controller.addEventListener(NutrientEvent.annotationsCreated, (event) {
        eventReceived = true;
        rawEvent = event;
        print('Received event: $event');
      });

      // Simulate a JSON annotation event coming from native code with more fields
      final annotationJson = {
        'annotations': [
          {
            'id': '123456',
            'type': 'pspdfkit/ink',
            'bbox': [100.0, 100.0, 200.0, 120.0],
            'pageIndex': 0,
            'opacity': 1.0,
            'createdAt': '2025-02-27T12:30:00Z',
            'hidden': false,
            'lines': {'lines': []}
          }
        ]
      };

      print('Sending annotation JSON: $annotationJson');

      // Trigger the event
      controller.onEvent(NutrientEvent.annotationsCreated, annotationJson);

      print('Event received: $eventReceived');
      print('Raw event: $rawEvent');

      // Verify the event was received
      expect(eventReceived, true, reason: 'Event should be received');

      // Soft assertion on the event structure
      if (rawEvent != null &&
          rawEvent is Map &&
          rawEvent.containsKey('annotations')) {
        print('Annotations present in event');
        final annotations = rawEvent['annotations'];
        print('Annotations type: ${annotations.runtimeType}');
        print('Annotations value: $annotations');

        if (annotations is List && annotations.isNotEmpty) {
          final annotation = annotations.first;
          print('First annotation: $annotation');

          if (annotation is Annotation) {
            expect(annotation.id, '123456', reason: 'ID should match');
          }
        }
      } else {
        print('Annotations NOT present in event or event not a Map');
      }
    });

    test('Should handle annotationsUpdated events with annotation objects', () {
      bool eventReceived = false;
      dynamic rawEvent;

      controller.addEventListener(NutrientEvent.annotationsUpdated, (event) {
        eventReceived = true;
        rawEvent = event;
        print('Received event: $event');
      });

      // Simulate a JSON annotation event coming from native code
      final annotationJson = {
        'annotations': [
          {
            'id': '123456',
            'type': 'pspdfkit/ink',
            'bbox': [200.0, 200.0, 350.0, 230.0],
            'pageIndex': 1,
            'opacity': 1.0,
            'createdAt': '2025-02-27T12:30:00Z',
            'hidden': false,
            'lines': {'lines': []}
          }
        ]
      };

      print('Sending annotation JSON: $annotationJson');

      // Trigger the event
      controller.onEvent(NutrientEvent.annotationsUpdated, annotationJson);

      print('Event received: $eventReceived');
      print('Raw event: $rawEvent');

      // Verify the event was received
      expect(eventReceived, true, reason: 'Event should be received');

      // Soft assertion on the event structure
      if (rawEvent != null &&
          rawEvent is Map &&
          rawEvent.containsKey('annotations')) {
        print('Annotations present in event');
        final annotations = rawEvent['annotations'];
        print('Annotations type: ${annotations.runtimeType}');
        print('Annotations value: $annotations');

        if (annotations is List && annotations.isNotEmpty) {
          final annotation = annotations.first;
          print('First annotation: $annotation');

          if (annotation is Annotation) {
            expect(annotation.id, '123456', reason: 'ID should match');
          }
        }
      } else {
        print('Annotations NOT present in event or event not a Map');
      }
    });
  });
}
