import 'dart:async';

import 'package:flutter/services.dart';

class Pspdfkit {
  static const MethodChannel _channel = const MethodChannel('pspdfkit');

  static Future<dynamic> get frameworkVersion =>
      _channel.invokeMethod('frameworkVersion');

  static Future<void> openExternalDocument(String document) =>
    _channel.invokeMethod(
        'openExternalDocument', <String, dynamic>{'document': document});
}
