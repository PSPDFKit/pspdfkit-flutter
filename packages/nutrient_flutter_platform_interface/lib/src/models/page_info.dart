///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Information about a single PDF page.
///
/// Fields not yet surfaced cross-platform — for now, reach for the
/// platform-specific [NutrientPlatformAdapter] (cast it to the concrete
/// `AndroidAdapter` / `IOSAdapter` / `NutrientWebAdapter` and use the
/// native binding directly) if you need them:
///
/// - **Raw PDF boxes** (`mediaBox`, `cropBox`, `bleedBox`, `trimBox`,
///   `artBox`): iOS exposes `mediaBox`/`cropBox` on `PSPDFPageInfo` and
///   web exposes the full set via `PageInfo.rawPdfBoxes`; Android's
///   high-level `PdfDocument` API doesn't surface them, so adding them
///   here would force Android to return `null` for every box.
/// - **`rotationOffset`**: iOS-only (transient per-display rotation on
///   top of `savedRotation`). No analogue on Android / Web.
/// - **`hasTransparency`**: iOS-only flag on `PSPDFPageInfo`.
class PageInfo {
  /// Zero-based page index.
  final int pageIndex;

  /// Page width in PDF points.
  final double width;

  /// Page height in PDF points.
  final double height;

  /// Page rotation in degrees (0, 90, 180, 270).
  final int rotation;

  /// Optional page label (e.g. "i", "ii", "1", "A-1").
  final String? label;

  const PageInfo({
    required this.pageIndex,
    required this.width,
    required this.height,
    required this.rotation,
    this.label,
  });

  @override
  String toString() =>
      'PageInfo(pageIndex: $pageIndex, width: $width, height: $height, '
      'rotation: $rotation, label: $label)';
}
