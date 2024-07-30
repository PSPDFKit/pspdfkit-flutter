///
///  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
library pspdfkit;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:pspdfkit_flutter/src/pspdfkit_flutter_platform_interface.dart';
import 'pspdfkit.dart';

export 'src/pdf_configuration.dart';
export 'src/web/pspdfkit_web_configuration.dart';
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
export 'src/document/document_save_options.dart';
export 'src/document/document_permissions.dart';
export 'src/document/pdf_version.dart';
export 'src/forms/forms.dart';
export 'src/processor/annotation_processing_mode.dart';
export 'src/annotations/annotation_types.dart';

part 'src/android_permission_status.dart';

part 'src/pspdfkit_processor.dart';

part 'src/annotation_preset_configurations.dart';

part 'src/annotations/annotation_tools.dart';

/// PSPDFKit plugin to load PDF and image documents on both platform iOS and Android.
class Pspdfkit {
  /// Gets the PSPDFKit framework version.
  static Future<String?> get frameworkVersion =>
      PspdfkitFlutterPlatform.instance.getFrameworkVersion();

  /// Sets the license key.
  /// @param licenseKey The license key to be used.
  static Future<void> setLicenseKey(String? licenseKey) =>
      PspdfkitFlutterPlatform.instance.setLicenseKey(licenseKey);

  /// Sets the license keys for both platforms.
  static Future<void> setLicenseKeys(String? androidLicenseKey,
          String? iOSLicenseKey, String? webLicenseKey) async =>
      PspdfkitFlutterPlatform.instance
          .setLicenseKeys(androidLicenseKey, iOSLicenseKey, webLicenseKey);

  /// Loads a [document] with a supported format using a given [configuration].
  static Future<bool?> present(String document,
          {dynamic configuration,
          MeasurementScale? measurementScale,
          MeasurementPrecision? measurementPrecision}) async =>
      PspdfkitFlutterPlatform.instance
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
      PspdfkitFlutterPlatform.instance
          .presentInstant(serverUrl, jwt, configuration);

  /// Sets the value of a form field by specifying its fully qualified field name.
  static Future<bool?> setFormFieldValue(
          String value, String fullyQualifiedName) async =>
      PspdfkitFlutterPlatform.instance
          .setFormFieldValue(value, fullyQualifiedName);

  /// Gets the form field value by specifying its fully qualified name.
  static Future<String?> getFormFieldValue(String fullyQualifiedName) async =>
      PspdfkitFlutterPlatform.instance.getFormFieldValue(fullyQualifiedName);

  /// Applies Instant document JSON to the presented document.
  static Future<bool?> applyInstantJson(String annotationsJson) async =>
      PspdfkitFlutterPlatform.instance.applyInstantJson(annotationsJson);

  /// Exports Instant document JSON from the presented document.
  static Future<String?> exportInstantJson() async =>
      PspdfkitFlutterPlatform.instance.exportInstantJson();

  /// Adds the given annotation to the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  static Future<bool?> addAnnotation(dynamic jsonAnnotation) async =>
      PspdfkitFlutterPlatform.instance.addAnnotation(jsonAnnotation);

  /// Removes the given annotation from the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  static Future<bool?> removeAnnotation(dynamic jsonAnnotation) async =>
      PspdfkitFlutterPlatform.instance.removeAnnotation(jsonAnnotation);

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  static Future<dynamic> getAnnotations(int pageIndex, String type) async =>
      PspdfkitFlutterPlatform.instance.getAnnotations(pageIndex, type);

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  static Future<dynamic> getAllUnsavedAnnotations() async =>
      PspdfkitFlutterPlatform.instance.getAllUnsavedAnnotations();

  /// Processes annotations of the given type with the provided processing
  /// mode and stores the PDF at the given destination path.
  static Future<bool?> processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  ) async =>
      PspdfkitFlutterPlatform.instance
          .processAnnotations(type, processingMode, destinationPath);

  /// Imports annotations from the XFDF file at the given path.
  static Future<bool?> importXfdf(String xfdfPath) async =>
      PspdfkitFlutterPlatform.instance.importXfdf(xfdfPath);

  /// Exports annotations to the XFDF file at the given path.
  static Future<bool?> exportXfdf(String xfdfPath) async =>
      PspdfkitFlutterPlatform.instance.exportXfdf(xfdfPath);

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  static Future<bool?> save() async => PspdfkitFlutterPlatform.instance.save();

  /// Sets a delay for synchronizing local changes to the Instant Server (PSPDFKit Document Engine).
  /// [delay] is the delay in milliseconds.
  static Future<bool?> setDelayForSyncingLocalChanges(double delay) async =>
      PspdfkitFlutterPlatform.instance.setDelayForSyncingLocalChanges(delay);

  /// Enable or disable listening to Instant Server (PSPDFKit Document Engine) changes.
  static Future<bool?> setListenToServerChanges(bool listen) async =>
      PspdfkitFlutterPlatform.instance.setListenToServerChanges(listen);

  /// Manually triggers synchronization.
  static Future<bool?> syncAnnotations() async =>
      PspdfkitFlutterPlatform.instance.syncAnnotations();

  /// Checks the external storage permission for writing on Android only.
  static Future<bool?> checkAndroidWriteExternalStoragePermission() =>
      PspdfkitFlutterPlatform.instance
          .checkAndroidWriteExternalStoragePermission();

  /// Requests the external storage permission for writing on Android only.
  static Future<AndroidPermissionStatus>
      requestAndroidWriteExternalStoragePermission() async =>
          PspdfkitFlutterPlatform.instance
              .requestAndroidWriteExternalStoragePermission();

  /// Opens the Android settings.
  static Future<void> openAndroidSettings() async =>
      PspdfkitFlutterPlatform.instance.openAndroidSettings();

  static Future<bool?> setAnnotationPresetConfigurations(
          Map<String, dynamic> configurations) async =>
      PspdfkitFlutterPlatform.instance
          .setAnnotationPresetConfigurations(configurations);

  /// Get the annotation author name.
  static String authorName = PspdfkitFlutterPlatform.instance.authorName;

  /// Get default Web main toolbar items.
  /// - Returns a list of default [PspdfkitWebToolbarItem] items when called on web.
  /// - Returns an empty list on other platforms.
  static List<PspdfkitWebToolbarItem> get defaultWebToolbarItems =>
      PspdfkitFlutterPlatform.instance.defaultWebToolbarItems;

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
      PspdfkitFlutterPlatform.instance.getTemporaryDirectory();

  /// onPause callback for FlutterPdfActivity. Only available on Android.
  static set flutterPdfActivityOnPause(
      VoidCallback? flutterPdfActivityOnPause) {
    PspdfkitFlutterPlatform.instance.flutterPdfActivityOnPause =
        flutterPdfActivityOnPause;
  }

  /// called when a PdfFragment is added. Only available on Android.
  static set flutterPdfFragmentAdded(VoidCallback? flutterPdfFragmentAdded) {
    PspdfkitFlutterPlatform.instance.flutterPdfFragmentAdded =
        flutterPdfFragmentAdded;
  }

  /// Called when a document is loaded.
  static set pspdfkitDocumentLoaded(
      PspdfkitDocumentLoadedCallback? pspdfkitDocumentLoaded) {
    PspdfkitFlutterPlatform.instance.flutterPdfDocumentLoaded =
        pspdfkitDocumentLoaded;
  }

  /// ViewControllerWillDismiss callback for PDFViewController. Only available on iOS.
  static set pdfViewControllerWillDismiss(
      VoidCallback? pdfViewControllerWillDismiss) {
    PspdfkitFlutterPlatform.instance.pdfViewControllerWillDismiss =
        pdfViewControllerWillDismiss;
  }

  /// ViewControllerDidDismiss callback for PDFViewController. Only available on iOS.
  static set pdfViewControllerDidDismiss(VoidCallback? callback) {
    PspdfkitFlutterPlatform.instance.pdfViewControllerDidDismiss = callback;
  }

  /// Called when instant synchronization starts.
  static set instantSyncStarted(InstantSyncStartedCallback? callback) {
    PspdfkitFlutterPlatform.instance.instantSyncStarted = callback;
  }

  /// Called when instant synchronization ends.
  static set instantSyncFinished(InstantSyncFinishedCallback? callback) {
    PspdfkitFlutterPlatform.instance.instantSyncFinished = callback;
  }

  /// Called when instant synchronization fails.
  static set instantSyncFailed(InstantSyncFailedCallback? callback) {
    PspdfkitFlutterPlatform.instance.instantSyncFailed = callback;
  }

  /// Called when instant authentication is done.
  static set instantAuthenticationFinished(
      InstantAuthenticationFinishedCallback? callback) {
    PspdfkitFlutterPlatform.instance.instantAuthenticationFinished = callback;
  }

  /// Called when instant authentication fails.
  static set instantAuthenticationFailed(
      InstantAuthenticationFailedCallback? callback) {
    PspdfkitFlutterPlatform.instance.instantAuthenticationFailed = callback;
  }

  /// Called when instant document download is done.Only available on iOS.
  static set instantDownloadFinished(
      InstantDownloadFinishedCallback? callback) {
    PspdfkitFlutterPlatform.instance.instantDownloadFinished = callback;
  }

  /// Called when instant document download fails. Only available on iOS.
  static set instantDownloadFailed(InstantDownloadFailedCallback? callback) {
    PspdfkitFlutterPlatform.instance.instantDownloadFailed = callback;
  }
}

/// An exception thrown when a directory that should always be available on
/// the current platform cannot be obtained.
class MissingPlatformDirectoryException implements Exception {
  /// Creates a new exception
  MissingPlatformDirectoryException(this.message, {this.details});

  /// The explanation of the exception.
  final String message;

  /// Added details, if any.
  ///
  /// E.g., an error object from the platform implementation.
  final Object? details;

  @override
  String toString() {
    final String detailsAddition = details == null ? '' : ': $details';
    return 'MissingPlatformDirectoryException($message)$detailsAddition';
  }
}
