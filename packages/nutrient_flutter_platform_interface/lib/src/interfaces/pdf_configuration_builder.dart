///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Abstract interface for converting a [PdfConfiguration] map into a
/// platform-specific configuration representation.
///
/// Each platform package provides a concrete implementation:
/// - `AndroidConfigurationBuilder` (`nutrient_flutter_android`) — produces a
///   native `PdfActivityConfiguration` via JNI.
/// - `IOSConfigurationBuilder` (`nutrient_flutter_ios`) — produces a
///   `Map<String, dynamic>` with iOS-specific keys that is JSON-encoded and
///   passed to `nutrient_create_instant_view_controller_with_config`.
/// - `WebConfigurationBuilder` (`nutrient_flutter_web`) — produces a
///   `Map<String, dynamic>` suitable for `PSPDFKit.load()`.
///
/// Callers always pass the output of [PdfConfiguration.toMap()] (with null
/// values already stripped) to [buildConfigMap]. The returned map contains
/// only the keys understood by the target platform; unrecognised keys are
/// silently ignored.
abstract class PdfConfigurationBuilder {
  /// Builds a platform-specific configuration map from [configMap].
  ///
  /// [configMap] is the output of `PdfConfiguration.toMap()` — a
  /// `Map<String, dynamic>` with all `null` values already removed.
  ///
  /// Returns a new map containing only the entries relevant to the target
  /// platform's configuration API.
  Map<String, dynamic> buildConfigMap(Map<String, dynamic> configMap);
}
