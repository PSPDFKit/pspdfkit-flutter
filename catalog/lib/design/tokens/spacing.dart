// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

/// 4px base spacing scale.
///
/// Use these named tokens instead of hardcoded `EdgeInsets.all(16)` so that
/// spacing is consistent across the catalog and easy to retune globally.
class BrandSpacing {
  BrandSpacing._();

  /// 2px — hairline gap (icon vs glyph).
  static const double xxs = 2;

  /// 4px — tight inline gap.
  static const double xs = 4;

  /// 8px — default inline gap.
  static const double sm = 8;

  /// 12px — compact stack.
  static const double md = 12;

  /// 16px — default block padding.
  static const double lg = 16;

  /// 24px — section padding.
  static const double xl = 24;

  /// 32px — page-level padding.
  static const double xxl = 32;

  /// 48px — hero padding.
  static const double xxxl = 48;
}
