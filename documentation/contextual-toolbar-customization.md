# Annotation Menu Customization

This document describes the annotation contextual menu customization feature in the Nutrient Flutter SDK.

## Overview

The annotation menu customization feature allows developers to modify the contextual menu that appears when users select annotations in a PDF document. You can remove or disable default menu actions and control the visibility of the style picker.

## Core Features

### 1. Default Menu Actions

The following default menu actions can be removed or disabled:

- `AnnotationMenuAction.delete` - Remove annotation
- `AnnotationMenuAction.copy` - Copy annotation
- `AnnotationMenuAction.cut` - Cut annotation
- `AnnotationMenuAction.color` - Color/style picker
- `AnnotationMenuAction.note` - Add/edit note
- `AnnotationMenuAction.undo` - Undo last action
- `AnnotationMenuAction.redo` - Redo last action

### 2. Menu Configuration Options

- `itemsToRemove` - List of default actions to completely remove from the menu
- `itemsToDisable` - List of default actions to disable (shown but grayed out)
- `showStylePicker` - Show/hide the style picker (default: true)
- `groupMarkupItems` - Group markup annotation tools together (iOS only, default: true)
- `maxVisibleItems` - Maximum items before creating overflow menu (iOS only)

## Platform-Specific Implementation

### iOS Implementation

**Technology**: Uses native `UIMenu` API with `UIAction` and `UICommand` elements

**Capabilities**:

- ✅ **Remove default items** - Can remove most default actions
- ✅ **Disable default items** - Native support for disabled state
- ✅ **Style picker control** - Can show/hide style options
- ✅ **Group markup items** - Can group related annotation tools
- ✅ **Max visible items** - Can suggest maximum items before overflow

**Limitations**:

- Some system actions (like copy/paste) may be protected by iOS
- Maximum visible items is a suggestion and may be overridden by iOS UI guidelines

### Android Implementation

**Technology**: Uses `ContextualToolbar` and `AnnotationEditingToolbar` APIs

**Capabilities**:

- ✅ **Remove default items** - Can remove toolbar items by ID
- ✅ **Disable default items** - Can disable toolbar items  
- ✅ **Style picker control** - Can remove style-related items
- ❌ **Group markup items** - Not supported on Android
- ❌ **Max visible items** - Not supported on Android

**Implementation Details**:

- Uses `setMenuItemVisibility(View.GONE)` to remove items
- Uses `menuItem.isEnabled = false` to disable items
- Handles both `AnnotationEditingToolbar` and generic `ContextualToolbar`

## Feature Comparison Table

| Feature | iOS | Android | Notes |
|---------|-----|---------|-------|
| Remove Default Items | ✅ | ✅ | Both platforms fully supported |
| Disable Default Items | ✅ | ✅ | Both platforms fully supported |
| Style Picker Control | ✅ | ✅ | Both platforms fully supported |
| Group Markup Items | ✅ | ❌ | iOS only |
| Max Visible Items | ✅ | ❌ | iOS only |

## Example Usage

```dart
PdfConfiguration(
  enableAnnotationEditing: true,
  annotationMenuConfiguration: AnnotationMenuConfiguration(
    // Remove actions from the menu (both platforms)
    itemsToRemove: [
      AnnotationMenuAction.delete,
      AnnotationMenuAction.color,
    ],
    // Disable actions - shown but grayed out (both platforms)
    itemsToDisable: [AnnotationMenuAction.copy],
    // Control style picker visibility (both platforms)
    showStylePicker: true,
    // iOS-only options
    groupMarkupItems: true,
    maxVisibleItems: 5,
  ),
)
```

### Working Example

See `example/lib/annotation_menu_example.dart` for a complete implementation.

## API Reference

### AnnotationMenuConfiguration

```dart
class AnnotationMenuConfiguration {
  /// List of default menu actions to remove
  final List<AnnotationMenuAction> itemsToRemove;
  
  /// List of default menu actions to disable (grayed out)
  final List<AnnotationMenuAction> itemsToDisable;
  
  /// Whether to show the style picker (default: true)
  final bool showStylePicker;
  
  /// Group markup items together (iOS only, default: true)
  final bool groupMarkupItems;
  
  /// Maximum visible items before overflow (iOS only)
  final int? maxVisibleItems;
}
```

### AnnotationMenuAction Enum

```dart
enum AnnotationMenuAction {
  delete,  // Remove annotation
  copy,    // Copy annotation
  cut,     // Cut annotation  
  color,   // Color/style picker
  note,    // Add/edit note
  undo,    // Undo last action
  redo,    // Redo last action
}
```

## Summary

The annotation menu customization feature provides essential control over the contextual menu that appears when users select annotations. Both iOS and Android platforms support the core functionality of removing and disabling default menu items, as well as controlling the style picker visibility.
