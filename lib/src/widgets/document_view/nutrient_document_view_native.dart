///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Native (Android + iOS) implementation of [NutrientDocumentView]'s
/// platform view dispatch. Delegates to the federated platform views.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:nutrient_flutter_android/nutrient_flutter_android.dart';
import 'package:nutrient_flutter_ios/nutrient_flutter_ios.dart';

Widget createNutrientDocumentView({
  String? documentPath,
  Uint8List? documentBytes,
  NutrientViewConfiguration? configuration,
  void Function(NutrientViewHandle handle)? onViewCreated,
  NutrientPlatformAdapter? adapter,
}) {
  if (Platform.isAndroid) {
    return NutrientViewAndroid(
      documentPath: documentPath,
      documentBytes: documentBytes,
      configuration: configuration,
      onViewCreated: onViewCreated,
      adapter: adapter,
    );
  } else if (Platform.isIOS) {
    return NutrientViewIOS(
      documentPath: documentPath,
      documentBytes: documentBytes,
      configuration: configuration,
      onViewCreated: onViewCreated,
      adapter: adapter,
    );
  }
  return const Center(
    child: Text(
      'NutrientDocumentView is only supported on Android and iOS.',
      textAlign: TextAlign.center,
    ),
  );
}
