///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Stub file for adapter exports on web platform.
///
/// AndroidAdapter and IOSAdapter use JNI/FFI bindings that don't compile on web.
/// This stub provides empty classes for API compatibility - the adapters are
/// only used on their respective native platforms.

import 'package:flutter/foundation.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

/// Stub for AndroidAdapter on web platform.
///
/// This class is never instantiated on web - it exists only for API compatibility.
class AndroidAdapter extends NutrientPlatformAdapter {
  AndroidAdapter._();

  @override
  TargetPlatform get platform => TargetPlatform.android;

  @override
  Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {}

  @override
  Future<void> dispose() async {}
}

/// Stub for IOSAdapter on web platform.
///
/// This class is never instantiated on web - it exists only for API compatibility.
class IOSAdapter extends NutrientPlatformAdapter {
  IOSAdapter._();

  @override
  TargetPlatform get platform => TargetPlatform.iOS;

  @override
  Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {}

  @override
  Future<void> dispose() async {}
}
