// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Nutrient typography tokens.
///
/// The Nutrient brand uses two open-source typefaces in product surfaces:
/// - **Archivo** for display, headings, and body text.
/// - **IBM Plex Mono** for code, monospaced labels, and technical UI.
///
/// (The brand-restricted fonts — ABC Monument Grotesk, Arizona Mix — are
/// licensed for marketing collateral only and are not shipped in apps.)
class BrandTypography {
  BrandTypography._();

  /// The primary font family name (Archivo, served via google_fonts).
  static const String primaryFamily = 'Archivo';

  /// The monospaced font family name (IBM Plex Mono, served via google_fonts).
  static const String monoFamily = 'IBM Plex Mono';

  /// Returns a Material 3 [TextTheme] built from Archivo with IBM Plex Mono
  /// for label-mono variants. Pass the resolved [base] from the parent theme
  /// so that colors derived from the [ColorScheme] are preserved.
  static TextTheme textTheme(TextTheme base) {
    return GoogleFonts.archivoTextTheme(base).copyWith(
      // Display / headlines — slightly tighter tracking for brand feel.
      displayLarge: GoogleFonts.archivo(
        textStyle: base.displayLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.archivo(
        textStyle: base.displayMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      displaySmall: GoogleFonts.archivo(
        textStyle: base.displaySmall,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineLarge: GoogleFonts.archivo(
        textStyle: base.headlineLarge,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.archivo(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: GoogleFonts.archivo(
        textStyle: base.headlineSmall,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.archivo(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.archivo(
        textStyle: base.titleMedium,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.archivo(
        textStyle: base.titleSmall,
        fontWeight: FontWeight.w600,
      ),
      // Body / labels — Archivo regular.
      bodyLarge: GoogleFonts.archivo(textStyle: base.bodyLarge),
      bodyMedium: GoogleFonts.archivo(textStyle: base.bodyMedium),
      bodySmall: GoogleFonts.archivo(textStyle: base.bodySmall),
      labelLarge: GoogleFonts.archivo(
        textStyle: base.labelLarge,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.archivo(
        textStyle: base.labelMedium,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: GoogleFonts.archivo(
        textStyle: base.labelSmall,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Convenience helper for monospaced text (code blocks, API tags, etc.).
  static TextStyle mono({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }
}
