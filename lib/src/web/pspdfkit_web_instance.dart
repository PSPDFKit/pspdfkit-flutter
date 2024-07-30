///
///  Copyright © 2023-2024 PSPDFKit GmbH. All rights reserved.
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
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:pspdfkit_flutter/src/web/pspdfkit_web_utils.dart';
import '../document/page_info.dart';

/// This class is used to interact with a
/// [PSPDFKit.Instance](https://pspdfkit.com/api/web/PSPDFKit.Instance.html) in
/// PSPDFKit Web SDK.
/// It is returned by [PSPDFKit.load].
class PspdfkitWebInstance {
  final JsObject _pspdfkitInstance;
  PspdfkitWebInstance(this._pspdfkitInstance);

  List<String> get availableDocumentInfoKeys {
    return _pspdfkitInstance.callMethod('getAvailableDocumentInfoKeys');
  }

  /// Returns the PSPDFKitInstance JsObject.
  JsObject get jsObject => _pspdfkitInstance;

  /// Saves the current state of the PSPDFKit instance.
  /// Throws an error if the operation fails.
  Future<void> save() async {
    try {
      await promiseToFuture(_pspdfkitInstance.callMethod('save'));
    } catch (e) {
      throw Exception('Failed to save document: $e');
    }
  }

  /// Adds an annotation to the document.
  ///
  /// The annotation is passed as a [Map<String, dynamic>].
  /// The object structure should be the same as the one returned by
  /// `PSPDFKit.Annotations.toSerializableObject` in PSPDFKit for Web.
  ///
  ///Throws an error if the operation fails.
  Future<void> addAnnotation(Map<String, dynamic> jsonAnnotation) async {
    try {
      var annotation = context['PSPDFKit']['Annotations'].callMethod(
          'fromSerializableObject', [JsObject.jsify(jsonAnnotation)]);
      await promiseToFuture(
          _pspdfkitInstance.callMethod('create', [annotation]));
    } catch (e) {
      throw Exception('Failed to add annotation: $e');
    }
  }

  /// Returns a list of all annotations on the given page.
  /// The return annotations are in the [Instant JSON](https://pspdfkit.com/guides/web/json/) format.
  /// [pageIndex] is the index of the page to get the annotations from.
  /// Returns a [Future] that completes with the list of annotations.
  Future<dynamic> getAnnotations(int pageIndex,
      [String? annotationType]) async {
    var annotationsPromise =
        await _pspdfkitInstance.callMethod('getAnnotations', [pageIndex]);

    var annotations = await promiseToFuture(annotationsPromise);
    var annotationJSON = <dynamic>[];

    for (var i = 0; i < annotations['size']; i++) {
      var annotation = annotations.callMethod('get', [i]);

      JsObject annotationObject = context['PSPDFKit']['Annotations']
          .callMethod('toSerializableObject', [annotation]);

      var ann = annotationObject.toJson();

      if (annotationType != null) {
        if (ann['type'] == annotationType) {
          annotationJSON.add(ann);
          continue;
        }
      } else {
        annotationJSON.add(ann);
      }
    }
    return annotationJSON;
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
        await _pspdfkitInstance.callMethod('exportInstantJSON');
    JsObject instant = await promiseToFuture(annotationsJsonPromise);
    return instant.toJson().toString();
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
          await promiseToFuture(_pspdfkitInstance.callMethod('exportXFDF'));
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
  Future<List<dynamic>> getAllAnnotations() async {
    var pageCount = await _pspdfkitInstance['totalPageCount'];
    var annotations = [];
    for (var i = 0; i < pageCount - 1; i++) {
      var pageAnnotations = await getAnnotations(i);
      annotations.addAll(pageAnnotations);
    }
    return annotations;
  }

  /// Removes the specified annotation from the PDF document.
  ///
  /// The [jsonAnnotation] parameter should be a JSON representation of the annotation to be removed.
  /// Throws an error if the operation fails.
  Future<void> removeAnnotation(dynamic jsonAnnotation) async {
    try {
      var id = jsonAnnotation['id'];
      await _pspdfkitInstance.callMethod('delete', [id]);
    } catch (e) {
      throw Exception('Failed to remove annotation: $e');
    }
  }

  /// Removes multiple annotations from the PDF document.
  Future<void> removeAnnotations(List<dynamic> jsonAnnotations) async {
    try {
      var ids = jsonAnnotations.map((e) => e['id']).toList();
      await _pspdfkitInstance.callMethod('delete', [ids]);
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
      await promiseToFuture(_pspdfkitInstance.callMethod('setFormFieldValues', [
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
    JsObject values = await _pspdfkitInstance.callMethod('getFormFieldValues');
    return values.toJson()[fullyQualifiedName];
  }

  /// Sets the measurement precision for the PSPDFKit Web instance.
  /// The [precision] parameter specifies the desired measurement precision.
  Future<void> setMeasurementPrecision(MeasurementPrecision precision) async {
    try {
      await promiseToFuture(
          _pspdfkitInstance.callMethod('setMeasurementPrecision', [
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
          _pspdfkitInstance.callMethod('setMeasurementScale', [
        JsObject.jsify(webScale),
      ]));
    } catch (e) {
      throw Exception('Failed to set measurement scale: $e');
    }
  }

  /// Applies a list of operations to the PSPDFKit instance.
  /// Returns a Future that completes with the result of the operation.
  /// The operations are represented as a list of maps, where each map represents an operation.
  /// For a full list of supported operations, see the [PSPDFKit.DocumentOperation](https://pspdfkit.com/api/web/PSPDFKit.DocumentOperation.html) API reference.
  /// The operation names and arguments are specific to the PSPDFKit API.
  /// Throws an error if the operation fails.
  Future<dynamic> applyOperations(List<Map<String, dynamic>> operations) async {
    try {
      await promiseToFuture(_pspdfkitInstance.callMethod('applyOperations', [
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
          _pspdfkitInstance.callMethod('setAnnotationCreatorName', [name]));
    } catch (e) {
      throw Exception('Failed to set annotation creator name: $e');
    }
  }

  /// Adds event listener to the PSPDFKit instance.
  /// The [eventName] parameter specifies the name of the event to listen to.
  /// The [callback] parameter specifies the callback function to be called when the event is triggered.
  /// The callback parameter function accepts varying number of arguments depending on the event.
  /// See the [PSPDFKit.Instance.addEventListener](https://pspdfkit.com/api/web/PSPDFKit.Instance.html#addEventListener) API reference for more information about the events and their arguments.
  void addEventListener(String eventName, Function(dynamic) callback) {
    try {
      _pspdfkitInstance.callMethod('addEventListener', [
        eventName,
        allowInterop(([dynamic event, dynamic event2]) {
          // If the event is a primitive type, pass it directly to the callback function.
          if (event is int ||
              event is String ||
              event is bool ||
              event == null) {
            callback(event);
            return;
          }
          // If the event is a JsObject and the second event is null, pass it to the callback function.
          if (event is JsObject && event2 == null) {
            callback(event.toJson());
            return;
          }

          /// If the event and the second event are JsObjects, pass them to the callback function.
          /// This is used for events that return multiple value for example `viewState.change` event.
          if (event is JsObject && event2 is JsObject) {
            callback([event, event2]);
            return;
          }
          // Convert the event to JSON and pass it to the callback function.
          callback((event as JsObject).toJson());
        })
      ]);
    } catch (e) {
      throw Exception('Failed to add event listener: $e');
    }
  }

  /// Sets the toolbar items to be displayed in the toolbar.
  /// The [items] parameter is a list of [PspdfkitWebToolbarItem] objects.
  void setToolbarItems(List<PspdfkitWebToolbarItem> items) {
    var jsItems = items.map((e) => e.toJsObject()).toList();
    _pspdfkitInstance.callMethod('setToolbarItems', [JsObject.jsify(jsItems)]);
  }

  /// Get the page info for the given page index.
  /// The [pageIndex] parameter is the index of the page to get the info for.
  /// Returns a [Future] that completes with the [PageInfo] object for the given page index.
  Future<PageInfo> getPageInfo(int pageIndex) async {
    var pageInfo =
        _pspdfkitInstance.callMethod('pageInfoForIndex', [pageIndex]);
    return PageInfo.fromJson(pageInfo);
  }

  /// Exports the current document as a raw PDF file.
  /// The [options] parameter is an optional [DocumentSaveOptions] object that specifies the export options.
  /// Returns a [Future] that completes with a [Uint8List] containing the exported PDF data.
  Future<Uint8List> exportPdf({DocumentSaveOptions? options}) async {
    var webOptions = options?.toWebOptions();
    var arrayBuffer = await promiseToFuture(_pspdfkitInstance.callMethod(
        'exportPDF', [JsObject.jsify(webOptions ?? <String, dynamic>{})]));

    var uintList = JsObject(context['Uint8Array'], [arrayBuffer]);
    JsArray jsArray = context['Array'].callMethod('from', [uintList]);
    Uint8List bytes = Uint8List.fromList(List<int>.from(jsArray));
    return bytes;
  }

  /// Get all form fields in the document.
  Future<List<PdfFormField>> getFormFields() async {
    JsObject formFields =
        await promiseToFuture(_pspdfkitInstance.callMethod('getFormFields'));

    // `getFormFields` returns a custom  (PSPDFKit.Immutable.List)[https://pspdfkit.com/api/web/PSPDFKit.Immutable.List.html]
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
      _pspdfkitInstance.callMethod('jumpAndZoomToRect', [
        pageIndex,
        webRect,
      ]);
    } catch (e) {
      throw Exception('Failed to zoom to rect: $e');
    }
  }

  Future<double> getZoomScale(int pageIndex) async {
    try {
      var scale = _pspdfkitInstance['currentZoomLevel'];
      return scale.toDouble();
    } catch (e) {
      throw Exception('Failed to get zoom scale: $e');
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
}
