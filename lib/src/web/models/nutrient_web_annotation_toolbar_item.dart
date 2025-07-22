///
///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'models.dart';

typedef NutrientWebAnnotationToolbarItemsCallback
    = List<NutrientWebAnnotationToolbarItem> Function(
        Map<String, dynamic> annotation,
        NutrientAnnotationToolbarItemsCallbackOptions options);

class NutrientWebAnnotationToolbarItem {
  final String? className;
  final bool? disabled;
  final String? icon;
  final String? id;
  final Function? onPress;
  final String? title;
  final NutrientWebAnnotationToolbarItemType type;

  NutrientWebAnnotationToolbarItem({
    this.className,
    this.disabled,
    this.icon,
    this.id,
    this.onPress,
    this.title,
    required this.type,
  });
}
