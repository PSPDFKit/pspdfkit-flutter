part of pspdfkit;

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

  ///
  static MeasurementScale defaultScale() {
    UnitTo var0 = UnitTo.cm;
    return MeasurementScale(
        unitFrom: UnitFrom.inch, valueFrom: 1.0, unitTo: var0, valueTo: 1.0);
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

  @override
  String toString() {
    return 'Scale{fromUnits: $unitFrom, valueFrom: $valueFrom, toUnits: $unitTo, valueTo: $valueTo}';
  }
}
