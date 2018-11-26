import 'dart:async';

import 'package:flutter/services.dart';
import 'package:simple_permissions/simple_permissions.dart';

class Pspdfkit {
  static const MethodChannel _channel = const MethodChannel('pspdfkit');

  static Future<dynamic> get frameworkVersion =>
      _channel.invokeMethod('frameworkVersion');

  static Future<void> present(String document) =>
    _channel.invokeMethod('present', <String, dynamic>{'document': document});

  static Future<bool> checkWriteExternalStoragePermission() =>
    SimplePermissions.checkPermission(Permission.WriteExternalStorage);

  static Future<PermissionStatus> requestWriteExternalStoragePermission() =>
    SimplePermissions.requestPermission(Permission.WriteExternalStorage);
}
