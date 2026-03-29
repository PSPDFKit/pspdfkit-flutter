///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of nutrient_flutter must implement.
///
/// Platform implementations should extend this class rather than implement it as `nutrient_flutter`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [NutrientFlutterPlatform] methods.
abstract class NutrientFlutterPlatform extends PlatformInterface {
  /// Constructs a NutrientFlutterPlatform.
  NutrientFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The default instance of [NutrientFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelNutrientFlutter].

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NutrientFlutterPlatform] when
  /// they register themselves.
  static set instance(NutrientFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// Returns the framework version.
  Future<String?> getPlatformVersion();

  Future<void> initialize(
      {String? androidLicenseKey,
      String? iosLicenseKey,
      String? webLicenseKey});
}
