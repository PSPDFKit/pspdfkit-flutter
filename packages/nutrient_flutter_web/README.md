# nutrient_flutter_web

The Web implementation of [`nutrient_flutter`](https://pub.dev/packages/nutrient_flutter), the Flutter Document SDK by Nutrient.

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin), which means you can simply use `nutrient_flutter` normally. This package will be automatically included in your app when you do, so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you should add it to your `pubspec.yaml` as usual.

## Requirements

- Modern web browser with WebAssembly support
- Flutter 3.27.0+

## Note on Web implementation

The web platform uses `dart:js_interop` and the Nutrient Web SDK. The `NutrientView` widget provides direct JavaScript interop with the Nutrient Web SDK for full PDF viewing and editing capabilities in the browser.

## Learn more

- [Getting started guide](https://nutrient.io/guides/flutter/)
- [API documentation](https://pub.dev/documentation/nutrient_flutter/latest/)
- [Example project](https://github.com/PSPDFKit/pspdfkit-flutter/tree/master/nutrient_flutter/example)
- [Support](https://support.nutrient.io/hc/en-us/requests/new)
