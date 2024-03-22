///  Copyright © 2024-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
import 'package:pspdfkit_flutter/pspdfkit.dart';

class MeasurementValueConfiguration {
  final String? name;
  final MeasurementScale scale;
  final MeasurementPrecision precision;

  // Only used for Android.
  /// Whether this configuration should be added to the undo stack.
  final bool addToUndo;

  // Only used for Web.
  /// Whether this configuration is selected.
  final bool isSelected;

  MeasurementValueConfiguration(
      {required this.name,
      required this.scale,
      required this.precision,
      this.addToUndo = false,
      this.isSelected = false});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'scale': scale.toMap(),
      'precision': precision.name,
      'addToUndo': addToUndo
    };
  }

  Map<String, dynamic> toWebMap() {
    return <String, dynamic>{
      'name': name,
      'scale': scale.toWebMap(),
      'precision': precision.webName,
      'selected': isSelected
    };
  }

  factory MeasurementValueConfiguration.fromMap(Map<String, dynamic> map) {
    return MeasurementValueConfiguration(
      name: map['name'],
      scale: MeasurementScale.fromMap(map['scale']),
      precision: MeasurementPrecision.values
          .firstWhere((element) => element.name == map['precision']),
    );
  }

  factory MeasurementValueConfiguration.fromWebMap(Map<String, dynamic> map) {
    return MeasurementValueConfiguration(
      name: map['name'],
      scale: MeasurementScale.fromWebMap(map['scale']),
      precision: MeasurementPrecision.values
          .firstWhere((element) => element.webName == map['precision']),
      isSelected: map['selected'] ?? false,
    );
  }
}
