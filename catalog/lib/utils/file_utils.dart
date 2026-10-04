// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

/// File utilities for the catalog examples.
///
/// The catalog ships demo documents as Flutter assets. Some SDK operations
/// (saving, exporting, opening with platform readers) require a real file
/// path on disk — [extractAsset] writes the asset bytes to the OS
/// temporary directory and returns the resulting path so it can be passed
/// to the native iOS/Android SDK.
///
/// The browser has no writable file system, so on web both methods short-
/// circuit: [extractAsset] returns the asset path unchanged (the Nutrient
/// Web SDK loads asset paths directly), [getOutputPath] returns `null`.
///
/// `dart:io` is imported unconditionally — Flutter's web compiler accepts
/// the import; only the actual IO calls would throw at runtime, and the
/// `kIsWeb` guard ensures they're never reached.
class FileUtils {
  FileUtils._();

  /// Returns a path inside the OS temporary directory for [filename], or
  /// `null` on web (no writable file system).
  static Future<String?> getOutputPath(String filename) async {
    if (kIsWeb) return null;
    final tempDir = await path_provider.getTemporaryDirectory();
    return '${tempDir.path}/$filename';
  }

  /// Extracts a bundled Flutter asset to the OS temporary directory and
  /// returns its native file path.
  ///
  /// On web, returns [assetPath] unchanged — the Nutrient Web SDK loads
  /// asset paths directly via `documentPath`, so no extraction is needed.
  ///
  /// - [context] — used to obtain the asset bundle.
  /// - [assetPath] — the asset path (e.g. `assets/documents/welcome.pdf`).
  /// - [shouldOverwrite] — if `true` (default), an existing temp file is
  ///   overwritten. Set to `false` to skip writing when the file exists.
  /// - [prefix] — optional prefix prepended to the temp filename.
  static Future<String> extractAsset(
    BuildContext context,
    String assetPath, {
    bool shouldOverwrite = true,
    String prefix = '',
  }) async {
    if (kIsWeb) return assetPath;

    final byteData = await DefaultAssetBundle.of(context).load(assetPath);
    final bytes = byteData.buffer.asUint8List();

    final tempDir = await path_provider.getTemporaryDirectory();
    final tempPath = '${tempDir.path}/$prefix$assetPath';
    final file = File(tempPath);

    if (shouldOverwrite || !file.existsSync()) {
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
    }
    return file.path;
  }
}
