///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:ui_web' as ui_web;

import 'package:flutter/services.dart';

import 'utils/document_path.dart';

/// Returns the URL to load a `documentPath` from: declared Flutter assets map
/// to the URL Flutter serves them at, anything else passes through.
///
/// See [resolveDocumentPath]. The asset manifest is fetched once: [rootBundle]
/// caches it, and drops a failed load so the next call tries again.
Future<String> resolveWebDocumentPath(String path) => resolveDocumentPath(
      path,
      assetKeys: () async =>
          (await AssetManifest.loadFromAssetBundle(rootBundle))
              .listAssets()
              .toSet(),
      assetUrl: ui_web.assetManager.getAssetUrl,
    );
