// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

/// Platform adapter factory with conditional imports.
///
/// Exposes [createCatalogAdapter], which builds the right
/// [CatalogAdapterController] implementation for the current platform. The
/// conditional export keeps FFI code off web and JS-interop code off native.
///
/// Usage — register the controller type once, then build a fresh adapter per
/// view via the type-keyed factory:
/// ```dart
/// import 'adapters/catalog_adapters.dart';
/// import 'adapters/catalog_adapter_controller.dart';
///
/// Nutrient.addAdapterClass<CatalogAdapterController>(
///   () => createCatalogAdapter()!,
/// );
///
/// // any screen:
/// NutrientDocumentView<CatalogAdapterController>(documentPath: '…');
/// ```
library;

export 'catalog_adapters_stub.dart'
    if (dart.library.io) 'catalog_adapters_native.dart'
    if (dart.library.js_interop) 'catalog_adapters_web.dart';
