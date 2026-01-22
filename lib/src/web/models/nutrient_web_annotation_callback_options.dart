import 'nutrient_web_annotation_toolbar_item.dart';

///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

class NutrientAnnotationToolbarItemsCallbackOptions {
  final List<NutrientWebAnnotationToolbarItem> defaultAnnotationToolbarItems;
  final bool? hasDesktopLayout;

  NutrientAnnotationToolbarItemsCallbackOptions(
      {required this.defaultAnnotationToolbarItems,
      required this.hasDesktopLayout});
}
