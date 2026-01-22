///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
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

/// Nutrient plugin to load PDF and image documents on both platform iOS and Android.
class Nutrient {
  /// Gets the Nutrient plugin version.
  static Future<String?> get frameworkVersion =>
      NutrientFlutterPlatform.instance.getFrameworkVersion();

  static Future<void> initialize({
    String? androidLicenseKey,
    String? iosLicenseKey,
    String? webLicenseKey,
  }) async {
    await NutrientFlutterPlatform.instance
        .setLicenseKeys(androidLicenseKey, iosLicenseKey, webLicenseKey);
  }

  /// Loads a [document] with a supported format using a given [configuration].
  static Future<bool?> present(String document,
          {dynamic configuration}) async =>
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
  static Future<bool?> addAnnotation(Annotation annotation) async =>
      NutrientFlutterPlatform.instance.addAnnotation(annotation);

  /// Removes the given annotation from the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  static Future<bool?> removeAnnotation(Annotation annotation) async =>
      NutrientFlutterPlatform.instance.removeAnnotation(annotation);

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  static Future<List<Annotation>> getAnnotations(
          int pageIndex, String type) async =>
      NutrientFlutterPlatform.instance
          .getAnnotations(pageIndex, annotationTypeFromString(type));

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

  /// Called when a document is loaded. This is only triggered in present mode.
  /// The [documentId] is the ID of the document that was loaded.
  static set onDocumentLoaded(
      NutrientDocumentLoadedCallback? pspdfkitDocumentLoaded) {
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

  // ============================
  // Headless Document API
  // ============================

  /// Opens a PDF document without displaying a viewer (headless mode).
  ///
  /// This allows programmatic access to the document for operations like:
  /// - Reading and modifying annotations
  /// - Processing annotations (flatten, embed, remove)
  /// - Copying annotations between documents
  /// - Exporting/importing XFDF
  /// - Form field manipulation
  ///
  /// The returned [PdfDocument] must be closed when no longer needed by
  /// calling [PdfDocument.close] to release native resources.
  ///
  /// **Example - Basic usage:**
  /// ```dart
  /// final document = await Nutrient.openDocument('/path/to/document.pdf');
  /// try {
  ///   final annotations = await document.getAnnotations(0, AnnotationType.all);
  ///   await document.processAnnotations(
  ///     AnnotationType.all,
  ///     AnnotationProcessingMode.flatten,
  ///     '/path/to/output.pdf',
  ///   );
  /// } finally {
  ///   await document.close();
  /// }
  /// ```
  ///
  /// **Example - Copy annotations between documents:**
  /// This is useful for scenarios like removing watermarks while preserving annotations.
  /// ```dart
  /// final sourceDoc = await Nutrient.openDocument('/path/to/watermarked.pdf');
  /// final targetDoc = await Nutrient.openDocument('/path/to/clean.pdf');
  ///
  /// try {
  ///   // Export annotations from source as XFDF
  ///   final tempXfdfPath = '${(await Nutrient.getTemporaryDirectory()).path}/temp.xfdf';
  ///   await sourceDoc.exportXfdf(tempXfdfPath);
  ///
  ///   // Import annotations to target
  ///   final xfdfContent = await File(tempXfdfPath).readAsString();
  ///   await targetDoc.importXfdf(xfdfContent);
  ///
  ///   // Save target document
  ///   await targetDoc.save();
  /// } finally {
  ///   await sourceDoc.close();
  ///   await targetDoc.close();
  /// }
  /// ```
  ///
  /// **Example - Password-protected document:**
  /// ```dart
  /// final document = await Nutrient.openDocument(
  ///   '/path/to/encrypted.pdf',
  ///   password: 'secret',
  /// );
  /// ```
  ///
  /// @param documentPath Path to the PDF document (file path or content:// URI)
  /// @param password Optional password for encrypted documents
  /// @return A [PdfDocument] instance for programmatic access
  /// @throws Exception if the document cannot be opened
  static Future<PdfDocument> openDocument(
    String documentPath, {
    String? password,
  }) async {
    return NutrientFlutterPlatform.instance.openDocument(
      documentPath,
      password: password,
    );
  }
}
