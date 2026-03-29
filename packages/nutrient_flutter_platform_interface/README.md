# nutrient_flutter_platform_interface

A common platform interface for the [`nutrient_flutter`](https://pub.dev/packages/nutrient_flutter) plugin, the Flutter Document SDK by Nutrient.

This interface allows platform-specific implementations of the `nutrient_flutter` plugin, as well as the plugin itself, to ensure they are supporting the same interface.

## Usage

To implement a new platform-specific implementation of `nutrient_flutter`, extend `NutrientFlutterPlatform` with an implementation that performs the platform-specific behavior.

## Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface) over breaking changes for this package.

See [flutter.dev/go/platform-interface-breaking-changes](https://flutter.dev/go/platform-interface-breaking-changes) for a discussion on why a less-clean interface is preferable to a breaking change.

## Learn more

- [Getting started guide](https://nutrient.io/guides/flutter/)
- [API documentation](https://pub.dev/documentation/nutrient_flutter/latest/)
- [Example project](https://github.com/PSPDFKit/pspdfkit-flutter/tree/master/nutrient_flutter/example)
- [Support](https://support.nutrient.io/hc/en-us/requests/new)
