///
///  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Represents a custom toolbar item for PSPDFKit.
class CustomToolbarItem {
  /// The identifier for the toolbar item. Must be unique.
  final String identifier;

  /// The title for the toolbar item. Displayed in the overflow menu.
  final String title;

  /// Icon name for Android (resource name in drawable) or iOS (SF Symbol name).
  final String? iconName;

  /// Optional color for the toolbar item icon. Will be applied based on platform capabilities.
  final String? iconColor;

  /// Optional grouped position of the toolbar item.
  /// For iOS, this corresponds to the position in the navigation bar.
  /// For Android, this is used to determine positioning in the toolbar.
  final ToolbarPosition position;

  /// Constructor for CustomToolbarItem.
  CustomToolbarItem({
    required this.identifier,
    required this.title,
    this.iconName,
    this.iconColor,
    this.position = ToolbarPosition.primary,
  });

  /// Convert to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier,
      'title': title,
      'iconName': iconName,
      'iconColor': iconColor,
      'position': position.name,
    };
  }
}

/// Defines the position of toolbar items.
enum ToolbarPosition {
  /// Primary position, typically visible in the main toolbar.
  primary,

  /// Secondary position, may be in overflow menu.
  secondary,

  /// For iOS, represents the navigation bar left (leading) position.
  iosLeft,

  /// For iOS, represents the navigation bar right (trailing) position.
  iosRight,
}
