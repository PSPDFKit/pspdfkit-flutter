///
///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:pspdfkit_flutter/src/web/models/pspdfkit_web_annotation_toolbar_item.dart';

class PspdfkitAnnotationToolbarItemsCallbackOptions {
  final List<PspdfkitWebAnnotationToolbarItem> defaultAnnotationToolbarItems;
  final bool? hasDesktopLayout;

  PspdfkitAnnotationToolbarItemsCallbackOptions(
      {required this.defaultAnnotationToolbarItems,
      required this.hasDesktopLayout});
}
