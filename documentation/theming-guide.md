# Customizing the PDF Viewer Appearance

Style the Nutrient PDF viewer from your Flutter app. Each platform uses a different approach:

- **Android** — XML theme resources
- **iOS** — Programmatic colors via `ThemeConfiguration`
- **Web** — Coming soon

---

## Android

The Nutrient SDK on Android resolves colors from XML theme attributes at view inflation time. Define a theme in XML and pass its name through `PdfConfiguration`.

**1. Create `android/app/src/main/res/values/nutrient_theme.xml`:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="viewer_bg">#FF1E1E2E</color>
    <color name="viewer_toolbar_bg">#FF181825</color>
    <color name="viewer_status_bar">#FF11111B</color>
    <color name="viewer_icons">#FFCDD6F4</color>
    <color name="viewer_icons_active">#FF89B4FA</color>

    <style name="MyApp.NutrientTheme" parent="PSPDFKit.Theme.Default">
        <item name="colorPrimary">@color/viewer_toolbar_bg</item>
        <item name="colorPrimaryDark">@color/viewer_status_bar</item>
        <item name="colorAccent">@color/viewer_icons_active</item>
        <item name="windowActionBar">false</item>
        <item name="windowNoTitle">true</item>
        <item name="windowActionModeOverlay">true</item>
        <item name="pspdf__backgroundColor">@color/viewer_bg</item>
        <item name="pspdf__actionBarIconsStyle">@style/MyApp.ActionBarIcons</item>
        <item name="pspdf__contextualToolbarStyle">@style/MyApp.ContextualToolbar</item>
    </style>

    <style name="MyApp.ActionBarIcons" parent="PSPDFKit.ActionBarIcons">
        <item name="pspdf__iconsColor">@color/viewer_icons</item>
        <item name="pspdf__iconsColorActivated">@color/viewer_icons_active</item>
    </style>

    <style name="MyApp.ContextualToolbar" parent="PSPDFKit.ContextualToolbar">
        <item name="pspdf__iconsColor">@color/viewer_icons</item>
        <item name="pspdf__iconsColorActivated">@color/viewer_icons_active</item>
    </style>
</resources>
```

**2. Pass the theme name from Flutter:**

```dart
PdfConfiguration(
  androidDefaultThemeResource: 'MyApp.NutrientTheme',
)
```

**3. For dark mode**, use `androidDarkThemeResource`:

```dart
PdfConfiguration(
  androidDefaultThemeResource: 'MyApp.NutrientTheme.Light',
  androidDarkThemeResource: 'MyApp.NutrientTheme.Dark',
)
```

To customize more components (search, thumbnails, dialogs), add additional `pspdf__` attributes. See the full list in the [Nutrient Android Appearance Styling guide](https://www.nutrient.io/guides/android/customizing-the-interface/appearance-styling/).

A complete dark theme example ships with the SDK:
[`example/android/app/src/main/res/values/dark_theme.xml`](example/android/app/src/main/res/values/dark_theme.xml)

---

## iOS

On iOS, colors are applied programmatically via `ThemeConfiguration`. No native files needed.

```dart
PdfConfiguration(
  themeConfiguration: const ThemeConfiguration(
    backgroundColor: Color(0xFF1E1E2E),
    toolbar: ToolbarTheme(
      backgroundColor: Color(0xFF181825),
      iconColor: Color(0xFFCDD6F4),
      titleColor: Color(0xFFCDD6F4),
    ),
    annotationToolbar: AnnotationToolbarTheme(
      backgroundColor: Color(0xFF1E1E2E),
      iconColor: Color(0xFFBAC2DE),
      activeIconColor: Color(0xFF89B4FA),
    ),
  ),
)
```

**What you can control:**

- `backgroundColor` — viewer background
- `toolbar.backgroundColor` — navigation bar background
- `toolbar.iconColor` — toolbar button tint
- `toolbar.titleColor` — toolbar title text
- `annotationToolbar.backgroundColor` — annotation toolbar background
- `annotationToolbar.iconColor` — annotation toolbar icons
- `annotationToolbar.activeIconColor` — active annotation tool icon

A complete example ships with the SDK:
[`example/lib/theme_example.dart`](example/lib/theme_example.dart)

---

## Web

Coming soon.

---

## Cross-Platform

Combine Android XML themes with iOS programmatic theming:

```dart
import 'dart:io';

PdfConfiguration(
  androidDefaultThemeResource:
      Platform.isAndroid ? 'MyApp.NutrientTheme' : null,
  themeConfiguration: Platform.isIOS
      ? const ThemeConfiguration(
          backgroundColor: Color(0xFF1E1E2E),
          toolbar: ToolbarTheme(
            backgroundColor: Color(0xFF181825),
            iconColor: Color(0xFFCDD6F4),
          ),
          annotationToolbar: AnnotationToolbarTheme(
            backgroundColor: Color(0xFF1E1E2E),
            iconColor: Color(0xFFBAC2DE),
            activeIconColor: Color(0xFF89B4FA),
          ),
        )
      : null,
)
```

## Troubleshooting

- **Android theme not applying** — Verify the style name matches exactly. Run `flutter clean && flutter build apk` to pick up resource changes.
- **Android toolbar icons wrong color** — Don't set `android:colorBackground`. Use `pspdf__backgroundColor` for the viewer and `colorPrimary` for the toolbar.
- **iOS toolbar background not changing** — Ensure `backgroundColor` is set in `ToolbarTheme`.
- **System theme overriding colors** — Set `appearanceMode: AppearanceMode.defaultMode`.

## Further Reading

- [Nutrient Android — Appearance Styling](https://www.nutrient.io/guides/android/customizing-the-interface/appearance-styling/)
- [Nutrient Android — Customizing the Toolbar](https://www.nutrient.io/guides/android/customizing-the-interface/customizing-the-toolbar/)
- [Nutrient Android — Modal Dialogs Styling](https://www.nutrient.io/guides/android/customizing-the-interface/modal-dialogs-styling/)
- [Nutrient iOS — Appearance Customization](https://www.nutrient.io/guides/ios/customizing-the-interface/appearance-customization/)
- [Nutrient iOS — Customizing the Toolbar](https://www.nutrient.io/guides/ios/customizing-the-interface/customizing-the-toolbar/)
