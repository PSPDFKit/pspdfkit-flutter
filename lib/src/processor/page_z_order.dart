///  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
part of pspdfkit;

/// This class represents Z axis order of a page.
class PageZOrder {
  final String order;

  PageZOrder._(this.order);

  /// The page is rendered in the background.
  static PageZOrder get background {
    return PageZOrder._('BACKGROUND');
  }

  /// The page is rendered in the foreground.
  static PageZOrder get foreground {
    return PageZOrder._('FOREGROUND');
  }
}
