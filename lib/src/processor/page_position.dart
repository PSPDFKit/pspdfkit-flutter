///  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// This class represents a page position gravity.
class PagePosition {
  final String position;

  PagePosition(this.position);

  /// Page position is at the top.
  static PagePosition get top {
    return PagePosition('TOP');
  }

  /// Page position is at the bottom.
  static PagePosition get bottom {
    return PagePosition('BOTTOM');
  }

  /// Page position is at the left.
  static PagePosition get left {
    return PagePosition('LEFT');
  }

  /// Page position is at the right.
  static PagePosition get right {
    return PagePosition('RIGHT');
  }

  /// Page position is at the center.
  static PagePosition get center {
    return PagePosition('CENTER');
  }

  /// Page position is at the top left.
  static PagePosition get topLeft {
    return PagePosition('TOP_LEFT');
  }

  /// Page position is at the top right.
  static PagePosition get topRight {
    return PagePosition('TOP_RIGHT');
  }

  /// Page position is at the bottom left.
  static PagePosition get bottomLeft {
    return PagePosition('BOTTOM_LEFT');
  }

  /// Page position is at the bottom right.
  static PagePosition get bottomRight {
    return PagePosition('BOTTOM_RIGHT');
  }
}
