# NutrientViewConfiguration

`NutrientViewConfiguration` is the configuration object for Nutrient widgets that use the bindings-based implementation (`NutrientInstantView` and the bindings-based `NutrientView`). It controls the viewer's layout, UI chrome, editing capabilities, and appearance.

All fields are optional. Unset fields fall through to the native SDK's built-in defaults, so you only need to set what you want to change. Options that apply to all platforms are top-level fields; options specific to one platform are grouped under `androidConfig`, `iosConfig`, or `webConfig`.

```dart
NutrientInstantView(
  serverUrl: serverUrl,
  jwt: jwt,
  configuration: const NutrientViewConfiguration(
    pageLayoutMode: PageLayoutMode.single,
    thumbnailBarMode: ThumbnailBarMode.floating,
    enableAnnotationEditing: true,
    enableFormEditing: true,
    androidConfig: AndroidViewConfiguration(
      showSearchAction: true,
      showOutlineAction: true,
    ),
    iosConfig: IOSViewConfiguration(
      spreadFitting: SpreadFitting.adaptive,
    ),
  ),
)
```

---

## Cross-platform fields

These fields apply to Android, iOS, and Web unless noted otherwise.

### Layout

| Field | Type | Description |
|-------|------|-------------|
| `scrollDirection` | `ScrollDirection?` | The axis along which pages scroll: `horizontal` (default) or `vertical` |
| `pageLayoutMode` | `PageLayoutMode?` | How many pages appear side-by-side: `single`, `double`, or `automatic` |
| `pageTransition` | `PageTransition?` | Animation used when moving between pages. See values below |
| `firstPageAlwaysSingle` | `bool?` | When `true`, the first page is always shown alone even in double-page mode. Useful for documents with a full-width cover |
| `startPage` | `int?` | Zero-based index of the page to open on. Applied on Android and Web; ignored on iOS |

#### `PageTransition` values

| Value | Platforms |
|-------|-----------|
| `scrollContinuous` | Android, iOS, Web |
| `scrollPerSpread` | Android, iOS, Web |
| `curl` | iOS only |
| `slideHorizontal`, `slideVertical`, `cover`, `fade` | Android, iOS |
| `scrollContinuousPerPage`, `auto` | Android, iOS |
| `disabled` | Android, iOS, Web |

### UI chrome

| Field | Type | Description |
|-------|------|-------------|
| `userInterfaceViewMode` | `UserInterfaceViewMode?` | When the toolbar and overlays are visible: `automatic` (shown on tap), `always`, `automaticNoFirstLastPage`, or `never` (kiosk/immersive mode) |
| `thumbnailBarMode` | `ThumbnailBarMode?` | Where the page thumbnail strip appears: `none`, `defaultStyle`, `pinned`, `scrubberBar`, `scrollable`, or `floating` |
| `appearanceMode` | `AppearanceMode?` | Colour theme: `defaultMode`, `sepia`, `night`, or `allCustomColors` |

### Editing

| Field | Type | Description |
|-------|------|-------------|
| `enableTextSelection` | `bool?` | Allow the user to select and copy text |
| `enableAnnotationEditing` | `bool?` | Allow creating, moving, and deleting annotations. When `false`, annotations are read-only |
| `enableFormEditing` | `bool?` | Allow filling in PDF form fields. When `false`, fields are rendered but not interactive |
| `disableAutosave` | `bool?` | When `true`, the SDK does not automatically save changes. The app must trigger saves manually via `NutrientViewHandle` |

### Zoom

These fields apply to iOS and Web. Android does not expose zoom constraints through its configuration builder.

| Field | Type | Description |
|-------|------|-------------|
| `minimumZoomScale` | `double?` | Minimum zoom factor the user can zoom out to |
| `maximumZoomScale` | `double?` | Maximum zoom factor the user can zoom in to |

---

## AndroidViewConfiguration

`AndroidViewConfiguration` holds options that only apply to the Android platform. Pass it as `NutrientViewConfiguration.androidConfig`. It is silently ignored on iOS and Web.

```dart
androidConfig: AndroidViewConfiguration(
  showSearchAction: true,
  showOutlineAction: true,
  showBookmarksAction: false,
  inlineSearch: true,
  enableDocumentEditor: false,
  darkThemeResource: 'MyApp_Dark',
  defaultThemeResource: 'MyApp_Light',
)
```

| Field | Type | Description |
|-------|------|-------------|
| `appearanceMode` | `AppearanceMode?` | Overrides the top-level `appearanceMode` on Android |
| `thumbnailBarMode` | `ThumbnailBarMode?` | Overrides the top-level `thumbnailBarMode` on Android |
| `grayScale` | `bool?` | Render the document in greyscale |
| `showPageLabels` | `bool?` | Use named page labels (e.g. "i", "Cover") instead of numeric indices |
| `documentLabelEnabled` | `bool?` | Show the document title as an overlay at the top of the screen |
| `inlineSearch` | `bool?` | Show search as a compact inline bar instead of a full modal dialog |
| `showActionNavigationButtons` | `bool?` | Show back and forward buttons for navigating previously visited pages |
| `showSearchAction` | `bool?` | Show the search button in the toolbar |
| `showOutlineAction` | `bool?` | Show the outline (table of contents) button in the toolbar |
| `showBookmarksAction` | `bool?` | Show the bookmarks button in the toolbar |
| `showAnnotationListAction` | `bool?` | Show a button that opens the annotation list |
| `showThumbnailGridAction` | `bool?` | Show a button that opens the full-screen thumbnail grid |
| `showPrintAction` | `bool?` | Show a print button in the toolbar overflow menu |
| `enableDocumentEditor` | `bool?` | Enable page editing — insertion, deletion, reordering (requires Document Editor licence) |
| `contentEditorEnabled` | `bool?` | Enable in-place text and image editing (requires Content Editor licence) |
| `darkThemeResource` | `String?` | Name of the Android XML theme resource to apply in dark mode |
| `defaultThemeResource` | `String?` | Name of the Android XML theme resource to apply in light mode |

---

## IOSViewConfiguration

`IOSViewConfiguration` holds options that only apply to the iOS platform. Pass it as `NutrientViewConfiguration.iosConfig`. It is silently ignored on Android and Web.

```dart
iosConfig: IOSViewConfiguration(
  spreadFitting: SpreadFitting.adaptive,
  leftBarButtonItems: ['closeButtonItem'],
  rightBarButtonItems: ['annotationButtonItem', 'searchButtonItem'],
)
```

| Field | Type | Description |
|-------|------|-------------|
| `spreadFitting` | `SpreadFitting?` | How a page spread is fitted into the viewport: `fit` (letterbox), `fill` (crop to fill), or `adaptive` (SDK chooses per spread) |
| `thumbnailBarMode` | `ThumbnailBarMode?` | Overrides the top-level `thumbnailBarMode` on iOS |
| `showPageLabels` | `bool?` | Use named page labels instead of numeric indices |
| `documentLabelEnabled` | `bool?` | Show the document title overlay |
| `inlineSearch` | `bool?` | Show search as a compact inline bar instead of a modal sheet |
| `showActionNavigationButtons` | `bool?` | Show back and forward page navigation buttons |
| `allowToolbarTitleChange` | `bool?` | Update the navigation bar title to the current page label while scrolling |
| `bookmarkIndicatorMode` | `IOSBookmarkIndicatorMode?` | When to show the bookmark icon on pages: `off`, `alwaysOn`, or `onWhenBookmarked` |
| `bookmarkIndicatorInteractionEnabled` | `bool?` | Allow tapping the bookmark indicator to toggle bookmarks. Only meaningful when `bookmarkIndicatorMode` is not `off` |
| `leftBarButtonItems` | `List<String>?` | Replaces the default left navigation bar buttons. Pass an empty list to remove all buttons |
| `rightBarButtonItems` | `List<String>?` | Replaces the default right navigation bar buttons. Pass an empty list to remove all buttons |

### Bar button item identifiers

| Identifier | Description |
|------------|-------------|
| `closeButtonItem` | Close/dismiss |
| `annotationButtonItem` | Opens the annotation toolbar |
| `searchButtonItem` | Opens search |
| `outlineButtonItem` | Opens the outline / TOC panel |
| `bookmarkButtonItem` | Opens the bookmarks panel |
| `thumbnailsButtonItem` | Opens the thumbnail grid |
| `printButtonItem` | Opens the print dialog |
| `activityButtonItem` | Opens the system share sheet |
| `brightnessButtonItem` | Opens brightness control |

---

## WebViewConfiguration

`WebViewConfiguration` holds options specific to the Web platform. It is typed as `Object?` in the platform interface to avoid a circular package dependency — import it from `package:nutrient_flutter` and pass it as `webConfig`.

```dart
import 'package:nutrient_flutter/nutrient_flutter.dart';

NutrientViewConfiguration(
  webConfig: WebViewConfiguration(
    showToolbar: true,
    showAnnotations: true,
    readOnly: false,
    theme: 'DARK',
  ),
)
```
