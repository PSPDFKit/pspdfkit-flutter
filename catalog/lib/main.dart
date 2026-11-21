// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:nutrient_flutter/bindings.dart';

import 'adapters/catalog_adapter_controller.dart';
import 'adapters/catalog_adapters.dart';
import 'design/design.dart';
import 'home_page.dart';

/// Entry point for the Nutrient Flutter SDK catalog application.
///
/// Initialises the SDK with platform-specific adapters before launching the
/// app. The adapters are provided via conditional imports so that the correct
/// implementation is selected at compile time for Android and iOS.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force the Flutter Semantics tree to be exposed in the DOM on web so
  // that DOM-based UI test tooling (Maestro, Playwright, screen readers)
  // can read element labels. CanvasKit otherwise renders directly to a
  // <canvas> with no accessible text. Holding the handle for the lifetime
  // of the app keeps semantics on. No-op cost on native platforms, but we
  // gate on `kIsWeb` to avoid spurious tree builds where it isn't needed.
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }

  // Initialize the SDK (licensing only — no global adapter slots).
  await Nutrient.initialize();

  // Register the catalog's controller type once. Every
  // `NutrientDocumentView<CatalogAdapterController>` then builds a *fresh*
  // adapter per view from this factory (conditionally imported, so the right
  // platform implementation is selected at compile time), and the view owns
  // and disposes it. Examples that hold their own adapter instance pass it via
  // `NutrientDocumentView.adapter` instead (see two_widgets_example).
  Nutrient.addAdapterClass<CatalogAdapterController>(
    () => createCatalogAdapter()!,
  );

  runApp(const CatalogApp());
}

/// Root widget for the Nutrient Flutter SDK catalog.
class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrient Flutter SDK Catalog',
      debugShowCheckedModeBanner: false,
      theme: BrandTheme.light,
      darkTheme: BrandTheme.dark,
      home: const CatalogHomePage(),
    );
  }
}
