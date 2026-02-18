## 5.4.0 - 18 Feb 2026

- [**Beta**] Adds federated plugin architecture with platform-specific packages (`nutrient_flutter_platform_interface`, `nutrient_flutter_android`, `nutrient_flutter_ios`, `nutrient_flutter_web`) for native SDK bindings via JNI (Android), FFI (iOS), and `dart:js_interop` (Web). Refer to the [platform adapters](/guides/flutter/platform-adapters/) guide for details. (J#HYB-895)
- [**Beta**] Adds platform adapter APIs (`NutrientPlatformAdapter`, `NutrientController`, `NutrientViewHandle`), enabling direct native SDK access alongside the existing Pigeon-based API. (J#HYB-895)
- Adds platform adapter examples demonstrating native SDK customization, event handling, and UI configuration. (J#HYB-895)
- Adds the `ThemeConfiguration` class to `PdfConfiguration` for configuring the viewer’s theme, including support for light, dark, and custom themes. (J#HYB-947)
- Updates web conditional exports to use `dart.library.js_interop`, replacing the deprecated `dart.library.html`. (J#HYB-895)
- Fixes an Android crash when using the `startPage` configuration option. (J#HYB-948)
- Fixes an iOS issue where `iOSRightBarButtonItems` and `iOSLeftBarButtonItems` weren’t displayed. (J#HYB-948)


## 5.3.1 - 26 Jan 2026

- Fixes an Android crash when adding image annotations with the `annotationsCreated` event listener active. (#50437)
- Fixes a type cast error when parsing `GoToAction` link annotations with integer parameters. (#50437)

## 5.3.0 — 22 Jan 2026

- Adds a headless document API for opening and manipulating PDF documents without displaying a viewer. (J#HYB-931)
- Adds programmatic bookmark management APIs to `PdfDocument` for creating, reading, updating, and deleting bookmarks. (J#HYB-932)
- Adds document dirty state APIs for tracking unsaved changes with cross-platform `hasUnsavedChanges()` and platform-specific methods. (J#HYB-934)
- Adds the `iOSFileConflictResolution` configuration option to handle file conflicts when a PDF is modified externally on iOS. (J#HYB-933)
- Adds the `CustomStampItem` class for configuring custom stamps with colors (iOS) and subtitles (iOS/Android).
- Improves the annotation properties API (J#HYB-935):
  - Fixes the text annotation font color being reset to black when updating other properties like opacity (Web).
  - Fixes the ink annotation line width property not being applied correctly.
  - Fixes the `pspdfkit/undefined` type exception when adding or removing text annotations.
  - Fixes `getAnnotationProperties` returning null for valid annotations.
  - Makes `Annotation` class properties immutable; use `AnnotationProperties` and `AnnotationManager` for updates.
- Updates to Nutrient iOS SDK 26.4.0.
- Updates to Nutrient Android SDK 10.10.1.
- Fixes an Android issue where the PDF view was hidden behind the keyboard when editing form fields. (J#HYB-929)
- Adds `enableFormEditing` configuration option to `PdfConfiguration` for controlling form field editing independently from annotation editing on iOS and Android. (J#HYB-925)

## 5.2.0 - 13 Oct 2025

- Introduces `AnnotationProperties` class to manage and update annotation properties such as color, opacity, line width, flags, and custom data. (J#HYB-879)
- Updates Android SDK configuration (minSdk 24, compileSdk/targetSdk 36) to support Nutrient Android SDK 10.7.0.
- Updates iOS deployment target to 16 to support Nutrient iOS SDK 26.0.0.
- Updates AI Assistant implementation to use new `createAiAssistant` API with `AiAssistantProvider` interface support. (J#HYB-886)
- Fixes issue where getPageInfo throws an error if not page labels are set on Android. (J#HYB-882)
- Fixes issue where updating annotation flags results into unexpected behavior. (J#HYB-880,J#HYB-879)

## 5.1.0 - 04 Sep 2025

- Adds the `androidShowAnnotationCreationAction` configuration option to hide the default annotation creation button while keeping annotation editing functionality enabled on Android. (J#HYB-864)
- Adds `OfficeConversionSettings` for configuring Office document conversion parameters in Nutrient Flutter Web, including spreadsheet dimension controls. (J#HYB-861)
- Adds annotation contextual menu customization support with `AnnotationMenuConfiguration`. (J#HYB-683)
- Improves event listeners handling for better performance and reliability. (J#HYB-868)
- Updates to Nutrient iOS SDK 14.12.0 with the latest features and fixes.
- Updates to Nutrient Android SDK 10.5.0 with the latest features and fixes.
- Updates Kotlin version to 2.1.20 for compatibility with Nutrient Android SDK 10.6.0.
- Fixes an iOS issue where the signature dialog would immediately dismiss when entering annotation creation mode programmatically. (J#HYB-859)
- Fixes an Android race condition when calling `getPageInfo` immediately after `onDocumentLoaded` on a cold start. (J#HYB-870)

## 5.0.1 - 24 Jul 2025

- Update README.md files to include the latest rebranding changes for Nutrient Flutter SDK. (J#HYB-842)

## 5.0.0 - 22 Jul 2025

- Rebrands the PSPDFKit Flutter SDK to Nutrient Flutter SDK. Now available as [`nutrient_flutter`](https://pub.dev/packages/nutrient_flutter) on pub.dev.(J#HG-682)
- Adds the `androidContentEditorEnabled` configuration option to `PdfConfiguration` for controlling content editor availability on Android. (J#HYB-834)
- Adds automatic disabling of date stamps when custom default stamps are configured on iOS for a better user experience. (J#HYB-835)
- Introduces a migration script for seamless upgrade to Nutrient Flutter SDK 5.0.0. (#48175)
- Updates to Nutrient Android SDK 10.5.0 with the latest features and fixes.
- Updates to Nutrient iOS SDK 14.10.0 with the latest features and fixes.
- Now requires Flutter 3.30.0 or later.
- Fixes an issue where the `onPageChanged` callback was triggering multiple times on iOS. (J#HYB-839)

## 4.4.1 - 20 Jun 2025

- Updates for Nutrient Android SDK 10.4.0.
- Fixes issue where the Android signature dialog custom style is not applied. (HYB-820)

## 4.4.0 - 10 Jun 2025

- Adds AI Assistant support. (J#HYB-742)
- Adds `addWebEventListener` and `removeWebEventListener` APIs to `PspdfkitWidgetController` for Flutter Web. (J#HYB-760)
- Fixes missing resource ID issue with Android Gradle Plugin (AGP) version 8.9.2. (J#HYB-808)
- Fixes issue where PDF viewer fails to load when the mounting container has zero width on Flutter Web. (J#HYB-812)

## 4.3.0 - 11 Apr 2025

- Adds setting custom stamp items support. Only custom text stamps are supported, and this is available only on iOS and Android for now. (J#HYB-715)
- Adds signature creation configuration and signature saving strategy support. (J#HYB-739)
- Adds support for custom main toolbar items with icons. (J#HYB-732)
- Fixes issue where an annotation doesn't get selected when clicked on iOS. (J#HYB-735)

## 4.2.2 - 24 Mar 2025

- Updates for Nutrient Android SDK 10.1.1 — [see changelog](https://www.nutrient.io/guides/android/changelog/).
- Updates Android bridging by moving `MethodCallHandler` from `PspdfkitPlugin` to `PspdfkitPluginMethodCallHandler`, preparing for a complete migration to Pigeon and a proper deprecation path. (J#HYB-690)
- Fixes an issue on Android when adding an `annotationDeleted` event listener. (J#HYB-640)

## 4.2.1 - 10 Mar 2025

- Adds `enterAnnotationCreationMode` and `exitAnnotationCreationMode` APIs to `PspdfkitWidgetController`.
- Updates base `Annotation` model class to make more base properties mutable.

## 4.2.0 - 03 Mar 2025

- Adds `Annotation` model classes. (J#HYB-614)
- Adds ability to set and get an annotation's author name programmatically. (J#HYB-678)
- Adds a `getPageCount` API to `PdfDocument`. (J#HYB-680)
- Adds support for custom data. (J#HYB-682)
- Adds support for annotation flags. (J#HYB-683)
- Adds support for custom stamps. (J#HYB-685)
- Fixes issue where setting an iOS license key shows "PSPDFKit Licensing Issue" error. (J#HYB-658)
- Fixes annotation preset customizations not being set correctly. (J#HYB-686)

## 4.1.1 - 17 Jan 2025

- Fixes build issues where some Android resource IDs are missing. (J#HYB-625)
- Fixes issue where `onPageChanged` callback returns the wrong page index on iOS. (J#HYB-575)

## 4.1.0 - 03 Jan 2025

- Adds support for `PspdfkitWidgetController.addEventListener` to iOS and Android. (J#HYB-550)`
- Adds support for the latest Android Studio version. (J#HYB-539)
- Nutrient Flutter SDK now requires Android Gradle Plugin 8.0.0 or later. (J#HYB-539)
- Nutrient Flutter SDK now requires Flutter 3.27.0 or later. (J#HYB-596)
- Updates for Nutrient Android SDK 2024.9.0.
- Updates for Nutrient iOS SDK 14.3.0.
- Fixes onPageChanged callback being triggered early on iOS. (J#HYB-596)

## 4.0.0 - 01 Nov 2024

- Adds Pigeon for communication between Flutter and native iOS and Android platforms. (J#HYB-455)
- Fixes issue where annotation preset configurations are not applied to some annotation tools. (J#HYB-185)
- Fixes inconsistency in the `applyInstantJson` method parameter type. It now accepts a string on both iOS and Android. (#45541)
- Updates for Nutrient Android SDK 2024.6.1. (#45458)
- Updates for Nutrient iOS SDK 14.1.1. (#45458)
- Updates for Nutrient Web SDK 2024.7.0. (#45458)

## 3.12.1 - 11 Sep 2024

- Updates for PSPDFKit 2024.5.1 for Android. (J#HYB-506)
- Updates for PSPDFKit 13.9.1 for iOS. (J#HYB-506)
- PSPDFKit for Flutter now requires Flutter 3.24.1 or later.
- Fixes an issue where some annotation toolbar items are not displayed when custom grouping is used. (J#HYB-440)
- Fixes an issue where `onDocumentLoaded` is triggered multiple times. (J#HYB-494)

## 3.12.0 - 30 Jul 2024

- Adds `zoomToRect` and `getVisibleRect` APIs to `PspdfkitWidgetController`. (J#HYB-429)
- Adds `processAnnotations` API support for Android. (J#HYB-426)
- Updates the `processAnnotations` parameter types to `AnnotationType` and `AnnotationProcessingMode` enums. (#44722)
- Updates for PSPDFKit 2024.4.0 for Android. (J#HYB-422)
- Updates for PSPDFKit 13.8.0 for iOS. (J#HYB-422)

## 3.11.0 - 21 Jun 2024

- Adds API to get form filled properties to `PdfDocument`. (J#HYB-169)
- Adds Instant synchronization support on Web. (J#HYB-377)

## 3.10.1 - 28 May 2024

- Fixes an issue where `ViewUtils.generateViewId()` cannot be resolved. (J#HYB-379)

## 3.10.0 - 03 May 2024

- Adds APIs to get page information such as size, rotation, and label. (J#HYB-195)
- Adds document load callbacks to `PspdfkitWidget`. (J#HYB-195)
- Adds page change callback to `PspdfkitWidget`. (J#HYB-195)
- Adds support for exporting document as binary data. (J#HYB-337)
- Updates for PSPDFKit 2024.2.1 for Android.
- Updates for PSPDFKit 13.4.1 for iOS.

## 3.9.1 - 12 Apr 2024

- Downgrades to AGP 7.* for backward compatibility (J#HYB-290)
- Allow null value for `Pspdfkit.setLicenseKey` (J#HYB-294)
- Updates for PSPDFKit 2024.2.1 for Android (J#HYB-303)

## 3.9.0 - 22 Mar 2024

- Adds annotation toolbar customization for iOS and Android. (J#HYB-209)
- Adds support for `MeasurementValueConfiguration` to replace `setMeasurementScale` and `setMeasurementPrecision`. (J#HYB-206)
- Updates for PSPDFKit 13.3.3 for iOS. (#43792)
- Updates for PSPDFKit 2024.1.2 for Android. (#43792)
- Fixes events callback functions not being triggered on Web. (J#HYB-221)
- Fixes blank page when an annotation toolbar item is selected on Web. (#43792)

## 3.8.2 - 27 Feb 2024

- Updates for PSPDFKit 13.3.1 for iOS. (#43550)
- Fixes issue where PSPDFKit for Flutter does not work on web with Flutter SDK version 13.19.0 (J#HYB-216)
- Fixes issue where annotation toolbar items are not being displayed on Web. (J#HYB-217)

## 3.8.1 - 14 Feb 2024

- Fixes callbacks when Pspdfkit.present() is used. (J#HYB-204)

## 3.8.0 - 06 Feb 2024

- Adds Flutter for Web support. (#42151)
- Replaces configuration `Map` with a dedicated `PdfConfiguration` class. (#42191)
- Deprecates imports for `package:pspdfkit_flutter/widgets/pspdfkit_widget.dart` and `package:pspdfkit_flutter/widgets/pspdfkit_widget_controller.dart`.
  Use `package:pspdfkit_flutter/pspdfkit.dart` instead. (#43254)
- Updates for PSPDFKit 2024.1.0 for Android. (#43305)
- Updates for PSPDFKit 13.3.0 for iOS. (#43305)
- Compile SDK version 34 is now required on Android. (#43305)

## 3.7.2 - 12 Jan 2024

- Adds `flutterPdfFragmentAdded` callback for Android. (#42631)
- Updates FlutterAppCompatActivity to Support Flutter 3.16.0. (#42767)

## 3.7.1 - 18 Oct 2023

- Fixes issue where iOS Appstore upload fails due to PSPDFKit Flutter missing "CFBundleShortVersionString" key. (#42166)
- Fixes issue where Plugin returned "Document is missing or invalid" during pdfViewControllerWillDismiss events. (#42255)

## 3.7.0 - 07 Sep 2023

- Adds annotation preset customization. (#41669)
- Updates for PSPDFKit 8.8.1 for Android. (#41910)
- Updates for PSPDFKit 12.3.1 for iOS. (#41910)
- Updates the deployment target to iOS 15. (#39956)
- Updates example catalog with PspdfkitWidget usage. (#40861)

## 3.6.0 - 08 May 2023

- Adds measurement tools. (#39806)
- Updates for PSPDFKit 8.6.0 for Android. (#39501)
- Updates for PSPDFKit 12.2 for iOS. (#39995)

## 3.5.1 - 15 Mar 2023

- Updates iOS license initialization in the example catalog. (#38999)
- Updates Instant web demo links. (#39018)
- Updates for PSPDFKit 8.5.1 for Android. (#39090)
- Updates for PSPDFKit 12.1.2 for iOS. (#39090)

## 3.5.0 - 17 Jan 2023

- Adds Instant Synchronization support. (#37675)
- Updates for PSPDFKit 8.5 for Android. (#38136)
- Updates for PSPDFKit 12.0.2 for iOS. (#38136)

## 3.4.1 - 18 Nov 2022

- Updates for PSPDFKit 12.0 for iOS. (#37508)
- Fixes missing header file issue. (#37283)

## 3.4.0 - 26 Oct 2022

- Adds generating PDF from images, templates and HTML. (#36736)
- Updates for PSPDFKit 8.4.1 Android. (#37192)
- Updates for PSPDFKit  12.0 for iOS. (#37192)
- Fixes keyboard cutting off search results when inline search is disabled. (#35418)
- Fixes an issue where the `PspdfkitView` widget is not rendered in Flutter versions 3.3.0 and above on Android. (#37044)

## 3.3.0 - 19 Jul 2022

- Moved package files from `lib/src` to `lib` to remove import warnings and renamed `main.dart` to `pspdfkit.dart`. (#34058)
- Updates the deployment target to iOS 14.0. (#33871)
- PSPDFKit now requires Flutter 3.0.1 or later (#35028)
- Updates for PSPDFKit 11.4.0 for iOS. (#35384)
- Updates for PSPDFKit 8.2.1 for Android. (#35384)
- Handles multiple initializations exception. (#35079)
- Fixes an issue where tapping on form fields yields unexpected behavior in the Catalog basic example. (#33853)
- Fixes the configuration option `userInterfaceViewMode: 'alwaysHidden'` not hiding the widget’s top bar on iOS. (#31095)

## 3.2.2 - 16 Mar 2022

- Improves the example project by using the `PlatformUtils` class to check for supported platforms (#33212)
- Adds a new **Save As** example to the example project. (#33376)
- Updates for PSPDFKit 11.3.0 for iOS. (#33514)

## 3.2.1 - 04 Mar 2022

- Updates for PSPDFKit 8.1.2 for Android. (#33314)
- Updates for PSPDFKit 11.2.4 for iOS. (#33314)

## 3.2.0 - 14 Feb 2022

- This release requires you to update your Android project's `compileSdkVersion` to version 31. Please refer to [our migration guide](https://pspdfkit.com/guides/flutter/migration-guides/flutter-3-2-migration-guide) for this release.
- PSPDFKit now requires Flutter 2.10.1 or later. (#33016)
- Adds a new configuration option to disable autosave. (#32857)
- Adds a new example illustrating manual saving of documents with autosave disabled. (#32857)
- Updates for PSPDFKit 8.1.1 for Android. (#33016)
- Updates for PSPDFKit 11.2.2 for iOS. (#33016)

## 3.1.0 - 06 Jan 2022

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

## 3.0.3 - 07 Dec 2021

- Updates for PSPDFKit 8.0.2 for Android. (#32165)

## 3.0.2 - 02 Nov 2021

- Updates for PSPDFKit 11.1 for iOS. (#31654)
- Updates for PSPDFKit 8.0.1 for Android. (#31743)
- Improves the repository's README. (#31633)

## 3.0.1 - 21 Oct 2021

- Update to PSPDFKit for Android 8.
- PSPDFKit now requires Flutter 2.5.3 or later. (#31360)

## 3.0.0 - 28 Sep 2021

- Adds the ability to open TIFF images as Image Documents. (#28630)
- Adds a `setLicenseKeys` method which accepts both Android and iOS license keys. (#30943)
- Adds support for iOS 15. (#31008)
- PSPDFKit now requires Flutter 2.5.1 or later. (#30960)
- PSPDFKit now requires Xcode 13 or later. (#31008)
- Migrates Flutter APIs to Android embedding v2. (#30680)
- Removes `path_provider` as a dependency. (#30680)

## 2.4.0 - 22 Jul 2021

- Updates to PSPDFKit for Android 7.0. (#30286)
- Bump minimum SDK version `androidMinSdkVersion` to API 21. (#30286)

## 2.3.3 - 19 Jul 2021

- Improves readme file removing `compileOptions` section as not required anymore. (#30258)

## 2.3.2 - 07 Jul 2021

- Updates the deployment target of iOS to 13 for PSPDFKit 10.5 for iOS. (#30057)

## 2.3.1 - 03 Jun 2021

- Updates readme example to enable running with sound null safety. (#29631)
- Adds the implementation for the `save` method on iOS. (#29644)

## 2.3.0 - 01 Jun 2021

- Removes the need of a trial key for running PSPDFKit Flutter in demo mode. (#28297)
- Updates to PSPDFKit for Android 6.6.2 (#29523)

## 2.2.2 - 06 May 2021

- Adds a title image for the plugin frontpage. (#29330)

## 2.2.1 - 03 May 2021

- Reverts some unneeded file changes. (#29286)

## 2.2.0 - 03 May 2021

- Updates the minimum required Dart version to 2.12.0. (#29277)
- Migrates the plugin and the examples to support Sound Null Safety. (#29277)

## 2.1.0 - 20 Apr 2021

- Adds a string for the reader view button in iOS so that it can be used in PSPDFViewController's toolbar. (#28465)
- Fixes dart code formatting. (#28303)
- Updates the `README` for easier getting started instructions and simpler example code. (#28303)
- Updates to PSPDFKit for Android 6.6.0. (#28926)
- Updates example app dependencies to latest: `path_provider` and `cupertino_icons`. (#28926)

## 2.0.1 - 24 Feb 2021

- Updates package description for pub.dev. (#28225)
- Adds pedantic static analysis check and addresses the analysis warnings. (#28225)

## 2.0.0 - 17 Feb 2021

- First pub.dev published version. (#28157)
- Updates the minimum required Flutter SDK version to 1.12.0. (#28157)

## 1.10.6 - 9 Feb 2021

- Adds “Migrating from Version 1.10.3” section in the main README. (pspdfkit-flutter:#83)
- Fixes import in getting started code snippets for iOS and Android. (pspdfkit-flutter:#83)
- Updates the requirements in the iOS README. (pspdfkit-flutter:#83)

## 1.10.5 - 2 Feb 2021

- Fixes the license key in the example project. (pspdfkit-flutter:#82)

## 1.10.4 - 2 Feb 2021

- Updates Gradle version and enable AndroidX for Android plugin and example. (pspdfkit-flutter:#80)
- Updates for PSPDFKit 10.2 for iOS and Xcode 12.4. (pspdfkit-flutter:#81)
- Changes open source license to modified BSD instead of Apache. (pspdfkit-flutter:#79)
- Fixes versioning system to not require a manual update in two places. (pspdfkit-flutter:#80)

## 1.10.3 - 11 Jan 2021

- Updates copyright year to 2021. (pspdfkit-flutter:#75)

## 1.10.2 - 20 Nov 2020

- Updates for PSPDFKit for iOS 10.1 and Xcode 12.2. (pspdfkit-flutter:#74)

## 1.10.1 - 28 Oct 2020

- Updates to PSPDFKit for Android 6.5.3. (pspdfkit-flutter:#71)

## 1.10.0 - 9 Oct 2020

- Updates to PSPDFKit for Android 6.5. (pspdfkit-flutter:#66)

## 1.9.0 - 3 Mar 2020

- Updates to PSPDFKit for Android 6.2. (pspdfkit-flutter:#62)

## 1.8.0 - 21 Jan 2020

- Updates to PSPDFKit for Android 6.1.1. (pspdfkit-flutter:#54)
- Adds Instant JSON document support. (pspdfkit-flutter:#48)
- Fixes example project. (pspdfkit-flutter:#50, #53)

## 1.7.1 - 26 Nov 2019

- Exposes the `pageLayoutMode` and `isFirstPageAlwaysSingle` configuration options. (pspdfkit-flutter:#46)

## 1.7.0 - 8 Oct 2019

- Updates to PSPDFKit for Android 6.0. (pspdfkit-flutter:#36)
- Updates to PSPDFKit for iOS 9. (pspdfkit-flutter:#42)
- Adds Forms API. (pspdfkit-flutter:#28)
