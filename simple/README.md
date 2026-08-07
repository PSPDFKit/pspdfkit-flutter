# Nutrient Flutter — Simple example

The smallest end-to-end app built on the Nutrient Flutter **bindings** API: it
initializes the SDK and displays a bundled PDF with `NutrientDocumentView`, on
Android, iOS, and web. No license key — it runs in trial mode (watermarked).

The entire app is one file, [`lib/main.dart`](lib/main.dart):

```dart
await Nutrient.initialize();              // no key, no adapter
// ...
NutrientDocumentView(documentPath: path); // display the document
```

No platform adapter is registered. When you don't pass one, `Nutrient.initialize`
falls back to the SDK's built-in default adapter for the current platform, which
is all `NutrientDocumentView` needs. Register a custom adapter only when you want
to customize the viewer or reach platform-specific APIs — see the
[`catalog/`](../catalog) app for that and the full feature tour.

## Run

```bash
flutter pub get
flutter run            # Android / iOS device or simulator
flutter run -d chrome  # web
```

## Per-platform wiring worth noting

Even with no adapter in Dart, the federated platform packages must be present so
their native plugins register (that registration is what makes the default
adapter available). They're listed as direct dependencies in
[`pubspec.yaml`](pubspec.yaml), with `dependency_overrides` pointing at the local
monorepo checkout. Beyond that:

- **Android** — the launcher activity is
  `com.nutrient.nutrient_flutter_android.NutrientFlutterActivity` and the
  manifest sets `nutrient_automatic_initialize=true` for trial-mode auto-init.
  See [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml).
- **iOS** — deployment target 17.0 and `use_frameworks!`
  (see [`ios/Podfile`](ios/Podfile)).
- **Web** — the Nutrient Web SDK `<script>` is loaded in
  [`web/index.html`](web/index.html) before the Flutter app boots.
