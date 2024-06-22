# Flutter PDF Library by PSPDFKit

![Flutter Intro](screenshots/flutter-intro.png)

PSPDFKit for Flutter is an SDK for viewing, annotating, and editing PDFs. It offers developers the ability to quickly add PDF functionality to any Flutter application. It is available at [pub.dev](https://pub.dev/packages/pspdfkit_flutter) and [GitHub](https://github.com/PSPDFKit/pspdfkit-flutter).

If you are new to Flutter, make sure to check our Flutter blog posts:

- [How I Got Started With Flutter](https://pspdfkit.com/blog/2018/starting-with-flutter/).
- [Getting Started with Flutter PDF Library by PSPDFKit](https://pspdfkit.com/blog/2019/getting-started-with-pspdfkit-flutter/).
- [Opening a PDF in Flutter](https://pspdfkit.com/blog/2019/opening-a-pdf-in-flutter/).
- [How to Bridge Native iOS Code to Flutter](https://pspdfkit.com/blog/2021/how-to-bridge-native-ios-code-to-flutter/).
- [How to Customize Our Flutter PDF SDK for Android](https://pspdfkit.com/blog/2021/how-to-customize-our-flutter-pdf-sdk/).
- [Advances in Hybrid Technologies](https://pspdfkit.com/blog/2019/advances-in-hybrid-technologies/).
- [How We Maintain Our Public Flutter Project Using a Private Monorepo](https://pspdfkit.com/blog/2021/maintaining-open-source-repo-from-monorepo/).
- [How to Download and Display a PDF Document in Flutter with PSPDFKit](https://pspdfkit.com/blog/2022/download-and-display-pdf-in-flutter-with-pspdfkit/).

For our quick-start guides, [check out our website](https://pspdfkit.com/getting-started/mobile/?frontend=flutter).

Platform specific README exists for [Android](android/) and [iOS](ios/).

# Setup

## Integration into a New Flutter App

### Install PSPDFKit Flutter Plugin

1. Open `pubspec.yaml`:

    ```bash
    open pubspec.yaml
    ```

2. Add the PSPDFKit dependency in `pubspec.yaml`:

    ```diff
     dependencies:
       flutter:
         sdk: flutter
    +  pspdfkit_flutter: any
    ```


3. Open `lib/main.dart` and replace the entire content with the contents of [demo_project_main.dart.txt](doc/demo_project_main.dart.txt). This simple example will load a PDF document from local device filesystem.

4. Add the PDF document you want to display in your project’s `assets` directory.
    - First create a `PDFs` directory:

        ```bash
        mkdir PDFs
        ```

    - Move a [sample document](example/PDFs/PSPDFKit.pdf) into the newly created `PDFs` directory, and rename it as `Document.pdf`:

        ```bash
        cp ~/Downloads/PSPDFKit.pdf PDFs/Document.pdf
        ```

5. Specify the `assets` directory in `pubspec.yaml`:

    ```diff
     # The following section is specific to Flutter.
     flutter:
    +  assets:
    +    - PDFs/
     ...
    ```

6.  From the terminal app, run the following command to get all the packages:

    ```bash
    flutter pub get
    ```

### Android

#### Requirements

- The [latest stable version of Flutter][install-flutter]
- The [latest stable version of Android Studio][android studio]
- The [Android NDK][install ndk]
- An [Android Virtual Device][managing avds] or a hardware device

#### Getting Started

1. Create a Flutter project called `pspdfkit_demo` with the `flutter` CLI:

    ```bash
    flutter create --org com.example.pspdfkit_demo pspdfkit_demo
    ```

2. In the terminal app, change the location of the current working directory to your project:

    ```bash
    cd pspdfkit_demo
    ```

3. Update the `pluginManagement` block in the `android/settings.gradle` file as follows:

    ```diff
    pluginManagement {
        ...
    +    buildscript {
    +        repositories {
    +            mavenCentral()
    +            maven {
    +                url = uri("https://storage.googleapis.com/r8-releases/raw")
    +            }
    +        }
    +        dependencies {
    +            classpath("com.android.tools:r8:8.3.37")
    +       }
    +    }
    }

    // Upgrade Kotlin version.
    plugins {
        id "dev.flutter.flutter-plugin-loader" version "1.0.0"
        id "com.android.application" version "7.3.0" apply false
    -   id "org.jetbrains.kotlin.android" version "1.7.10" apply false
    +   id "org.jetbrains.kotlin.android" version "1.8.22" apply false
    }
    ```
    This step involves enabling R8 for code shrinking (not required for AGP 8.* and above) and upgrading the Kotlin version.

4. Open the app’s Gradle build file, `android/app/build.gradle`:

    ```bash
    open android/app/build.gradle
    ```

5. Modify the compile SDK version and the minimum SDK version:

    ```diff
    android {
    -   compileSdkVersion flutter.compileSdkVersion
    +   compileSdkVersion 34
    ...
        defaultConfig {
    -        minSdkVersion flutter.minSdkVersion
    +        minSdkVersion 21
    ...
        }
        compileOptions {
    -       sourceCompatibility JavaVersion.VERSION_1_8
    -       targetCompatibility JavaVersion.VERSION_1_8
    +       sourceCompatibility JavaVersion.VERSION_17
    +       targetCompatibility JavaVersion.VERSION_17
        }

    // If you have this block, update the `jvmTarget` to 17.
        kotlinOptions {
    -        jvmTarget = '1.8'
    +        jvmTarget = '17'
        }
    ...    
    }
    ```
6. Add the AppCompat AndroidX library to your `android/app/build.gradle` file:

    ```diff
    dependencies {
        implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    +   implementation 'androidx.appcompat:appcompat:1.4.0'
    }
    ```
7. Open the project’s main activity class, `android/app/src/main/kotlin/com/example/pspdfkit_demo/pspdfkit_demo/MainActivity.kt`:

    ```bash
        open android/app/src/main/kotlin/com/example/pspdfkit_demo/pspdfkit_demo/MainActivity.kt
    ```

8. Change the base `Activity` to extend `FlutterAppCompatActivity`:

    ```diff
    - import io.flutter.embedding.android.FlutterActivity;
    + import io.flutter.embedding.android.FlutterAppCompatActivity;

    - public class MainActivity extends FlutterActivity {
    + public class MainActivity extends FlutterAppCompatActivity {
    }
    ```

    Alternatively you can update the `AndroidManifest.xml` file to use `FlutterAppCompatActivity` as the launcher activity:

    ```diff
    <activity 
    -   android:name=".MainActivity" 
    +   android:name="io.flutter.embedding.android.FlutterAppCompatActivity" 
        android:launchMode="singleTop" 
        android:theme="@style/LaunchTheme" 
        android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode" 
        android:hardwareAccelerated="true" 
        android:windowSoftInputMode="adjustResize" 
        android:exported="true">
    ```
    **NOTE:** <code>FlutterAppCompatActivity</code> isn’t an official part of the Flutter SDK. It’s a custom <code>Activity</code> that extends <code>AppCompatActivity</code> from the AndroidX AppCompat library, and it’s necessary to use PSPDFKit for Android with Flutter. You can read more about this in the [AppCompatActivity Migration][] guide.

9. Update the theme in `android/app/src/main/res/values/styles.xml` to use `PSPDFKit.Theme.default` as the parent:

    ```diff
    - <style name="NormalTheme" parent="Theme.AppCompat.Light.NoActionBar">
    + <style name="NormalTheme" parent="PSPDFKit.Theme.Default">
    ```
    This is to customize the theme of the PSPDFKit UI. You can read more about this in the [appearance styling][] guide.

10. [Start your Android emulator][start-the-emulator], or connect a device.

11. Run the app with:

    ```bash
    flutter run
    ```

### iOS

#### Requirements

- The [latest stable version of Flutter][install-flutter]
- The [latest stable version of Xcode][xcode]
- The [latest stable version of CocoaPods][cocoapods releases]

#### Getting Started

1. Create a Flutter project called `pspdfkit_demo` with the `flutter` CLI:

    ```bash
    flutter create --org com.example.pspdfkit_demo pspdfkit_demo
    ```

2. In the terminal app, change the location of the current working directory to your project:

    ```bash
    cd pspdfkit_demo
    ```

3. Open `Runner.xcworkspace` from the `ios` folder in Xcode:

    ```bash
    open ios/Runner.xcworkspace
    ```

4. Make sure the `iOS Deployment Target` is set to 15.0 or higher.

    ![iOS Deployment Target](screenshots/ios-deployment-target.png)

5. Change "View controller-based status bar appearance" to YES in `Info.plist`.

    ![iOS View controller-based status bar appearance](screenshots/ios-info-plist-statusbarappearance.png)

6. Open your project’s Podfile in a text editor:

    ```bash
    open ios/Podfile
    ```

7. Update the platform to iOS 15 and add the PSPDFKit Podspec:

    ```diff
    -# platform :ios, '9.0'
    + platform :ios, '15.0'
     ...
     target 'Runner' do
       use_frameworks!
       use_modular_headers!`

       flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
    +  pod 'PSPDFKit', podspec:'https://customers.pspdfkit.com/pspdfkit-ios/latest.podspec'
     end
    ```

8. Run `flutter emulators --launch apple_ios_simulator` to launch the iOS Simulator.

9. Run the app with:

    ```bash
    flutter run
    ```

### Web

#### Requirements

- The [latest stable version of Chrome][chrome]

#### Getting Started

PSPDFKit for Web library files are distributed as an archive that can be extracted manually.

1. <a href="https://my.pspdfkit.com/download/web/latest" target="_blank" rel="noreferrer">Download the framework here</a>. The download will start immediately and will save a `.tar.gz` archive like `PSPDFKit-Web-binary-<%= latest_version(:web) %>.tar.gz` to your computer.

2. Once the download is complete, extract the archive and copy the **entire** contents of its `dist` folder to your project’s `web/assets` folder or any other folder of your choice inside the web subfolder.

3. Make sure your `assets` folder contains the `pspdfkit.js` file and a `pspdfkit-lib` directory with the library assets.

4. Make sure your server has the `Content-Type: application/wasm` MIME typeset. Read more about this in the [Troubleshooting][] section.

5. Include the PSPDFKit library in your `index.html` file:

```html
<script src="assets/pspdfkit.js"></script>
```
6. Run the app with:

    ```bash
    flutter run
    ```

# Example App

To see PSPDFKit for Flutter in action check out our [Flutter example app](example/).

Showing a PDF document inside your Flutter app is as simple as this:

    ```dart
        PspdfkitWidget(documentPath: 'file:///path/to/Documentpdf')
    ```

# Upgrading to a Full PSPDFKit License Key

PSPDFKit is a commercial product and requires the purchase of a license key when used in production. By default, this library will
initialize in demo mode, placing a watermark on each PDF and limiting usage to 60 minutes.

To purchase a license for production use, please reach out to us via https://pspdfkit.com/sales/form/.

To initialize PSPDFKit using a license key, call either of the following before using any other PSPDFKit APIs or features:

To set the license key for both Android and iOS, use:
```
await Pspdfkit.setLicenseKeys("YOUR_FLUTTER_ANDROID_LICENSE_KEY_GOES_HERE", "YOUR_FLUTTER_IOS_LICENSE_KEY_GOES_HERE");
```

To set the license key for the currently running platform, use:
```
await Pspdfkit.setLicenseKey("YOUR_FLUTTER_LICENSE_KEY_GOES_HERE");
```

# Migrating from Previous Version

To upgrade PSPDFKit for Flutter in your app, please refer to the [Upgrade and Migration Guides][flutter upgrade] section.

# Troubleshooting

For Troubleshooting common issues you might encounter when setting up PSPDFKit for Flutter, please refer to the [Troubleshooting][] section.


<!-- References -->

[install-flutter]: https://flutter.dev/docs/get-started/install
[android studio]: https://developer.android.com/studio
[install ndk]: https://developer.android.com/studio/projects/install-ndk
[managing avds]: https://developer.android.com/studio/run/managing-avds.html
[xcode]: https://apps.apple.com/us/app/xcode/id497799835?mt=12
[cocoapods releases]: https://github.com/CocoaPods/CocoaPods/releases
[start-the-emulator]: https://developer.android.com/studio/run/emulator#runningemulator
[flutter upgrade]: https://pspdfkit.com/guides/flutter/upgrade/
[troubleshooting]: https://pspdfkit.com/guides/flutter/troubleshoot/
[appcompatactivity migration]: https://pspdfkit.com/guides/flutter/troubleshooting/pspdfkit-widget-appcompat-activity-issue/
[appearance styling]: /guides/android/customizing-the-interface/appearance-styling
[chrome]: https://www.google.com/chrome/