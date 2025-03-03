///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
///

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:pspdfkit_flutter/src/document/annotation_json_converter.dart';
import 'package:pspdfkit_flutter/src/events/nutrient_events_extension.dart';
import 'package:pspdfkit_flutter/src/web/pspdfkit_web_instance.dart';
import '../../pspdfkit.dart';
import '../web/pspdfkit_web.dart';

/// A controller for a PSPDFKit widget for Web.
class PspdfkitWidgetControllerWeb extends PspdfkitWidgetController
    with AnnotationJsonConverter {
  final PspdfkitWebInstance pspdfkitInstance;

  PspdfkitWidgetControllerWeb(this.pspdfkitInstance);

  @override
  Future<List<Annotation>> getAnnotations(int pageIndex, String type) async {
    final jsonAnnotations =
        await pspdfkitInstance.getAnnotations(pageIndex, type);

    // Convert the list of JSON annotations to Annotation objects
    final annotations = <Annotation>[];

    if (jsonAnnotations is List) {
      for (final jsonAnnotation in jsonAnnotations) {
        try {
          if (jsonAnnotation is Map<String, dynamic>) {
            final annotation = Annotation.fromJson(jsonAnnotation);
            annotations.add(annotation);
          }
        } catch (e) {
          // Skip annotations that can't be converted
          if (kDebugMode) {
            print('Failed to convert annotation: $e');
          }
        }
      }
    }

    return annotations;
  }

  @override
  Future<bool?> addAnnotation(Map<String, dynamic> jsonAnnotation) async {
    await pspdfkitInstance.addAnnotation(jsonAnnotation);
    return Future.value(true);
  }

  @override
  Future<bool?> applyInstantJson(String annotationsJson) async {
    await pspdfkitInstance.applyInstantJson(annotationsJson);
    return Future.value(true);
  }

  @override
  Future<String?> exportInstantJson() {
    return pspdfkitInstance.exportInstantJson();
  }

  @override
  Future<bool?> exportXfdf(String xfdfPath) async {
    await pspdfkitInstance.exportXfdf(xfdfPath);
    return Future.value(true);
  }

  @override
  Future<dynamic> getAllUnsavedAnnotations() {
    return pspdfkitInstance.getAllAnnotations();
  }

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) {
    return pspdfkitInstance.getFormFieldValue(fullyQualifiedName);
  }

  @override
  Future<bool?> importXfdf(String xfdfPath) async {
    await pspdfkitInstance.importXfdf(xfdfPath);
    return Future.value(true);
  }

  @override
  Future<bool?> processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  ) {
    throw UnimplementedError('This method is not supported on the web!');
  }

  @override
  Future<bool?> removeAnnotation(jsonAnnotation) async {
    await pspdfkitInstance.removeAnnotation(jsonAnnotation);
    return Future.value(true);
  }

  @override
  Future<bool?> save() async {
    await pspdfkitInstance.save();
    return Future.value(true);
  }

  @override
  Future<bool?> setAnnotationConfigurations(
      Map<AnnotationTool, AnnotationConfiguration> configurations) async {
    throw UnimplementedError('This method is not supported on the web!');
  }

  @override
  Future<bool?> setFormFieldValue(
      String value, String fullyQualifiedName) async {
    await pspdfkitInstance.setFormFieldValue(value, fullyQualifiedName);
    return Future.value(true);
  }

  void dispose() {
    PSPDFKitWeb.unload(pspdfkitInstance.jsObject);
  }

  @override
  Future<void> addEventListener(
      NutrientEvent event, Function(dynamic) callback) async {
    return pspdfkitInstance.addEventListener(event.webName,
        (dynamic eventData) {
      // Process and convert annotations for events that contain annotation data
      if (event == NutrientEvent.annotationsSelected ||
          event == NutrientEvent.annotationsCreated ||
          event == NutrientEvent.annotationsUpdated) {
        try {
          // Check if eventData contains an annotation
          if (eventData is Map<String, dynamic> &&
              eventData.containsKey('annotation')) {
            final annotationData = eventData['annotation'];

            // If annotationData is a Map, convert it to an Annotation object
            if (annotationData is Map<String, dynamic>) {
              try {
                // Create the annotation directly - the type has already been
                // properly set by annotationToJSON in the web instance
                final annotation = Annotation.fromJson(annotationData);

                // Create a new event object with the converted annotation
                final processedEvent = {
                  ...eventData,
                  'annotation': annotation,
                };

                // Call the callback with the processed event
                callback(processedEvent);
                return;
              } catch (e) {
                // If conversion fails, fall back to the original data
                callback(eventData);
                return;
              }
            }
          } else if (eventData is Map<String, dynamic> &&
              eventData.containsKey('annotations')) {
            try {
              final annotations = (eventData['annotations'] as List)
                  .map((e) => Annotation.fromJson(e as Map<String, dynamic>))
                  .toList();
              final processedEvent = {
                ...eventData,
                'annotations': annotations,
              };
              callback(processedEvent);
              return;
            } catch (e) {
              // In case of any error, pass the original event data
              callback(eventData);
              return;
            }
          }

          // If we can't process the event data, pass it through unchanged
          callback(eventData);
        } catch (e) {
          // In case of any error, pass the original event data
          callback(eventData);
        }
      } else {
        // For other events, pass through unchanged
        callback(eventData);
      }
    });
  }

  @override
  Future<void> removeEventListener(NutrientEvent event) {
    throw UnimplementedError('This method is not supported on the web!');
  }

  @override
  Future<Rect> getVisibleRect(int pageIndex) {
    // This method is not supported on the web.
    throw UnimplementedError('This method is not supported yet on web!');
  }

  @override
  Future<void> zoomToRect(int pageIndex, Rect rect) {
    return pspdfkitInstance.zoomToRect(pageIndex, rect);
  }

  @override
  Future<double> getZoomScale(int pageIndex) {
    return pspdfkitInstance.getZoomScale(pageIndex);
  }
}
