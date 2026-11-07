// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/widgets.dart';

import '../../utils/file_utils.dart';

/// Asset path tokens for brand imagery.
///
/// Use `*Inverse` variants on dark backgrounds — the inverse logos use white
/// glyphs designed to read against [BrandNeutrals.warmBlack].
class BrandAssets {
  BrandAssets._();

  /// Full Nutrient wordmark for light backgrounds.
  static const String logo = 'assets/brand/nutrient-logo.png';

  /// Full Nutrient wordmark for dark backgrounds.
  static const String logoInverse = 'assets/brand/nutrient-logo-inverse.png';

  /// Symbol-only mark for light backgrounds (use for app icon contexts).
  static const String symbol = 'assets/brand/nutrient-symbol.png';

  /// Symbol-only mark for dark backgrounds.
  static const String symbolInverse =
      'assets/brand/nutrient-symbol-inverse.png';
}

/// A bundled catalog demo document.
///
/// Each instance encapsulates a Flutter asset path plus the extraction logic
/// needed to turn that asset into a native file path. Instances are
/// callable: `await CatalogDocuments.welcome(context)` resolves the document
/// to a usable path on every platform — extracting to the OS temp directory
/// on Android and iOS, returning the asset path unchanged on web.
class CatalogDocument {
  /// The Flutter asset path (e.g. `assets/documents/welcome.pdf`).
  final String assetPath;

  /// A short human-readable label for the document.
  final String label;

  const CatalogDocument(this.assetPath, {required this.label});

  /// Resolves this document to a path the Nutrient SDK can load.
  ///
  /// On Android/iOS the asset bytes are written to the OS temporary
  /// directory and the resulting native file path is returned. On web the
  /// asset path is returned unchanged — the Web SDK loads asset paths
  /// directly.
  ///
  /// ```dart
  /// final path = await CatalogDocuments.welcome(context);
  /// NutrientDocumentView(documentPath: path);
  /// ```
  Future<String> call(BuildContext context) =>
      FileUtils.extractAsset(context, assetPath);

  @override
  String toString() => assetPath;
}

/// Demo document assets bundled with the catalog.
///
/// Sourced from the Android native catalog (`PSPDFKit/android/examples/
/// catalog/app/src/main/assets/`). Each entry is a [CatalogDocument] that
/// can be resolved to a native file path with `await doc(context)`.
class CatalogDocuments {
  CatalogDocuments._();

  /// Branded "Nutrient welcome" doc — default for the basic viewer example.
  static const welcome = CatalogDocument(
    'assets/documents/welcome.pdf',
    label: 'Welcome',
  );

  /// Document with a variety of pre-existing annotations.
  static const annotations = CatalogDocument(
    'assets/documents/annotations.pdf',
    label: 'Annotations',
  );

  /// Interactive AcroForm fields (text, checkboxes, radios).
  static const form = CatalogDocument(
    'assets/documents/form.pdf',
    label: 'Form',
  );

  /// Architectural plan with measurement annotations.
  static const measurements = CatalogDocument(
    'assets/documents/measurements.pdf',
    label: 'Measurements',
  );

  /// Multi-page scientific paper — useful for navigation and bookmarks.
  static const scientificPaper = CatalogDocument(
    'assets/documents/scientific-paper.pdf',
    label: 'Scientific Paper',
  );

  /// Document containing a digital signature.
  static const digitalSignatures = CatalogDocument(
    'assets/documents/digital-signatures.pdf',
    label: 'Digital Signatures',
  );

  /// Password-protected document (password: `test123`).
  static const password = CatalogDocument(
    'assets/documents/password.pdf',
    label: 'Password Protected',
  );

  /// Document with embedded bookmarks for the bookmarks example.
  static const bookmarks = CatalogDocument(
    'assets/documents/bookmarks.pdf',
    label: 'Bookmarks',
  );

  /// JPG photo opened as an image document (single annotatable page).
  static const imageDocument = CatalogDocument(
    'assets/documents/image-document.jpg',
    label: 'Image Document',
  );
}
