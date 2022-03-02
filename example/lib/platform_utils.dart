import 'package:flutter/foundation.dart';

class PlatformUtils {
  static bool isCurrentPlatformSupported() {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool isAndroid() {
    return defaultTargetPlatform == TargetPlatform.android;
  }

  static bool isIOS() {
    return defaultTargetPlatform == TargetPlatform.iOS;
  }
}
