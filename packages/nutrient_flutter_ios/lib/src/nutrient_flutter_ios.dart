///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
// The String/NSString conversion extensions (`toNSString`/`toDartString`)
// apply implicitly even through this prefixed import.
import 'package:objective_c/objective_c.dart' as objc;

// `Rect`/`Deprecated` are hidden to match the adapter's import (they otherwise
// shadow dart:ui's Rect / dart:core's @Deprecated); we need PSPDFKitGlobal here.
import 'bindings/nutrient_ios_bindings.dart' hide Rect, Deprecated;
import 'ios_platform_adapter.dart';
import 'nutrient_instant_controller_ios.dart';

/// The iOS implementation of [NutrientFlutterPlatform].
///
/// Hosts the SDK-global, stateless concerns (license activation, native SDK
/// version) that used to live on the iOS adapter — they're independent of any
/// per-view adapter, so a single platform-wide owner is the right home.
class NutrientFlutterIOS extends NutrientFlutterPlatform {
  /// Registers this class as the default instance of [NutrientFlutterPlatform].
  static void registerWith() {
    NutrientFlutterPlatform.instance = NutrientFlutterIOS();
  }

  bool _licenseActivated = false;

  @override
  Future<String?> getPlatformVersion() async {
    // The Nutrient iOS (PSPDFKit) SDK version number.
    return PSPDFKitGlobal.getVersionNumber().toDartString();
  }

  @override
  Future<void> activateLicense(String? licenseKey) async {
    // No key → stay in trial mode (watermarked).
    if (licenseKey == null || licenseKey.isEmpty) return;
    if (_licenseActivated) return;
    // `setLicenseKey` must be called before any other Nutrient API, so this
    // runs at `Nutrient.initialize()` time, before any view controller or
    // headless document is created.
    //
    // The hybrid-environment option is load-bearing: Flutter license keys are
    // issued for the "Nutrient Flutter SDK (iOS)" product, and without it the
    // SDK validates the key against the plain "Nutrient iOS SDK" product and
    // rejects it ("Nutrient Licensing Issue" alert, then an abort). This mirrors
    // the legacy plugin's
    // `SDK.setLicenseKey(key, options: [PSPDFSettingKeyHybridEnvironment: "Flutter"])`.
    PSPDFKitGlobal.setLicenseKey_options(
      licenseKey.toNSString(),
      options: {
        'com.pspdfkit.hybrid-environment'.toNSString(): 'Flutter'.toNSString(),
      }.toNSDictionary(),
    );
    _licenseActivated = true;
  }

  @override
  NutrientPlatformAdapter createDefaultAdapter() => DefaultIOSAdapter();

  @override
  NutrientPlatformAdapter createDefaultInstantAdapter() =>
      IOSInstantController();
}
