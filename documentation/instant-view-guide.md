# NutrientInstantView

`NutrientInstantView` is a Flutter widget that embeds a live collaborative PDF document into your widget tree. It connects to a [Nutrient Document Engine][document-engine-setup] server and renders the document with real-time annotation sync — multiple users see each other's changes instantly without any extra setup.

**Platform support:** Android, iOS. Web renders a placeholder.

## Server setup

Before using `NutrientInstantView`, you need a running Document Engine instance and a signed JWT for the document you want to load.

- [Document Engine — Getting started][document-engine-setup]
- [Deploying Document Engine][document-engine-docker]
- [Real-time collaboration (Instant Sync)][instant-sync]
- [Generating a JWT][jwt-guide]

## Basic usage

Add the widget to your widget tree and give it a `serverUrl` pointing to the document on your Document Engine instance, along with a signed JWT. The widget fills its available space, so wrap it in an `Expanded`, `SizedBox`, or any other layout widget.

```dart
NutrientInstantView(
  serverUrl: 'https://your-server.example.com/api/1/documents/ABC123',
  jwt: 'eyJhbGci...',
  onViewCreated: (NutrientViewHandle handle) {
    // The native view is ready. Store the handle for programmatic access
    // to annotations, page navigation, and other document operations.
  },
)
```

## Constructor parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `serverUrl` | `String` | Yes | Full Document Engine API URL for the document: `https://host/api/1/documents/<id>` |
| `jwt` | `String` | Yes | Signed JWT with at least `read-document` and `write` permissions |
| `configuration` | `NutrientViewConfiguration?` | No | Viewer appearance and behaviour options. See [view-configuration-guide.md](view-configuration-guide.md) |
| `onViewCreated` | `void Function(NutrientViewHandle)?` | No | Called once the native view is initialised and ready |
| `key` | `Key?` | No | Standard Flutter widget key |

## Applying configuration

Use `NutrientViewConfiguration` to customise the viewer's layout, UI, and editing capabilities. Platform-specific options are grouped under `androidConfig` and `iosConfig`.

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

For the full list of options see [view-configuration-guide.md](view-configuration-guide.md).

## Reconnecting and changing documents

`serverUrl` and `jwt` are fixed at construction time — the native SDK establishes the WebSocket connection once and does not observe changes to these values. To switch to a different document or refresh an expired JWT, force the widget to fully rebuild by changing its `key`.

A common pattern is to keep an integer counter in state and increment it whenever new connection settings are applied:

```dart
int _viewKey = 0;

void _applyNewConnection(String serverUrl, String jwt) {
  setState(() {
    _serverUrl = serverUrl;
    _jwt = jwt;
    _viewKey++; // Forces NutrientInstantView to rebuild with new values.
  });
}

NutrientInstantView(
  key: ValueKey(_viewKey),
  serverUrl: _serverUrl!,
  jwt: _jwt!,
)
```

## Full example

See `nutrient_flutter/example/lib/nutrient_instant_view_example.dart` for a complete working example including a connection sheet, status indicator, and platform-specific configuration.

[document-engine-setup]: https://www.nutrient.io/guides/document-engine/
[instant-sync]: https://www.nutrient.io/guides/flutter/instant-synchronization/
[jwt-guide]: https://www.nutrient.io/guides/flutter/instant-synchronization/authentication/
[document-engine-docker]: https://www.nutrient.io/guides/document-engine/deployment/kubernetes/
