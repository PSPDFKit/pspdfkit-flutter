# Custom Toolbar Items Guide for PSPDFKit Flutter

This guide explains how to implement and customize toolbar items in the PSPDFKit Flutter plugin, including creating custom toolbar items, handling interactions, and adding custom icons.

## Quick Start Example

Here's a quick example demonstrating how to add several custom toolbar items, including a back button, a highlight button with a custom icon, and a share button, along with handling their tap events:

```dart
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'dart:io' show Platform;

PSPDFKitWidget(
  documentPath: 'path/to/document.pdf',
  customToolbarItems: [
    // Back button (left side on iOS)
    CustomToolbarItem(
      identifier: 'action_back',
      title: 'Back',
      iconName: Platform.isIOS ? 'chevron.left' : 'arrow_back',
      position: ToolbarPosition.iosLeft,
    ),
    // Highlight button (main toolbar)
    CustomToolbarItem(
      identifier: 'action_highlight',
      title: 'Highlight',
      iconName: Platform.isIOS ? 'highlighter' : 'highlight_icon',
      iconColor: '#FFCC00',
      position: ToolbarPosition.primary,
    ),
    // Share button (may be in overflow menu on Android)
    CustomToolbarItem(
      identifier: 'action_share',
      title: 'Share',
      iconName: Platform.isIOS ? 'square.and.arrow.up' : 'share',
      position: ToolbarPosition.secondary,
    ),
  ],
  onCustomToolbarItemTapped: (identifier) {
    switch (identifier) {
      case 'action_back':
        Navigator.of(context).pop();
        break;
      case 'action_highlight':
        // Show highlight options or activate highlighting mode
        _pspdfkitWidgetController?.enterAnnotationCreationMode(
          AnnotationType.highlight
        );
        break;
      case 'action_share':
        // Share document
        _shareDocument();
        break;
    }
  },
)
```

## Toolbar Item Positioning

The `CustomToolbarItem` class provides a `position` parameter that controls where your toolbar item appears. The position affects how the toolbar item is displayed on both Android and iOS platforms.

| Position    | Value                      | Behavior                                        |
|-------------|----------------------------|------------------------------------------------|
| `primary`   | `ToolbarPosition.primary`  | Main toolbar (Android) / Right side (iOS)      |
| `secondary` | `ToolbarPosition.secondary`| Overflow menu (Android) / Right side (iOS)     |
| `iosLeft`   | `ToolbarPosition.iosLeft`  | Left side of navigation bar (iOS)              |

## Adding Custom Icons

To make your toolbar items more visually appealing and intuitive, you can add custom icons. The implementation differs between Android and iOS.

### Android

1. Add icon files (Vector Drawables recommended) to your drawable resources:
   ```
   android/app/src/main/res/drawable/my_icon.xml  // Vector drawable
   android/app/src/main/res/drawable/my_icon.png  // Or bitmap image
   ```

2. Reference in code using the filename without extension:
   ```dart
   iconName: 'my_icon'
   ```

### iOS

1. Use SF Symbols (recommended) by providing the symbol name:
   ```dart
   iconName: 'bookmark.fill'  // SF Symbol name
   ```

2. Or use custom images from your asset catalog:
   - Add images to Assets.xcassets in Xcode.
   - Set "Render As" to "Template Image" for tinting.
   - Reference the image set name: `iconName: 'custom_icon'`

## Cross-Platform Implementation

Use `Platform.isIOS` to conditionally provide the correct icon name for each platform. Remember to add the corresponding icon assets to both your Android (`drawable`) and iOS (`Assets.xcassets`) projects.

```dart
import 'dart:io' show Platform;

CustomToolbarItem(
  identifier: 'bookmark_action',
  title: 'Bookmark',
  iconName: Platform.isIOS ? 'bookmark.fill' : 'bookmark_icon',
  iconColor: '#0066CC',  // Blue color (hex format)
  position: ToolbarPosition.primary,
)
```

## Back Button Example

Implementing a custom back button requires adding the `CustomToolbarItem` and handling its tap event to navigate back.

```dart
// Add back button to the customToolbarItems list
CustomToolbarItem(
  identifier: 'action_back',
  title: 'Back',
  iconName: Platform.isIOS ? 'chevron.left' : 'arrow_back',
  position: ToolbarPosition.iosLeft, // Position on the left for iOS
),

// Handle back button tap in the `onCustomToolbarItemTapped` callback
onCustomToolbarItemTapped: (identifier) {
  if (identifier == 'action_back') {
    Navigator.of(context).pop(); // Or your preferred navigation logic
  }
  // ... handle other identifiers
},
```

## Handling Click Events

To respond to user taps on your custom toolbar items, implement the `onCustomToolbarItemTapped` callback. Use the `identifier` passed to the callback to determine which item was tapped and execute the corresponding action.

```dart
onCustomToolbarItemTapped: (identifier) {
  switch (identifier) {
    case 'action_highlight':
      // Example: Activate highlighting annotation mode
      _pspdfkitWidgetController?.enterAnnotationCreationMode(
        AnnotationType.highlight
      );
      break;
    case 'action_share':
      // Example: Implement a function to share the document
      _shareDocument();
      break;
    case 'action_search':
      // Example: Show the built-in search UI
      _pspdfkitWidgetController?.showSearchUI();
      break;
    // Handle other identifiers...
  }
},
```

## Key Tips

- **Identifiers**: Use unique, descriptive strings for each `CustomToolbarItem`.
- **Icons**: Test appearance on both platforms. Prefer vector drawables (Android) and SF Symbols (iOS).
- **Color**: Use the `iconColor` parameter with a hex string (e.g., `'#FF0000'`). For iOS custom images, ensure they are set as "Template Image" in the asset catalog to allow tinting.
- **Callback**: Ensure the `onCustomToolbarItemTapped` callback handles all defined identifiers.
