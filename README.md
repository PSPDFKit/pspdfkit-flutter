# PSPDFKit Flutter

![Flutter Intro](screenshots/flutter-intro.png)

PSPDFKit for Flutter is available at [pub.dev](https://pub.dev/packages/pspdfkit_flutter) and [GitHub](https://github.com/PSPDFKit/pspdfkit-flutter).

If you are new to Flutter, make sure to check our Flutter blog posts:

- [How I Got Started With Flutter](https://pspdfkit.com/blog/2018/starting-with-flutter/).
- [Getting Started with PSPDFKit Flutter](https://pspdfkit.com/blog/2019/getting-started-with-pspdfkit-flutter/).
- [Opening a PDF in Flutter](https://pspdfkit.com/blog/2019/opening-a-pdf-in-flutter/).
- [How to Bridge Native iOS Code to Flutter](https://pspdfkit.com/blog/2021/how-to-bridge-native-ios-code-to-flutter/).
- [How to Customize Our Flutter PDF SDK for Android](https://pspdfkit.com/blog/2021/how-to-customize-our-flutter-pdf-sdk/).
- [Advances in Hybrid Technologies](https://pspdfkit.com/blog/2019/advances-in-hybrid-technologies/).
- [How We Maintain Our Public Flutter Project Using a Private Monorepo](https://pspdfkit.com/blog/2021/maintaining-open-source-repo-from-monorepo/).

For our quick-start guides, [check out our website](https://pspdfkit.com/getting-started/mobile/?frontend=flutter).

Platform specific README exists for [Android](android/) and [iOS](ios/).

# Setup

## Integration into a New Flutter App

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

3. Open the app’s Gradle build file, `android/app/build.gradle`:

    ```bash
    open android/app/build.gradle
    ```

4. Modify the minimum SDK version, and enable `multidex`. All this is done inside the `android` section:

    ```diff
     android {
         defaultConfig {
    -        minSdkVersion 16
    +        minSdkVersion 21
             ...
    +        multiDexEnabled true
         }
     }
    ```

5. Open `pubspec.yaml`:

    ```bash
    open pubspec.yaml
    ```

6. Add the PSPDFKit dependency in `pubspec.yaml`:

    ```diff
     dependencies:
       flutter:
         sdk: flutter
    +  pspdfkit_flutter: any
    ```

7. From the terminal app, run the following command to get all the packages:

    ```bash
    flutter pub get
    ```

8. Then run the command below to upgrade the dependencies:

    ```bash
    flutter pub upgrade
    ```

9. Open `lib/main.dart` and replace the entire content with the contents of [demo_project_main.dart.txt](doc/demo_project_main.dart.txt). This simple example will load a PDF document from local device filesystem.

10. Add the PDF document you want to display in your project’s `assets` directory.
    - First create a `PDFs` directory:

        ```bash
        mkdir PDFs
        ```

    - Move a [sample document](example/PDFs/PSPDFKit.pdf) into the newly created `PDFs` directory, and rename it as `Document.pdf`: 

        ```bash
        cp ~/Downloads/PSPDFKit.pdf PDFs/Document.pdf
        ```

11. Specify the `assets` directory in `pubspec.yaml`:

    ```diff
     # The following section is specific to Flutter.
     flutter:
    +  assets:
    +    - PDFs/
     ...
    ```

12. [Start your Android emulator][start-the-emulator], or connect a device.

13. Run the app with:

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

4. Make sure the `iOS Deployment Target` is set to 13.0 or higher.

    ![iOS Deployment Target](screenshots/ios-deployment-target.png)

5. Change "View controller-based status bar appearance" to YES in `Info.plist`.

    ![iOS View controller-based status bar appearance](screenshots/ios-info-plist-statusbarappearance.png)

6. Add the PSPDFKit dependency in `pubspec.yaml`:

    ```diff
     dependencies:
       flutter:
         sdk: flutter
    +  pspdfkit_flutter:
    ```

7. From the terminal app, run the following command to get all the packages:

    ```bash
    flutter pub get
    ```

8. Then run the command below to upgrade the dependencies:

    ```bash
    flutter pub upgrade
    ```

9. Open your project’s Podfile in a text editor:

    ```bash
    open ios/Podfile
    ```

10. Update the platform to iOS 13 and add the PSPDFKit Podspec:

    ```diff
    -# platform :ios, '9.0'
    + platform :ios, '13.0'
     ...
     target 'Runner' do
       use_frameworks!
       use_modular_headers!`
       
       flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
    +  pod 'PSPDFKit', podspec:'https://customers.pspdfkit.com/pspdfkit-ios/latest.podspec'
     end
    ```

11. Open `lib/main.dart` and replace the entire content with the contents of [demo_project_main.dart.txt](doc/demo_project_main.dart.txt). This simple example will load a PDF document from local device filesystem.

12. Add the PDF document you want to display in your project’s `assets` directory.
    - First create a `PDFs` directory:

        ```bash
        mkdir PDFs
        ```

    - Move a [sample document](example/PDFs/PSPDFKit.pdf) into the newly created `PDFs` directory, and rename it as `Document.pdf`:

        ```bash
        cp ~/Downloads/PSPDFKit.pdf PDFs/Document.pdf
        ```

13. Specify the `assets` directory in `pubspec.yaml`:

    ```diff
     # The following section is specific to Flutter.
     flutter:
    +  assets:
    +    - PDFs/
     ...
    ```

14. Run `flutter emulators --launch apple_ios_simulator` to launch the iOS Simulator.

15. Run the app with:

    ```bash
    flutter run
    ```

# Example App

To see PSPDFKit Flutter in action check out our [Flutter example app](example/).

Showing a PDF document inside your Flutter app is as simple as this:

    ```dart
    Pspdfkit.present('file:///path/to/Document.pdf');
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

# Migrating from Version 1.10.3

Q: I updated the Flutter library and I am getting the following error:

```bash
lib/main.dart:8:8: Error: Error when reading '../../.pub-cache/git/pspdfkit-flutter-b6241555b1ee3e816a0dce65145991c1a4477d94/lib/pspdfkit.dart': No such file or directory
import 'package:pspdfkit_flutter/pspdfkit.dart';
       ^
lib/main.dart:37:7: Error: The getter 'Pspdfkit' isn't defined for the class '_MyAppState'.
 - '_MyAppState' is from 'package:myapp/main.dart' ('lib/main.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'Pspdfkit'.
      Pspdfkit.present(tempDocumentPath);
      ^^^^^^^^
lib/main.dart:58:32: Error: The getter 'Pspdfkit' isn't defined for the class '_MyAppState'.
 - '_MyAppState' is from 'package:myapp/main.dart' ('lib/main.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'Pspdfkit'.
      frameworkVersion = await Pspdfkit.frameworkVersion;
                               ^^^^^^^^
lib/main.dart:73:5: Error: The getter 'Pspdfkit' isn't defined for the class '_MyAppState'.
 - '_MyAppState' is from 'package:myapp/main.dart' ('lib/main.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'Pspdfkit'.
    Pspdfkit.setLicenseKey("YOUR_LICENSE_KEY_GOES_HERE");
    ^^^^^^^^


FAILURE: Build failed with an exception.
````
A: If you were using version [1.10.3](https://github.com/PSPDFKit/pspdfkit-flutter/releases/tag/1.10.3) or earlier, you will need to update the imports in your Dart files like so:

```diff
-import 'package:pspdfkit_flutter/pspdfkit.dart';
+import 'package:pspdfkit_flutter/src/main.dart';
```

# Troubleshooting

## Flutter Updates

To update Flutter to the latest version, all you have to do is run `flutter upgrade`.

## Flutter Configuration Problems

Among the tools provided by Flutter, there is `flutter doctor`, a very handy program that checks your system configuration for you and provides step-by-step actions to take in case of problems.

![Flutter doctor example](screenshots/flutter-doctor.png)

The verbose mode of flutter doctor is even more helpful; it prints out extensive information about the nature of an issue and how to fix it. To run the verbose mode, all you have to do is type `flutter doctor -d`.

### CocoaPods Conflicts With Asdf

If [asdf](https://github.com/asdf-vm/asdf) is installed in your machine it might create problems when running Cocoapods, and Flutter will erroneously suggest to install CocoaPods via brew with `brew install cocoapods`. This won't work because for this specific configuration CocoaPods needs to be installed via [RubyGems](https://rubygems.org/). To fix this configuration issue just type `gem install cocoapods && pod setup`.



[install-flutter]: https://flutter.dev/docs/get-started/install
[android studio]: https://developer.android.com/studio
[install ndk]: https://developer.android.com/studio/projects/install-ndk
[managing avds]: https://developer.android.com/studio/run/managing-avds.html
[xcode]: https://apps.apple.com/us/app/xcode/id497799835?mt=12
[cocoapods releases]: https://github.com/CocoaPods/CocoaPods/releases
[start-the-emulator]: https://developer.android.com/studio/run/emulator#runningemulator
