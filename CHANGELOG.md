## Newest Release

### 3.5.0 - 17 Jan 2023
- Adds Instant Synchronization support. (#37675) 
- Updates for PSPDFKit 8.5 for Android. (#38136)
- Updates for PSPDFKit 12.0.2 for iOS. (#38136)

## Previous Releases

### 3.4.1 - 18 Nov 2022

- Updates for PSPDFKit 12.0 for iOS. (#37508)
- Fixes missing header file issue. (#37283) 

### 3.4.0 - 26 Oct 2022

- Adds generating PDF from images, templates and HTML. (#36736)
- Updates for PSPDFKit 8.4.1 Android. (#37192)
- Updates for PSPDFKit  12.0 for iOS. (#37192)
- Fixes keyboard cutting off search results when inline search is disabled. (#35418)
- Fixes an issue where the `PspdfkitView` widget is not rendered in Flutter versions 3.3.0 and above on Android. (#37044)

### 3.3.0 - 19 Jul 2022

- Moved package files from `lib/src` to `lib` to remove import warnings and renamed `main.dart` to `pspdfkit.dart`. (#34058)
- Updates the deployment target to iOS 14.0. (#33871)
- PSPDFKit now requires Flutter 3.0.1 or later (#35028)
- Updates for PSPDFKit 11.4.0 for iOS. (#35384)
- Updates for PSPDFKit 8.2.1 for Android. (#35384)
- Handles multiple initializations exception. (#35079)
- Fixes an issue where tapping on form fields yields unexpected behavior in the Catalog basic example. (#33853)
- Fixes the configuration option `userInterfaceViewMode: 'alwaysHidden'` not hiding the widget’s top bar on iOS. (#31095)

### 3.2.2 - 16 Mar 2022

- Improves the example project by using the `PlatformUtils` class to check for supported platforms (#33212)
- Adds a new **Save As** example to the example project. (#33376)
- Updates for PSPDFKit 11.3.0 for iOS. (#33514)

### 3.2.1 - 04 Mar 2022

- Updates for PSPDFKit 8.1.2 for Android. (#33314)
- Updates for PSPDFKit 11.2.4 for iOS. (#33314)

### 3.2.0 - 14 Feb 2022

- This release requires you to update your Android project's `compileSdkVersion` to version 31. Please refer to [our migration guide](https://pspdfkit.com/guides/flutter/migration-guides/flutter-3-2-0-migration-guide) for this release.
- PSPDFKit now requires Flutter 2.10.1 or later. (#33016)
- Adds a new configuration option to disable autosave. (#32857)
- Adds a new example illustrating manual saving of documents with autosave disabled. (#32857)
- Updates for PSPDFKit 8.1.1 for Android. (#33016)
- Updates for PSPDFKit 11.2.2 for iOS. (#33016)

### 3.1.0 - 06 Jan 2022

- Adds Flutter widget support for Android. (#23824)
- Adds `tiff` support for image documents for Android. (#23824)
- Adds documentation for all the configuration options. (#32246)
- Unifies the configuration options on Android and iOS. (#32246)
- Adds a new example that shows how to open a PDF document using the appropriate platform style. (#32100)
- Adds new Flutter APIs in `pspdfkit_widget.dart`. (#23824)
- Implements Android support for `PspdfkitWidget.applyInstantJson` method. (#23824)
- Implements Android support for `PspdfkitWidget.exportInstantJson` method. (#23824)
- Implements Android support for `PspdfkitWidget.setFormFieldValue` method. (#23824)
- Implements Android support for `PspdfkitWidget.getFormFieldValue` method. (#23824)
- Implements Android support for `PspdfkitWidget.addAnnotation` method. (#23824)
- Implements Android support for `PspdfkitWidget.getAnnotations` method. (#23824)
- Implements Android support for `PspdfkitWidget.getAllUnsavedAnnotations` method. (#23824)
- Implements Android support for `PspdfkitWidget.save` method. (#23824)
- Improves logic in `AnnotationTypeAdapter` for converting an Instant JSON annotation type into a proper `AnnotationType`. (#23824)
- Improves the layout in the Programmatic form filling example. (#23824)
- Unifies Dart examples and removes Cupertino widgets in favor of Material widgets. (#32100)
- PSPDFKit now requires Flutter 2.8.1 or later. (#32494)
- Updates for PSPDFKit 11.2 for iOS. (#32494)
- Renames `pspdfkit_view.dart` into `pspdfkit_widget_controller.dart`. (#23824)
- Fixes button overflow issue on iOS devices in the Flutter example. (#31198)

### 3.0.3 - 07 Dec 2021

- Updates for PSPDFKit 8.0.2 for Android. (#32165)

### 3.0.2 - 02 Nov 2021

- Updates for PSPDFKit 11.1 for iOS. (#31654)
- Updates for PSPDFKit 8.0.1 for Android. (#31743)
- Improves the repository's README. (#31633)

### 3.0.1 - 21 Oct 2021

- Update to PSPDFKit for Android 8.
- PSPDFKit now requires Flutter 2.5.3 or later. (#31360)

### 3.0.0 - 28 Sep 2021

- Adds the ability to open TIFF images as Image Documents. (#28630)
- Adds a `setLicenseKeys` method which accepts both Android and iOS license keys. (#30943)
- Adds support for iOS 15. (#31008)
- PSPDFKit now requires Flutter 2.5.1 or later. (#30960)
- PSPDFKit now requires Xcode 13 or later. (#31008)
- Migrates Flutter APIs to Android embedding v2. (#30680)
- Removes `path_provider` as a dependency. (#30680)

### 2.4.0 - 22 Jul 2021

- Updates to PSPDFKit for Android 7.0. (#30286)
- Bump minimum SDK version `androidMinSdkVersion` to API 21. (#30286)

### 2.3.3 - 19 Jul 2021

- Improves readme file removing `compileOptions` section as not required anymore. (#30258)

### 2.3.2 - 07 Jul 2021

- Updates the deployment target of iOS to 13 for PSPDFKit 10.5 for iOS. (#30057)

### 2.3.1 - 03 Jun 2021

- Updates readme example to enable running with sound null safety. (#29631)
- Adds the implementation for the `save` method on iOS. (#29644)

### 2.3.0 - 01 Jun 2021

- Removes the need of a trial key for running PSPDFKit Flutter in demo mode. (#28297)
- Updates to PSPDFKit for Android 6.6.2 (#29523)

### 2.2.2 - 06 May 2021

- Adds a title image for the plugin frontpage. (#29330)

### 2.2.1 - 03 May 2021

- Reverts some unneeded file changes. (#29286)

### 2.2.0 - 03 May 2021

- Updates the minimum required Dart version to 2.12.0. (#29277)
- Migrates the plugin and the examples to support Sound Null Safety. (#29277)

### 2.1.0 - 20 Apr 2021

- Adds a string for the reader view button in iOS so that it can be used in PSPDFViewController's toolbar. (#28465)
- Fixes dart code formatting. (#28303)
- Updates the `README` for easier getting started instructions and simpler example code. (#28303)
- Updates to PSPDFKit for Android 6.6.0. (#28926)
- Updates example app dependencies to latest: `path_provider` and `cupertino_icons`. (#28926)

### 2.0.1 - 24 Feb 2021

- Updates package description for pub.dev. (#28225)
- Adds pedantic static analysis check and addresses the analysis warnings. (#28225)

### 2.0.0 - 17 Feb 2021

- First pub.dev published version. (#28157)
- Updates the minimum required Flutter SDK version to 1.12.0. (#28157)

### 1.10.6 - 9 Feb 2021

- Adds “Migrating from Version 1.10.3” section in the main README. (pspdfkit-flutter:#83)
- Fixes import in getting started code snippets for iOS and Android. (pspdfkit-flutter:#83)
- Updates the requirements in the iOS README. (pspdfkit-flutter:#83)

### 1.10.5 - 2 Feb 2021

- Fixes the license key in the example project. (pspdfkit-flutter:#82)

### 1.10.4 - 2 Feb 2021

- Updates Gradle version and enable AndroidX for Android plugin and example. (pspdfkit-flutter:#80)
- Updates for PSPDFKit 10.2 for iOS and Xcode 12.4. (pspdfkit-flutter:#81)
- Changes open source license to modified BSD instead of Apache. (pspdfkit-flutter:#79)
- Fixes versioning system to not require a manual update in two places. (pspdfkit-flutter:#80)

### 1.10.3 - 11 Jan 2021

- Updates copyright year to 2021. (pspdfkit-flutter:#75)

### 1.10.2 - 20 Nov 2020

- Updates for PSPDFKit for iOS 10.1 and Xcode 12.2. (pspdfkit-flutter:#74)

### 1.10.1 - 28 Oct 2020

- Updates to PSPDFKit for Android 6.5.3. (pspdfkit-flutter:#71)

### 1.10.0 - 9 Oct 2020

- Updates to PSPDFKit for Android 6.5. (pspdfkit-flutter:#66)

### 1.9.0 - 3 Mar 2020

- Updates to PSPDFKit for Android 6.2. (pspdfkit-flutter:#62)

### 1.8.0 - 21 Jan 2020

- Updates to PSPDFKit for Android 6.1.1. (pspdfkit-flutter:#54)
- Adds Instant JSON document support. (pspdfkit-flutter:#48)
- Fixes example project. (pspdfkit-flutter:#50, #53)

### 1.7.1 - 26 Nov 2019

- Exposes the `pageLayoutMode` and `isFirstPageAlwaysSingle` configuration options. (pspdfkit-flutter:#46)

### 1.7.0 - 8 Oct 2019

- Updates to PSPDFKit for Android 6.0. (pspdfkit-flutter:#36)
- Updates to PSPDFKit for iOS 9. (pspdfkit-flutter:#42)
- Adds Forms API. (pspdfkit-flutter:#28)
