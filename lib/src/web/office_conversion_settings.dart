///
///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Configuration options for Office document conversion in Nutrient Web.
///
/// These settings control how Office documents (.docx, .xlsx, .pptx) are
/// converted to PDF for viewing in the web viewer.
class OfficeConversionSettings {
  /// Maximum height (in millimeters) for spreadsheet content per sheet.
  ///
  /// This setting controls the maximum height of content that will be rendered
  /// for each sheet in Excel spreadsheets. Content exceeding this height will
  /// be truncated. The default value is platform-specific.
  final num? spreadsheetMaximumContentHeightPerSheet;

  /// Maximum width (in millimeters) for spreadsheet content per sheet.
  ///
  /// This setting controls the maximum width of content that will be rendered
  /// for each sheet in Excel spreadsheets. Content exceeding this width will
  /// be truncated. The default value is platform-specific.
  final num? spreadsheetMaximumContentWidthPerSheet;

  /// Creates an instance of [OfficeConversionSettings].
  ///
  /// All parameters are optional and will use platform defaults if not specified.
  const OfficeConversionSettings({
    this.spreadsheetMaximumContentHeightPerSheet,
    this.spreadsheetMaximumContentWidthPerSheet,
  });

  /// Converts this configuration to a Map for JavaScript interop.
  Map<String, dynamic> toMap() {
    return {
      'spreadsheetMaximumContentHeightPerSheet':
          spreadsheetMaximumContentHeightPerSheet,
      'spreadsheetMaximumContentWidthPerSheet':
          spreadsheetMaximumContentWidthPerSheet,
    }..removeWhere((key, value) => value == null);
  }
}
