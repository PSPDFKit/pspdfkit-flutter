# PSPDFKit Flutter Example 

This is a brief example of how to use the PSPDFKit with Flutter.

# Running the Example Project

1. Clone the repository `git clone https://github.com/PSPDFKit/pspdfkit-flutter.git`

2. Create a local property file in `pspdfkit-flutter/example/android/local.properties` and specify the following properties:

```local.properties
sdk.dir=/path/to/your/Android/sdk
flutter.sdk=/path/to/your/flutter/sdk
pspdfkit.password=YOUR_PASSWORD_GOES_HERE
flutter.buildMode=debug
```

3. cd `pspdfkit-flutter/example`
4. Run `flutter emulators --launch <EMULATOR_ID>` to launch the desired emulator. Optionally, you can repeat this step to launch multiple emulators.
5. The app is ready to start! Run `flutter run -d all` and the PSPDFKit Flutter example will be deployed on all your devices connected, both iOS and Android.
