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

import 'web_platform_adapter.dart';
import 'web_sdk_namespace.dart' as sdk;

/// A web implementation of the NutrientFlutterPlatform.
///
/// Hosts the SDK-global, stateless concerns: the native SDK version, and
/// license activation (a no-op on web — the key is injected into every
/// `NutrientViewer.load()` call instead, so it inherits the base no-op).
class NutrientFlutterWeb extends NutrientFlutterPlatform {
  /// Registers this class as the default instance of [NutrientFlutterPlatform].
  static void registerWith(Registrar registrar) {
    NutrientFlutterPlatform.instance = NutrientFlutterWeb();
  }

  @override
  Future<String?> getPlatformVersion() async => sdk.sdkVersion;

  /// `NutrientWebAdapter` is concrete, so the no-customization default is just
  /// a plain instance. This is what [Nutrient.initialize] registers when the
  /// caller doesn't pass a `webAdapter`.
  @override
  NutrientPlatformAdapter createDefaultAdapter() => NutrientWebAdapter();
}
