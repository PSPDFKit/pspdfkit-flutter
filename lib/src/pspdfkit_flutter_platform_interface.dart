///
///  Copyright © 2018-2023 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'pspdfkit_flutter_method_channel.dart';

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

typedef PspdfkitDocumentLoadedCallback = void Function(String documentId);

abstract class PspdfkitFlutterPlatform extends PlatformInterface {
  /// Constructs a PspdfkitFlutterPlatform.
  PspdfkitFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static PspdfkitFlutterPlatform _instance = MethodChannelPspdfkitFlutter();

  /// The default instance of [PspdfkitFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelPspdfkitFlutter].
  static PspdfkitFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PspdfkitFlutterPlatform] when
  /// they register themselves.
  static set instance(PspdfkitFlutterPlatform instance) {
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
  Future<bool?> present(String document,
      {dynamic configuration,
      @Deprecated('Use setMeasurementConfiguration instead.')
      MeasurementScale? measurementScale,
      @Deprecated('Use setMeasurementConfiguration instead.')
      MeasurementPrecision? measurementPrecision});

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

  /// Adds the given annotation to the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  Future<bool?> addAnnotation(dynamic jsonAnnotation);

  /// Removes the given annotation from the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  Future<bool?> removeAnnotation(dynamic jsonAnnotation);

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  Future<dynamic> getAnnotations(int pageIndex, String type);

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  Future<dynamic> getAllUnsavedAnnotations();

  /// Processes annotations of the given type with the provided processing
  /// mode and stores the PDF at the given destination path.
  Future<bool?> processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  );

  /// Imports annotations from the XFDF file at the given path.
  Future<bool?> importXfdf(String xfdfPath);

  /// Exports annotations to the XFDF file at the given path.
  Future<bool?> exportXfdf(String xfdfPath);

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  Future<bool?> save();

  /// Sets a delay for synchronising local changes to the Instant server.
  /// [delay] is the delay in milliseconds.
  Future<bool?> setDelayForSyncingLocalChanges(double delay);

  /// Enable or disable listening to Instant server changes.
  Future<bool?> setListenToServerChanges(bool listen);

  /// Manually triggers synchronisation.
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

  /// onPAuse callback for FlutterPdfActivity
  VoidCallback? flutterPdfActivityOnPause;

  VoidCallback? flutterPdfFragmentAdded;

  PspdfkitDocumentLoadedCallback? flutterPdfDocumentLoaded;

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

  /// Gets the annotation author name.
  String get authorName;

  /// Gets the default main toolbar [PspdfkitWebToolbarItem]s on Web.
  /// Returns an empty list when called on other platforms.
  List<PspdfkitWebToolbarItem> get defaultWebToolbarItems;
}
