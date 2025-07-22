///
///  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'dart:io';
import 'package:nutrient_flutter/src/nutrient_flutter_platform_interface.dart';

export 'src/pdf_configuration.dart';
export 'src/web/nutrient_web_configuration.dart';
export 'src/types.dart';
export 'src/web/models/models.dart';
export 'src/configuration_options.dart';
export 'src/toolbar/toolbar.dart';
export 'src/widgets/pspdfkit_widget.dart'
    if (dart.library.io) 'src/widgets/pspdfkit_widget.dart'
    if (dart.library.html) 'src/widgets/pspdfkit_widget_web.dart';
export 'src/widgets/pspdfkit_widget_controller.dart';
export 'src/measurements/measurements.dart';
export 'src/processor/processor.dart';
export 'src/document/pdf_document.dart';
export 'src/forms/forms.dart';

export 'src/annotation_preset_configurations.dart';
export 'src/annotations/annotations.dart';
export 'src/web/models/nutrient_web_events.dart';
export 'src/ai/ai_assistant_configuration.dart';

/// Nutrient plugin to load PDF and image documents on both platform iOS and Android.
@Deprecated('Use [Nutrient] instead.')
class Pspdfkit {
  static bool useLegacy = false;

  /// Gets the Nutrient framework version.
  static Future<String?> get frameworkVersion =>
      NutrientFlutterPlatform.instance.getFrameworkVersion();

  static Future<void> initialize({
    String? androidLicenseKey,
    String? iosLicenseKey,
    String? webLicenseKey,
    bool? useLegacy,
  }) async {
    Pspdfkit.useLegacy = useLegacy ?? false;
    await NutrientFlutterPlatform.instance
        .setLicenseKeys(androidLicenseKey, iosLicenseKey, webLicenseKey);
  }

  /// Sets the license key.
  /// @param licenseKey The license key to be used.
  @Deprecated('Use [Pspdfkit.initialize] instead.')
  static Future<void> setLicenseKey(String? licenseKey) =>
      NutrientFlutterPlatform.instance.setLicenseKey(licenseKey);

  /// Sets the license keys for both platforms.
  @Deprecated('Use [Pspdfkit.initialize] instead.')
  static Future<void> setLicenseKeys(String? androidLicenseKey,
          String? iOSLicenseKey, String? webLicenseKey) async =>
      NutrientFlutterPlatform.instance
          .setLicenseKeys(androidLicenseKey, iOSLicenseKey, webLicenseKey);

  /// Loads a [document] with a supported format using a given [configuration].
  static Future<bool?> present(String document,
          {dynamic configuration,
          MeasurementScale? measurementScale,
          MeasurementPrecision? measurementPrecision}) async =>
      NutrientFlutterPlatform.instance
          .present(document, configuration: configuration);

  /// Loads an Instant document from a server [serverUrl] with using a [jwt] in a native Instant PDFViewer.
  ///
  /// The [serverUrl] is the URL of the server that hosts the Instant document.
  /// The [jwt] is the JSON Web Token used to authenticate the user. It also contains the document ID.
  /// The [configuration] is a map of PDFViewer configurations.
  /// Returns true if the document was successfully opened.
  /// Returns false if the document could not be opened.
  static Future<bool?> presentInstant(String serverUrl, String jwt,
          [dynamic configuration]) async =>
      NutrientFlutterPlatform.instance
          .presentInstant(serverUrl, jwt, configuration);

  /// Sets the value of a form field by specifying its fully qualified field name.
  static Future<bool?> setFormFieldValue(
          String value, String fullyQualifiedName) async =>
      NutrientFlutterPlatform.instance
          .setFormFieldValue(value, fullyQualifiedName);

  /// Gets the form field value by specifying its fully qualified name.
  static Future<String?> getFormFieldValue(String fullyQualifiedName) async =>
      NutrientFlutterPlatform.instance.getFormFieldValue(fullyQualifiedName);

  /// Applies Instant document JSON to the presented document.
  static Future<bool?> applyInstantJson(String annotationsJson) async =>
      NutrientFlutterPlatform.instance.applyInstantJson(annotationsJson);

  /// Exports Instant document JSON from the presented document.
  static Future<String?> exportInstantJson() async =>
      NutrientFlutterPlatform.instance.exportInstantJson();

  /// Adds the given annotation to the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  static Future<bool?> addAnnotation(dynamic annotation) async =>
      NutrientFlutterPlatform.instance.addAnnotation(annotation);

  /// Removes the given annotation from the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  static Future<bool?> removeAnnotation(dynamic annotation) async =>
      NutrientFlutterPlatform.instance.removeAnnotation(annotation);

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  static Future<dynamic> getAnnotations(int pageIndex, String type) async =>
      NutrientFlutterPlatform.instance
          .getAnnotations(pageIndex, annotationTypeFromString(type));

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  @Deprecated('Use getAllUnsavedAnnotationModels instead')
  static Future<dynamic> getAllUnsavedAnnotations() async =>
      NutrientFlutterPlatform.instance.getAllUnsavedAnnotations();

  /// Processes annotations of the given type with the provided processing
  /// mode and stores the PDF at the given destination path.
  static Future<bool?> processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  ) async =>
      NutrientFlutterPlatform.instance
          .processAnnotations(type, processingMode, destinationPath);

  /// Imports annotations from the XFDF file at the given path.
  static Future<bool?> importXfdf(String xfdfPath) async =>
      NutrientFlutterPlatform.instance.importXfdf(xfdfPath);

  /// Exports annotations to the XFDF file at the given path.
  static Future<bool?> exportXfdf(String xfdfPath) async =>
      NutrientFlutterPlatform.instance.exportXfdf(xfdfPath);

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  static Future<bool?> save() async => NutrientFlutterPlatform.instance.save();

  /// Sets a delay for synchronizing local changes to the Instant Server (Nutrient Document Engine).
  /// [delay] is the delay in milliseconds.
  static Future<bool?> setDelayForSyncingLocalChanges(double delay) async =>
      NutrientFlutterPlatform.instance.setDelayForSyncingLocalChanges(delay);

  /// Enable or disable listening to Instant Server (Nutrient Document Engine) changes.
  static Future<bool?> setListenToServerChanges(bool listen) async =>
      NutrientFlutterPlatform.instance.setListenToServerChanges(listen);

  /// Manually triggers synchronization.
  static Future<bool?> syncAnnotations() async =>
      NutrientFlutterPlatform.instance.syncAnnotations();

  /// Checks the external storage permission for writing on Android only.
  static Future<bool?> checkAndroidWriteExternalStoragePermission() =>
      NutrientFlutterPlatform.instance
          .checkAndroidWriteExternalStoragePermission();

  /// Requests the external storage permission for writing on Android only.
  static Future<AndroidPermissionStatus>
      requestAndroidWriteExternalStoragePermission() async =>
          NutrientFlutterPlatform.instance
              .requestAndroidWriteExternalStoragePermission();

  /// Opens the Android settings.
  static Future<void> openAndroidSettings() async =>
      NutrientFlutterPlatform.instance.openAndroidSettings();

  static Future<bool?> setAnnotationPresetConfigurations(
          Map<String, dynamic> configurations) async =>
      NutrientFlutterPlatform.instance
          .setAnnotationPresetConfigurations(configurations);

  static Future<String?> generatePdfFromHtmlString(
          String html, String outPutFile, [dynamic options]) async =>
      NutrientFlutterPlatform.instance
          .generatePdfFromHtmlString(html, outPutFile);

  static Future<String?> generatePdfFromHtmlUri(Uri htmlUri, String outPutFile,
          [dynamic options]) async =>
      NutrientFlutterPlatform.instance
          .generatePdfFromHtmlUri(htmlUri, outPutFile);

  static Future<String?> generatePdf(List<NewPage> pages, String outPutFile,
          [dynamic options]) async =>
      NutrientFlutterPlatform.instance.generatePdf(pages, outPutFile);

  /// Get the annotation author name.
  static String authorName = NutrientFlutterPlatform.instance.authorName;

  /// Get default Web main toolbar items.
  /// - Returns a list of default [NutrientWebToolbarItem] items when called on web.
  /// - Returns an empty list on other platforms.
  static List<NutrientWebToolbarItem> get defaultWebToolbarItems =>
      NutrientFlutterPlatform.instance.defaultWebToolbarItems;

  /// Path to the temporary directory on the device that is not backed up and is
  /// suitable for storing caches of downloaded files.
  ///
  /// Files in this directory may be cleared at any time. This does *not* return
  /// a new temporary directory. Instead, the caller is responsible for creating
  /// (and cleaning up) files or directories within this directory. This
  /// directory is scoped to the calling application.
  ///
  /// On iOS, this uses the `NSCachesDirectory` API.
  ///
  /// On Android, this uses the `getCacheDir` API on the context.
  ///
  /// Throws a `MissingPlatformDirectoryException` if the system is unable to
  /// provide the directory.
  static Future<Directory> getTemporaryDirectory() =>
      NutrientFlutterPlatform.instance.getTemporaryDirectory();

  static Future<void> enableAnalytics(bool enabled) async =>
      NutrientFlutterPlatform.instance.enableAnalytics(enabled);

  /// Sets the author name for annotations.
  static Future<void> setDefaultAuthorName(String authorName) async =>
      NutrientFlutterPlatform.instance.setDefaultAuthorName(authorName);

  /// Gets the author name for annotations.
  /// Returns the author name for annotations.
  /// Returns an empty string if the author name is not set.
  static Future<String> getAuthorName() async =>
      NutrientFlutterPlatform.instance.getAuthorName();

  /// onPause callback for FlutterPdfActivity. Only available on Android.
  static set flutterPdfActivityOnPause(
      VoidCallback? flutterPdfActivityOnPause) {
    NutrientFlutterPlatform.instance.flutterPdfActivityOnPause =
        flutterPdfActivityOnPause;
  }

  /// called when a PdfFragment is added. Only available on Android.
  static set flutterPdfFragmentAdded(VoidCallback? flutterPdfFragmentAdded) {
    NutrientFlutterPlatform.instance.flutterPdfFragmentAdded =
        flutterPdfFragmentAdded;
  }

  /// Called when a document is loaded.
  static set pspdfkitDocumentLoaded(
      PspdfkitDocumentLoadedCallback? pspdfkitDocumentLoaded) {
    NutrientFlutterPlatform.instance.flutterPdfDocumentLoaded =
        pspdfkitDocumentLoaded;
  }

  /// ViewControllerWillDismiss callback for PDFViewController. Only available on iOS.
  static set pdfViewControllerWillDismiss(
      VoidCallback? pdfViewControllerWillDismiss) {
    NutrientFlutterPlatform.instance.pdfViewControllerWillDismiss =
        pdfViewControllerWillDismiss;
  }

  /// ViewControllerDidDismiss callback for PDFViewController. Only available on iOS.
  static set pdfViewControllerDidDismiss(VoidCallback? callback) {
    NutrientFlutterPlatform.instance.pdfViewControllerDidDismiss = callback;
  }

  /// Called when instant synchronization starts.
  static set instantSyncStarted(InstantSyncStartedCallback? callback) {
    NutrientFlutterPlatform.instance.instantSyncStarted = callback;
  }

  /// Called when instant synchronization ends.
  static set instantSyncFinished(InstantSyncFinishedCallback? callback) {
    NutrientFlutterPlatform.instance.instantSyncFinished = callback;
  }

  /// Called when instant synchronization fails.
  static set instantSyncFailed(InstantSyncFailedCallback? callback) {
    NutrientFlutterPlatform.instance.instantSyncFailed = callback;
  }

  /// Called when instant authentication is done.
  static set instantAuthenticationFinished(
      InstantAuthenticationFinishedCallback? callback) {
    NutrientFlutterPlatform.instance.instantAuthenticationFinished = callback;
  }

  /// Called when instant authentication fails.
  static set instantAuthenticationFailed(
      InstantAuthenticationFailedCallback? callback) {
    NutrientFlutterPlatform.instance.instantAuthenticationFailed = callback;
  }

  /// Called when instant document download is done.Only available on iOS.
  static set instantDownloadFinished(
      InstantDownloadFinishedCallback? callback) {
    NutrientFlutterPlatform.instance.instantDownloadFinished = callback;
  }

  /// Called when instant document download fails. Only available on iOS.
  static set instantDownloadFailed(InstantDownloadFailedCallback? callback) {
    NutrientFlutterPlatform.instance.instantDownloadFailed = callback;
  }

  static set analyticsEventsListener(AnalyticsEventsListener? listener) {
    NutrientFlutterPlatform.instance.analyticsEventsListener = listener;
  }
}
