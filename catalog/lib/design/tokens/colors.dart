// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/material.dart';

/// Nutrient brand color palette.
///
/// Source of truth: Notion → Design → Nutrient brand resources.
/// Hex values are taken verbatim from the brand guidelines.
///
/// The palette is split into three groups:
/// - [BrandColors] — primary accents (light and dark variants).
/// - [BrandNeutrals] — neutral surfaces and text colors.
/// - [BrandSemantic] — convenience aliases for success / warning / error.
class BrandColors {
  BrandColors._();

  // ---- Light mode accents ----

  /// Pure white. Used for the lightest surfaces in light mode.
  static const Color white = Color(0xFFFFFFFF);

  /// Disc Pink. Soft pink accent.
  static const Color discPink = Color(0xFFDE9DCC);

  /// Code Coral. Primary brand accent — warm coral / orange-red.
  static const Color codeCoral = Color(0xFFF25E45);

  /// Data Green. Sage green accent.
  static const Color dataGreen = Color(0xFF6EB579);

  /// Digital Pollen. Warm yellow accent.
  static const Color digitalPollen = Color(0xFFF0C968);

  // ---- Dark mode accents (muted variants) ----

  /// Disc Pink — dark mode variant.
  static const Color discPinkDark = Color(0xFF4F2B45);

  /// Code Coral — dark mode variant.
  static const Color codeCoralDark = Color(0xFF672D23);

  /// Data Green — dark mode variant.
  static const Color dataGreenDark = Color(0xFF2B412F);

  /// Digital Pollen — dark mode variant.
  static const Color digitalPollenDark = Color(0xFF5B481A);
}

/// Neutral surface and text colors.
class BrandNeutrals {
  BrandNeutrals._();

  /// Warm Black. Primary dark surface / text in light mode.
  static const Color warmBlack = Color(0xFF1A1414);

  /// Off-white. Primary light surface (light mode background).
  static const Color offWhite = Color(0xFFEFEBE7);

  /// Pixel Mist. Secondary surface / hover layer.
  static const Color pixelMist = Color(0xFFE2DBD9);

  /// Soft grey. Tertiary surface / divider.
  static const Color softGrey = Color(0xFFC2B8AE);

  /// Warm grey. Muted text / secondary content.
  static const Color warmGrey = Color(0xFF67594B);
}

/// Semantic aliases — success/warning/error mapped to the brand palette.
///
/// The Nutrient brand guidelines do not define explicit semantic states;
/// these are conventions chosen so that the catalog uses brand colors for
/// status indicators rather than introducing off-palette colors.
class BrandSemantic {
  BrandSemantic._();

  /// Success — Data Green.
  static const Color success = BrandColors.dataGreen;

  /// Warning — Digital Pollen.
  static const Color warning = BrandColors.digitalPollen;

  /// Error — Code Coral.
  static const Color error = BrandColors.codeCoral;

  /// Info — Disc Pink.
  static const Color info = BrandColors.discPink;
}
