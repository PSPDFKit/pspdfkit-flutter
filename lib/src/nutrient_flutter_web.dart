///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
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
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter/src/nutrient_flutter_platform_interface.dart';

import 'web/nutrient_web.dart';

/// Creates the platform-specific instance for web.
NutrientFlutterPlatform createPlatformInstance() => NutrientFlutterWeb();

/// A web implementation of the NutrientFlutterPlatform of the NutrientFlutter plugin.
class NutrientFlutterWeb extends NutrientFlutterPlatform {
  static const String _notSupportedOnWebMessage =
      'Not supported on web, Please use NutrientWidget instead.';

  /// Constructs a NutrientFlutterWeb
  NutrientFlutterWeb();

  static void registerWith(Registrar registrar) {
    NutrientFlutterPlatform.instance = NutrientFlutterWeb();
  }

  @override
  Future<bool?> addAnnotation(dynamic annotation,
      [Map<String, dynamic>? attachment]) {
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
  Future getAnnotationsAsJSON(int pageIndex, String type) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<String?> getFrameworkVersion() {
    return NutrientWeb.version;
  }

  @override
  Future<bool?> importXfdf(String xfdfString) {
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
  Future<bool?> removeAnnotation(annotation) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<bool?> updateAnnotation(Annotation annotation) {
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
      NutrientWeb.setLicenseKey(licenseKey);

  @override
  Future<void> setLicenseKeys(String? androidLicenseKey, String? iOSLicenseKey,
      String? webLicenseKey) async {
    if (webLicenseKey != null) {
      await NutrientWeb.setLicenseKey(webLicenseKey);
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
  String get authorName => NutrientWeb.authorName;

  @override
  List<NutrientWebToolbarItem> get defaultWebToolbarItems =>
      NutrientWeb.defaultToolbarItems;

  @override
  Future<String?> generatePdf(List<NewPage> pages, String outPutFile,
      [Map<String, Object?>? options]) {
    throw UnimplementedError();
  }

  @override
  Future<String?> generatePdfFromHtmlString(String html, String outPutFile,
      [Map<String, Object?>? options]) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<String?> generatePdfFromHtmlUri(Uri htmlUri, String outPutFile,
      [Map<String, Object?>? options]) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<void> enableAnalytics(bool enabled) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<List<Annotation>> getUnsavedAnnotations() =>
      throw UnimplementedError(_notSupportedOnWebMessage);

  @override
  Future<List<Annotation>> getAnnotations(int pageIndex, AnnotationType type) =>
      throw UnimplementedError(_notSupportedOnWebMessage);

  @override
  Future<String> getAuthorName() {
    throw UnimplementedError();
  }

  @override
  Future<void> setDefaultAuthorName(String authorName) {
    throw UnimplementedError();
  }

  @override
  Future<PdfDocument> openDocument(String documentPath, {String? password}) {
    throw UnimplementedError(
        'Headless document API is not yet supported on web platform. Use NutrientView instead.');
  }
}
