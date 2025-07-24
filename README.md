# Flutter Document SDK by Nutrient

Add powerful PDF functionality to your Flutter apps with the Nutrient Flutter SDK. View, annotate, and edit PDFs seamlessly across Android, iOS, and Web platforms.

## Requirements

- Flutter SDK (latest stable version)
- For Android:
  - Android Studio (latest stable version)
  - Android NDK
  - Android Virtual Device or physical device
- For iOS:
  - Xcode 16 or later
  - iOS 16.0 or later
- For Web:
  - Modern web browser with WebAssembly support

## Installation

1. Add the Nutrient Flutter SDK to your `pubspec.yaml`:

```yaml
dependencies:
  nutrient_flutter: any
```

2. Run the following command:

```bash
flutter pub get
```

## Platform Setup

### Android Setup

1. Update your Android configuration in `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 35
    
    defaultConfig {
        minSdkVersion 21
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:<version>'
}
```

2. Update your theme in `android/app/src/main/res/values/styles.xml`:

```diff
- <style name="NormalTheme" parent="Theme.AppCompat.Light.NoActionBar">
+ <style name="NormalTheme" parent="PSPDFKit.Theme.Default">
```

3. Update your main activity to use `FlutterAppCompatActivity`:

```kotlin
import io.flutter.embedding.android.FlutterAppCompatActivity

class MainActivity: FlutterAppCompatActivity() {
}
```

### iOS Setup

Make sure to set the minimum iOS version to 16.0 in your `ios/Podfile`:

```ruby
platform :ios, '16.0'
```

### Web Setup

You can include the Nutrient Web SDK using either CDN or local installation:

#### Option 1: CDN (Recommended)

Add the following script to your `web/index.html` file:

```html
<script src="https://cdn.cloud.pspdfkit.com/pspdfkit-web@1.1.0/nutrient-viewer.js"></script>
```

**Note:** Replace `1.1.0` with the latest version of Nutrient Web SDK. Check the [latest releases][web changelog] for the current version.

#### Option 2: Local Installation

1. [Download Nutrient Web SDK][download web sdk]. The download will start immediately and save a `.tar.gz` archive like `PSPDFKit-Web-binary-<version>.tar.gz` to your computer.

2. Once downloaded, extract the archive and copy the **entire** contents of its `dist` folder to your project's `web/assets` folder.

3. Verify your `assets` folder contains:
   - `nutrient-viewer.js` file
   - `nutrient-viewer-lib` directory with library assets

4. Add the Nutrient library to your `web/index.html`:

```html
<script src="assets/nutrient-viewer.js"></script>
```

Note: Your server must have the `Content-Type: application/wasm` MIME type configured for WebAssembly files.

## Sample Document Setup

1. Create a `PDFs` directory in your project root:

```bash
mkdir PDFs
```

2. Download our [sample PDF document][sample document] and save it as `Document.pdf` in the `PDFs` directory.

3. Add the assets directory to your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - PDFs/
```

## Usage

Create a new file `lib/main.dart` with the following content:

```dart
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

const String documentPath = 'PDFs/Document.pdf';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Nutrient SDK with your license key
  await Nutrient.initialize(
    androidLicenseKey: 'YOUR_ANDROID_LICENSE_KEY',
    iosLicenseKey: 'YOUR_IOS_LICENSE_KEY',
    webLicenseKey: 'YOUR_WEB_LICENSE_KEY',
  );

   runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> extractAsset(BuildContext context, String assetPath) async {

    if (kIsWeb) {
      return assetPath;
    }

    final bytes = await DefaultAssetBundle.of(context).load(assetPath);
    final list = bytes.buffer.asUint8List();
    final tempDir = await Nutrient.getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/$assetPath';
    final file = File(tempDocumentPath);

    await file.create(recursive: true);
    file.writeAsBytesSync(list);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
          future: extractAsset(context, documentPath),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              /// NutrientView is a widget that displays a PDF document.
              return NutrientView(
                documentPath: snapshot.data!,
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
```

**Note:** Replace `'YOUR_ANDROID_LICENSE_KEY'`, `'YOUR_IOS_LICENSE_KEY'`, and `'YOUR_WEB_LICENSE_KEY'` with your actual license keys. Do not pass any license keys if you want to run the SDK in demo mode, the SDK will run in demo mode with a watermark.

## Learn More

- [Documentation][documentation]
- [Example Projects][example project]
- [Release Notes][release notes]
- [Customization][customization]
- [Migration Guide][migration guide]

## Support

Visit our [Support Center][support] for help with the SDK.

## License

This project is licensed under the Nutrient Commercial License. See [LICENSE][license file] for details.

[documentation]: https://www.nutrient.io/guides/flutter/
[example project]: https://github.com/PSPDFKit/pspdfkit-flutter
[release notes]: https://www.nutrient.io/changelog/flutter
[customization]: https://www.nutrient.io/guides/flutter/customize/
[migration guide]: https://nutrient.io/guides/flutter/upgrade/
[support]: https://support.nutrient.io
[download web sdk]: https://my.nutrient.io/download/web/latest
[sample document]: https://www.nutrient.io/downloads/pspdfkit-web-demo.pdf
[web changelog]: https://www.nutrient.io/changelog/web/
[license file]: LICENSE