///
///  Copyright @2023-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js';
import 'dart:typed_data';
import 'package:flutter/painting.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter/src/document/document_save_options_extension.dart';
import 'nutrient_web_utils.dart';

/// This class is used to interact with a
/// [PSPDFKit.Instance](https://www.nutrient.io/api/web/PSPDFKit.Instance.html) in
/// PSPDFKit Web SDK.
/// It is returned by [PSPDFKit.load].
class NutrientWebInstance {
  final JsObject _nutrientInstance;
  NutrientWebInstance(this._nutrientInstance);

  List<String> get availableDocumentInfoKeys {
    return _nutrientInstance.callMethod('getAvailableDocumentInfoKeys');
  }

  /// Returns the PSPDFKitInstance JsObject.
  JsObject get jsObject => _nutrientInstance;

  /// Saves the current state of the PSPDFKit instance.
  /// Throws an error if the operation fails.
  Future<void> save() async {
    try {
      await promiseToFuture(_nutrientInstance.callMethod('save'));
    } catch (e) {
      throw Exception('Failed to save document: $e');
    }
  }

  /// Adds an annotation to the document.
  ///
  /// The annotation is passed as a [Map<String, dynamic>].
  /// The object structure should be the same as the one returned by
  /// `PSPDFKit.Annotations.toSerializableObject` in Nutrient Web SDK.
  ///
  ///Throws an error if the operation fails.
  Future<void> addAnnotation(Map<String, dynamic> jsonAnnotation,
      [Map<String, dynamic>? attachment]) async {
    try {
      var annotation = context['PSPDFKit']['Annotations'].callMethod(
          'fromSerializableObject', [JsObject.jsify(jsonAnnotation)]);
      await promiseToFuture(
          _nutrientInstance.callMethod('create', [annotation]));
    } catch (e) {
      throw Exception('Failed to add annotation: $e');
    }
  }

  /// Updates an annotation in the document.
  ///
  /// The annotation is passed as a [Map<String, dynamic>].
  /// The object structure should be the same as the one returned by
  /// `PSPDFKit.Annotations.toSerializableObject` in PSPDFKit for Web.
  ///
  /// Throws an error if the operation fails.
  Future<void> updateAnnotation(Map<String, dynamic> jsonAnnotation) async {
    try {
      await removeAnnotation(jsonAnnotation)
          .then((value) => addAnnotation(jsonAnnotation));
    } catch (e) {
      throw Exception('Failed to update annotation: $e');
    }
  }

  /// Returns a list of all annotations on the given page.
  /// The return annotations are in the [Instant JSON](https://www.nutrient.io/guides/web/json/) format.
  /// [pageIndex] is the index of the page to get the annotations from.
  /// Returns a [Future] that completes with the list of annotations.
  Future<dynamic> getAnnotations(int pageIndex,
      [String? annotationType]) async {
    var annotations = await _getRawAnnotations(pageIndex);
    var annotationJSON = <dynamic>[];

    for (var i = 0; i < annotations['size']; i++) {
      var annotation = annotations.callMethod('get', [i]);

      var ann = webAnnotationToJSON(annotation);

      if (annotationType != null) {
        if (ann['type'] == annotationType || annotationType == 'pspdfkit/all') {
          annotationJSON.add(ann);
          continue;
        }
      } else {
        annotationJSON.add(ann);
      }
    }
    return annotationJSON;
  }

  Future<dynamic> _getRawAnnotations(int pageIndex) async {
    var annotationPromise =
        await _nutrientInstance.callMethod('getAnnotations', [pageIndex]);
    return await promiseToFuture(annotationPromise);
  }

  /// Applies the given Instant JSON string to the document.
  /// Returns a Future that completes with a boolean indicating whether the operation was successful.
  /// The [annotationsJson] parameter is a String or Map containing the Instant JSON data to apply.
  /// Throws an error if the operation fails.
  ///
  Future<void> applyInstantJson(dynamic annotationsJson) async {
    Map<String, dynamic> instantJsonObject;
    if (annotationsJson is String) {
      instantJsonObject = jsonDecode(annotationsJson);
    } else if (annotationsJson is Map<String, dynamic>) {
      instantJsonObject = annotationsJson;
    } else {
      throw ArgumentError(
          'annotationsJson must be a String or a Map<String, dynamic>');
    }
    var operations = [
      {'type': 'applyInstantJson', 'instantJson': instantJsonObject}
    ];
    await applyOperations(operations);
  }

  /// Asynchronously exports the Instant JSON representation of the current document.
  /// Returns a [String] containing the Instant JSON data, or throws an exception if the export failed.
  Future<String?> exportInstantJson() async {
    var annotationsJsonPromise =
        await _nutrientInstance.callMethod('exportInstantJSON');
    JsObject instant = await promiseToFuture(annotationsJsonPromise);
    return jsonEncode(instant.toJson());
  }

  /// Imports XFDF annotations from a file path.
  /// Returns a Future that completes with a boolean value indicating whether the import was successful or not.
  /// The [xfdfPath] parameter is a String representing the file path of the XFDF file to import.
  /// The [ignorePageRotation] parameter is an optional boolean value indicating whether to ignore page rotation when importing annotations.
  /// Throws an error if the operation fails.
  Future<void> importXfdf(String xfdfPath, [bool? ignorePageRotation]) async {
    var operation = [
      {
        'type': 'applyXfdf',
        'xfdf': xfdfPath,
        'ignorePageRotation': ignorePageRotation ?? false,
      }
    ];
    try {
      await applyOperations(operation);
    } catch (e) {
      throw Exception('Failed to import XFDF: $e');
    }
  }

  /// Exports the current document as XFDF (XML Forms Data Format).
  ///
  /// The [xfdfPath] parameter is a String representing the file path of the XFDF file to export.
  /// Throws an error if the operation fails.
  Future<void> exportXfdf(
    String xfdfPath,
  ) async {
    try {
      var xfdf =
          await promiseToFuture(_nutrientInstance.callMethod('exportXFDF'));
      // Download the XFDF file to the provided path.
      var blob = Blob([xfdf], 'application/vnd.adobe.xfdf');
      var url = Url.createObjectUrlFromBlob(blob);
      var anchor = AnchorElement(href: url);
      anchor.download = xfdfPath;
      anchor.click();
    } catch (e) {
      throw Exception('Failed to export XFDF: $e');
    }
  }

  /// Retrieves all annotations in the document.
  /// Returns a [Future] that completes with a list of unsaved annotations.
  /// The annotations are retrieved asynchronously.
  Future<dynamic> getAllAnnotations() async {
    var json = await exportInstantJson();
    if (json == null) return {};
    var annotationsJson = jsonDecode(json);
    return annotationsJson;
  }

  /// Removes the specified annotation from the PDF document.
  ///
  /// The [jsonAnnotation] parameter should be a JSON representation of the annotation to be removed.
  /// Throws an error if the operation fails.
  Future<void> removeAnnotation(dynamic jsonAnnotation) async {
    try {
      if (jsonAnnotation is String) {
        jsonAnnotation = jsonDecode(jsonAnnotation);
      }
      var annotationId = jsonAnnotation['id'];
      var pageIndex = jsonAnnotation['pageIndex'];
      var name = jsonAnnotation['name'];

      JsObject rawAnnotations = await _getRawAnnotations(pageIndex);

      for (var i = 0; i < rawAnnotations['size']; i++) {
        var annotation = rawAnnotations.callMethod('get', [i]);

        if ((annotation['id'] == annotationId &&
                annotation['pageIndex'] == pageIndex) ||
            (annotation['name'] == name &&
                annotation['pageIndex'] == pageIndex)) {
          await _nutrientInstance.callMethod('delete', [annotation]);
        }
      }

      // Remove the annotation from the PDF document.
    } catch (e) {
      throw Exception('Failed to remove annotation: $e');
    }
  }

  /// Removes multiple annotations from the PDF document.
  Future<void> removeAnnotations(List<dynamic> jsonAnnotations) async {
    try {
      var ids = jsonAnnotations.map((e) => e['id']).toList();
      await _nutrientInstance.callMethod('delete', [ids]);
    } catch (e) {
      throw Exception('Failed to remove annotations: $e');
    }
  }

  /// Sets the value of a form field.
  ///
  /// This method allows you to programmatically set the value of a form field in the PSPDFKit Web instance.
  /// The form field is identified by its name or ID.
  ///
  /// Example usage:
  /// ```dart
  /// await setFormFieldValue('username', 'John Doe');
  /// ```
  ///
  /// Throws an Exception if an error occurs while setting the form field value.
  Future<void> setFormFieldValue(
      String value, String fullyQualifiedName) async {
    var formValues = {
      fullyQualifiedName: value,
    };
    return setFormFieldValues(formValues);
  }

  /// Sets the values of form fields in the PDF document.
  ///
  /// The [formValues] parameter is a map where the keys represent the field names
  /// and the values represent the new values to be set for each field.
  ///
  /// Throws an error if the operation fails.
  Future<void> setFormFieldValues(Map<String, String> formValues) async {
    try {
      await promiseToFuture(_nutrientInstance.callMethod('setFormFieldValues', [
        JsObject.jsify(formValues),
      ]));
    } catch (e) {
      throw Exception('Failed to set form field values: $e');
    }
  }

  /// Retrieves the value of a form field with the specified fully qualified name.
  /// The [fullyQualifiedName] parameter is the fully qualified name of the form field.
  /// Returns a [Future] that completes with the value of the form field, or `null` if the form field is not found.
  Future<String?> getFormFieldValue(String fullyQualifiedName) async {
    JsObject values = await _nutrientInstance.callMethod('getFormFieldValues');
    return values.toJson()[fullyQualifiedName];
  }

  /// Sets the measurement precision for the PSPDFKit Web instance.
  /// The [precision] parameter specifies the desired measurement precision.
  Future<void> setMeasurementPrecision(MeasurementPrecision precision) async {
    try {
      await promiseToFuture(
          _nutrientInstance.callMethod('setMeasurementPrecision', [
        precision.webName,
      ]));
    } catch (e) {
      throw Exception('Failed to set measurement precision: $e');
    }
  }

  /// Sets the measurement scale for the PSPDFKit Web instance.
  /// The [scale] parameter represents the measurement scale to be set.
  Future<void> setMeasurementScale(MeasurementScale scale) async {
    var webScale = {
      'unitFrom': scale.unitFrom,
      'unitTo': scale.unitTo,
      'fromValue': scale.valueFrom,
      'toValue': scale.valueTo,
    };

    try {
      await promiseToFuture(
          _nutrientInstance.callMethod('setMeasurementScale', [
        JsObject.jsify(webScale),
      ]));
    } catch (e) {
      throw Exception('Failed to set measurement scale: $e');
    }
  }

  /// Applies a list of operations to the PSPDFKit instance.
  /// Returns a Future that completes with the result of the operation.
  /// The operations are represented as a list of maps, where each map represents an operation.
  /// For a full list of supported operations, see the [PSPDFKit.DocumentOperation](https://www.nutrient.io/api/web/PSPDFKit.DocumentOperation.html) API reference.
  /// The operation names and arguments are specific to the PSPDFKit API.
  /// Throws an error if the operation fails.
  Future<dynamic> applyOperations(List<Map<String, dynamic>> operations) async {
    try {
      await promiseToFuture(_nutrientInstance.callMethod('applyOperations', [
        JsObject.jsify(operations),
      ]));
    } catch (e) {
      throw Exception('Failed to apply operations: $e');
    }
  }

  /// Sets the name of the annotation creator.
  ///
  /// The [name] parameter specifies the name of the annotation creator.
  /// This method is used to set the name of the user who is creating the annotations.
  /// The name will be associated with the annotations created by the user.
  /// Throws an error if the operation fails.
  Future<void> setAnnotationCreatorName(String name) async {
    try {
      await promiseToFuture(
          _nutrientInstance.callMethod('setAnnotationCreatorName', [name]));
    } catch (e) {
      throw Exception('Failed to set annotation creator name: $e');
    }
  }

  /// Sets the tool mode for the PSPDFKit Web instance using the ViewState API.
  ///
  /// The [toolMode] parameter specifies the interaction mode to set.
  /// This can be one of the PSPDFKit.InteractionMode values.
  /// If null is provided, it will reset to the default interaction mode (null).
  ///
  /// Throws an error if the operation fails.
  Future<void> setToolMode(AnnotationTool? toolMode) async {
    try {
      if (toolMode == null) {
        // Reset to default interaction mode (null)
        await promiseToFuture(_nutrientInstance.callMethod('setViewState', [
          allowInterop((viewState) {
            return viewState.callMethod('set', ['interactionMode', null]);
          })
        ]));
      } else {
        // Set the interaction mode using ViewState API
        await promiseToFuture(_nutrientInstance.callMethod('setViewState', [
          allowInterop((viewState) {
            return viewState.callMethod('set', [
              'interactionMode',
              context['PSPDFKit']['InteractionMode']
                  [toolMode.toWebInteractionMode()]
            ]);
          })
        ]));
      }
    } catch (e) {
      throw Exception('Failed to set tool mode: $e');
    }
  }

  /// Adds event listener to the PSPDFKit instance.
  /// The [eventName] parameter specifies the name of the event to listen to.
  /// The [callback] parameter specifies the callback function to be called when the event is triggered.
  /// The callback parameter function accepts varying number of arguments depending on the event.
  /// See the [PSPDFKit.Instance.addEventListener](https://www.nutrient.io/api/web/PSPDFKit.Instance.html#addEventListener) API reference for more information about the events and their arguments.
  void addEventListener(String eventName, Function(dynamic) callback) {
    try {
      _nutrientInstance.callMethod('addEventListener', [
        eventName,
        allowInterop(([dynamic event, dynamic event2]) {
          dynamic processedEvent1;
          dynamic processedEvent2;

          // --- Process event 1 ---
          if (event is JsObject) {
            // Convert JsObject to Map, handling annotations specifically
            final eventData = event.toJson();
            if (eventData is Map<String, dynamic>) {
              // Handle single annotation property
              if (eventData.containsKey('annotation') &&
                  event['annotation'] is JsObject) {
                eventData['annotation'] =
                    webAnnotationToJSON(event['annotation']);
              }
              // Handle annotations array property
              if (eventData.containsKey('annotations') &&
                  event['annotations'] is JsObject) {
                final jsAnnotationsArray = event['annotations'];
                // Check if it behaves like an array (has length property)
                if (jsAnnotationsArray.hasProperty('length')) {
                  final length = jsAnnotationsArray['length'] as int;
                  final convertedAnnotations = <dynamic>[];
                  for (var i = 0; i < length; i++) {
                    final annotation =
                        jsAnnotationsArray[i]; // Access array element
                    if (annotation is JsObject) {
                      convertedAnnotations.add(webAnnotationToJSON(annotation));
                    } else {
                      // Keep non-JsObject elements as they are
                      convertedAnnotations.add(annotation);
                    }
                  }
                  eventData['annotations'] =
                      convertedAnnotations; // Update the map
                }
              }
              processedEvent1 = eventData; // Use the processed map
            } else {
              processedEvent1 =
                  eventData; // Use the result of toJson directly if not map
            }
          } else {
            processedEvent1 = event; // Keep primitives/null as is
          }

          // --- Process event 2 ---
          if (event2 is JsObject) {
            // Check if event2 itself looks like an annotation before generic conversion
            // Use a heuristic: check for common annotation properties like 'id' and 'type'.
            final id = event2['id'];
            final type = event2['type'];
            if (id != null && type is String && type.startsWith('pspdfkit/')) {
              // Looks like an annotation, use the specific converter
              processedEvent2 = webAnnotationToJSON(event2);
            } else {
              // Not identified as an annotation, use generic conversion
              processedEvent2 = event2.toJson();
            }
          } else {
            processedEvent2 = event2; // Keep primitives/null as is
          }

          // --- Pass to callback ---
          if (event2 != null) {
            // Two arguments were passed from JS API. Package into a Map.
            callback({
              'argument1': processedEvent1,
              'argument2': processedEvent2,
            });
          } else {
            // Only one (or zero) argument was passed from JS API.
            callback(processedEvent1);
          }
        })
      ]);
    } catch (e) {
      throw Exception('Failed to add event listener for $eventName: $e');
    }
  }

  /// Removes event listener from the PSPDFKit instance.
  /// The [eventName] parameter specifies the name of the event to remove the listener from.
  /// The [jsCallback] parameter specifies the JavaScript function reference that was originally added.
  void removeEventListener(String eventName, Function jsCallback) {
    try {
      _nutrientInstance
          .callMethod('removeEventListener', [eventName, jsCallback]);
    } catch (e) {
      throw Exception('Failed to remove event listener for $eventName: $e');
    }
  }

  /// Sets the toolbar items to be displayed in the toolbar.
  /// The [items] parameter is a list of [NutrientWebToolbarItem] objects.
  void setToolbarItems(List<NutrientWebToolbarItem> items) {
    var jsItems = items.map((e) => e.toJsObject()).toList();
    _nutrientInstance.callMethod('setToolbarItems', [JsObject.jsify(jsItems)]);
  }

  /// Get the page info for the given page index.
  /// The [pageIndex] parameter is the index of the page to get the info for.
  /// Returns a [Future] that completes with the [PageInfo] object for the given page index.
  Future<PageInfo> getPageInfo(int pageIndex) async {
    var pageInfo =
        _nutrientInstance.callMethod('pageInfoForIndex', [pageIndex]);
    return PageInfo(
      pageIndex: pageInfo['pageIndex'],
      height: pageInfo['height'],
      width: pageInfo['width'],
      rotation: pageInfo['rotation'],
      label: pageInfo['label'],
    );
  }

  /// Exports the current document as a raw PDF file.
  /// The [options] parameter is an optional [DocumentSaveOptions] object that specifies the export options.
  /// Returns a [Future] that completes with a [Uint8List] containing the exported PDF data.
  Future<Uint8List> exportPdf({DocumentSaveOptions? options}) async {
    var webOptions = options?.toWebOptions();
    var arrayBuffer = await promiseToFuture(_nutrientInstance
        .callMethod('exportPDF', [JsObject.jsify(webOptions ?? {})]));

    var uintList = JsObject(context['Uint8Array'], [arrayBuffer]);
    JsArray jsArray = context['Array'].callMethod('from', [uintList]);
    Uint8List bytes = Uint8List.fromList(List<int>.from(jsArray));
    return bytes;
  }

  /// Get all form fields in the document.
  Future<List<PdfFormField>> getFormFields() async {
    JsObject formFields =
        await promiseToFuture(_nutrientInstance.callMethod('getFormFields'));

    // `getFormFields` returns a custom  (PSPDFKit.Immutable.List)[https://www.nutrient.io/api/web/PSPDFKit.Immutable.List.html]
    // whose value in an iterator. We need to convert this to a Dart list.
    var values = formFields.callMethod('values');

    List<dynamic> resultList = [];

    while (true) {
      JsObject nextItem = values.callMethod('next');
      // Check if the iterator is done.
      if (nextItem['done']) {
        break;
      }
      JsObject field = nextItem['value'];

      Map<String, dynamic> fieldMap = field.toJson();
      fieldMap['type'] = _getFormFieldType(field);
      resultList.add(fieldMap);
    }
    return resultList.map((field) => PdfFormField.fromMap(field)).toList();
  }

  /// Zooms to the specified rectangle on the given page.
  /// The [pageIndex] parameter is the index of the page to zoom to.
  /// The [rect] parameter is the rectangle to zoom to.
  /// Returns a [Future] that completes when the operation is complete.
  /// Throws an error if the operation fails.
  Future<void> zoomToRect(int pageIndex, Rect rect) async {
    try {
      JsObject webRect = JsObject(context['PSPDFKit']['Geometry']['Rect'], [
        JsObject.jsify({
          'left': rect.left,
          'top': rect.top,
          'width': rect.width,
          'height': rect.height
        })
      ]);
      _nutrientInstance.callMethod('jumpAndZoomToRect', [
        pageIndex,
        webRect,
      ]);
    } catch (e) {
      throw Exception('Failed to zoom to rect: $e');
    }
  }

  Future<double> getZoomScale(int pageIndex) async {
    try {
      var scale = _nutrientInstance['currentZoomLevel'];
      return scale.toDouble();
    } catch (e) {
      throw Exception('Failed to get zoom scale: $e');
    }
  }

  Future<int> getPageCount() async {
    try {
      var count = _nutrientInstance['totalPageCount'];
      return Future.value(count);
    } catch (e) {
      throw Exception('Failed to get document title: $e');
    }
  }

  String _getFormFieldType(JsObject field) {
    JsObject textClass = context['PSPDFKit']['FormFields']['TextFormField'];
    JsObject signatureClass =
        context['PSPDFKit']['FormFields']['SignatureFormField'];
    JsObject checkBoxClass =
        context['PSPDFKit']['FormFields']['CheckBoxFormField'];
    JsObject radioButtonClass =
        context['PSPDFKit']['FormFields']['RadioButtonFormField'];
    JsObject comboBoxClass =
        context['PSPDFKit']['FormFields']['ComboBoxFormField'];
    JsObject listBoxClass =
        context['PSPDFKit']['FormFields']['ListBoxFormField'];
    JsObject buttonClass = context['PSPDFKit']['FormFields']['ButtonFormField'];

    if (_instanceOf(field, textClass)) {
      return 'text';
    } else if (_instanceOf(field, signatureClass)) {
      return 'signature';
    } else if (_instanceOf(field, checkBoxClass)) {
      return 'checkbox';
    } else if (_instanceOf(field, radioButtonClass)) {
      return 'radioButton';
    } else if (_instanceOf(field, comboBoxClass)) {
      return 'comboBox';
    } else if (_instanceOf(field, listBoxClass)) {
      return 'listBox';
    } else if (_instanceOf(field, buttonClass)) {
      return 'button';
    } else {
      return 'unknown';
    }
  }

  bool _instanceOf(JsObject formField, JsObject formFieldClass) {
    String script = '''function instanceOf(formField, formFieldClass) {
      return formField instanceof formFieldClass;
    }''';
    context.callMethod('eval', [script]);
    var result = context.callMethod('instanceOf', [formField, formFieldClass]);
    return result;
  }

  /// Converts a Nutrient Web annotation to a JSON object.
  /// The [annotation] parameter is the PSPDFKit Web annotation to convert.
  /// Returns a JSON object representing the annotation.
  dynamic webAnnotationToJSON(JsObject annotation) {
    // Convert the annotation to a JSON object
    JsObject json = context['PSPDFKit']['Annotations']
        .callMethod('toSerializableObject', [annotation]);

    final result = json.toJson();

    // Add type information if result is a Map
    if (result is Map<String, dynamic>) {
      // Map of Nutrient Web annotation class names to their corresponding Nutrient type strings
      // as defined in annotation_type_extensions.dart
      final annotationTypeMap = {
        'TextAnnotation': 'pspdfkit/text',
        'NoteAnnotation': 'pspdfkit/note',
        'InkAnnotation': 'pspdfkit/ink',
        'HighlightAnnotation': 'pspdfkit/markup/highlight',
        'UnderlineAnnotation': 'pspdfkit/markup/underline',
        'SquiggleAnnotation': 'pspdfkit/markup/squiggly',
        'StrikeOutAnnotation': 'pspdfkit/markup/strikeout',
        'LineAnnotation': 'pspdfkit/shape/line',
        'RectangleAnnotation': 'pspdfkit/shape/rectangle',
        'EllipseAnnotation': 'pspdfkit/shape/ellipse',
        'PolygonAnnotation': 'pspdfkit/shape/polygon',
        'PolylineAnnotation': 'pspdfkit/shape/polyline',
        'LinkAnnotation': 'pspdfkit/link',
        'ImageAnnotation': 'pspdfkit/image',
        'RedactionAnnotation': 'pspdfkit/markup/redaction',
        'StampAnnotation': 'pspdfkit/stamp',
        'MediaAnnotation': 'pspdfkit/media',
        'WidgetAnnotation': 'pspdfkit/widget',
        'CommentMarkerAnnotation': 'pspdfkit/comment',
        'MarkupAnnotation': 'pspdfkit/markup'
      };

      // Check each annotation type
      for (final entry in annotationTypeMap.entries) {
        final className = entry.key;
        final typeString = entry.value;

        // Skip if the class doesn't exist
        if (!context['PSPDFKit']['Annotations'].hasProperty(className)) {
          continue;
        }

        // Get the annotation class
        final annotationClass = context['PSPDFKit']['Annotations'][className];

        // Check if the annotation is an instance of this class
        if (annotationClass != null &&
            _instanceOf(annotation, annotationClass)) {
          // Add the type to the result using the proper format
          result['type'] = typeString;
          break;
        }
      }
    }

    return result;
  }
}
