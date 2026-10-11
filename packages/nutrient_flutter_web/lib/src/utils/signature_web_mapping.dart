///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/widgets.dart' show Color;
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

/// Pure (no `dart:js_interop`) mapping helpers for
/// [SignatureCreationConfiguration] → Web SDK `ElectronicSignaturesConfiguration`.
///
/// These are factored out of `WebConfigurationBuilder` so the decision logic
/// (mode string mapping, color-preset localization fallback, byte conversion)
/// can be unit-tested on the Dart VM. `web_configuration_builder.dart` uses
/// these results to construct the actual `dart:js_interop` objects, which
/// requires a real JS host and can't run under `flutter test`'s default VM
/// runner (see `lib/src/_smoke_test.dart` for the same constraint on the raw
/// generated bindings).

/// Maps a [SignatureCreationMode] to the matching
/// `NutrientViewer.ElectronicSignatureCreationMode` string constant.
///
/// These are the stable string ids the Web SDK enum resolves to (`'DRAW'` /
/// `'IMAGE'` / `'TYPE'`, per `defaultElectronicSignatureCreationModes` in the
/// generated bindings) — used as a fallback if the live namespace lookup
/// can't resolve the enum object.
String webCreationModeString(SignatureCreationMode mode) => switch (mode) {
      SignatureCreationMode.draw => 'DRAW',
      SignatureCreationMode.image => 'IMAGE',
      SignatureCreationMode.type => 'TYPE',
    };

/// The plain-Dart shape of a single Web SDK `ColorPreset` entry, prior to
/// being turned into `dart:js_interop` objects.
class WebColorPresetShape {
  /// Color channel bytes (0-255), alpha dropped (Web SDK `Color` has none).
  final int r;
  final int g;
  final int b;

  final String localizationId;
  final String? defaultMessage;
  final String? description;

  WebColorPresetShape({
    required this.r,
    required this.g,
    required this.b,
    required this.localizationId,
    this.defaultMessage,
    this.description,
  });

  @override
  bool operator ==(Object other) =>
      other is WebColorPresetShape &&
      other.r == r &&
      other.g == g &&
      other.b == b &&
      other.localizationId == localizationId &&
      other.defaultMessage == defaultMessage &&
      other.description == description;

  @override
  int get hashCode =>
      Object.hash(r, g, b, localizationId, defaultMessage, description);

  @override
  String toString() => 'WebColorPresetShape(r: $r, g: $g, b: $b, '
      'localizationId: $localizationId, defaultMessage: $defaultMessage, '
      'description: $description)';
}

/// Converts a Flutter [Color] (0.0-1.0 channels) to 0-255 byte values,
/// matching the Web SDK `Color` class's range (see `WebColorUtils` for the
/// equivalent ARGB-int conversion used elsewhere).
(int r, int g, int b) colorToWebBytes(Color color) => (
      (color.r * 255).round(),
      (color.g * 255).round(),
      (color.b * 255).round(),
    );

/// Builds the plain-Dart shape for a single [SignatureColorPreset].
///
/// `localization.id` is required by the Web SDK type; when the preset
/// doesn't specify one, [fallbackId] (`'option1'`/`'option2'`/`'option3'`)
/// is used instead. `defaultMessage`/`description` are only carried through
/// when non-null — the Web SDK type declares both optional.
WebColorPresetShape buildColorPresetShape(
  SignatureColorPreset preset,
  String fallbackId,
) {
  final (r, g, b) = colorToWebBytes(preset.color);
  return WebColorPresetShape(
    r: r,
    g: g,
    b: b,
    localizationId: preset.id ?? fallbackId,
    defaultMessage: preset.defaultMessage,
    description: preset.description,
  );
}

/// Builds the 3-entry (option1/option2/option3) list of preset shapes from
/// [SignatureColorOptions], in display order.
List<WebColorPresetShape> buildColorPresetShapes(
  SignatureColorOptions options,
) =>
    [
      buildColorPresetShape(options.option1, 'option1'),
      buildColorPresetShape(options.option2, 'option2'),
      buildColorPresetShape(options.option3, 'option3'),
    ];
