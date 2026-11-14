// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/widgets.dart';

/// Border-radius tokens.
class BrandRadius {
  BrandRadius._();

  /// 4px — small chips, badges.
  static const double sm = 4;

  /// 8px — buttons, list items.
  static const double md = 8;

  /// 12px — cards, default surfaces.
  static const double lg = 12;

  /// 20px — sheet headers, large surfaces.
  static const double xl = 20;

  /// Fully rounded — pills, avatars.
  static const double pill = 999;

  // ---- Pre-built BorderRadius for convenience ----

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));
}
