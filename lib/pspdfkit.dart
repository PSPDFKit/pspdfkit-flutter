///
///  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
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
import 'package:flutter/material.dart';

part 'src/processor/pdf_image_page.dart';

part 'android_permission_status.dart';

part 'configuration_options.dart';

part 'src/processor/new_page.dart';

part 'src/processor/page_pattern.dart';

part 'src/processor/page_position.dart';

part 'src/processor/page_z_order.dart';

part 'src/processor/pdf_page.dart';

part 'src/processor/page_size.dart';

part 'pspdfkit_processor.dart';

/// PSPDFKit plugin to load PDF and image documents on both platform iOS and Android.
class Pspdfkit {
  static MethodChannel? _privateChannel;

  static MethodChannel get _channel {
    if (_privateChannel == null) {
      _privateChannel = const MethodChannel('com.pspdfkit.global');
      _privateChannel!.setMethodCallHandler(_platformCallHandler);
    }
    return _privateChannel!;
  }

  /// Gets the PSPDFKit framework version.
  static Future<String?> get frameworkVersion async =>
      _channel.invokeMethod('frameworkVersion');

  /// Sets the license key.
  static Future<void> setLicenseKey(String licenseKey) async =>
      await _channel.invokeMethod(
          'setLicenseKey', <String, String>{'licenseKey': licenseKey});

  /// Sets the license keys for both platforms.
  static Future<void> setLicenseKeys(
          String? androidLicenseKey, String? iOSLicenseKey) async =>
      await _channel.invokeMethod('setLicenseKeys', <String, String?>{
        'androidLicenseKey': androidLicenseKey,
        'iOSLicenseKey': iOSLicenseKey,
      });

  /// Loads a [document] with a supported format using a given [configuration].
  static Future<bool?> present(String document,
          [dynamic configuration]) async =>
      await _channel.invokeMethod('present', <String, dynamic>{
        'document': document,
        'configuration': configuration
      });

  /// Loads an Instant document from a server [serverUrl] with using a[jwt] in a native Instant PDFViewer.
  ///
  /// The [serverUrl] is the URL of the server that hosts the Instant document.
  /// The [jwt] is the JSON Web Token used to authenticate the user. It also contains the document ID.
  /// The [configuration] is a map of PDFViewer configurations.
  /// Returns true if the document was successfully opened.
  /// Returns false if the document could not be opened.
  ///
  static Future<bool?> presentInstant(String serverUrl, String jwt,
          [dynamic configuration]) async =>
      await _channel.invokeMethod('presentInstant', <String, dynamic>{
        'serverUrl': serverUrl,
        'jwt': jwt,
        'configuration': configuration
      });

  /// Sets the value of a form field by specifying its fully qualified field name.
  static Future<bool?> setFormFieldValue(
          String value, String fullyQualifiedName) async =>
      _channel.invokeMethod('setFormFieldValue', <String, dynamic>{
        'value': value,
        'fullyQualifiedName': fullyQualifiedName
      });

  /// Gets the form field value by specifying its fully qualified name.
  static Future<String?> getFormFieldValue(String fullyQualifiedName) async =>
      _channel.invokeMethod('getFormFieldValue',
          <String, dynamic>{'fullyQualifiedName': fullyQualifiedName});

  /// Applies Instant document JSON to the presented document.
  static Future<bool?> applyInstantJson(String annotationsJson) async =>
      _channel.invokeMethod('applyInstantJson',
          <String, String>{'annotationsJson': annotationsJson});

  /// Exports Instant document JSON from the presented document.
  static Future<String?> exportInstantJson() async =>
      _channel.invokeMethod('exportInstantJson');

  /// Adds the given annotation to the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  static Future<bool?> addAnnotation(dynamic jsonAnnotation) async =>
      _channel.invokeMethod(
          'addAnnotation', <String, dynamic>{'jsonAnnotation': jsonAnnotation});

  /// Removes the given annotation from the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  static Future<bool?> removeAnnotation(dynamic jsonAnnotation) async =>
      _channel.invokeMethod('removeAnnotation',
          <String, dynamic>{'jsonAnnotation': jsonAnnotation});

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  static Future<dynamic> getAnnotations(int pageIndex, String type) async =>
      _channel.invokeMethod<dynamic>('getAnnotations',
          <String, dynamic>{'pageIndex': pageIndex, 'type': type});

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  static Future<dynamic> getAllUnsavedAnnotations() async =>
      _channel.invokeMethod<dynamic>('getAllUnsavedAnnotations');

  /// Processes annotations of the given type with the provided processing
  /// mode and stores the PDF at the given destination path.
  static Future<bool?> processAnnotations(
          String type, String processingMode, String destinationPath) async =>
      _channel.invokeMethod('processAnnotations', <String, String>{
        'type': type,
        'processingMode': processingMode,
        'destinationPath': destinationPath
      });

  /// Imports annotations from the XFDF file at the given path.
  static Future<bool?> importXfdf(String xfdfPath) async => _channel
      .invokeMethod('importXfdf', <String, String>{'xfdfPath': xfdfPath});

  /// Exports annotations to the XFDF file at the given path.
  static Future<bool?> exportXfdf(String xfdfPath) async => _channel
      .invokeMethod('exportXfdf', <String, String>{'xfdfPath': xfdfPath});

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  static Future<bool?> save() async => _channel.invokeMethod('save');

  /// Sets a delay for synchronising local changes to the Instant server.
  /// [delay] is the delay in milliseconds.
  static Future<bool?> setDelayForSyncingLocalChanges(double delay) async =>
      _channel.invokeMethod(
          'setDelayForSyncingLocalChanges', <String, dynamic>{'delay': delay});

  /// Enable or disable listening to Instant server changes.
  static Future<bool?> setListenToServerChanges(bool listen) async =>
      _channel.invokeMethod(
          'setListenToServerChanges', <String, dynamic>{'listen': listen});

  /// Manually triggers synchronisation.
  static Future<bool?> syncAnnotations() async =>
      _channel.invokeMethod('syncAnnotations');

  /// Checks the external storage permission for writing on Android only.
  static Future<bool?> checkAndroidWriteExternalStoragePermission() async {
    return _channel.invokeMethod(
        'checkPermission', {'permission': 'WRITE_EXTERNAL_STORAGE'});
  }

  /// Requests the external storage permission for writing on Android only.
  static Future<AndroidPermissionStatus>
      requestAndroidWriteExternalStoragePermission() async {
    final dynamic status = await _channel.invokeMethod<dynamic>(
        'requestPermission', {'permission': 'WRITE_EXTERNAL_STORAGE'});

    return status is int
        ? _intToAndroidPermissionStatus(status)
        : status is bool
            ? (status
                ? AndroidPermissionStatus.authorized
                : AndroidPermissionStatus.denied)
            : AndroidPermissionStatus.notDetermined;
  }

  /// Opens the Android settings.
  static Future<void> openAndroidSettings() async =>
      _channel.invokeMethod('openSettings');

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
  static Future<Directory> getTemporaryDirectory() async {
    final String? path =
        await _channel.invokeMethod<String>('getTemporaryDirectory');
    if (path == null) {
      throw MissingPlatformDirectoryException(
          'Unable to get temporary directory');
    }
    return Directory(path);
  }

  /// onPAuse callback for FlutterPdfActivity
  static void Function()? flutterPdfActivityOnPause;

  /// ViewControllerWillDismiss callback for PDFViewController
  static void Function()? pdfViewControllerWillDismiss;

  /// ViewControllerDidDismiss callback for PDFViewController
  static void Function()? pdfViewControllerDidDismiss;

  /// Called when instant synchronization starts.
  static void Function(String? documentId)? instantSyncStarted;

  /// Called when instant synchronization ends.
  static void Function(String? documentId)? instantSyncFinished;

  /// Called when instant synchronization fails.
  static void Function(String? documentId, String? error)? instantSyncFailed;

  /// Called when instant authentication is done.
  static void Function(String documentId, String? validJWT)?
      instantAuthenticationFinished;

  /// Called when instant authentication fails.
  static void Function(String? documentId, String? error)?
      instantAuthenticationFailed;

  /// Only available on iOS.
  /// Called when instant document download is done.
  static void Function(String? documentId)? instantDownloadFinished;

  /// Only available on iOS.
  /// Called when instant document download fails.
  static void Function(String? documentId, String? error)?
      instantDownloadFailed;

  static Future<void> _platformCallHandler(MethodCall call) {
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
