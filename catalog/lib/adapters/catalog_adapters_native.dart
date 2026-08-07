// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

/// Native platform adapter factory for Android and iOS.
library;

import 'dart:io' show Platform;

import 'catalog_adapter_controller.dart';
import 'catalog_android_adapter.dart';
import 'catalog_ios_adapter.dart';

/// Returns a fresh per-view catalog adapter for the current native platform,
/// typed as [CatalogAdapterController] so example pages can use its
/// catalog-specific surface (`goToPage`, `attachListeners`, …) without
/// runtime casting.
///
/// Returns `null` if the current platform is neither Android nor iOS.
/// Each call returns a *new* instance — pages own the adapter's lifetime
/// and should dispose it alongside their widget state.
CatalogAdapterController? createCatalogAdapter() {
  if (Platform.isAndroid) return CatalogAndroidAdapter();
  if (Platform.isIOS) return CatalogIOSAdapter();
  return null;
}
