///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Conditional import: use web implementation on web, native on other platforms
import 'package:nutrient_flutter/src/nutrient_flutter_api_impl.dart'
    if (dart.library.js_interop) 'package:nutrient_flutter/src/nutrient_flutter_web.dart'
    as platform_impl;

typedef InstantSyncStartedCallback = void Function(String? documentId);
typedef InstantSyncFinishedCallback = void Function(String? documentId);
typedef InstantSyncFailedCallback = void Function(
    String? documentId, String? error);
typedef InstantAuthenticationFinishedCallback = void Function(
    String documentId, String? validJWT);
typedef InstantAuthenticationFailedCallback = void Function(
    String? documentId, String? error);
typedef InstantDownloadFinishedCallback = void Function(String? documentId);
typedef InstantDownloadFailedCallback = void Function(
    String? documentId, String? error);

@Deprecated(
    'Use NutrientDocumentLoadedCallback instead. This will be removed in a future version.')
typedef PspdfkitDocumentLoadedCallback = void Function(String documentId);

/// Callback for when a document is loaded in the Nutrient plugin.
typedef NutrientDocumentLoadedCallback = void Function(String documentId);

typedef AnalyticsEventsListener = void Function(
    String event, Map<String, dynamic> attributes);

abstract class NutrientFlutterPlatform extends PlatformInterface {
  /// Constructs a NutrientFlutterPlatform.
  NutrientFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static NutrientFlutterPlatform _instance =
      platform_impl.createPlatformInstance();

  /// The default instance of [NutrientFlutterPlatform] to use.
  ///
  /// Defaults to [NutrientFlutterWeb] on web, [NutrientFlutterApiImpl] on native platforms.
  static NutrientFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NutrientFlutterPlatform] when
  /// they register themselves.
  static set instance(NutrientFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Gets the PSPDFKit framework version.
  Future<String?> getFrameworkVersion();

  /// Sets the license key.
  Future<void> setLicenseKey(String? licenseKey);

  /// Sets the license keys for both platforms.
  /// The [androidLicenseKey] is the license key for Android.
  /// The [iOSLicenseKey] is the license key for iOS.
  /// The [webLicenseKey] is the license key for Web.
  Future<void> setLicenseKeys(
      String? androidLicenseKey, String? iOSLicenseKey, String? webLicenseKey);

  /// Loads a [document] with a supported format using a given [configuration].
  Future<bool?> present(String document, {dynamic configuration});

  /// Loads an Instant document from a server [serverUrl] with using a[jwt] in a native Instant PDFViewer.
  ///
  /// The [serverUrl] is the URL of the server that hosts the Instant document.
  /// The [jwt] is the JSON Web Token used to authenticate the user. It also contains the document ID.
  /// The [configuration] is a map of PDFViewer configurations.
  /// Returns true if the document was successfully opened.
  /// Returns false if the document could not be opened.
  ///
  Future<bool?> presentInstant(String serverUrl, String jwt,
      [dynamic configuration]);

  /// Sets the value of a form field by specifying its fully qualified field name.
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName);

  /// Gets the form field value by specifying its fully qualified name.
  Future<String?> getFormFieldValue(String fullyQualifiedName);

  /// Applies Instant document JSON to the presented document.
  Future<bool?> applyInstantJson(String annotationsJson);

  /// Exports Instant document JSON from the presented document.
  Future<String?> exportInstantJson();

  /// Adds an annotation to the presented document.
  ///
  /// This method accepts various types of input:
  /// - An [Annotation] object (will be converted to JSON using toJson())
  /// - A JSON string representing an annotation
  /// - A [Map] representing an annotation (will be converted to JSON)
  ///
  /// Returns true if the annotation was successfully added.
  Future<bool?> addAnnotation(dynamic annotation);

  /// Removes an annotation from the presented document.
  ///
  /// This method accepts various types of input:
  /// - An [Annotation] object (will be converted to JSON using toJson())
  /// - A JSON string representing an annotation
  /// - A [Map] representing an annotation (will be converted to JSON)
  ///
  /// Returns true if the annotation was successfully removed.
  Future<bool?> removeAnnotation(dynamic annotation);

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  Future<dynamic> getAnnotationsAsJSON(int pageIndex, String type);

  /// Returns a list of annotation models for all the annotations of the given `type` on the given `pageIndex`.
  Future<List<Annotation>> getAnnotations(int pageIndex, AnnotationType type);

  /// Updates the given annotation in the presented document.
  Future<bool?> updateAnnotation(Annotation annotation);

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  @Deprecated('Use getUnsavedAnnotations instead')
  Future<dynamic> getAllUnsavedAnnotations();

  /// Returns a list of annotation models for all the unsaved annotations in the presented document.
  Future<List<Annotation>> getUnsavedAnnotations();

  /// Processes annotations of the given type with the provided processing
  /// mode and stores the PDF at the given destination path.
  Future<bool?> processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  );

  /// Imports annotations from the XFDF file at the given path.
  Future<bool?> importXfdf(String xfdfString);

  /// Exports annotations to the XFDF file at the given path.
  Future<bool?> exportXfdf(String xfdfPath);

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  Future<bool?> save();

  /// Sets a delay for synchronizing local changes to the Instant server.
  /// [delay] is the delay in milliseconds.
  Future<bool?> setDelayForSyncingLocalChanges(double delay);

  /// Enable or disable listening to Instant server changes.
  Future<bool?> setListenToServerChanges(bool listen);

  /// Manually triggers synchronization.
  Future<bool?> syncAnnotations();

  /// Checks the external storage permission for writing on Android only.
  Future<bool?> checkAndroidWriteExternalStoragePermission();

  /// Requests the external storage permission for writing on Android only.
  Future<AndroidPermissionStatus>
      requestAndroidWriteExternalStoragePermission();

  /// Opens the Android settings.
  Future<void> openAndroidSettings();

  Future<bool?> setAnnotationPresetConfigurations(
      Map<String, dynamic> configurations);

  /// Generate a PDF from the given HTML string.
  /// [html]: The HTML string to be converted to PDF.
  /// [outPutFile]: The path to the output file.
  /// [options]: A map of options that can be used to customize the PDF generation.
  /// Returns the path to the generated PDF file or null if the input is invalid or if the PDF generation fails.
  Future<String?> generatePdfFromHtmlString(String html, String outPutFile,
      [Map<String, Object?>? options]);

  /// Generates a PDF from the given HTML URI.
  /// [htmlUri]: The URI to the HTML file to be converted to PDF. The URI can be for a local file or a remote file.
  /// [outPutFile]: The path to the output file.
  /// [options]: A map of options that can be used to customize the PDF generation.
  /// Returns the path to the generated PDF file or null if the input is invalid or if the PDF generation fails.
  Future<String?> generatePdfFromHtmlUri(Uri htmlUri, String outPutFile,
      [Map<String, Object?>? options]);

  /// Generates a PDF from the given list of pages.
  /// [pages]: The list of pages to be converted to PDF.
  /// [outPutFile]: The path to the output file.
  /// Returns the path to the generated PDF file or null if the input is invalid or if the PDF generation fails.
  /// The [options] parameter is a map of options that can be used to customize the PDF generation.
  Future<String?> generatePdf(List<NewPage> pages, String outPutFile,
      [Map<String, Object?>? options]);

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
  Future<Directory> getTemporaryDirectory();

  Future<void> enableAnalytics(bool enabled);

  Future<void> setDefaultAuthorName(String authorName);

  Future<String> getAuthorName();

  /// onPAuse callback for FlutterPdfActivity
  VoidCallback? flutterPdfActivityOnPause;

  VoidCallback? flutterPdfFragmentAdded;

  NutrientDocumentLoadedCallback? flutterPdfDocumentLoaded;

  /// ViewControllerWillDismiss callback for PDFViewController
  VoidCallback? pdfViewControllerWillDismiss;

  /// ViewControllerDidDismiss callback for PDFViewController
  VoidCallback? pdfViewControllerDidDismiss;

  /// Called when instant synchronization starts.
  InstantSyncStartedCallback? instantSyncStarted;

  /// Called when instant synchronization ends.
  InstantSyncFinishedCallback? instantSyncFinished;

  /// Called when instant synchronization fails.
  InstantSyncFailedCallback? instantSyncFailed;

  /// Called when instant authentication is done.
  InstantAuthenticationFinishedCallback? instantAuthenticationFinished;

  /// Called when instant authentication fails.
  InstantAuthenticationFailedCallback? instantAuthenticationFailed;

  /// Only available on iOS.
  /// Called when instant document download is done.
  InstantDownloadFinishedCallback? instantDownloadFinished;

  /// Only available on iOS.
  /// Called when instant document download fails.
  InstantDownloadFailedCallback? instantDownloadFailed;

  AnalyticsEventsListener? analyticsEventsListener;

  /// Gets the annotation author name.
  String get authorName;

  /// Gets the default main toolbar [NutrientWebToolbarItem]s on Web.
  /// Returns an empty list when called on other platforms.
  List<NutrientWebToolbarItem> get defaultWebToolbarItems;

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
  /// @param documentPath Path to the PDF document (file path or content:// URI)
  /// @param password Optional password for encrypted documents
  /// @return A [PdfDocument] instance for programmatic access
  /// @throws Exception if the document cannot be opened
  Future<PdfDocument> openDocument(
    String documentPath, {
    String? password,
  });
}
