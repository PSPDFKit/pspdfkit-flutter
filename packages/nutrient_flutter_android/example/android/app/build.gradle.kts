plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.example"
    // The Nutrient SDK's AAR metadata requires compileSdk 37.1, ahead of what this
    // Flutter release defaults to (36).
    compileSdk = 37
    compileSdkMinor = 1
    ndkVersion = "27.2.12479018"

    compileOptions {
        // Java 17, matching the plugin packages and the Nutrient Android SDK: the
        // 11.6.x AAR ships Java 17 class files, which fail `mergeExtDexDebug`
        // ("Error while dexing") when the app module targets Java 11.
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Kotlin 2.3 removed the legacy kotlinOptions { jvmTarget } DSL in favour of the
// compilerOptions DSL.
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
