///
///  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/services.dart';
import '../../pspdfkit.dart';

/// A controller for a PSPDFKit widget for native platforms that use the [MethodChannel].
class PspdfkitWidgetControllerNative implements PspdfkitWidgetController {
  final MethodChannel _channel;

  PspdfkitWidgetControllerNative(int id)
      : _channel = MethodChannel('com.pspdfkit.widget.$id');

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
          String type, String processingMode, String destinationPath) async =>
      _channel.invokeMethod('processAnnotations', <String, String>{
        'type': type,
        'processingMode': processingMode,
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
  Future<bool?> setMeasurementScale(MeasurementScale scale) async =>
      _channel.invokeMethod('setMeasurementScale', <String, dynamic>{
        'measurementScale': scale.toMap(),
      });
  @override
  Future<bool?> setMeasurementPrecision(MeasurementPrecision precision) async =>
      _channel.invokeMethod('setMeasurementPrecision', <String, dynamic>{
        'measurementPrecision': precision.name,
      });

  @override
  Future<bool?> setAnnotationConfigurations(
      Map<AnnotationTool, AnnotationConfiguration> configurations) async {
    var configMap = <String, dynamic>{};

    configurations.forEach((key, value) {
      configMap[key.name] = value.toMap();
    });

    return await _channel
        .invokeMethod('setAnnotationPresetConfigurations', <String, dynamic>{
      'annotationConfigurations': configMap,
    });
  }

  @override
  void addEventListener(String eventName, Function(dynamic) callback) {
    // TODO: implement addEventListener
    throw UnimplementedError();
  }
}
