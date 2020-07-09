# PSPDFKit Flutter for Android

## Setup

### Dependencies

In order to build the PSPDFKit Flutter wrapper and example project, you need to prepare a couple of dependencies:

* Flutter SDK
* Android Studio
* `local.properties` file

#### `local.properties`

Upon opening the Flutter example project for the first time inside Android Studio, the IDE will create a new `local.properties` file which should already contain paths to your local Android SDK installation. You will need to add another property `flutter.sdk` which points to your local flutter installation. Like this:

```local.properties
sdk.dir=/path/to/your/android/sdk
ndk.dir=/path/to/your/android/sdk/ndk-bundle
flutter.sdk=/path/to/your/flutter/sdk
```

## Troubleshooting

### Configuration on demand

This project uses Gradle 4.9+ which no longer supports on-demand configuration of projects. It might be that your Android Studio still has configuration on demand enabled, in which case syncing the Gradle files will yield an error like this:

```
> Failed to apply plugin [id 'com.android.application']
   > Configuration on demand is not supported by the current version of the Android Gradle plugin since you are using Gradle version 4.6 or above. Suggestion: disable configuration on demand by setting org.gradle.configureondemand=false in your gradle.properties file or use a Gradle version less than 4.6.
```

To resolve this, please go to your Android Studio preferences and remove the checkmark at `Configure on demand` inside `Build, Execution, Deployment -> Compiler`.