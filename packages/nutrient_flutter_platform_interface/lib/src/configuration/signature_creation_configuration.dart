///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/widgets.dart';

// These types mirror the legacy signature configuration API from the
// `nutrient_flutter` wrapper, lifted to the bindings' platform-interface layer
// so [NutrientViewConfiguration] can reference them (the legacy definitions in
// the higher-level wrapper are replaced by re-exports of these — same pattern
// as `ToolbarItem` / `IOSBookmarkIndicatorMode`).

/// When the signature creation UI offers to save a newly created signature.
///
/// - [neverSave]: Never save the signature.
/// - [alwaysSave]: Always save the signature.
/// - [saveIfSelected]: Save the signature only if the user selects the option.
///
/// Supported on Android and iOS. On Web, signature storage is app-managed
/// (via the Web SDK's stored-signatures API), so this option is ignored.
enum SignatureSavingStrategy { neverSave, alwaysSave, saveIfSelected }

/// How a signature can be created in the signature creation UI.
///
/// - [draw]: Draw the signature.
/// - [image]: Use an image as the signature.
/// - [type]: Type the signature.
enum SignatureCreationMode { draw, image, type }

/// A color preset offered in the signature creation UI.
///
/// [id], [defaultMessage] and [description] localize the preset's
/// accessibility label where the platform supports it.
class SignatureColorPreset {
  final Color color;
  final String? id;
  final String? defaultMessage;
  final String? description;

  SignatureColorPreset(
      {required this.color, this.id, this.defaultMessage, this.description});

  Map<String, dynamic> toMap() {
    return {
      'color': _colorToHex(color),
      'id': id,
      'defaultMessage': defaultMessage,
      'description': description
    }..removeWhere((key, value) => value == null);
  }
}

/// The set of color presets offered in the signature creation UI.
class SignatureColorOptions {
  final SignatureColorPreset option1;
  final SignatureColorPreset option2;
  final SignatureColorPreset option3;

  SignatureColorOptions(
      {required this.option1, required this.option2, required this.option3});

  Map<String, dynamic> toMap() {
    return {
      'option1': option1.toMap(),
      'option2': option2.toMap(),
      'option3': option3.toMap()
    }..removeWhere((key, value) => value == null);
  }
}

/// Orientation of the signature creation dialog on Android.
///
/// - [portrait]: Locked to portrait.
/// - [landscape]: Locked to landscape.
/// - [automatic]: Chosen automatically from the device type.
/// - [unlocked]: Follows the device orientation.
enum NutrientAndroidSignatureOrientation {
  portrait,
  landscape,
  automatic,
  unlocked
}

/// Configuration for the signature creation UI.
///
/// | Option | Android | iOS | Web |
/// |---|---|---|---|
/// | [creationModes] | ✅ | ✅ | ✅ |
/// | [colorOptions] | ✅ | ✅ | ✅ |
/// | [fonts] | ❌ (no native API) | ✅ | ✅ |
/// | [androidSignatureOrientation] | ✅ | — | — |
/// | [iosSignatureAspectRatio] | — | ✅ | — |
class SignatureCreationConfiguration {
  /// The creation modes (tabs) offered by the signature UI, in order.
  final List<SignatureCreationMode>? creationModes;

  /// The three ink/text color presets offered by the signature UI.
  final SignatureColorOptions? colorOptions;

  /// Aspect ratio of the signing area (iOS only).
  final AspectRatio? iosSignatureAspectRatio;

  /// Orientation of the signature dialog (Android only).
  final NutrientAndroidSignatureOrientation? androidSignatureOrientation;

  /// Fonts offered for typed signatures (iOS and Web).
  ///
  /// On Web, each name must match a font available to the page (declare
  /// custom fonts via a style sheet `@font-face` rule).
  final List<String>? fonts;

  SignatureCreationConfiguration(
      {this.creationModes,
      this.colorOptions,
      this.iosSignatureAspectRatio,
      this.androidSignatureOrientation,
      this.fonts});

  Map<String, dynamic> toMap() {
    return {
      'creationModes': creationModes?.map((e) => e.name).toList(),
      'colorOptions': colorOptions?.toMap(),
      'iosSignatureAspectRatio': iosSignatureAspectRatio?.aspectRatio,
      'androidSignatureOrientation': androidSignatureOrientation?.name,
      'fonts': fonts
    }..removeWhere((key, value) => value == null);
  }
}

/// Converts a [Color] to `#RRGGBB` (or `#AARRGGBB` when not fully opaque),
/// matching the format the platform-side parsers accept. Same logic as the
/// legacy wrapper's `ColorToHex` extension, kept private here to avoid
/// exporting a second extension with the same name.
String _colorToHex(Color color) {
  final alpha = (color.a * 255).round();
  final red = (color.r * 255).round();
  final green = (color.g * 255).round();
  final blue = (color.b * 255).round();
  final rgb = '#${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
  if (alpha == 0xFF) return rgb;
  return '#${alpha.toRadixString(16).padLeft(2, '0')}${rgb.substring(1)}';
}
