///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter/src/api/nutrient_api.g.dart';

/// Configuration for annotation contextual menu customization.
class AnnotationMenuConfiguration {
  /// Default menu actions to remove from the contextual menu.
  final List<AnnotationMenuAction> itemsToRemove;

  /// Default menu actions to disable (show as grayed out).
  final List<AnnotationMenuAction> itemsToDisable;

  /// Whether to show the default style picker. Defaults to true.
  final bool showStylePicker;

  /// Whether to group markup annotations (highlight, underline, etc.) together.
  ///
  /// **Platform Support:** iOS only
  final bool groupMarkupItems;

  /// Maximum number of items to show before creating an overflow menu.
  ///
  /// **Platform Support:**
  /// - iOS: ✅ Respects platform UI guidelines
  /// - Android: ⚠️ Limited by toolbar constraints
  final int? maxVisibleItems;

  const AnnotationMenuConfiguration({
    this.itemsToRemove = const <AnnotationMenuAction>[],
    this.itemsToDisable = const <AnnotationMenuAction>[],
    this.showStylePicker = true,
    this.groupMarkupItems = true,
    this.maxVisibleItems,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemsToRemove': itemsToRemove.map((action) => action.index).toList(),
      'itemsToDisable': itemsToDisable.map((action) => action.index).toList(),
      'showStylePicker': showStylePicker,
      'groupMarkupItems': groupMarkupItems,
      'maxVisibleItems': maxVisibleItems,
    };
  }

  /// Converts to Pigeon data object.
  AnnotationMenuConfigurationData toPigeonData() {
    return AnnotationMenuConfigurationData(
      itemsToRemove: itemsToRemove,
      itemsToDisable: itemsToDisable,
      showStylePicker: showStylePicker,
      groupMarkupItems: groupMarkupItems,
      maxVisibleItems: maxVisibleItems,
    );
  }
}
