///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Stub implementation of [NutrientInstantView] for the web platform.
///
/// Nutrient Instant is not supported on web. This stub exists solely to allow
/// the package to compile for web targets without pulling in the JNI/FFI
/// bindings from the native platform packages.

import 'package:flutter/widgets.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

/// Web stub for [NutrientInstantView].
///
/// Nutrient Instant is not supported on web. Rendering this widget on web
/// displays an unsupported-platform message.
class NutrientInstantView extends StatelessWidget {
  /// The Document Engine server URL for the Instant document to open.
  final String serverUrl;

  /// The JWT used to authenticate with the Document Engine server.
  final String jwt;

  /// Optional viewer configuration. Accepted for API parity but ignored on web
  /// since Instant is not supported on this platform.
  // ignore: unused_field
  final NutrientViewConfiguration? configuration;

  /// Called when the platform view has been created and is ready to use.
  final void Function(NutrientViewHandle handle)? onViewCreated;

  /// Creates a [NutrientInstantView].
  const NutrientInstantView({
    super.key,
    required this.serverUrl,
    required this.jwt,
    this.configuration,
    this.onViewCreated,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      'NutrientInstantView is not supported on web.',
    );
  }
}
