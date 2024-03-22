///  Copyright © 2023-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// The precision values for measurement tools.
enum MeasurementPrecision {
  oneDP,
  twoDP,
  threeDP,
  fourDP,
  whole,
  wholeInch,
  halvesInch,
  quartersInch,
  eighthsInch,
  sixteenthsInch
}

extension MeasurementPrecisionExtension on MeasurementPrecision {
  String get webName {
    switch (this) {
      case MeasurementPrecision.oneDP:
        return 'oneDp';
      case MeasurementPrecision.twoDP:
        return 'twoDp';
      case MeasurementPrecision.threeDP:
        return 'threeDp';
      case MeasurementPrecision.fourDP:
        return 'fourDp';
      case MeasurementPrecision.whole:
        return 'whole';
      case MeasurementPrecision.wholeInch:
        return 'whole';
      case MeasurementPrecision.halvesInch:
        return '1/2';
      case MeasurementPrecision.quartersInch:
        return '1/4';
      case MeasurementPrecision.eighthsInch:
        return '1/8';
      case MeasurementPrecision.sixteenthsInch:
        return '1/16';
    }
  }
}
