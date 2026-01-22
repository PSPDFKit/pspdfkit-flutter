///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter/src/document/annotation_json_converter.dart';
import 'package:nutrient_flutter/src/nutrient_flutter_platform_interface.dart';

/// Creates the platform-specific instance for native platforms.
NutrientFlutterPlatform createPlatformInstance() => NutrientFlutterApiImpl();

class NutrientFlutterApiImpl
    with AnnotationJsonConverter
    implements
        NutrientFlutterPlatform,
        NutrientApiCallbacks,
        AnalyticsEventsCallback {
  late NutrientApi _nutrientApi = NutrientApi();
  NutrientFlutterApiImpl() {
    var messageChannel = const MethodChannel('com.nutrient.global');

    _nutrientApi = NutrientApi(
        binaryMessenger: messageChannel.binaryMessenger,
        messageChannelSuffix: 'nutrient');

    NutrientApiCallbacks.setUp(this,
        binaryMessenger: messageChannel.binaryMessenger,
        messageChannelSuffix: 'nutrient');

    AnalyticsEventsCallback.setUp(this,
        binaryMessenger: messageChannel.binaryMessenger,
        messageChannelSuffix: 'nutrient');
  }

  @override
  VoidCallback? flutterPdfActivityOnPause;

  @override
  NutrientDocumentLoadedCallback? flutterPdfDocumentLoaded;

  @override
  VoidCallback? flutterPdfFragmentAdded;

  @override
  InstantAuthenticationFailedCallback? instantAuthenticationFailed;

  @override
  InstantAuthenticationFinishedCallback? instantAuthenticationFinished;

  @override
  InstantDownloadFailedCallback? instantDownloadFailed;

  @override
  InstantDownloadFinishedCallback? instantDownloadFinished;

  @override
  InstantSyncFailedCallback? instantSyncFailed;

  @override
  InstantSyncFinishedCallback? instantSyncFinished;

  @override
  InstantSyncStartedCallback? instantSyncStarted;

  @override
  VoidCallback? pdfViewControllerDidDismiss;

  @override
  VoidCallback? pdfViewControllerWillDismiss;

  @override
  AnalyticsEventsListener? analyticsEventsListener;

  @override
  Future<bool?> addAnnotation(dynamic annotation) async {
    Map<String, dynamic>? attachment;

    if (annotation is Annotation && annotation is HasAttachment) {
      attachment = (annotation as HasAttachment).attachment?.toJson();
    }

    bool? success = await _nutrientApi.addAnnotation(
        convertAnnotationToJson(annotation), jsonEncode(attachment));

    return success;
  }

  @override
  Future<bool?> applyInstantJson(String annotationsJson) {
    return _nutrientApi.applyInstantJson(annotationsJson);
  }

  @override
  String get authorName => throw UnimplementedError();

  @override
  Future<bool?> checkAndroidWriteExternalStoragePermission() {
    return _nutrientApi.checkAndroidWriteExternalStoragePermission();
  }

  @override
  List<NutrientWebToolbarItem> get defaultWebToolbarItems => [];

  @override
  Future<String?> exportInstantJson() {
    return _nutrientApi.exportInstantJson();
  }

  @override
  Future<bool?> exportXfdf(String xfdfPath) {
    return _nutrientApi.exportXfdf(xfdfPath);
  }

  @override
  Future getAllUnsavedAnnotations() {
    return _nutrientApi.getAllUnsavedAnnotationsJson();
  }

  @override
  Future<List<Annotation>> getUnsavedAnnotations() async {
    final jsonString = await _nutrientApi.getAllUnsavedAnnotationsJson();
    if (jsonString != null) {
      final results = jsonDecode(jsonString);
      if (results is List) {
        return results
            .map((dynamic json) =>
                Annotation.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
    }
    return [];
  }

  @override
  Future getAnnotationsAsJSON(int pageIndex, String type) {
    return _nutrientApi.getAnnotationsJson(pageIndex, type).then((jsonString) {
      if (jsonString != null) {
        var results = jsonDecode(jsonString) as List<dynamic>;
        return results.map((result) {
          return Map<String, dynamic>.from(result as Map);
        }).toList();
      }
      return [];
    });
  }

  @override
  Future<List<Annotation>> getAnnotations(
      int pageIndex, AnnotationType type) async {
    final jsonString =
        await _nutrientApi.getAnnotationsJson(pageIndex, type.fullName);
    if (jsonString != null) {
      final results = jsonDecode(jsonString) as List<dynamic>;
      return results
          .map((dynamic json) =>
              Annotation.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    }
    return [];
  }

  @override
  Future<bool?> updateAnnotation(Annotation annotation) {
    throw UnimplementedError();
  }

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) {
    return _nutrientApi.getFormFieldValue(fullyQualifiedName);
  }

  @override
  Future<String?> getFrameworkVersion() {
    return _nutrientApi.getFrameworkVersion();
  }

  @override
  Future<Directory> getTemporaryDirectory() {
    return _nutrientApi.getTemporaryDirectory().then((path) => Directory(path));
  }

  @override
  Future<bool?> importXfdf(String xfdfString) {
    return _nutrientApi.importXfdf(xfdfString);
  }

  @override
  Future<void> openAndroidSettings() {
    return _nutrientApi.openAndroidSettings();
  }

  @override
  Future<bool?> present(String document, {dynamic configuration}) {
    Map<String, dynamic>? configurationMap;
    if (configuration is PdfConfiguration) {
      configurationMap = (configuration).toMap();
    } else if (configuration is Map<String, dynamic>) {
      configurationMap = configuration;
    } else {
      configurationMap = {};
    }
    return _nutrientApi.present(
      document,
      configuration: configurationMap.cast<String, Object>(),
    );
  }

  @override
  Future<bool?> presentInstant(String serverUrl, String jwt, [configuration]) {
    Map<String, dynamic>? configurationMap;
    if (configuration is PdfConfiguration) {
      configurationMap = (configuration).toMap();
    } else if (configuration is Map<String, dynamic>) {
      configurationMap = configuration;
    } else {
      configurationMap = {};
    }
    return _nutrientApi.presentInstant(serverUrl, jwt,
        configuration: configurationMap as Map<String, Object>?);
  }

  @override
  Future<bool?> processAnnotations(AnnotationType type,
      AnnotationProcessingMode processingMode, String destinationPath) {
    return _nutrientApi.processAnnotations(
        type, processingMode, destinationPath);
  }

  @override
  Future<bool?> removeAnnotation(dynamic annotation) {
    try {
      return _nutrientApi.removeAnnotation(convertAnnotationToJson(annotation));
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }
  }

  @override
  Future<AndroidPermissionStatus>
      requestAndroidWriteExternalStoragePermission() {
    return _nutrientApi.requestAndroidWriteExternalStoragePermission();
  }

  @override
  Future<bool?> save() {
    return _nutrientApi.save();
  }

  @override
  Future<bool?> setAnnotationPresetConfigurations(
      Map<String, dynamic> configurations) {
    return _nutrientApi.setAnnotationPresetConfigurations(configurations);
  }

  @override
  Future<bool?> setDelayForSyncingLocalChanges(double delay) {
    return _nutrientApi.setDelayForSyncingLocalChanges(delay);
  }

  @override
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName) {
    return _nutrientApi.setFormFieldValue(value, fullyQualifiedName);
  }

  @override
  Future<void> setLicenseKey(String? licenseKey) {
    return _nutrientApi.setLicenseKey(licenseKey);
  }

  @override
  Future<void> setLicenseKeys(
      String? androidLicenseKey, String? iOSLicenseKey, String? webLicenseKey) {
    return _nutrientApi.setLicenseKeys(
        androidLicenseKey, iOSLicenseKey, webLicenseKey);
  }

  @override
  Future<bool?> setListenToServerChanges(bool listen) {
    return _nutrientApi.setListenToServerChanges(listen);
  }

  @override
  Future<bool?> syncAnnotations() {
    return _nutrientApi.syncAnnotations();
  }

  @override
  void onDocumentLoaded(String documentId) {
    flutterPdfDocumentLoaded?.call(documentId);
  }

  @override
  void onInstantAuthenticationFailed(String documentId, String error) {
    instantAuthenticationFailed?.call(documentId, error);
  }

  @override
  void onInstantAuthenticationFinished(String documentId, String validJWT) {
    instantAuthenticationFinished?.call(documentId, validJWT);
  }

  @override
  void onInstantDownloadFailed(String documentId, String error) {
    instantDownloadFailed?.call(documentId, error);
  }

  @override
  void onInstantDownloadFinished(String documentId) {
    instantDownloadFinished?.call(documentId);
  }

  @override
  void onInstantSyncFailed(String documentId, String error) {
    instantSyncFailed?.call(documentId, error);
  }

  @override
  void onInstantSyncFinished(String documentId) {
    instantSyncFinished?.call(documentId);
  }

  @override
  void onInstantSyncStarted(String documentId) {
    instantSyncStarted?.call(documentId);
  }

  @override
  void onPdfActivityOnPause() {
    flutterPdfActivityOnPause?.call();
  }

  @override
  void onPdfFragmentAdded() {
    flutterPdfFragmentAdded?.call();
  }

  @override
  void onPdfViewControllerDidDismiss() {
    pdfViewControllerDidDismiss?.call();
  }

  @override
  void onPdfViewControllerWillDismiss() {
    pdfViewControllerWillDismiss?.call();
  }

  @override
  Future<String?> generatePdf(List<NewPage> pages, String outPutFile,
      [Map<String, Object?>? options]) {
    var pagesMaps =
        pages.map((page) => page.toMap().cast<String, Object>()).toList();
    return _nutrientApi.generatePdf(pagesMaps, outPutFile);
  }

  @override
  Future<String?> generatePdfFromHtmlString(String html, String outPutFile,
      [Map<String, Object?>? options]) {
    return _nutrientApi.generatePdfFromHtmlString(
        html, outPutFile, options?.cast<String, Object>());
  }

  @override
  Future<String?> generatePdfFromHtmlUri(Uri htmlUri, String outPutFile,
      [Map<String, Object?>? options]) {
    return _nutrientApi.generatePdfFromHtmlUri(
        htmlUri.toString(), outPutFile, options?.cast<String, Object>());
  }

  @override
  Future<void> enableAnalytics(bool enabled) {
    return _nutrientApi.enableAnalyticsEvents(enabled);
  }

  @override
  void onEvent(String event, Map<String, Object?>? attributes) {
    analyticsEventsListener?.call(
        event, attributes?.cast<String, Object>() ?? {});
  }

  @override
  Future<String> getAuthorName() {
    return _nutrientApi.getAuthorName();
  }

  @override
  Future<void> setDefaultAuthorName(String authorName) {
    return _nutrientApi.setAuthorName(authorName);
  }

  // ============================
  // Headless Document API
  // ============================

  final HeadlessDocumentApi _headlessDocumentApi = HeadlessDocumentApi(
    binaryMessenger: const MethodChannel('com.nutrient.global').binaryMessenger,
    messageChannelSuffix: 'nutrient',
  );

  @override
  Future<PdfDocument> openDocument(
    String documentPath, {
    String? password,
  }) async {
    final options = password != null
        ? HeadlessDocumentOpenOptions(password: password)
        : null;

    final documentId =
        await _headlessDocumentApi.openDocument(documentPath, options);

    // Create a PdfDocumentApi for this specific document using the documentId as channel suffix
    final documentApi = PdfDocumentApi(
      binaryMessenger:
          const MethodChannel('com.nutrient.global').binaryMessenger,
      messageChannelSuffix: documentId,
    );

    return HeadlessPdfDocumentNative(
      documentId: documentId,
      api: documentApi,
    );
  }
}
