library pspdfkit;

import 'dart:async';

import 'package:flutter/services.dart';
import 'simple_permissions.dart';

part 'configuration_options.dart';

class Pspdfkit {
  static const MethodChannel _channel = const MethodChannel('pspdfkit');

  static Future<dynamic> get frameworkVersion =>
      _channel.invokeMethod('frameworkVersion');

  static Future<void> setLicenseKey(String licenseKey) =>
    _channel.invokeMethod('setLicenseKey', <String, dynamic>{'licenseKey': licenseKey});

  static Future<void> present(String document, [dynamic configuration]) =>
    _channel.invokeMethod(
        'present',
        <String, dynamic>{'document': document, 'configuration': configuration}
        );

  static Future<bool> checkWriteExternalStoragePermission() =>
    SimplePermissions.checkPermission(Permission.WriteExternalStorage);

  static Future<PermissionStatus> requestWriteExternalStoragePermission() =>
    SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    
  static Future<bool> openSettings() =>
    SimplePermissions.openSettings();
}
