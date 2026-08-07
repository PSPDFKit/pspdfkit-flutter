// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/material.dart';

import 'tokens/colors.dart';
import 'tokens/radius.dart';
import 'tokens/typography.dart';

/// Material 3 themes for the catalog, built from Nutrient brand tokens.
///
/// Code Coral is used as the seed color so that derived tonal palettes carry
/// the brand's warm coral identity. Surface and text colors are pinned to the
/// brand's neutral palette (Off-white / Warm Black) rather than the seed-based
/// defaults so that the surface chrome matches the brand guidelines.
class BrandTheme {
  BrandTheme._();

  /// Light theme — Off-white surfaces, Code Coral primary accent.
  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: BrandColors.codeCoral,
          brightness: Brightness.light,
        ).copyWith(
          primary: BrandColors.codeCoral,
          onPrimary: BrandColors.white,
          secondary: BrandColors.discPink,
          tertiary: BrandColors.dataGreen,
          surface: BrandNeutrals.offWhite,
          onSurface: BrandNeutrals.warmBlack,
          surfaceContainer: BrandNeutrals.pixelMist,
          surfaceContainerHigh: BrandNeutrals.pixelMist,
          outlineVariant: BrandNeutrals.softGrey,
          error: BrandColors.codeCoral,
        );

    return _buildTheme(scheme, brightness: Brightness.light);
  }

  /// Dark theme — Warm Black surfaces, Code Coral primary accent.
  static ThemeData get dark {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: BrandColors.codeCoral,
          brightness: Brightness.dark,
        ).copyWith(
          primary: BrandColors.codeCoral,
          onPrimary: BrandColors.white,
          secondary: BrandColors.discPink,
          tertiary: BrandColors.dataGreen,
          surface: BrandNeutrals.warmBlack,
          onSurface: BrandNeutrals.offWhite,
          surfaceContainer: BrandColors.codeCoralDark,
          surfaceContainerHigh: const Color(0xFF2A2222),
          outlineVariant: BrandNeutrals.warmGrey,
          error: BrandColors.codeCoral,
        );

    return _buildTheme(scheme, brightness: Brightness.dark);
  }

  static ThemeData _buildTheme(
    ColorScheme scheme, {
    required Brightness brightness,
  }) {
    final base = ThemeData(useMaterial3: true, brightness: brightness);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: BrandTypography.textTheme(
        base.textTheme,
      ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: BrandTypography.textTheme(base.textTheme).titleLarge
            ?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BrandRadius.brLg),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BrandRadius.brMd),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BrandRadius.brMd),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: BrandRadius.brSm),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
