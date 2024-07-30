///
///  Copyright © 2018-2023 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:io';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:pspdfkit_flutter/src/web/pspdfkit_web.dart';
import 'pspdfkit_flutter_platform_interface.dart';

/// A web implementation of the PspdfkitFlutterPlatform of the PspdfkitFlutter plugin.
class PspdfkitFlutterWeb extends PspdfkitFlutterPlatform {
  static const String _notSupportedOnWebMessage = 'Not supported on web';

  /// Constructs a PspdfkitFlutterWeb
  PspdfkitFlutterWeb();

  static void registerWith(Registrar registrar) {
    PspdfkitFlutterPlatform.instance = PspdfkitFlutterWeb();
  }

  @override
  Future<bool?> addAnnotation(jsonAnnotation) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<bool?> applyInstantJson(String annotationsJson) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<String?> exportInstantJson() {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<bool?> exportXfdf(String xfdfPath) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future getAllUnsavedAnnotations() async {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future getAnnotations(int pageIndex, String type) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<String?> getFrameworkVersion() {
    return PSPDFKitWeb.version;
  }

  @override
  Future<bool?> importXfdf(String xfdfPath) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<void> openAndroidSettings() {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<bool?> present(String document,
      {configuration,
      MeasurementScale? measurementScale,
      MeasurementPrecision? measurementPrecision}) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<bool?> presentInstant(String serverUrl, String jwt, [configuration]) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<bool?> processAnnotations(AnnotationType type,
      AnnotationProcessingMode processingMode, String destinationPath) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<bool?> removeAnnotation(jsonAnnotation) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<bool?> save() {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<bool?> setAnnotationPresetConfigurations(
      Map<String, dynamic> configurations) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<bool?> setDelayForSyncingLocalChanges(double delay) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<void> setLicenseKey(String? licenseKey) =>
      PSPDFKitWeb.setLicenseKey(licenseKey);

  @override
  Future<void> setLicenseKeys(String? androidLicenseKey, String? iOSLicenseKey,
      String? webLicenseKey) async {
    if (webLicenseKey != null) {
      await PSPDFKitWeb.setLicenseKey(webLicenseKey);
    }
  }

  @override
  Future<bool?> setListenToServerChanges(bool listen) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<bool?> syncAnnotations() {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<bool?> checkAndroidWriteExternalStoragePermission() {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<Directory> getTemporaryDirectory() {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<AndroidPermissionStatus>
      requestAndroidWriteExternalStoragePermission() {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  String get authorName => PSPDFKitWeb.authorName;

  @override
  List<PspdfkitWebToolbarItem> get defaultWebToolbarItems =>
      PSPDFKitWeb.defaultToolbarItems;
}
