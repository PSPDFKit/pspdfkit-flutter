///
///  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/services.dart';
import '../../pspdfkit.dart';
import '../document/pdf_document_native.dart';

/// A controller for a PSPDFKit widget for native platforms that use the [MethodChannel].
@Deprecated(
    'Please use the new [PspdfkitFlutterWidgetControllerImpl] widget API instead.')
class PspdfkitWidgetControllerNative extends PspdfkitWidgetController {
  final MethodChannel _channel;

  PspdfkitWidgetControllerNative(
    this._channel, {
    PdfDocumentLoadedCallback? onPdfDocumentLoaded,
    PdfDocumentLoadFailedCallback? onPdfDocumentLoadFailed,
    PageChangedCallback? onPageChanged,
    AnnotationsChangedCallback? onAnnotationsChanged,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onDocumentLoaded':
          var documentId = call.arguments['documentId'] as String;
          var api = PdfDocumentApi(
              binaryMessenger: _channel.binaryMessenger,
              messageChannelSuffix: documentId);
          onPdfDocumentLoaded
              ?.call(PdfDocumentNative(documentId: documentId, api: api));
          break;
        case 'onDocumentLoadFailed':
          onPdfDocumentLoadFailed?.call(call.arguments['error'] as String);
          break;
        case 'onPageChanged':
          var pageIndex = call.arguments['pageIndex'];
          onPageChanged?.call(pageIndex);
          break;
        case 'onAnnotationsChanged':
          onAnnotationsChanged?.call(this);
          break;
      }
    });
  }

  @override
  Future<bool?> setFormFieldValue(
          String value, String fullyQualifiedName) async =>
      _channel.invokeMethod('setFormFieldValue', <String, dynamic>{
        'value': value,
        'fullyQualifiedName': fullyQualifiedName
      });

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) async =>
      _channel.invokeMethod('getFormFieldValue',
          <String, dynamic>{'fullyQualifiedName': fullyQualifiedName});

  @override
  Future<bool?> applyInstantJson(String annotationsJson) async =>
      _channel.invokeMethod('applyInstantJson',
          <String, String>{'annotationsJson': annotationsJson});

  @override
  Future<String?> exportInstantJson() async =>
      _channel.invokeMethod('exportInstantJson');

  @override
  Future<bool?> addAnnotation(dynamic jsonAnnotation) async =>
      _channel.invokeMethod(
          'addAnnotation', <String, dynamic>{'jsonAnnotation': jsonAnnotation});

  @override
  Future<bool?> removeAnnotation(dynamic jsonAnnotation) async =>
      _channel.invokeMethod('removeAnnotation',
          <String, dynamic>{'jsonAnnotation': jsonAnnotation});

  @override
  Future<dynamic> getAnnotations(int pageIndex, String type) async =>
      _channel.invokeMethod<dynamic>('getAnnotations',
          <String, dynamic>{'pageIndex': pageIndex, 'type': type});

  @override
  Future<dynamic> getAllUnsavedAnnotations() async =>
      _channel.invokeMethod<dynamic>('getAllUnsavedAnnotations');

  @override
  Future<bool?> processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  ) async =>
      _channel.invokeMethod('processAnnotations', <String, String>{
        'type': type.fullName,
        'processingMode': processingMode.name,
        'destinationPath': destinationPath
      });

  @override
  Future<bool?> importXfdf(String xfdfPath) async => _channel
      .invokeMethod('importXfdf', <String, String>{'xfdfPath': xfdfPath});

  @override
  Future<bool?> exportXfdf(String xfdfPath) async => _channel
      .invokeMethod('exportXfdf', <String, String>{'xfdfPath': xfdfPath});

  @override
  Future<bool?> save() async => _channel.invokeMethod('save');

  @override
  Future<bool?> setAnnotationConfigurations(
    Map<AnnotationTool, AnnotationConfiguration> configurations,
  ) async {
    await _channel
        .invokeMethod('setAnnotationPresetConfigurations', <String, dynamic>{
      'annotationConfigurations': configurations.map((key, value) {
        return MapEntry(key.name, value.toMap());
      }),
    });
    return true;
  }

  @override
  Future<void> addEventListener(
      NutrientEvent event, Function(dynamic) callback) {
    throw UnimplementedError(
        'addEventListener is not yet implemented on this platform');
  }

  @override
  Future<void> removeEventListener(NutrientEvent event) {
    throw UnimplementedError(
        'removeEventListener is not yet implemented on this platform');
  }

  @override
  Future<Rect> getVisibleRect(int pageIndex) {
    return _channel.invokeMethod('getVisibleRect', {
      'pageIndex': pageIndex,
    }).then((results) {
      if (results == null) {
        throw Exception('Visible rect is null');
      }
      return Rect.fromLTWH(
        results['left'],
        results['top'],
        results['width'],
        results['height'],
      );
    }).catchError((error) {
      throw Exception('Error getting visible rect: $error');
    });
  }

  @override
  Future<void> zoomToRect(int pageIndex, Rect rect) {
    return _channel.invokeMethod('zoomToRect', <String, dynamic>{
      'pageIndex': pageIndex,
      'rect': <String, dynamic>{
        'left': rect.left,
        'top': rect.top,
        'width': rect.width,
        'height': rect.height,
      },
    }).catchError((error) {
      throw Exception('Error zooming to rect: $error');
    });
  }

  @override
  Future<double> getZoomScale(int pageIndex) {
    return _channel.invokeMethod('getZoomScale', {
      'pageIndex': pageIndex,
    }).then((results) {
      if (results == null) {
        throw Exception('Zoom scale is null');
      }
      return results as double;
    }).catchError((error) {
      throw Exception('Error getting zoom scale: $error');
    });
  }

  @override
  Future<bool?> enterAnnotationCreationMode(
      [AnnotationTool? annotationTool]) async {
    throw UnimplementedError(
        'Annotation creation mode is not supported in legacy mode');
  }

  @override
  Future<bool?> exitAnnotationCreationMode() async {
    throw UnimplementedError(
        'Annotation creation mode is not supported in legacy mode');
  }
}
