///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Internal helper shared by the bindings-based view widgets. Not exported
/// from the package's public API.
library;

// ignore: depend_on_referenced_packages
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import 'web_view_configuration.dart';

/// Resolves [NutrientViewConfiguration.webConfig] before handing the
/// configuration to the web platform layer.
///
/// `webConfig` is typed as `Object?` on [NutrientViewConfiguration] so that
/// `nutrient_flutter_platform_interface` doesn't depend on `nutrient_flutter`
/// (where [WebViewConfiguration] lives). `WebConfigurationBuilder` in
/// `nutrient_flutter_web` can't import [WebViewConfiguration] either, so it
/// only consumes the pre-serialised builder-map form and silently ignores
/// anything else. Every widget that forwards a user-supplied configuration to
/// the web layer must therefore pre-serialise `webConfig` via
/// [WebViewConfiguration.toBuilderMap] — that's what this helper does.
///
/// Returns [config] unchanged when there is nothing to resolve.
NutrientViewConfiguration? resolveWebConfig(NutrientViewConfiguration? config) {
  final webConfig = config?.webConfig;
  if (webConfig is! WebViewConfiguration) return config;
  return config!.copyWith(webConfig: webConfig.toBuilderMap());
}
