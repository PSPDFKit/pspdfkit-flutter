import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  static bool isCupertino(BuildContext context) {
    final defaultTargetPlatform = Theme.of(context).platform;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
    }
  }
}
