# PSPDFKit Flutter

PSPDFKit wrapper for Flutter.

> If you are new to Flutter, make sure to check our [introductory blog post "How I Got Started With Flutter"](https://pspdfkit.com/blog/2018/starting-with-flutter/)

Platform specific README exists for [Android](android/).

# Setup

## Integration into a new Flutter app

### Android

Let's create a simple app that integrates PSPDFKit and uses the Flutter pspdfkit plugin.

1. Run `flutter create --org com.example.myapp myapp`.
2. Open `myapp/pubspec.yaml` and under `dependencies` add 
```yaml
  pspdfkit_flutter:
    git:
      url: git://github.com/PSPDFKit/pspdfkit-flutter.git
```
<strong>Spaces are important</strong>, so don't forget them.

3. From `myapp` run `flutter packages get` to install the packages.
4. Open `myapp/android/local.properties` and specify the following properties

```local.properties
sdk.dir=/path/to/your/Android/sdk
flutter.sdk=/path/to/your/flutter/sdk
pspdfkit.password=YOUR_PASSWORD_GOES_HERE
flutter.buildMode=debug
```

5. Open `myapp/android/app/build.gradle` and modify `compileSdkVersion` from `27` to `28`, `minSdkVersion` from `16` to `19`, `targetSdkVersion` from `27` to `28` and add compile options to enable desugaring 
  
  ```groovy
  compileOptions {
        sourceCompatibility 1.8
        targetCompatibility 1.8
    }
  ```
  
**Four changes** to edit:

```diff
...
android {
-   compileSdkVersion 27
+   compileSdkVersion 28
    
+    compileOptions {
+       sourceCompatibility 1.8
+       targetCompatibility 1.8
+   }

    lintOptions {
        disable 'InvalidPackage'
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId "com.example.myapp"
-       minSdkVersion 16
+       minSdkVersion 19
-       targetSdkVersion 27
+       targetSdkVersion 28
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
    }
...
```


6. Open `myapp/lib/main.dart` and replace the whole content with a simple example that will load a pdf document from local device filesystem

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:simple_permissions/simple_permissions.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _frameworkVersion = '';

  present() {
    Pspdfkit.present("file:///sdcard/document.pdf");
  }

  showDocument(BuildContext context) async {
    try {
      if (await Pspdfkit.checkWriteExternalStoragePermission()) {
        present();
      } else {
        PermissionStatus permissionStatus =
            await Pspdfkit.requestWriteExternalStoragePermission();
        if (permissionStatus == PermissionStatus.authorized) {
          present();
        } else if (permissionStatus == PermissionStatus.deniedNeverAsk) {
          _showToast(context);
        }
      }
    } on PlatformException catch (e) {
      print("Failed to open document: '${e.message}'.");
    }
  }

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String frameworkVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      frameworkVersion = await Pspdfkit.frameworkVersion;
    } on PlatformException {
      frameworkVersion = 'Failed to get platform version. ';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _frameworkVersion = frameworkVersion;
    });
  }

  _openSettings(ScaffoldState scaffold) {
    scaffold.hideCurrentSnackBar();
    Pspdfkit.openSettings();
  }

  _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('PSPDFKit Flutter example requires file system permissions to open a PDF document into the sdcard folder.'),
        action: SnackBarAction(
            label: 'Open Settings', onPressed: () => _openSettings(scaffold)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('PSPDFKit Flutter Plugin example app'),
          ),
          body: Builder(
            // Create an inner BuildContext so that the onPressed methods
            // can refer to the Scaffold with Scaffold.of().
            builder: (BuildContext context) {
              return Center(
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                    new Text('PSPDFKit for $_frameworkVersion\n',
                        style: themeData.textTheme.display1
                            .copyWith(fontSize: 21.0)),
                    new RaisedButton(
                        child: new Text('Tap to Open Document',
                            style: themeData.textTheme.display1
                                .copyWith(fontSize: 21.0)),
                        onPressed: () => showDocument(context))
                  ]));
            },
          )),
    );
  }
}
```

7. Enter your PSPDFKit license key into `myapp/android/app/src/main/AndroidManifest.xml` file: 

  ```diff
     <application>
        ...

  +      <meta-data
  +          android:name="pspdfkit_license_key"
  +          android:value="YOUR_LICENSE_KEY_GOES_HERE"/>

     </application> 
  ```

8. Before launching the app you need to copy a PDF document onto your development device or emulator
```bash
adb push /path/to/your/document.pdf /sdcard/document.pdf
```

9. The app is ready to start! From `myapp` run `flutter run`.


# Example

To see PSPDFKit Flutter in action check out our [Flutter example app](example/).

Showing a PDF document inside you Flutter app is as simple as this:

```MyApp.dart 
showDocument() async {
    try {
        Pspdfkit.present("file:///sdcard/document.pdf");
    } on PlatformException catch (e) {
        print("Failed to open document: '${e.message}'.");
    }
}
```

## iOS

1. Run `flutter create --org com.example.myapp myapp`.
2. Open `myapp/pubspec.yaml` and under `dependencies` add

```yaml
  path_provider:
  pspdfkit_flutter:
    git:
      url: git://github.com/PSPDFKit/pspdfkit-flutter.git
```

3. Add a `PDFs` directory with a document in it in the root directory: `myapp/PDFs/Guide_v4.pdf` and specify it in your `pubspec.yaml`:

```yaml
  assets:
    - PDFs/   
```
<strong>Spaces are important</strong>, so don't forget them.

4. Step into your newly created app folder: `cd myapp`
5. Open `Runner.xcworkspace` in Xcode: `open Runner.xcworkspace`
6. Make sure the `iOS Deployment Target` is set to 10.0 or higher. 
7. Change "View controller-based status bar appearance" to YES in `Info.plist`.
8. Run `flutter packages get` to install the packages.
9. Open the `Podfile`: `open ios/Podfile` and edit it as follows:

```diff
# Uncomment this line to define a global platform for your project
-   # platform :ios, '9.0'
+   platform :ios, '10.0'
+   use_frameworks!
...
target 'Runner' do

+   pod 'PSPDFKit', podspec:'https://customers.pspdfkit.com/cocoapods/YOUR_COCOAPODS_KEY_GOES_HERE/pspdfkit/latest.podspec'
...
end  
``` 

9. Open `myapp/lib/main.dart` and replace the whole content with a simple example that will load a pdf document from local device filesystem:

```dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

const String DOCUMENT_PATH = 'PDFs/Guide_v4.pdf';
const String PSPDFKIT_FLUTTER_PLUGIN_TITLE = 'PSPDFKit Flutter Plugin example app';
const String OPEN_DOCUMENT_BUTTON = 'Tap to Open Document';
const String PSPDFKIT_FOR = 'PSPDFKit for';
const double FONT_SIZE = 21.0;

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _frameworkVersion = '';

  showDocument() async {
    try {
      final ByteData bytes = await DefaultAssetBundle.of(context).load(DOCUMENT_PATH);
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempDocumentPath = '${tempDir.path}/$DOCUMENT_PATH';

      final file = await new File(tempDocumentPath).create(recursive: true);
      file.writeAsBytesSync(list);
    
      Pspdfkit.present(tempDocumentPath);
    } on PlatformException catch (e) {
      print("Failed to open document: '${e.message}'.");
    }
  }

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  frameworkVersion() {
    return '$PSPDFKIT_FOR $_frameworkVersion\n';
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String frameworkVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      frameworkVersion = await Pspdfkit.frameworkVersion;
    } on PlatformException {
      frameworkVersion = 'Failed to get platform version. ';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _frameworkVersion = frameworkVersion;
    });
    
    // Replace 
    Pspdfkit.setLicenseKey("YOUR_LICENSE_KEY_GOES_HERE");
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
      return new CupertinoApp(
        home: new CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
              middle: Text(PSPDFKIT_FLUTTER_PLUGIN_TITLE,
              style: themeData.textTheme.title
              )
          ),
          child: new Center(
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new Text(frameworkVersion(),
                        style: themeData.textTheme.display1.copyWith(fontSize: FONT_SIZE)),
                    new CupertinoButton(
                        child: new Text(OPEN_DOCUMENT_BUTTON),
                        onPressed: showDocument)
                  ])),
              ),
          );
      }
}
```

10. Run `flutter emulators --launch apple_ios_simulator` to launch the iOS Simulator.
11. Run `flutter run`.

# Contributing

Please ensure [you signed our CLA](https://pspdfkit.com/guides/web/current/miscellaneous/contributing/) so we can accept your contributions.
