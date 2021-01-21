# PSPDFKit Flutter Example 

This is a brief example of how to use the PSPDFKit with Flutter.

# Requirements

## Android

- Android SDK 29.0.3 or later
- PSPDFKit 6.5.3 for Android or later
- Flutter 1.22.0-12.1.pre or later

## iOS

- The latest [Xcode](https://developer.apple.com/xcode/)
- PSPDFKit 10.1.0 for iOS or later
- Flutter 1.23.0-18.1.pre or later
- CocoaPods 1.10.0 or later (Update cocoapods with: `gem install cocoapods`)

# Running the Example Project

1. Before trying to run the project, please make sure that you are on the correct versions of all the tools mentioned above.
2. Clone the repository `git clone https://github.com/PSPDFKit/pspdfkit-flutter.git`

3. Create a local property file in `pspdfkit-flutter/example/android/local.properties` and specify the following properties:

```local.properties
sdk.dir=/path/to/your/Android/sdk
flutter.sdk=/path/to/your/flutter/sdk
flutter.buildMode=debug
```

4. cd `pspdfkit-flutter/example`
5. Run `flutter emulators --launch <EMULATOR_ID>` to launch the desired emulator. Optionally, you can repeat this step to launch multiple emulators.
6. The app is ready to start! Run `flutter run -d all` and the PSPDFKit Flutter example will be deployed on all your devices connected, both iOS and Android.
