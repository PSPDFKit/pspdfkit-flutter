import 'nutrient_web_toolbar_item_type.dart';

///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Represents a toolbar item in the PSPDFKit Web toolbar.
/// See [PSPDFKit.ToolbarItem](https://www.nutrient.io/api/web/PSPDFKit.ToolbarItem.html)
class NutrientWebToolbarItem {
  final NutrientWebToolbarItemType type;
  final String? title;
  final String? className;
  final bool? disabled;
  final String? dropdownGroup;
  final String? icon;
  final String? id;
  final List<String>? mediaQueries;
  final Function? onPress;
  final String? preset;
  final String? responsiveGroup;
  final bool? selected;

  NutrientWebToolbarItem(
      {required this.type,
      this.title,
      this.className,
      this.disabled,
      this.dropdownGroup,
      this.icon,
      this.id,
      this.mediaQueries,
      this.onPress,
      this.preset,
      this.responsiveGroup,
      this.selected});
}
