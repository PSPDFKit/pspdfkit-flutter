///
///  Copyright © 2018-2023 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class PspdfkitWidgetController {
  final MethodChannel _channel;

  PspdfkitWidgetController(int id)
      : _channel = MethodChannel('com.pspdfkit.widget.$id');

  /// Sets the value of a form field by specifying its fully qualified field name.
  Future<bool?> setFormFieldValue(
          String value, String fullyQualifiedName) async =>
      _channel.invokeMethod('setFormFieldValue', <String, dynamic>{
        'value': value,
        'fullyQualifiedName': fullyQualifiedName
      });

  /// Gets the form field value by specifying its fully qualified name.
  Future<String?> getFormFieldValue(String fullyQualifiedName) async =>
      _channel.invokeMethod('getFormFieldValue',
          <String, dynamic>{'fullyQualifiedName': fullyQualifiedName});

  /// Applies Instant document JSON to the presented document.
  Future<bool?> applyInstantJson(String annotationsJson) async =>
      _channel.invokeMethod('applyInstantJson',
          <String, String>{'annotationsJson': annotationsJson});

  /// Exports Instant document JSON from the presented document.
  Future<String?> exportInstantJson() async =>
      _channel.invokeMethod('exportInstantJson');

  /// Adds the given annotation to the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  Future<bool?> addAnnotation(dynamic jsonAnnotation) async =>
      _channel.invokeMethod(
          'addAnnotation', <String, dynamic>{'jsonAnnotation': jsonAnnotation});

  /// Removes the given annotation from the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  Future<bool?> removeAnnotation(dynamic jsonAnnotation) async =>
      _channel.invokeMethod('removeAnnotation',
          <String, dynamic>{'jsonAnnotation': jsonAnnotation});

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  Future<dynamic> getAnnotations(int pageIndex, String type) async =>
      _channel.invokeMethod<dynamic>('getAnnotations',
          <String, dynamic>{'pageIndex': pageIndex, 'type': type});

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  Future<dynamic> getAllUnsavedAnnotations() async =>
      _channel.invokeMethod<dynamic>('getAllUnsavedAnnotations');

  /// Processes annotations of the given type with the provided processing
  /// mode and stores the PDF at the given destination path.
  Future<bool?> processAnnotations(
          String type, String processingMode, String destinationPath) async =>
      _channel.invokeMethod('processAnnotations', <String, String>{
        'type': type,
        'processingMode': processingMode,
        'destinationPath': destinationPath
      });

  /// Imports annotations from the XFDF file at the given path.
  Future<bool?> importXfdf(String xfdfPath) async => _channel
      .invokeMethod('importXfdf', <String, String>{'xfdfPath': xfdfPath});

  /// Exports annotations to the XFDF file at the given path.
  Future<bool?> exportXfdf(String xfdfPath) async => _channel
      .invokeMethod('exportXfdf', <String, String>{'xfdfPath': xfdfPath});

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  Future<bool?> save() async => _channel.invokeMethod('save');

  /// Sets the measurement scale of the document.
  /// The scale is used to convert between real world measurements and points.
  /// The default scale is 1 inch = 1 inch.
  /// @param scale The scale to be used for the document.
  /// @return True if the scale was set successfully, false otherwise.
  Future<bool?> setMeasurementScale(MeasurementScale scale) async =>
      _channel.invokeMethod('setMeasurementScale', <String, dynamic>{
        'measurementScale': scale.toMap(),
      });

  /// Sets the measurement precision of the document.
  /// The precision is used to round the measurement values.
  /// The default precision is 2 decimal places.
  /// @param precision The precision to be used for the document.
  /// @return True if the precision was set successfully, false otherwise.
  Future<bool?> setMeasurementPrecision(MeasurementPrecision precision) async =>
      _channel.invokeMethod('setMeasurementPrecision', <String, dynamic>{
        'measurementPrecision': precision.name,
      });

  /// Sets the annotation preset configurations for the given annotation tools.
  /// @param configurations A map of annotation tools and their corresponding configurations.
  /// @return True if the configurations were set successfully, false otherwise.
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
}
