///
///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import '../document/pdf_document_native.dart';

@Deprecated('Use NutrientViewController instead')
class PspdfkitFlutterWidgetControllerImpl
    implements
        PspdfkitWidgetController,
        NutrientViewCallbacks,
        NutrientEventsCallbacks,
        CustomToolbarCallbacks {
  final NutrientViewControllerApi _pspdfkitWidgetControllerApi;
  final PdfDocumentLoadedCallback? onPdfDocumentLoaded;
  final PdfDocumentLoadFailedCallback? onPdfDocumentLoadFailed;
  final PageChangedCallback? onPdfPageChanged;
  final PdfDocumentSavedCallback? onPdfDocumentSaved;
  final PageClickedCallback? onPageClicked;
  final Map<NutrientEvent, Function(dynamic eventData)> _eventListeners = {};
  final OnCustomToolbarItemTappedCallback? onCustomToolbarItemTappedListener;

  PspdfkitFlutterWidgetControllerImpl(
    this._pspdfkitWidgetControllerApi, {
    this.onPdfDocumentLoaded,
    this.onPdfDocumentLoadFailed,
    this.onPdfPageChanged,
    this.onPdfDocumentSaved,
    this.onPageClicked,
    this.onCustomToolbarItemTappedListener,
  });

  @override
  Future<bool?> addAnnotation(Map<String, dynamic> jsonAnnotation) {
    return _pspdfkitWidgetControllerApi
        .addAnnotation(jsonEncode(jsonAnnotation));
  }

  @override
  Future<void> addEventListener(
      NutrientEvent event, Function(dynamic eventData) callback) {
    _eventListeners[event] = callback;
    return _pspdfkitWidgetControllerApi.addEventListener(event);
  }

  @override
  Future<void> removeEventListener(NutrientEvent event) {
    _eventListeners.remove(event);
    return _pspdfkitWidgetControllerApi.removeEventListener(event);
  }

  @override
  Future<bool?> applyInstantJson(String annotationsJson) {
    return _pspdfkitWidgetControllerApi.applyInstantJson(annotationsJson);
  }

  @override
  Future<String?> exportInstantJson() {
    return _pspdfkitWidgetControllerApi.exportInstantJson();
  }

  @override
  Future<bool?> exportXfdf(String xfdfPath) {
    return _pspdfkitWidgetControllerApi.exportXfdf(xfdfPath);
  }

  @override
  Future getAllUnsavedAnnotations() {
    return _pspdfkitWidgetControllerApi.getAllUnsavedAnnotations();
  }

  @override
  Future getAnnotations(int pageIndex, String type) {
    return _pspdfkitWidgetControllerApi.getAnnotations(pageIndex, type);
  }

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) {
    return _pspdfkitWidgetControllerApi.getFormFieldValue(fullyQualifiedName);
  }

  @override
  Future<Rect> getVisibleRect(int pageIndex) async {
    PdfRect rect = await _pspdfkitWidgetControllerApi.getVisibleRect(pageIndex);
    return Rect.fromLTWH(rect.x, rect.y, rect.width, rect.height);
  }

  @override
  Future<double> getZoomScale(int pageIndex) {
    return _pspdfkitWidgetControllerApi.getZoomScale(pageIndex);
  }

  @override
  Future<bool?> importXfdf(String xfdfPath) {
    return _pspdfkitWidgetControllerApi.importXfdf(xfdfPath);
  }

  @override
  Future<bool?> processAnnotations(AnnotationType type,
      AnnotationProcessingMode processingMode, String destinationPath) {
    return _pspdfkitWidgetControllerApi.processAnnotations(
        type, processingMode, destinationPath);
  }

  @override
  Future<bool?> removeAnnotation(jsonAnnotation) {
    return _pspdfkitWidgetControllerApi.removeAnnotation(jsonAnnotation);
  }

  @override
  Future<bool?> save() {
    return _pspdfkitWidgetControllerApi.save();
  }

  @override
  Future<bool?> setAnnotationConfigurations(
      Map<AnnotationTool, AnnotationConfiguration> configurations) {
    var config = configurations.map((key, value) {
      return MapEntry(key.name, value.toMap());
    });
    return _pspdfkitWidgetControllerApi.setAnnotationConfigurations(config);
  }

  @override
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName) {
    return _pspdfkitWidgetControllerApi.setFormFieldValue(
        value, fullyQualifiedName);
  }

  @override
  Future<void> zoomToRect(int pageIndex, Rect rect) {
    return _pspdfkitWidgetControllerApi.zoomToRect(
        pageIndex,
        PdfRect(
            x: rect.left, y: rect.top, width: rect.width, height: rect.height),
        null,
        null);
  }

  @override
  Future<bool?> enterAnnotationCreationMode([AnnotationTool? annotationTool]) {
    return _pspdfkitWidgetControllerApi
        .enterAnnotationCreationMode(annotationTool);
  }

  @override
  Future<bool?> exitAnnotationCreationMode() {
    return _pspdfkitWidgetControllerApi.exitAnnotationCreationMode();
  }

  @override
  void onDocumentError(String documentId, String error) {
    onPdfDocumentLoadFailed?.call(error);
  }

  @override
  void onDocumentLoaded(String documentId) {
    var methodChannel = MethodChannel('com.pspdfkit.document.$documentId');
    var api = PdfDocumentApi(
        binaryMessenger: methodChannel.binaryMessenger,
        messageChannelSuffix: documentId);

    onPdfDocumentLoaded
        ?.call(PdfDocumentNative(documentId: documentId, api: api));
  }

  @override
  void onPageChanged(String documentId, int pageIndex) {
    onPdfPageChanged?.call(pageIndex);
  }

  @override
  void onPageClick(
      String documentId, int pageIndex, PointF? point, Object? annotation) {
    onPageClicked?.call(documentId, pageIndex, point, annotation);
  }

  @override
  void onEvent(NutrientEvent event, Object? data) {
    if (_eventListeners.containsKey(event)) {
      // Convert annotation data to Annotation objects for annotation-related events
      if (data is Map &&
          (event == NutrientEvent.annotationsCreated ||
              event == NutrientEvent.annotationsUpdated ||
              event == NutrientEvent.annotationsSelected ||
              event == NutrientEvent.annotationsDeselected)) {
        try {
          // Process annotations data
          if (data.containsKey('annotations')) {
            var annotations = <Annotation>[];
            var annotationsJson = data['annotations'];

            // Handle String JSON case
            if (annotationsJson is String) {
              try {
                annotationsJson = jsonDecode(annotationsJson);
              } catch (e) {
                if (kDebugMode) {
                  print('Error decoding annotations JSON string: $e');
                }
              }
            }

            if (annotationsJson is List) {
              // Convert each annotation JSON to an Annotation object
              for (var annotationJson in annotationsJson) {
                try {
                  // Handle String JSON case for individual annotations
                  if (annotationJson is String) {
                    try {
                      annotationJson = jsonDecode(annotationJson);
                    } catch (e) {
                      if (kDebugMode) {
                        print('Error decoding annotation JSON string: $e');
                      }
                      continue;
                    }
                  }

                  if (annotationJson is Map) {
                    final safeMap = <String, dynamic>{};

                    // Convert all keys to strings
                    annotationJson.forEach((key, value) {
                      safeMap[key.toString()] = value;
                    });

                    // Now create the Annotation
                    annotations.add(Annotation.fromJson(safeMap));
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print('Error converting annotation JSON to Annotation: $e');
                  }
                }
              }

              // Replace JSON data with Annotation objects
              if (annotations.length > 1) {
                data = {'annotations': annotations};
              } else if (annotations.length == 1) {
                data = {'annotation': annotations[0]};
              } else {
                data = {};
              }
            }
          } else if (data.containsKey('annotation')) {
            // Handle single annotation case
            var annotationJson = data['annotation'];

            // Handle String JSON case
            if (annotationJson is String) {
              try {
                annotationJson = jsonDecode(annotationJson);
              } catch (e) {
                if (kDebugMode) {
                  print('Error decoding annotation JSON string: $e');
                }
              }
            }

            if (annotationJson is Map) {
              try {
                final safeMap = <String, dynamic>{};

                // Convert all keys to strings
                annotationJson.forEach((key, value) {
                  safeMap[key.toString()] = value;
                });

                // Now create the Annotation
                var annotation = Annotation.fromJson(safeMap);
                data = {'annotation': annotation};
              } catch (e) {
                if (kDebugMode) {
                  print('Error converting annotation JSON to Annotation: $e');
                }
              }
            }
          } else {
            data = data;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error processing annotation event: $e');
          }
        }
      }
      _eventListeners[event]?.call(data);
    }
  }

  @override
  void onDocumentSaved(String documentId, String? path) {
    onPdfDocumentSaved?.call(documentId, path);
  }

  @override
  void onCustomToolbarItemTapped(String identifier) {
    onCustomToolbarItemTappedListener?.call(identifier);
  }

  @override
  void addWebEventListener(
      NutrientWebEvent event, Function(dynamic p1) callback) {
    // Web event listeners are not supported on native platforms.
    throw UnimplementedError('addWebEventListener is only supported on web.');
  }

  @override
  void removeWebEventListener(
      NutrientWebEvent event, Function(dynamic p1) callback) {
    // Web event listeners are not supported on native platforms.
    throw UnimplementedError(
        'removeWebEventListener is only supported on web.');
  }
}
