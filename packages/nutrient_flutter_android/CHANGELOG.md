# Next version

- Adds `NutrientInstantViewAndroid`, an Android implementation of the embedded Instant document widget using `InstantPdfUiFragment` via JNI. (J#HYB-988)
- Adds `AndroidConfigurationBuilder` to convert `NutrientViewConfiguration` into the native Android viewer configuration. (J#HYB-988)

## 1.0.0 - 13 Feb 2026

- Initial release as standalone pub.dev package.
- Native Android bindings using JNI for direct Nutrient Android SDK integration.
- Provides platform adapter to extend `nutrient_flutter` with native bindings.
- Implements `nutrient_flutter_platform_interface` for the federated plugin architecture.
