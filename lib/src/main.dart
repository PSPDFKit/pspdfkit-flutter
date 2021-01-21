///
///  Copyright © 2018-2021 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
library pspdfkit;

import 'dart:async';

import 'package:flutter/services.dart';

part 'android_permission_status.dart';
part 'configuration_options.dart';

/// PSPDFKit plugin to load PDF and image documents on both platform iOS and Android.
class Pspdfkit {
  static const MethodChannel _channel = const MethodChannel('com.pspdfkit.global');

  /// Gets the PSPDFKit framework version.
  static Future<String> get frameworkVersion async =>
      _channel.invokeMethod('frameworkVersion');

  /// Sets the license key.
  static Future<void> setLicenseKey(String licenseKey) async =>
      await _channel.invokeMethod('setLicenseKey', <String, String>{'licenseKey': licenseKey});

  /// Loads a [document] with a supported format using a given [configuration].
  static Future<bool> present(String document, [dynamic configuration]) async =>
      await _channel.invokeMethod('present', <String, dynamic>{'document': document, 'configuration': configuration});

  /// Sets the value of a form field by specifying its fully qualified field name.
  static Future<bool> setFormFieldValue(String value, String fullyQualifiedName) async =>
      _channel.invokeMethod('setFormFieldValue', <String, dynamic>{'value': value, 'fullyQualifiedName': fullyQualifiedName});

  /// Gets the form field value by specifying its fully qualified name.
  static Future<String> getFormFieldValue(String fullyQualifiedName) async =>
      _channel.invokeMethod('getFormFieldValue', <String, dynamic>{'fullyQualifiedName': fullyQualifiedName});

  /// Applies Instant document JSON to the presented document.
  static Future<bool> applyInstantJson(String annotationsJson) async =>
      _channel.invokeMethod('applyInstantJson', <String, String>{'annotationsJson': annotationsJson});

  /// Exports Instant document JSON from the presented document.
  static Future<String> exportInstantJson() async => _channel.invokeMethod('exportInstantJson');

  /// Adds the given annotation to the presented document. 
  /// `jsonAnnotation` can either be a JSON string or a valid JSON dictionary.
  static Future<bool> addAnnotation(dynamic jsonAnnotation) async => 
      _channel.invokeMethod('addAnnotation', <String, dynamic>{'jsonAnnotation': jsonAnnotation});

  /// Removes the given annotation from the presented document. 
  /// `jsonAnnotation` can either be a JSON string or a valid JSON dictionary.
  static Future<bool> removeAnnotation(dynamic jsonAnnotation) async => 
      _channel.invokeMethod('removeAnnotation', <String, dynamic>{'jsonAnnotation': jsonAnnotation});

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  static Future<dynamic> getAnnotations(int pageIndex, String type) async =>
      _channel.invokeMethod<dynamic>('getAnnotations', <String, dynamic>{'pageIndex': pageIndex, 'type': type});

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  static Future<dynamic> getAllUnsavedAnnotations() async => _channel.invokeMethod<dynamic>('getAllUnsavedAnnotations');

  /// Processes annotations of the given type with the provided processing 
  /// mode and stores the PDF at the given destination path.
  static Future<bool> processAnnotations(String type, String processingMode, String destinationPath) async =>
      _channel.invokeMethod('processAnnotations', <String, String>{
        'type': type,
        'processingMode': processingMode,
        'destinationPath': destinationPath}
      );

  /// Imports annotations from the XFDF file at the given path.
  static Future<bool> importXfdf(String xfdfPath) async => 
      _channel.invokeMethod('importXfdf', <String, String>{'xfdfPath': xfdfPath});

  /// Exports annotations to the XFDF file at the given path.
  static Future<bool> exportXfdf(String xfdfPath) async => 
      _channel.invokeMethod('exportXfdf', <String, String>{'xfdfPath': xfdfPath});

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  static Future<bool> save() async => _channel.invokeMethod('save');
  
  /// Checks the external storage permission for writing on Android only.
  static Future<bool> checkAndroidWriteExternalStoragePermission() async {
    return _channel.invokeMethod(
        "checkPermission",
        {"permission": "WRITE_EXTERNAL_STORAGE"}
    );
  }

  /// Requests the external storage permission for writing on Android only.
  static Future<AndroidPermissionStatus> requestAndroidWriteExternalStoragePermission() async {
    final dynamic status = await _channel.invokeMethod<dynamic>(
      "requestPermission", 
      {"permission": "WRITE_EXTERNAL_STORAGE"}
    );

    return status is int
        ? _intToAndroidPermissionStatus(status)
        : status is bool
        ? (status ? AndroidPermissionStatus.authorized : AndroidPermissionStatus.denied)
        : AndroidPermissionStatus.notDetermined;
  }

  /// Opens the Android settings.
  static Future<void> openAndroidSettings() async => _channel.invokeMethod("openSettings");

  static AndroidPermissionStatus _intToAndroidPermissionStatus(int status) {
    switch (status) {
      case 0:
        return AndroidPermissionStatus.notDetermined;
      case 1:
        return AndroidPermissionStatus.denied;
      case 2:
        return AndroidPermissionStatus.authorized;
      case 3:
        return AndroidPermissionStatus.deniedNeverAsk;
      default:
        return AndroidPermissionStatus.notDetermined;
    }
  }
}
