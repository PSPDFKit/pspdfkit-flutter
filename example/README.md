# PSPDFKit Flutter Example 

This is a brief example of how to use the PSPDFKit with Flutter.

# Running Example Project

1. Clone the repository `git clone https://github.com/PSPDFKit/pspdfkit-flutter.git`

2. Create a local property file in `pspdfkit-flutter/example/android/local.properties` and specify the following properties
```local.properties
sdk.dir=/path/to/your/Android/sdk
flutter.sdk=/path/to/your/flutter/sdk
pspdfkit.password=YOUR_PASSWORD_GOES_HERE
flutter.buildMode=debug
```

3. Before launching the app you need to copy a PDF document onto your development device or emulator
```bash
adb push /path/to/your/document.pdf /sdcard/document.pdf
```

4. The app is ready to start! From `pspdfkit-flutter/example` run `flutter run`
