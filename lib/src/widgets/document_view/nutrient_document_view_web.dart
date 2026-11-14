///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Web implementation of [NutrientDocumentView]'s platform view dispatch.
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:nutrient_flutter_web/nutrient_flutter_web.dart';

import '../../configuration/web_config_resolution.dart';

Widget createNutrientDocumentView({
  String? documentPath,
  Uint8List? documentBytes,
  NutrientViewConfiguration? configuration,
  void Function(NutrientViewHandle handle)? onViewCreated,
  NutrientPlatformAdapter? adapter,
}) {
  return NutrientViewWeb(
    documentPath: documentPath,
    documentBytes: documentBytes,
    // Pre-serialise webConfig into the builder-map form WebConfigurationBuilder
    // consumes — it ignores a raw WebViewConfiguration (see resolveWebConfig).
    configuration: resolveWebConfig(configuration),
    onViewCreated: onViewCreated,
    adapter: adapter is NutrientWebAdapter ? adapter : null,
  );
}
