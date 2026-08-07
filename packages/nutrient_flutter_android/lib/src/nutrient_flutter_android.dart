///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:jni/jni.dart';
import 'package:jni_flutter/jni_flutter.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import 'android_instant_controller.dart';
import 'android_platform_adapter.dart';
import 'bindings/nutrient_android_sdk_bindings.dart' hide Nutrient;
// The native SDK's `Nutrient` (initialize/license/VERSION) collides with the
// cross-platform `Nutrient` entry point, so reach it under a prefix.
import 'bindings/nutrient_android_sdk_bindings.dart' as sdk_bindings
    show Nutrient;

/// The Android implementation of [NutrientFlutterPlatform].
///
/// Hosts the SDK-global, stateless concerns (license activation, native SDK
/// version) that used to live on the Android adapter — they're independent of
/// any per-view adapter, so a single platform-wide owner is the right home.
class NutrientFlutterAndroid extends NutrientFlutterPlatform {
  /// Registers this class as the default instance of [NutrientFlutterPlatform].
  static void registerWith() {
    NutrientFlutterPlatform.instance = NutrientFlutterAndroid();
  }

  bool _licenseActivated = false;

  @override
  Future<String?> getPlatformVersion() async {
    // The Nutrient Android SDK version string, e.g. "11.5.1".
    final version = sdk_bindings.Nutrient.VERSION;
    try {
      return version.toDartString();
    } finally {
      version.release();
    }
  }

  @override
  Future<void> activateLicense(String? licenseKey) async {
    // No key → stay in trial mode. The host manifest's
    // `nutrient_automatic_initialize` handles the (watermarked) trial init on
    // first SDK use, so there's nothing to do here.
    if (licenseKey == null || licenseKey.isEmpty) return;
    if (_licenseActivated) return;

    // The native SDK must be licensed before any document is opened, so
    // initialize it now against the cached application context. Pass
    // CrossPlatformTechnology.Flutter (Flutter licenses are issued against
    // this technology) and an empty additional-fonts list, mirroring the
    // legacy plugin's `Nutrient.initialize(context, InitializationOptions(…))`.
    final context = androidApplicationContext.as(Context.type);
    final key = licenseKey.toJString();
    // jni 1.0's JArrayList is typed JList<JString?>; InitializationOptions wants
    // a JList<JString>. The list is empty, so the element nullability is moot —
    // re-view it at the expected element type (extension types erase to JObject).
    final fonts = JArrayList<JString>();
    final technology = CrossPlatformTechnology.Flutter;
    final options =
        InitializationOptions(key, fonts as JList<JString>, technology, null);
    try {
      sdk_bindings.Nutrient.initialize(context, options);
      _licenseActivated = true;
    } finally {
      options.release();
      technology.release();
      fonts.release();
      key.release();
      context.release();
    }
  }

  @override
  NutrientPlatformAdapter createDefaultAdapter() => DefaultAndroidAdapter();

  @override
  NutrientPlatformAdapter createDefaultInstantAdapter() =>
      AndroidInstantController();
}
