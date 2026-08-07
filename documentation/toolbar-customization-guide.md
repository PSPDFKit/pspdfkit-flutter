# Customizing the Toolbars

Reorder, trim, group, and extend the viewer's toolbars from Dart — custom
buttons with real Dart callbacks, no platform code required.

The viewer has three customizable toolbars, each with a controller method
reachable from `NutrientDocumentView.onControllerReady`:

| Toolbar | Method | What it holds |
|---------|--------|---------------|
| **Main toolbar** | `setMainToolbarItems` | The viewer's primary bar (zoom, search, annotate, …) |
| **Annotation creation toolbar** | `setAnnotationToolbarItems` | The tool picker shown in annotation mode (ink, highlight, shapes, …) |
| **Annotation editing toolbar** | `setAnnotationEditingToolbarItems` | The property bar shown when an annotation is selected (color, opacity, …) |

All three calls are **re-appliable at any time** — call them again to add,
remove, enable, or disable items dynamically.

```dart
import 'package:nutrient_flutter/bindings.dart';
```

## Main toolbar

[`setMainToolbarItems`](../../nutrient_flutter_platform_interface/lib/src/interfaces/nutrient_controller_interface.dart)
takes a list of [`ToolbarItem`](../../nutrient_flutter_platform_interface/lib/src/configuration/toolbar_item.dart)s.
Two kinds go straight into the list, no wrapper needed:

- **`CustomToolbarItem`** — a custom button backed by a Dart `onPressed`.
  Works on **Android, iOS, and Web**.
- **`ToolbarItemType`** — a built-in item (e.g. `ToolbarItemType.zoomIn`).
  Listing the ones you want, in order, reorders/trims the built-ins —
  honored on **Web only**; Android and iOS keep their native toolbar and
  ignore built-in entries (custom items in the same list still apply).

```dart
NutrientDocumentView(
  documentPath: 'assets/document.pdf',
  onControllerReady: (controller) {
    controller.setMainToolbarItems([
      ToolbarItemType.sidebarThumbnails,
      ToolbarItemType.zoomOut,
      ToolbarItemType.zoomIn,
      ToolbarItemType.annotate,
      CustomToolbarItem(
        id: 'say-hello',
        title: 'Hello',
        onPressed: () => debugPrint('toolbar button tapped'),
      ),
    ]);
  },
)
```

The tap round-trips back into Dart on every platform with the exact same
call. On Android and Web the custom button sits in the viewer's document
toolbar; on iOS it's added to the navigation bar.

`CustomToolbarItem` fields:

| Field | Type | Honored on |
|-------|------|------------|
| `id` | `String` (required, unique) | All |
| `title` | `String?` — label / tooltip | All |
| `onPressed` | `VoidCallback?` — runs on the Dart side | All |
| `disabled` | `bool?` | All (where the platform allows) |
| `icon` | `String?` — URL, data-URI, or inline SVG | Web (native currently renders `title`) |
| `className` | `String?` — CSS class | Web |
| `selected` | `bool?` — active state | Web |

## Annotation creation toolbar

[`setAnnotationToolbarItems`](../../nutrient_flutter_platform_interface/lib/src/interfaces/nutrient_controller_interface.dart)
reorders, trims, or groups the annotation tool picker. Each entry is an
[`AnnotationTool`](../../nutrient_flutter_platform_interface/lib/src/models/annotation_tool.dart)
value or an `AnnotationToolGroup` — a collapsible group occupying one slot,
showing its `representative` until expanded:

```dart
controller.setAnnotationToolbarItems([
  AnnotationTool.inkPen,
  AnnotationTool.freeText,
  AnnotationToolGroup(
    representative: AnnotationTool.highlight,
    items: [
      AnnotationTool.highlight,
      AnnotationTool.underline,
      AnnotationTool.strikeOut,
      AnnotationTool.squiggly,
    ],
  ),
  AnnotationTool.eraser,
]);
```

Supported on **Android and iOS**. On **Web** the annotation tools live in the
main toolbar, so this is a no-op there — include the tool entries
(`ToolbarItemType.ink`, `ToolbarItemType.highlighter`, …) in your
`setMainToolbarItems` list instead.

## Annotation editing toolbar

[`setAnnotationEditingToolbarItems`](../../nutrient_flutter_platform_interface/lib/src/interfaces/nutrient_controller_interface.dart)
reorders or trims the bar shown when an annotation is selected. Entries are
[`AnnotationEditingItem`](../../nutrient_flutter_platform_interface/lib/src/configuration/annotation_editing_item.dart)
values — style controls (`color`, `fillColor`, `outlineColor`, `opacity`,
`thickness`, `blendMode`, `font`, `borderStyle`, `lineEnds`) and actions
(`note`, `delete`):

```dart
controller.setAnnotationEditingToolbarItems([
  AnnotationEditingItem.color,
  AnnotationEditingItem.opacity,
  AnnotationEditingItem.thickness,
  AnnotationEditingItem.note,
  AnnotationEditingItem.delete,
]);
```

Fully supported on **Web and Android**. On **iOS** the style controls apply,
but the `note` / `delete` menu actions are currently ignored (they need
native delegate glue — a tracked follow-up).

## Platform support

| Capability | Android | iOS | Web |
|------------|---------|-----|-----|
| Custom main-toolbar buttons (`CustomToolbarItem`) | ✅ | ✅ | ✅ |
| Built-in main-toolbar reordering (`ToolbarItemType`) | ❌ | ❌ | ✅ |
| Creation-toolbar reorder/group | ✅ | ✅ | ➖ tools are in the main toolbar |
| Editing-toolbar style controls | ✅ | ✅ | ✅ |
| Editing-toolbar `note` / `delete` | ✅ | ❌ follow-up | ✅ |

Platform notes:

- **iOS — mode transitions**: the native SDK owns the navigation bar and may
  rebuild it when the viewer switches modes (e.g. entering/leaving the
  thumbnail or document-editor view), which can drop custom buttons. The call
  is re-appliable — re-invoke `setMainToolbarItems` after such a transition to
  restore them.
- **Web — hiding the toolbar entirely**: set `showToolbar: false` in
  `WebViewConfiguration` to remove the main toolbar altogether.
- **Icons**: on Web, `icon` accepts a URL, data-URI, or inline SVG string;
  Android and iOS currently render the `title` text for custom buttons.

## Related surfaces

- The **annotation contextual menu** (the popup on a selected annotation) is
  configured separately via `AnnotationMenuConfiguration` — see
  [Annotation Menu Customization](contextual-toolbar-customization.md).
- The deprecated Pigeon-based widgets (`NutrientView`, `PspdfkitWidget`) use a
  different `customToolbarItems` API — see the
  [legacy custom toolbar items guide](custom-toolbar-items-guide.md).

## See Also

- [Example: toolbar_customization_example.dart](../catalog/lib/examples/toolbar_customization_example.dart) — main-toolbar custom button + dynamic re-apply
- [Example: annotation_toolbar_customization_example.dart](../catalog/lib/examples/annotation_toolbar_customization_example.dart) — creation grouping + editing bar
- [Working with Events](events-api-guide.md) — react to viewer events from the same controller
- [View Configuration](view-configuration-guide.md) — initial viewer options, including `showToolbar`
