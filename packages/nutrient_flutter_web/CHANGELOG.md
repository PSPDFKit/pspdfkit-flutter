# Next version

- Fixes `baseUrl` not being applied from the user's configuration before the first `NutrientViewer.load()` call, which caused an assertion error on subsequent loads. (J#HYB-910)
- Adds `WebConfigurationBuilder` to convert `NutrientViewConfiguration` into the Nutrient Web SDK configuration object. (J#HYB-988)

## 1.0.0 - 13 Feb 2026

- Initial release as standalone pub.dev package.
- Web platform bindings using `dart:js_interop` and `package:web` for Nutrient Web SDK integration.
- Provides platform adapter to extend `nutrient_flutter` with native bindings.
- Implements `nutrient_flutter_platform_interface` for the federated plugin architecture.
