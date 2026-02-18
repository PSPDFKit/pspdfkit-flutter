///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:io';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter/src/nutrient_flutter_platform_interface.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    as platform show Nutrient;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:nutrient_flutter_web/nutrient_flutter_web.dart' as web
    show nutrient, pspdfkit, NutrientWebStaticExtension;

/// Creates the platform-specific instance for web.
NutrientFlutterPlatform createPlatformInstance() => NutrientFlutterWeb();

/// A web implementation of the NutrientFlutterPlatform of the NutrientFlutter plugin.
class NutrientFlutterWeb extends NutrientFlutterPlatform {
  static const String _notSupportedOnWebMessage =
      'Not supported on web, Please use NutrientView instead.';

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
  Future<String?> getFrameworkVersion() async {
    try {
      return 'Web ${web.pspdfkit.version}';
    } catch (e) {
      return 'Web unknown';
    }
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
  Future<void> setLicenseKey(String? licenseKey) async {
    // License key is stored via Nutrient.initialize() and read during load
    // by nutrient_flutter_web. No direct JS call needed.
    if (licenseKey != null) {
      await platform.Nutrient.initialize(webLicenseKey: licenseKey);
    }
  }

  @override
  Future<void> setLicenseKeys(String? androidLicenseKey, String? iOSLicenseKey,
      String? webLicenseKey) async {
    if (webLicenseKey != null) {
      await platform.Nutrient.initialize(webLicenseKey: webLicenseKey);
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
  String get authorName {
    // Author name is set per-instance on web, not globally.
    // Use NutrientWebAdapter.onInstanceLoaded to access instance properties.
    return '';
  }

  @override
  List<NutrientWebToolbarItem> get defaultWebToolbarItems {
    try {
      // Try NutrientViewer namespace first, fall back to PSPDFKit
      final sdk =
          globalContext.has('NutrientViewer') ? web.nutrient : web.pspdfkit;
      final jsItems = sdk.defaultToolbarItems;
      final dartItems = jsItems.toDart;
      return dartItems
          .map((jsItem) {
            if (jsItem == null) return null;
            final obj = jsItem as JSObject;
            final type = (obj['type'] as JSString?)?.toDart;
            if (type == null) return null;
            return NutrientWebToolbarItem(
              type: NutrientWebToolbarItemType.values.firstWhere(
                (e) => e.name == type,
                orElse: () => NutrientWebToolbarItemType.custom,
              ),
              title: (obj['title'] as JSString?)?.toDart,
              className: (obj['className'] as JSString?)?.toDart,
              disabled: (obj['disabled'] as JSBoolean?)?.toDart,
              dropdownGroup: (obj['dropdownGroup'] as JSString?)?.toDart,
              icon: (obj['icon'] as JSString?)?.toDart,
              id: (obj['id'] as JSString?)?.toDart,
              preset: (obj['preset'] as JSString?)?.toDart,
              responsiveGroup: (obj['responsiveGroup'] as JSString?)?.toDart,
              selected: (obj['selected'] as JSBoolean?)?.toDart,
            );
          })
          .whereType<NutrientWebToolbarItem>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get defaultWebToolbarItems: $e');
    }
  }

  @override
  Future<String?> generatePdf(List<NewPage> pages, String outPutFile,
      [Map<String, Object?>? options]) {
    throw UnimplementedError(_notSupportedOnWebMessage);
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
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<void> setDefaultAuthorName(String authorName) {
    throw UnimplementedError(_notSupportedOnWebMessage);
  }

  @override
  Future<PdfDocument> openDocument(String documentPath, {String? password}) {
    throw UnimplementedError(
        'Headless document API is not yet supported on web platform. Use NutrientView instead.');
  }
}
