// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

/// Web platform adapter factory for the catalog app.
library;

import 'catalog_adapter_controller.dart';
import 'catalog_web_adapter.dart';

/// Returns a fresh per-view catalog adapter for web, typed as
/// [CatalogAdapterController] so example pages can use its
/// catalog-specific surface (`goToPage`, `attachListeners`, …) without
/// runtime casting. Each call returns a *new* instance.
CatalogAdapterController? createCatalogAdapter() => CatalogWebAdapter();
