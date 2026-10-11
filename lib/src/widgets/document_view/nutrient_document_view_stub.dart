///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Stub implementation — conditional imports select the platform one.
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

Widget createNutrientDocumentView({
  String? documentPath,
  Uint8List? documentBytes,
  NutrientViewConfiguration? configuration,
  void Function(NutrientViewHandle handle)? onViewCreated,
  NutrientPlatformAdapter? adapter,
}) {
  return const Center(
    child: Text(
      'NutrientDocumentView is not supported on this platform.\n'
      'Supported platforms: Android, iOS, Web',
      textAlign: TextAlign.center,
    ),
  );
}
