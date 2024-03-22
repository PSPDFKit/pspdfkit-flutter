///  Copyright © 2023-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

/// Units for PDF document measurements.
enum UnitFrom {
  /// Inches in the imperial system
  inch,

  /// Millimeters in the metric system
  mm,

  /// Centimeters in the metric system
  cm,

  /// Points in the PDF document
  pt,
}

// Units for real world measurements.
enum UnitTo {
  /// Inches in the imperial system
  inch,

  /// Millimeters in the metric system
  mm,

  /// Centimeters in the metric system
  cm,

  ///Points in the PDF document
  pt,

  /// Feet in the imperial system
  ft,

  /// Meters in the metric syste
  m,

  /// Yards in the imperial system
  yd,

  /// Kilometers in the metric system
  km,

  /// Miles in the imperial system
  mi
}

extension UnitFromExtension on UnitFrom {
  String get webName {
    switch (this) {
      case UnitFrom.inch:
        return 'in';
      case UnitFrom.mm:
        return 'mm';
      case UnitFrom.cm:
        return 'cm';
      case UnitFrom.pt:
        return 'pt';
    }
  }
}

extension UnitToExtension on UnitTo {
  String get webName {
    switch (this) {
      case UnitTo.inch:
        return 'in';
      case UnitTo.mm:
        return 'mm';
      case UnitTo.cm:
        return 'cm';
      case UnitTo.pt:
        return 'pt';
      case UnitTo.ft:
        return 'ft';
      case UnitTo.m:
        return 'm';
      case UnitTo.yd:
        return 'yd';
      case UnitTo.km:
        return 'km';
      case UnitTo.mi:
        return 'mi';
    }
  }
}

/// The scale of the document.
/// The scale is used to convert between real world measurements and points.
/// The default scale is 1 inch = 1 inch.
class MeasurementScale {
  /// The unit to convert from.
  final UnitFrom unitFrom;

  /// The original scale.
  final double valueFrom;

  /// The unit to convert to.
  final UnitTo unitTo;

  /// The final scale.
  final double valueTo;

  ///  Scale constructor for the measurement scale of the document.
  ///  @param fromUnits The unit of the valueFrom.
  ///  @param valueFrom The value of the fromUnits.
  ///  @param toUnits The unit of the valueTo.
  ///  @param valueTo The value of the toUnits.
  ///  @return Scale object.
  MeasurementScale(
      {required this.unitFrom,
      required this.valueFrom,
      required this.unitTo,
      required this.valueTo});

  /// The default scale is 1 inch = 1 cm.
  static MeasurementScale defaultScale() {
    return MeasurementScale(
        unitFrom: UnitFrom.inch,
        valueFrom: 1.0,
        unitTo: UnitTo.cm,
        valueTo: 1.0);
  }

  /// @return The scale as a map.
  Map<String, dynamic> toMap() {
    var mm = <String, dynamic>{
      'unitFrom': unitFrom.name,
      'unitTo': unitTo.name,
      'valueFrom': valueFrom,
      'valueTo': valueTo
    };
    return mm;
  }

  Map toWebMap() {
    return {
      'unitFrom': unitFrom.webName,
      'unitTo': unitTo.webName,
      'fromValue': valueFrom,
      'toValue': valueTo
    };
  }

  factory MeasurementScale.fromMap(Map<String, dynamic> map) {
    return MeasurementScale(
      unitFrom: _unitFromFromString(map['unitFrom']),
      valueFrom: map['valueFrom'],
      unitTo: _unitToFromString(map['unitTo']),
      valueTo: map['valueTo'],
    );
  }

  factory MeasurementScale.fromWebMap(Map<String, dynamic> map) {
    return MeasurementScale(
      unitFrom: _unitFromFromWebString(map['unitFrom']),
      valueFrom: map['fromValue'],
      unitTo: _unitToFromWebString(map['unitTo']),
      valueTo: map['toValue'],
    );
  }

  @override
  String toString() {
    return 'Scale{fromUnits: $unitFrom, valueFrom: $valueFrom, toUnits: $unitTo, valueTo: $valueTo}';
  }

  static UnitFrom _unitFromFromString(String name) {
    switch (name) {
      case 'inch':
        return UnitFrom.inch;
      case 'mm':
        return UnitFrom.mm;
      case 'cm':
        return UnitFrom.cm;
      case 'pt':
        return UnitFrom.pt;
    }
    throw Exception('Unknown unit from: $name');
  }

  static UnitFrom _unitFromFromWebString(String name) {
    switch (name) {
      case 'in':
        return UnitFrom.inch;
      case 'mm':
        return UnitFrom.mm;
      case 'cm':
        return UnitFrom.cm;
      case 'pt':
        return UnitFrom.pt;
    }
    throw Exception('Unknown unit from: $name');
  }

  static UnitTo _unitToFromString(String name) {
    switch (name) {
      case 'inch':
        return UnitTo.inch;
      case 'mm':
        return UnitTo.mm;
      case 'cm':
        return UnitTo.cm;
      case 'pt':
        return UnitTo.pt;
      case 'ft':
        return UnitTo.ft;
      case 'm':
        return UnitTo.m;
      case 'yd':
        return UnitTo.yd;
      case 'km':
        return UnitTo.km;
      case 'mi':
        return UnitTo.mi;
    }
    throw Exception('Unknown unit to: $name');
  }

  static UnitTo _unitToFromWebString(String name) {
    switch (name) {
      case 'in':
        return UnitTo.inch;
      case 'mm':
        return UnitTo.mm;
      case 'cm':
        return UnitTo.cm;
      case 'pt':
        return UnitTo.pt;
      case 'ft':
        return UnitTo.ft;
      case 'm':
        return UnitTo.m;
      case 'yd':
        return UnitTo.yd;
      case 'km':
        return UnitTo.km;
      case 'mi':
        return UnitTo.mi;
    }
    throw Exception('Unknown unit to: $name');
  }
}
