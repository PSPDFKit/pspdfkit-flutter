# Next version

- Adds `NutrientViewConfiguration`, a typed cross-platform viewer configuration with `IOSViewConfiguration`, `AndroidViewConfiguration`, shared enums (`PageLayoutMode`, `ThumbnailBarMode`, `SpreadFitting`, etc.), and a `PdfConfigurationBuilder` interface. Replaces `NutrientInstantConfiguration`. (J#HYB-988)

## 1.0.0 - 13 Feb 2026

- Initial release as standalone pub.dev package.
- Provides common platform interface for federated plugin architecture.
- Defines abstract APIs for native SDK integration across Android, iOS, and Web platforms.
- Enables extending `nutrient_flutter` with native bindings through platform adapters.
