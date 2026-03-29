///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

/// A web implementation of the NutrientFlutterPlatform.
///
/// Note: Most methods throw UnimplementedError on web as web uses a different
/// architecture with direct JavaScript interop via NutrientWidget.
class NutrientFlutterWeb extends NutrientFlutterPlatform {
  /// Registers this class as the default instance of [NutrientFlutterPlatform].
  static void registerWith(Registrar registrar) {
    NutrientFlutterPlatform.instance = NutrientFlutterWeb();
  }

  @override
  Future<String?> getPlatformVersion() {
    // TODO: implement getPlatformVersion
    throw UnimplementedError();
  }

  @override
  Future<void> initialize(
      {String? androidLicenseKey,
      String? iosLicenseKey,
      String? webLicenseKey}) {
    // TODO: implement initialize
    throw UnimplementedError();
  }
}
