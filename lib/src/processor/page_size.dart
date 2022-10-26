///  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
///
part of pspdfkit;

/// Standard sizes in PDF points according to http://www.prepressure.com/library/paper-size
class PageSize {
  /// Page size in PDF points.
  final Size size;

  /// Page size in PDF points.
  PageSize(this.size);

  /// Standard A0 841x1189mm size.
  static PageSize get a0 {
    return PageSize(const Size(2384, 3370));
  }

  /// Standard A4 210x297mm size.
  static PageSize get a4 {
    return PageSize(const Size(595, 842));
  }

  /// Standard A5 148x210mm size.
  static PageSize get a5 {
    return PageSize(const Size(420, 595));
  }

  /// Standard US letter 8.5x11" size.
  static PageSize get usLegal {
    return PageSize(const Size(612, 1008));
  }

  /// Standard US legal 8.5x14" size.
  static PageSize get usLetter {
    return PageSize(const Size(612, 792));
  }

  /// Standard B4 250x353mm size.
  static PageSize get b4 {
    return PageSize(const Size(709, 1001));
  }

  /// Standard B5 176x250mm size.
  static PageSize get b5 {
    return PageSize(const Size(499, 709));
  }
}
