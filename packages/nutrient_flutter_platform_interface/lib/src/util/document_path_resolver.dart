///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Utility class to resolve document paths for native platforms.
///
/// Handles different path formats:
/// - Asset paths (assets/...)
/// - File paths (file://...)
/// - Content URIs (content://...)
/// - Remote URLs (https://...)
class DocumentPathResolver {
  DocumentPathResolver._();

  static final DocumentPathResolver instance = DocumentPathResolver._();

  final Map<String, String> _resolvedPaths = {};

  /// Resolves a document path to a native-accessible path.
  ///
  /// For asset paths, copies the asset to a temporary location.
  /// For other paths, returns them as-is.
  Future<String> resolve(String documentPath, {String? cacheKey}) async {
    // If it's an asset path, copy to temp directory
    if (documentPath.startsWith('assets/') ||
        documentPath.startsWith('asset/')) {
      final key = cacheKey ?? documentPath;

      // Return cached path if available
      if (_resolvedPaths.containsKey(key)) {
        return _resolvedPaths[key]!;
      }

      // Copy asset to temp directory
      final tempDir = await getTemporaryDirectory();
      final fileName = documentPath.split('/').last;
      final tempFile = File('${tempDir.path}/$fileName');

      final byteData = await rootBundle.load(documentPath);
      final buffer = byteData.buffer;
      await tempFile.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );

      final resolvedPath = tempFile.path;
      _resolvedPaths[key] = resolvedPath;
      return resolvedPath;
    }

    // For other paths, return as-is
    return documentPath;
  }

  /// Writes in-memory document [bytes] to a temporary file and returns its
  /// path.
  ///
  /// The native document loaders take a file URI/URL, so opening a document
  /// from a `Uint8List` goes through a temp file. The file is cached under
  /// [cacheKey] (so a widget rebuild reuses it) and removed by [release] /
  /// [clearAll], exactly like a resolved asset.
  Future<String> resolveBytes(
    Uint8List bytes, {
    required String cacheKey,
  }) async {
    if (_resolvedPaths.containsKey(cacheKey)) {
      return _resolvedPaths[cacheKey]!;
    }

    final tempDir = await getTemporaryDirectory();
    // Derive the filename from the (unique) cache key itself rather than its
    // hashCode, so two different keys can't collide onto the same temp file
    // and clobber each other's bytes. Sanitize non-filename-safe characters.
    final safeName = cacheKey.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final tempFile = File('${tempDir.path}/nutrient_bytes_$safeName.pdf');
    await tempFile.writeAsBytes(bytes, flush: true);

    final resolvedPath = tempFile.path;
    _resolvedPaths[cacheKey] = resolvedPath;
    return resolvedPath;
  }

  /// Releases a cached resolved path.
  Future<void> release(String cacheKey) async {
    final path = _resolvedPaths.remove(cacheKey);
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore errors during cleanup
      }
    }
  }

  /// Clears all cached paths.
  Future<void> clearAll() async {
    final paths = List<String>.from(_resolvedPaths.values);
    _resolvedPaths.clear();

    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore errors during cleanup
      }
    }
  }
}
