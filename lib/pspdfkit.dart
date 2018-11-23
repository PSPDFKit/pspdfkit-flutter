import 'dart:async';

import 'package:flutter/services.dart';

class Pspdfkit {
  static const MethodChannel _channel = const MethodChannel('pspdfkit');

  static Future<dynamic> get frameworkVersion =>
      _channel.invokeMethod('frameworkVersion');

  static Future<void> present(String document) =>
    _channel.invokeMethod('present', <String, dynamic>{'document': document});
}
