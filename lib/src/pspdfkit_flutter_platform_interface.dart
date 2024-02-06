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
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

import 'pspdfkit_flutter_method_channel.dart';

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
  Future<void> setLicenseKey(String licenseKey);

  /// Sets the license keys for both platforms.
  /// The [androidLicenseKey] is the license key for Android.
  /// The [iOSLicenseKey] is the license key for iOS.
  /// The [webLicenseKey] is the license key for Web.
  Future<void> setLicenseKeys(
      String? androidLicenseKey, String? iOSLicenseKey, String? webLicenseKey);

  /// Loads a [document] with a supported format using a given [configuration].
  Future<bool?> present(String document,
      {dynamic configuration,
      MeasurementScale? measurementScale,
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
      String type, String processingMode, String destinationPath);

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

  /// Sets the measurement scale of the document.
  /// The scale is used to convert between real world measurements and points.
  /// The default scale is 1 inch = 1 inch.
  /// @param scale The scale to be used for the document.
  /// @return True if the scale was set successfully, false otherwise.
  Future<bool?> setMeasurementScale(MeasurementScale scale);

  /// Sets the measurement precision of the document.
  /// The precision is used to round the measurement values.
  /// The default precision is 2 decimal places.
  /// @param precision The precision to be used for the document.
  /// @return True if the precision was set successfully, false otherwise.
  Future<bool?> setMeasurementPrecision(MeasurementPrecision precision);

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
  void Function()? flutterPdfActivityOnPause;

  /// ViewControllerWillDismiss callback for PDFViewController
  void Function()? pdfViewControllerWillDismiss;

  /// ViewControllerDidDismiss callback for PDFViewController
  void Function()? pdfViewControllerDidDismiss;

  /// Called when instant synchronization starts.
  void Function(String? documentId)? instantSyncStarted;

  /// Called when instant synchronization ends.
  void Function(String? documentId)? instantSyncFinished;

  /// Called when instant synchronization fails.
  void Function(String? documentId, String? error)? instantSyncFailed;

  /// Called when instant authentication is done.
  void Function(String documentId, String? validJWT)?
      instantAuthenticationFinished;

  /// Called when instant authentication fails.
  void Function(String? documentId, String? error)? instantAuthenticationFailed;

  /// Only available on iOS.
  /// Called when instant document download is done.
  void Function(String? documentId)? instantDownloadFinished;

  /// Only available on iOS.
  /// Called when instant document download fails.
  void Function(String? documentId, String? error)? instantDownloadFailed;

  /// Gets the annotation author name.
  String get authorName;

  /// Gets the default main toolbar [PspdfkitWebToolbarItem]s on Web.
  /// Returns an empty list when called on other platforms.
  List<PspdfkitWebToolbarItem> get defaultWebToolbarItems;

  static AndroidPermissionStatus _intToAndroidPermissionStatus(int status) {
    switch (status) {
      case 0:
        return AndroidPermissionStatus.notDetermined;
      case 1:
        return AndroidPermissionStatus.denied;
      case 2:
        return AndroidPermissionStatus.authorized;
      case 3:
        return AndroidPermissionStatus.deniedNeverAsk;
      default:
        return AndroidPermissionStatus.notDetermined;
    }
  }

  Future<void> _platformCallHandler(MethodCall call) {
    try {
      switch (call.method) {
        case 'flutterPdfActivityOnPause':
          flutterPdfActivityOnPause?.call();
          break;
        case 'pdfViewControllerWillDismiss':
          pdfViewControllerWillDismiss?.call();
          break;
        case 'pdfViewControllerDidDismiss':
          pdfViewControllerDidDismiss?.call();
          break;
        case 'pspdfkitInstantSyncStarted':
          instantSyncStarted?.call(call.arguments as String);
          break;
        case 'pspdfkitInstantSyncFinished':
          instantSyncFinished?.call(call.arguments as String);
          break;
        case 'pspdfkitInstantSyncFailed':
          {
            final Map<dynamic, dynamic> map =
                call.arguments as Map<dynamic, dynamic>;
            instantSyncFailed?.call(
                map['documentId'] as String, map['error'] as String);
            break;
          }
        case 'pspdfkitInstantAuthenticationFinished':
          {
            final Map<dynamic, dynamic> map =
                call.arguments as Map<dynamic, dynamic>;
            instantAuthenticationFinished?.call(
                map['documentId'] as String, map['jwt'] as String);
            break;
          }
        case 'pspdfkitInstantAuthenticationFailed':
          {
            final Map<dynamic, dynamic> arguments =
                call.arguments as Map<dynamic, dynamic>;
            instantAuthenticationFailed?.call(arguments['documentId'] as String,
                arguments['error'] as String);
            break;
          }
        case 'pspdfkitInstantDownloadFinished':
          instantDownloadFinished?.call(call.arguments as String);
          break;
        case 'pspdfkitInstantDownloadFailed':
          {
            final Map<dynamic, dynamic> arguments =
                call.arguments as Map<dynamic, dynamic>;
            instantDownloadFailed?.call(arguments['documentId'] as String,
                arguments['error'] as String);
            break;
          }
        default:
          if (kDebugMode) {
            print('Unknown method ${call.method} ');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return Future.value();
  }
}
