///
///  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
library pspdfkit;

import 'dart:async';

import 'package:flutter/services.dart';

part 'android_permission_status.dart';
part 'configuration_options.dart';

/// PSPDFKit plugin to load PDF and image documents on both platform iOS and Android.
class Pspdfkit {
  static const MethodChannel _channel = const MethodChannel('pspdfkit');

  /// Gets the PSPDFKit framework version.
  static Future<dynamic> get frameworkVersion =>
      _channel.invokeMethod('frameworkVersion');

  /// Sets the license key.
  static Future<void> setLicenseKey(String licenseKey) =>
    _channel.invokeMethod('setLicenseKey', <String, dynamic>{'licenseKey': licenseKey});

  /// Loads a [document] with a supported format using a given [configuration].
  static Future<void> present(String document, [dynamic configuration]) =>
    _channel.invokeMethod(
        'present',
        <String, dynamic>{'document': document, 'configuration': configuration}
        );

  /// Checks the external storage permission for writing on Android only.
  static Future<bool> checkAndroidWriteExternalStoragePermission() async {
    final bool isGranted = await _channel.invokeMethod(
        "checkPermission", {"permission": "WRITE_EXTERNAL_STORAGE"});
    return isGranted;
  }

  /// Requests the external storage permission for writing on Android only.
  static Future<AndroidPermissionStatus> requestAndroidWriteExternalStoragePermission() async {
    final status = await _channel.invokeMethod(
        "requestPermission", {"permission": "WRITE_EXTERNAL_STORAGE"});

    return status is int
        ? _intToAndroidPermissionStatus(status)
        : status is bool
        ? (status ? AndroidPermissionStatus.authorized : AndroidPermissionStatus.denied)
        : AndroidPermissionStatus.notDetermined;
  }

  /// Opens the Android settings.
  static Future<bool> openAndroidSettings() async {
    final bool isOpen = await _channel.invokeMethod("openSettings");
    return isOpen;
  }

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
}
