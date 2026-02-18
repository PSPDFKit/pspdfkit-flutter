///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/services.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

/// Stub implementation for adapter bridging on unsupported platforms.
///
/// This is used on platforms where native adapter support is not available.
class AdapterBridge {
  /// Sets up the adapter bridge for the given view ID.
  ///
  /// On unsupported platforms, this is a no-op.
  static void setup({
    required int viewId,
    required MethodChannel channel,
    required NutrientPlatformAdapter adapter,
  }) {
    // No-op on unsupported platforms
  }

  /// Disposes the adapter bridge for the given view ID.
  static void dispose(int viewId) {
    // No-op on unsupported platforms
  }
}
