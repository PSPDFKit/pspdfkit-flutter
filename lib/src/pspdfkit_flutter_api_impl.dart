import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:pspdfkit_flutter/src/document/annotation_json_converter.dart';
import 'package:pspdfkit_flutter/src/pspdfkit_flutter_platform_interface.dart';

class PspdfkitFlutterApiImpl
    with AnnotationJsonConverter
    implements
        PspdfkitFlutterPlatform,
        PspdfkitFlutterApiCallbacks,
        AnalyticsEventsCallback {
  late PspdfkitApi _pspdfkitApi = PspdfkitApi();
  PspdfkitFlutterApiImpl() {
    var messageChannel = const MethodChannel('com.pspdfkit.global');

    _pspdfkitApi = PspdfkitApi(
        binaryMessenger: messageChannel.binaryMessenger,
        messageChannelSuffix: 'pspdfkit');

    PspdfkitFlutterApiCallbacks.setUp(this,
        binaryMessenger: messageChannel.binaryMessenger,
        messageChannelSuffix: 'pspdfkit');

    AnalyticsEventsCallback.setUp(this,
        binaryMessenger: messageChannel.binaryMessenger,
        messageChannelSuffix: 'pspdfkit');
  }

  @override
  VoidCallback? flutterPdfActivityOnPause;

  @override
  PspdfkitDocumentLoadedCallback? flutterPdfDocumentLoaded;

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

    bool? success = await _pspdfkitApi.addAnnotation(
        convertAnnotationToJson(annotation), jsonEncode(attachment));

    return success;
  }

  @override
  Future<bool?> applyInstantJson(String annotationsJson) {
    return _pspdfkitApi.applyInstantJson(annotationsJson);
  }

  @override
  String get authorName => throw UnimplementedError();

  @override
  Future<bool?> checkAndroidWriteExternalStoragePermission() {
    return _pspdfkitApi.checkAndroidWriteExternalStoragePermission();
  }

  @override
  List<PspdfkitWebToolbarItem> get defaultWebToolbarItems => [];

  @override
  Future<String?> exportInstantJson() {
    return _pspdfkitApi.exportInstantJson();
  }

  @override
  Future<bool?> exportXfdf(String xfdfPath) {
    return _pspdfkitApi.exportXfdf(xfdfPath);
  }

  @override
  Future getAllUnsavedAnnotations() {
    return _pspdfkitApi.getAllUnsavedAnnotations();
  }

  @override
  Future<List<Annotation>> getUnsavedAnnotations() async {
    final dynamic result = await _pspdfkitApi.getAllUnsavedAnnotations();
    if (result is List) {
      return result
          .map((dynamic json) =>
              Annotation.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future getAnnotationsAsJSON(int pageIndex, String type) {
    return _pspdfkitApi.getAnnotations(pageIndex, type);
  }

  @override
  Future<List<Annotation>> getAnnotations(
      int pageIndex, AnnotationType type) async {
    final dynamic result =
        await _pspdfkitApi.getAnnotations(pageIndex, type.fullName);
    if (result is List) {
      return result
          .map((dynamic json) =>
              Annotation.fromJson(json as Map<String, dynamic>))
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
    return _pspdfkitApi.getFormFieldValue(fullyQualifiedName);
  }

  @override
  Future<String?> getFrameworkVersion() {
    return _pspdfkitApi.getFrameworkVersion();
  }

  @override
  Future<Directory> getTemporaryDirectory() {
    return _pspdfkitApi.getTemporaryDirectory().then((path) => Directory(path));
  }

  @override
  Future<bool?> importXfdf(String xfdfString) {
    return _pspdfkitApi.importXfdf(xfdfString);
  }

  @override
  Future<void> openAndroidSettings() {
    return _pspdfkitApi.openAndroidSettings();
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
    return _pspdfkitApi.present(
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
    return _pspdfkitApi.presentInstant(serverUrl, jwt,
        configuration: configurationMap as Map<String, Object>?);
  }

  @override
  Future<bool?> processAnnotations(AnnotationType type,
      AnnotationProcessingMode processingMode, String destinationPath) {
    return _pspdfkitApi.processAnnotations(
        type, processingMode, destinationPath);
  }

  @override
  Future<bool?> removeAnnotation(dynamic annotation) {
    try {
      return _pspdfkitApi.removeAnnotation(convertAnnotationToJson(annotation));
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }
  }

  @override
  Future<AndroidPermissionStatus>
      requestAndroidWriteExternalStoragePermission() {
    return _pspdfkitApi.requestAndroidWriteExternalStoragePermission();
  }

  @override
  Future<bool?> save() {
    return _pspdfkitApi.save();
  }

  @override
  Future<bool?> setAnnotationPresetConfigurations(
      Map<String, dynamic> configurations) {
    return _pspdfkitApi.setAnnotationPresetConfigurations(configurations);
  }

  @override
  Future<bool?> setDelayForSyncingLocalChanges(double delay) {
    return _pspdfkitApi.setDelayForSyncingLocalChanges(delay);
  }

  @override
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName) {
    return _pspdfkitApi.setFormFieldValue(value, fullyQualifiedName);
  }

  @override
  Future<void> setLicenseKey(String? licenseKey) {
    return _pspdfkitApi.setLicenseKey(licenseKey);
  }

  @override
  Future<void> setLicenseKeys(
      String? androidLicenseKey, String? iOSLicenseKey, String? webLicenseKey) {
    return _pspdfkitApi.setLicenseKeys(
        androidLicenseKey, iOSLicenseKey, webLicenseKey);
  }

  @override
  Future<bool?> setListenToServerChanges(bool listen) {
    return _pspdfkitApi.setListenToServerChanges(listen);
  }

  @override
  Future<bool?> syncAnnotations() {
    return _pspdfkitApi.syncAnnotations();
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
    return _pspdfkitApi.generatePdf(pagesMaps, outPutFile);
  }

  @override
  Future<String?> generatePdfFromHtmlString(String html, String outPutFile,
      [Map<String, Object?>? options]) {
    return _pspdfkitApi.generatePdfFromHtmlString(
        html, outPutFile, options?.cast<String, Object>());
  }

  @override
  Future<String?> generatePdfFromHtmlUri(Uri htmlUri, String outPutFile,
      [Map<String, Object?>? options]) {
    return _pspdfkitApi.generatePdfFromHtmlUri(
        htmlUri.toString(), outPutFile, options?.cast<String, Object>());
  }

  @override
  Future<void> enableAnalytics(bool enabled) {
    return _pspdfkitApi.enableAnalyticsEvents(enabled);
  }

  @override
  void onEvent(String event, Map<String, Object?>? attributes) {
    analyticsEventsListener?.call(
        event, attributes?.cast<String, Object>() ?? {});
  }

  @override
  Future<String> getAuthorName() {
    return _pspdfkitApi.getAuthorName();
  }

  @override
  Future<void> setDefaultAuthorName(String authorName) {
    return _pspdfkitApi.setAuthorName(authorName);
  }
}
