# Nutrient Flutter SDK 5.0.0 Migration Guide

## Overview

We've rebranded the PSPDFKit Flutter SDK to **Nutrient Flutter SDK** to better align with our new branding. Version 5.0.0 marks the official transition with the complete rebranding. This guide covers all changes and provides step-by-step instructions for updating your Flutter applications. Most of your existing code will continue to work, with a few breaking changes detailed below.

## Breaking Changes Summary

### 1. Required Changes

#### Package Name Change

- **Old**: `pspdfkit_flutter`
- **New**: `nutrient_flutter`

**Impact**: You **must** update your `pubspec.yaml` to use the new package name.

#### Import Statements

- **Old**: `import 'package:pspdfkit_flutter/pspdfkit_flutter.dart';`
- **New**: `import 'package:nutrient_flutter/nutrient_flutter.dart';`

**Impact**: You **must** update all import statements in your Dart files.

### 2. Optional Changes

#### Good News: Most APIs Still Work

- Most existing APIs continue to work without modification
- Minimal immediate code changes required
- Old APIs are deprecated but still functional

#### When You're Ready (Optional Migrations)

- Migrate to new `NutrientView` widget (from `PspdfkitWidget`)
- Migrate to new `Nutrient` class (from `Pspdfkit`)
- Update callback parameter names

#### Additional Breaking Changes

- Configuration enum prefixes must be updated (e.g., `PspdfkitAppearanceMode` → `AppearanceMode`)
- Web toolbar classes now use `Nutrient` prefix (e.g., `PspdfkitWebToolbarItem` → `NutrientWebToolbarItem`)

#### Callback Parameter Names (Optional)

Widget callback parameter names have been simplified:

- **Old**: `onPspdfkitWidgetCreated` → **New**: `onViewCreated`
- **Old**: `onPdfDocumentLoaded` → **New**: `onDocumentLoaded`
- **Old**: `onPdfDocumentError` → **New**: `onDocumentError`
- **Old**: `onPdfDocumentSaved` → **New**: `onDocumentSaved`

**Impact**: Optional migration - old parameter names still work with deprecation warnings.

#### New Widgets and Classes (Optional)

These are new alternatives to existing classes. The old classes still work but are deprecated:

##### Main API Classes

- **Old**: `Pspdfkit` class → **New**: `Nutrient` class
- **Old**: `PspdfkitWidget` widget → **New**: `NutrientView` widget
- **Old**: `PspdfkitWidgetController` → **New**: `NutrientViewController`

##### Callback Types

- **Old**: `PspdfkitWidgetCreatedCallback` → **New**: `NutrientViewCreatedCallback`
- **Old**: `PspdfkitDocumentLoadedCallback` → **New**: `NutrientDocumentLoadedCallback`

##### Web-Specific Classes

- **Old**: `PspdfkitWebToolbarItem` → **New**: `NutrientWebToolbarItem`
- **Old**: `PspdfkitWebAnnotationToolbarItem` → **New**: `NutrientWebAnnotationToolbarItem`

##### Platform Interface Classes

- **Old**: `PspdfkitFlutterPlatform` → **New**: `NutrientFlutterPlatform`
- **Old**: `PspdfkitFlutterMethodChannel` → **New**: `NutrientFlutterMethodChannel`
- **Old**: `PspdfkitFlutterWeb` → **New**: `NutrientFlutterWeb`

**Impact**: Optional migration - old classes still work with deprecation warnings.

### 3. Configuration Enum Prefix Changes (Breaking)

All configuration enum prefixes have been simplified by removing the `Pspdfkit` prefix. **This is a breaking change if you use these enums:**

> **How to check if you're affected**: Search your codebase for `Pspdfkit` + enum names (e.g., `PspdfkitAppearanceMode`, `PspdfkitScrollDirection`). If found, you must update them.

#### Core Configuration Enums

| Old                                         | New                                         |
| ------------------------------------------- | ------------------------------------------- |
| `PspdfkitAppearanceMode.dark`               | `AppearanceMode.dark`                       |
| `PspdfkitScrollDirection.horizontal`        | `ScrollDirection.horizontal`                |
| `PspdfkitPageTransition.curl`               | `PageTransition.curl`                       |
| `PspdfkitSpreadFitting.fit`                 | `SpreadFitting.fit`                         |
| `PspdfkitUserInterfaceViewMode.automatic`   | `UserInterfaceViewMode.automatic`           |
| `PspdfkitThumbnailBarMode.floating`         | `ThumbnailBarMode.floating`                 |
| `PspdfkitPageLayoutMode.single`             | `PageLayoutMode.single`                     |
| `PspdfkitAutoSaveMode.immediate`            | `AutoSaveMode.immediate`                    |
| `PspdfkitToolbarPlacement.top`              | `ToolbarPlacement.top`                      |
| `PspdfkitZoomMode.fitToWidth`               | `ZoomMode.fitToWidth`                       |
| `PspdfkitToolbarMenuItems.searchButtonItem` | `ToolbarMenuItems.searchButtonItem`         |
| `PspdfkitSidebarMode.annotations`           | `SidebarMode.annotations`                   |
| `PspdfkitWebInteractionMode.ink`            | `NutrientWebInteractionMode.ink`            |
| `PspdfkitWebToolbarItemType.zoom`           | `NutrientWebToolbarItemType.zoom`           |
| `PspdfkitWebAnnotationToolbarItemType.note` | `NutrientWebAnnotationToolbarItemType.note` |

#### Signature & Form Enums

| Old                                                  | New                                            |
| ---------------------------------------------------- | ---------------------------------------------- |
| `PspdfkitShowSignatureValidationStatusMode.ifSigned` | `ShowSignatureValidationStatusMode.ifSigned`   |
| `PspdfkitSignatureSavingStrategy.alwaysSave`         | `SignatureSavingStrategy.alwaysSave`           |
| `PspdfkitSignatureCreationMode.draw`                 | `SignatureCreationMode.draw`                   |
| `PspdfkitAndroidSignatureOrientation.portrait`       | `NutrientAndroidSignatureOrientation.portrait` |

**Impact**: **Breaking change** - old enum prefixes have been removed. You must update your code if you use these enums.

#### Package Deprecation (Breaking)

- **Old package**: `pspdfkit_flutter` is now officially deprecated
- **New package**: `nutrient_flutter` is the only supported package
- **Migration timeline**: While the old package may still work temporarily, it will no longer receive updates

**Impact**: **You must migrate to `nutrient_flutter` for continued support and updates.**

#### API Priority Changes (Breaking)

- **Old APIs**: Now marked as deprecated with stronger warnings
- **New APIs**: Promoted to primary status
- **Future compatibility**: Old APIs may be removed in future versions

**Impact**: **Plan to migrate to new APIs within the next few releases.**

## Migration Steps

### Automated Migration (Recommended)

We provide a migration script that automatically updates your project. This is the fastest and most reliable way to migrate:

```bash
# Download and run the migration script
curl -O https://raw.githubusercontent.com/PSPDFKit/pspdfkit-flutter/refs/heads/master/tools/migrate_to_nutrient.dart

# Or if you've cloned the repository
dart path/to/pspdfkit-flutter/tools/migrate_to_nutrient.dart
```

#### Migration Script Options

- `--dry-run` - Preview changes without modifying files
- `--update-apis` - Also update class names and enum prefixes (Pspdfkit → Nutrient, PspdfkitWidget → NutrientView, etc.)
- `--help` - Show usage information

#### What the Script Does

1. Updates `pubspec.yaml` dependency from `pspdfkit_flutter` to `nutrient_flutter`
2. Updates all import statements in `.dart` files
3. Optionally updates API class names (with `--update-apis` flag):
   - `Pspdfkit` → `Nutrient`
   - `PspdfkitWidget` → `NutrientView`
   - `PspdfkitWidgetController` → `NutrientViewController`
   - Enum prefixes: `PspdfkitAppearanceMode.` → `AppearanceMode.`
   - Enum prefixes: `PspdfkitScrollDirection.` → `ScrollDirection.`
   - Enum prefixes: `PspdfkitPageTransition.` → `PageTransition.`
   - Enum prefixes: `PspdfkitSpreadFitting.` → `SpreadFitting.`
   - Enum prefixes: `PspdfkitUserInterfaceViewMode.` → `UserInterfaceViewMode.`
   - Enum prefixes: `PspdfkitThumbnailBarMode.` → `ThumbnailBarMode.`
   - Enum prefixes: `PspdfkitPageLayoutMode.` → `PageLayoutMode.`
   - Enum prefixes: `PspdfkitAutoSaveMode.` → `AutoSaveMode.`
   - Enum prefixes: `PspdfkitToolbarPlacement.` → `ToolbarPlacement.`
   - Enum prefixes: `PspdfkitZoomMode.` → `ZoomMode.`
   - Enum prefixes: `PspdfkitToolbarMenuItems.` → `ToolbarMenuItems.`
   - Enum prefixes: `PspdfkitSidebarMode.` → `SidebarMode.`
   - Enum prefixes: `PspdfkitShowSignatureValidationStatusMode.` → `ShowSignatureValidationStatusMode.`
   - Enum prefixes: `PspdfkitSignatureSavingStrategy.` → `SignatureSavingStrategy.`
   - Enum prefixes: `PspdfkitSignatureCreationMode.` → `SignatureCreationMode.`
   - Enum prefixes: `PspdfkitAndroidSignatureOrientation.` → `NutrientAndroidSignatureOrientation.`
   - Enum prefixes: `PspdfkitWebInteractionMode.` → `NutrientWebInteractionMode.`
   - Web classes: `PspdfkitWebToolbarItem` → `NutrientWebToolbarItem`
   - Web enums: `PspdfkitWebToolbarItemType.` → `NutrientWebToolbarItemType.`
   - Web annotation classes: `PspdfkitWebAnnotationToolbarItem` → `NutrientWebAnnotationToolbarItem`
   - Web annotation enums: `PspdfkitWebAnnotationToolbarItemType.` → `NutrientWebAnnotationToolbarItemType.`
   - Callback types: `PspdfkitWidgetCreatedCallback` → `NutrientViewCreatedCallback`
   - Callback parameters: `onPspdfkitWidgetCreated` → `onViewCreated`
   - Callback parameters: `onPdfDocumentLoaded` → `onDocumentLoaded`
   - Callback parameters: `onPdfDocumentError` → `onDocumentError`
   - Callback parameters: `onPdfDocumentSaved` → `onDocumentSaved`
   - Callback methods: `Nutrient.pspdfkitDocumentLoaded` → `Nutrient.documentLoaded`
4. Preserves your code structure and formatting
5. Shows a summary of changes made

#### Example Usage

```bash
# Preview changes first
dart migrate_to_nutrient.dart --dry-run

# Apply migration with new imports
dart migrate_to_nutrient.dart

# Full migration including API updates
dart migrate_to_nutrient.dart --update-apis

# Migrate specific directory
dart migrate_to_nutrient.dart lib/

# Combine options
dart migrate_to_nutrient.dart --dry-run --update-apis
```

### Manual Migration Steps

If you prefer to migrate manually or need more control over the process, follow these steps:

#### Step 1: Update pubspec.yaml

Replace the dependency in your `pubspec.yaml` file:

```diff
dependencies:
- pspdfkit_flutter: ^4.4.1
+ nutrient_flutter: ^5.0.0
```

#### Step 2: Update Import Statements

```diff
- import 'package:pspdfkit_flutter/pspdfkit_flutter.dart';
+ import 'package:nutrient_flutter/nutrient_flutter.dart';
```

#### Step 3: Update Widget Usage

```diff
- PspdfkitWidget(
+ NutrientView(
    documentPath: 'path/to/document.pdf',
    configuration: configuration,
-   onPspdfkitWidgetCreated: (PspdfkitWidgetController controller) {
+   onViewCreated: (NutrientViewController controller) {
      // Handle controller
    },
  )
```

#### Step 4: Update Plugin Initialization

```diff
- await Pspdfkit.initialize(
+ await Nutrient.initialize(
    androidLicenseKey: "YOUR_ANDROID_LICENSE_KEY",
    iosLicenseKey: "YOUR_IOS_LICENSE_KEY",
    webLicenseKey: "YOUR_WEB_LICENSE_KEY",
  );
```

#### Step 5: Update Method Calls

```diff
- await Pspdfkit.present('path/to/document.pdf');
+ await Nutrient.present('path/to/document.pdf');
```

## Compatibility Matrix

| Component    | Old                        | New                      | Status                    |
| ------------ | -------------------------- | ------------------------ | ------------------------- |
| Package Name | `pspdfkit_flutter`         | `nutrient_flutter`       | ⚠️ Use `nutrient_flutter` |
| Main Widget  | `PspdfkitWidget`           | `NutrientView`           | ✅ Both work               |
| Controller   | `PspdfkitWidgetController` | `NutrientViewController` | ✅ Both work               |
| Plugin Class | `Pspdfkit`                 | `Nutrient`               | ✅ Both work               |
| Import       | `pspdfkit_flutter.dart`    | `nutrient_flutter.dart`  | ✅ Both work               |

## Important Notes

### Backward Compatibility

- **Most existing APIs continue to work** - minimal breaking changes
- Old APIs are marked as `@Deprecated` but remain functional
- You can migrate gradually at your own pace
- **Exception**: Enum prefixes are breaking changes and must be updated

### Deprecation Timeline

- **Current (v5.0.0)**: Old APIs deprecated but functional
- **Future versions**: Old APIs will be removed (timeline TBD)

### For New Projects

- Use the new `nutrient_flutter` package and `NutrientView` widget
- Follow the new import patterns and class names from the start

### For Existing Projects

- Continue using old APIs temporarily if needed
- We recommend migrating to new APIs for future compatibility
- Update package dependency to `nutrient_flutter`

## Common Migration Issues & Solutions

### Issue 1: Import Resolution Errors

**Problem**: IDE shows "package not found" errors after changing package name.

**Solution**:

1. Run `flutter clean`
2. Run `flutter pub get`
3. Restart your IDE
4. If using VS Code, reload the window (Cmd/Ctrl + Shift + P → "Developer: Reload Window")

### Issue 2: Mixed API Usage Warnings

**Problem**: Deprecation warnings when using both old and new APIs.

**Solution**: Use consistent API style throughout your app:

```dart
// ❌ Don't mix old and new APIs
import 'package:nutrient_flutter/nutrient_flutter.dart';
await Pspdfkit.initialize(); // Will show deprecation warning

// ✅ Use consistent API style
import 'package:nutrient_flutter/nutrient_flutter.dart';
await Nutrient.initialize(); // Recommended

```

### Issue 3: Type Casting Errors

**Problem**: Type casting fails between old and new controller types.

**Solution**:

```dart
// ❌ Don't cast between different controller types
NutrientViewController controller = widget.controller as NutrientViewController;

// ✅ Use appropriate controller type for your widget
NutrientView(
  onViewCreated: (NutrientViewController controller) {
    // Use NutrientViewController here
  },
)

PspdfkitWidget(
  onPspdfkitWidgetCreated: (PspdfkitWidgetController controller) {
    // Use PspdfkitWidgetController here
  },
)
```

## Additional Resources

- [Nutrient Flutter Documentation][nutrient-flutter-docs]
- [Support][nutrient-support]

## Changelog

See [CHANGELOG.md][changelog] for detailed version history and all changes in the rebranding release.

### Migration Checklist

- ☑️ Update `pubspec.yaml` dependency
- ☑️ Run `flutter pub get`
- ☑️ Update import statements
- ☑️ Test app functionality
- ☑️ Gradually migrate APIs (optional)
- ☑️ Update tests

## Conclusion

*This migration guide covers the major changes in the PSPDFKit to Nutrient rebranding. For the most up-to-date information, please refer to the official documentation at [nutrient.io][nutrient-home].*

**🎉 You're all set!** Your app should now be using the new Nutrient Flutter SDK while maintaining full compatibility with your existing code.

<!-- Link References -->

[nutrient-flutter-docs]: https://nutrient.io/guides/flutter/
[nutrient-support]: https://support.nutrient.io/hc/en-us/requests/new
[changelog]: https://www.nutrient.io/guides/flutter/changelog/
[nutrient-home]: https://nutrient.io
