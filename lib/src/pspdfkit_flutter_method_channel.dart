///
///  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
///
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'pspdfkit_flutter_platform_interface.dart';

/// An implementation of [PspdfkitFlutterPlatform] that uses method channels.
class MethodChannelPspdfkitFlutter extends PspdfkitFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  late final methodChannel = const MethodChannel('com.pspdfkit.global')
    ..setMethodCallHandler((call) => _platformCallHandler(call));

  /// Gets the PSPDFKit framework version.
  @override
  Future<String?> getFrameworkVersion() async =>
      methodChannel.invokeMethod('frameworkVersion');

  /// Sets the license key.
  @override
  Future<void> setLicenseKey(String? licenseKey) async =>
      await methodChannel.invokeMethod(
          'setLicenseKey', <String, String?>{'licenseKey': licenseKey});

  /// Sets the license keys for both platforms.
  @override
  Future<void> setLicenseKeys(String? androidLicenseKey, String? iOSLicenseKey,
          String? webLicenseKey) async =>
      await methodChannel.invokeMethod('setLicenseKeys', <String, String?>{
        'androidLicenseKey': androidLicenseKey,
        'iOSLicenseKey': iOSLicenseKey,
      });

  /// Loads a [document] with a supported format using a given [configuration].
  @override
  Future<bool?> present(String document,
      {dynamic configuration,
      MeasurementScale? measurementScale,
      MeasurementPrecision? measurementPrecision}) async {
    Map<String, dynamic> pdfConfiguration;

    if (configuration == null) {
      pdfConfiguration = <String, dynamic>{};
    } else if (configuration is PdfConfiguration) {
      pdfConfiguration = configuration.toMap();
    } else if (configuration is Map<String, dynamic>) {
      pdfConfiguration = configuration;
    } else {
      throw ArgumentError(
          'Configuration must be either a PdfConfiguration or a Map<String, dynamic>');
    }

    return await methodChannel.invokeMethod('present', <String, dynamic>{
      'document': document,
      'configuration': pdfConfiguration,
      'measurementScale': measurementScale?.toMap(),
      'measurementPrecision': measurementPrecision?.name,
    });
  }

  /// Loads an Instant document from a server [serverUrl] with using a[jwt] in a native Instant PDFViewer.
  ///
  /// The [serverUrl] is the URL of the server that hosts the Instant document.
  /// The [jwt] is the JSON Web Token used to authenticate the user. It also contains the document ID.
  /// The [configuration] is a map of PDFViewer configurations.
  /// Returns true if the document was successfully opened.
  /// Returns false if the document could not be opened.
  ///
  @override
  Future<bool?> presentInstant(String serverUrl, String jwt,
      [dynamic configuration]) async {
    Map<String, dynamic> pdfConfiguration;

    if (configuration == null) {
      pdfConfiguration = <String, dynamic>{};
    } else if (configuration is PdfConfiguration) {
      pdfConfiguration = configuration.toMap();
    } else if (configuration is Map<String, dynamic>) {
      pdfConfiguration = configuration;
    } else {
      throw ArgumentError(
          'Configuration must be either a PdfConfiguration or a Map<String, dynamic>');
    }

    return await methodChannel.invokeMethod('presentInstant', <String, dynamic>{
      'serverUrl': serverUrl,
      'jwt': jwt,
      'configuration': pdfConfiguration,
    });
  }

  /// Sets the value of a form field by specifying its fully qualified field name.
  @override
  Future<bool?> setFormFieldValue(
          String value, String fullyQualifiedName) async =>
      methodChannel.invokeMethod('setFormFieldValue', <String, dynamic>{
        'value': value,
        'fullyQualifiedName': fullyQualifiedName
      });

  /// Gets the form field value by specifying its fully qualified name.
  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) async =>
      methodChannel.invokeMethod('getFormFieldValue',
          <String, dynamic>{'fullyQualifiedName': fullyQualifiedName});

  /// Applies Instant document JSON to the presented document.
  @override
  Future<bool?> applyInstantJson(String annotationsJson) async =>
      methodChannel.invokeMethod('applyInstantJson',
          <String, String>{'annotationsJson': annotationsJson});

  /// Exports Instant document JSON from the presented document.
  @override
  Future<String?> exportInstantJson() async =>
      methodChannel.invokeMethod('exportInstantJson');

  /// Adds the given annotation to the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  @override
  Future<bool?> addAnnotation(dynamic jsonAnnotation) async =>
      methodChannel.invokeMethod(
          'addAnnotation', <String, dynamic>{'jsonAnnotation': jsonAnnotation});

  /// Removes the given annotation from the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  @override
  Future<bool?> removeAnnotation(dynamic jsonAnnotation) async =>
      methodChannel.invokeMethod('removeAnnotation',
          <String, dynamic>{'jsonAnnotation': jsonAnnotation});

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  @override
  Future<dynamic> getAnnotations(int pageIndex, String type) async =>
      methodChannel.invokeMethod<dynamic>('getAnnotations',
          <String, dynamic>{'pageIndex': pageIndex, 'type': type});

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  @override
  Future<dynamic> getAllUnsavedAnnotations() async =>
      methodChannel.invokeMethod<dynamic>('getAllUnsavedAnnotations');

  /// Processes annotations of the given type with the provided processing
  /// mode and stores the PDF at the given destination path.
  @override
  Future<bool?> processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  ) async =>
      methodChannel.invokeMethod('processAnnotations', <String, String>{
        'type': type.name,
        'processingMode': processingMode.name,
        'destinationPath': destinationPath
      });

  /// Imports annotations from the XFDF file at the given path.
  @override
  Future<bool?> importXfdf(String xfdfPath) async => methodChannel
      .invokeMethod('importXfdf', <String, String>{'xfdfPath': xfdfPath});

  /// Exports annotations to the XFDF file at the given path.
  @override
  Future<bool?> exportXfdf(String xfdfPath) async => methodChannel
      .invokeMethod('exportXfdf', <String, String>{'xfdfPath': xfdfPath});

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  @override
  Future<bool?> save() async => methodChannel.invokeMethod('save');

  /// Sets a delay for synchronizing local changes to the Instant server.
  /// [delay] is the delay in milliseconds.
  @override
  Future<bool?> setDelayForSyncingLocalChanges(double delay) async =>
      methodChannel.invokeMethod(
          'setDelayForSyncingLocalChanges', <String, dynamic>{'delay': delay});

  /// Enable or disable listening to Instant server changes.
  @override
  Future<bool?> setListenToServerChanges(bool listen) async =>
      methodChannel.invokeMethod(
          'setListenToServerChanges', <String, dynamic>{'listen': listen});

  /// Manually triggers synchronization.
  @override
  Future<bool?> syncAnnotations() async =>
      methodChannel.invokeMethod('syncAnnotations');

  /// Checks the external storage permission for writing on Android only.
  @override
  Future<bool?> checkAndroidWriteExternalStoragePermission() async {
    return methodChannel.invokeMethod(
        'checkPermission', {'permission': 'WRITE_EXTERNAL_STORAGE'});
  }

  /// Requests the external storage permission for writing on Android only.
  @override
  Future<AndroidPermissionStatus>
      requestAndroidWriteExternalStoragePermission() async {
    final dynamic status = await methodChannel.invokeMethod<dynamic>(
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
  @override
  Future<void> openAndroidSettings() async =>
      methodChannel.invokeMethod('openSettings');

  AndroidPermissionStatus _intToAndroidPermissionStatus(int status) {
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

  @override
  Future<bool?> setAnnotationPresetConfigurations(
      Map<String, dynamic> configurations) async {
    return methodChannel.invokeMethod('setAnnotationPresetConfigurations', {
      'annotationConfigurations': configurations,
    });
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
  @override
  Future<Directory> getTemporaryDirectory() async {
    final String? path =
        await methodChannel.invokeMethod<String>('getTemporaryDirectory');
    if (path == null) {
      throw MissingPlatformDirectoryException(
          'Unable to get temporary directory');
    }
    return Directory(path);
  }

  /// onPause callback for FlutterPdfActivity

  @override
  set flutterPdfActivityOnPause(VoidCallback? flutterPdfActivityOnPause);

  @override
  set flutterPdfFragmentAdded(VoidCallback? flutterPdfFragmentAdded);

  @override
  set flutterPdfDocumentLoaded(
      PspdfkitDocumentLoadedCallback? flutterPdfDocumentLoaded);

  /// ViewControllerWillDismiss callback for PDFViewController
  @override
  set pdfViewControllerWillDismiss(VoidCallback? pdfViewControllerWillDismiss);

  /// ViewControllerDidDismiss callback for PDFViewController
  @override
  set pdfViewControllerDidDismiss(VoidCallback? pdfViewControllerDidDismiss);

  /// Called when instant synchronization starts.
  @override
  set instantSyncStarted(InstantSyncStartedCallback? instantSyncStarted);

  /// Called when instant synchronization ends.
  @override
  set instantSyncFinished(InstantSyncFinishedCallback? instantSyncFinished);

  /// Called when instant synchronization fails.
  @override
  set instantSyncFailed(InstantSyncFailedCallback? instantSyncFailed);

  /// Called when instant authentication is done.
  @override
  set instantAuthenticationFinished(
      InstantAuthenticationFinishedCallback? instantAuthenticationFinished);

  /// Called when instant authentication fails.
  @override
  set instantAuthenticationFailed(
      InstantAuthenticationFailedCallback? instantAuthenticationFailed);

  /// Only available on iOS.
  /// Called when instant document download is done.
  @override
  set instantDownloadFinished(
      InstantDownloadFinishedCallback? instantDownloadFinished);

  /// Only available on iOS.
  /// Called when instant document download fails.
  @override
  set instantDownloadFailed(
      InstantDownloadFailedCallback? instantDownloadFailed);

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

  @override
  String get authorName => throw UnimplementedError();

  @override
  List<PspdfkitWebToolbarItem> get defaultWebToolbarItems => [];
}
