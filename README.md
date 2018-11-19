# PSPDFKit Flutter

PSPDFKit wrapper for Flutter.

> If you are new to Flutter, make sure to check our [introductory blog post "How I Got Started With Flutter"](https://pspdfkit.com/blog/2018/starting-with-flutter/)

Platform specific README exists for [Android](android/).

# Setup

## Integration into a new Flutter app

Let's create a simple app that integrates PSPDFKit and uses the Flutter pspdfkit plugin.

1. Run `flutter create --org com.example.myapp myapp`.
2. Open `myapp/pubspec.yaml` and under `dependencies` add 
```yaml
  pspdfkit:
    git:
      url: git://github.com/PSPDFKit/pspdfkit-flutter.git
```
<strong>Spaces are important</strong>, so don't forget them.

3. From `myapp` run `flutter packages get` to install the packages.
4. Open `myapp/android/local.properties` and specify the following properties

```local.properties
ndk.dir=/path/to/your/Android/sdk/ndk-bundle
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
        applicationId "com.pspdfkit.myapp.myapp2"
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
import 'package:pspdfkit/pspdfkit.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _frameworkVersion = '';

  openExternalDocument() async {
    try {
      Pspdfkit.openExternalDocument("document.pdf");
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

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('PSPDFKit Flutter Plugin example app'),
        ),
        body: new Center(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              new Text('PSPDFKit for $_frameworkVersion\n',
                  style: themeData.textTheme.display1.copyWith(fontSize: 21.0)),
              new RaisedButton(
                  child: new Text('Tap to Open Document',
                      style: themeData.textTheme.display1
                          .copyWith(fontSize: 21.0)),
                  onPressed: openExternalDocument)
            ])),
      ),
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
openExternalDocument() async {
    try {
        Pspdfkit.openExternalDocument("document.pdf");
    } on PlatformException catch (e) {
        print("Failed to open document: '${e.message}'.");
    }
}
```

# Contributing

Please ensure [you signed our CLA](https://pspdfkit.com/guides/web/current/miscellaneous/contributing/) so we can accept your contributions.
