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

3. Replace `YOUR_COCOAPODS_KEY_GOES_HERE` with you Cocoapods key in `pspdfkit-flutter/example/iOS/Podfile`
```bash
...
target 'Runner' do
  pod 'PSPDFKit', podspec:'https://customers.pspdfkit.com/cocoapods/YOUR_COCOAPODS_KEY_GOES_HERE/pspdfkit/latest.podspec'
...  
```

4. The app is ready to start! From `pspdfkit-flutter/example` run `flutter run -d all` and the PSPDFKit Flutter example will be deployed on all you devices connected, both iOS and Android.
