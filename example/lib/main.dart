///
///  Copyright © 2020 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

import 'package:pspdfkit_flutter/src/main.dart';
import 'package:pspdfkit_flutter/src/pspdfkit_view.dart';
import 'package:pspdfkit_flutter/src/widgets/pspdfkit_widget.dart';

import 'pspdfkit_form_example.dart';
import 'pspdfkit_instantjson_example.dart';
import 'pspdfkit_annotations_example.dart';
import 'pspdfkit_annotation_processing_example.dart';

const String PSPDFKIT_LICENSE_KEY = "License key goes here";

const String _documentPath = 'PDFs/PSPDFKit.pdf';
const String _lockedDocumentPath = 'PDFs/protected.pdf';
const String _imagePath = 'PDFs/PSPDFKit_Image_Example.jpg';
const String _formPath = 'PDFs/Form_example.pdf';
const String _instantDocumentJsonPath = 'PDFs/Instant/instant-document.json';
const String _processedDocumentPath = 'PDFs/Embedded/PSPDFKit-processed.pdf';

const String _pspdfkitFlutterPluginTitle = 'PSPDFKit Flutter Plugin example app';

const String _basicExample = 'Basic Example';
const String _basicExampleSub = 'Opens a PDF Document.';
const String _imageDocument = 'Image Document';
const String _imageDocumentSub = 'Opens an image document.';
const String _darkTheme = 'Dark Theme';
const String _darkThemeSub = 'Opens a document in night mode with custom dark theme.';
const String _customConfiguration = 'Custom configuration options';
const String _customConfigurationSub = 'Opens a document with custom configuration options.';
const String _passwordProtectedDocument = 'Opens and unlocks a password protected document';
const String _passwordProtectedDocumentSub = 'Programmatically unlocks a password protected document.';

const String _formExample = 'Programmatic Form Filling Example';
const String _formExampleSub = 'Programmatically set and get the value of a form field using a custom Widget.';
const String _annotationsExample = 'Programmatically Add and Remove Annotations';
const String _annotationsExampleSub = 'Programmatically add and remove annotations using a custom Widget.';
const String _annotationProcessingExample = 'Process Annotations';
const String _annotationProcessingExampleSub = 'Programmatically add and remove annotations using a custom Widget.';
const String _importInstantJsonExample = 'Import Instant Document JSON';
const String _importInstantJsonExampleSub = 'Shows how to programmatically import Instant Document JSON using a custom Widget.';
const String _widgetExampleFullScreen = 'Show two PSPDFKit Widgets simultaneously';
const String _widgetExampleFullScreenSub = 'Opens two different PDF documents simultaneously using two PSPDFKit Widgets.';

const String _basicExampleGlobal = 'Basic Example';
const String _basicExampleGlobalSub = 'Opens a PDF Document.';
const String _imageDocumentGlobal = 'Image Document';
const String _imageDocumentGlobalSub = 'Opens an image document.';
const String _darkThemeGlobal = 'Dark Theme';
const String _darkThemeGlobalSub = 'Opens a document in night mode with custom dark theme.';
const String _customConfigurationGlobal = 'Custom configuration options';
const String _customConfigurationGlobalSub = 'Opens a document with custom configuration options.';
const String _passwordProtectedDocumentGlobal = 'Opens and unlocks a password protected document';
const String _passwordProtectedDocumentGlobalSub = 'Programmatically unlocks a password protected document.';
const String _formExampleGlobal = 'Programmatic Form Filling Example';
const String _formExampleGlobalSub = 'Programmatically set and get the value of a form field.';
const String _importInstantJsonExampleGlobal = 'Import Instant Document JSON';
const String _importInstantJsonExampleGlobalSub = 'Shows how to programmatically import Instant Document JSON.';

const String _pspdfkitFor = 'PSPDFKit for';
const double _fontSize = 18.0;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoApp(home: HomePage());
    } else {
      return MaterialApp(home: HomePage());
    }
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static final ThemeData lightTheme = ThemeData(
    backgroundColor: Colors.transparent,
    primaryColor: Colors.black,
    dividerColor: Colors.grey[400]
  );

  static final ThemeData darkTheme = ThemeData(
    backgroundColor: Colors.transparent,
    primaryColor: Colors.white,
    dividerColor: Colors.grey[800]
  );
  String _frameworkVersion = '';
  ThemeData currentTheme = lightTheme;

  Future<File> extractAsset(String assetPath) async {
    final ByteData bytes = await DefaultAssetBundle.of(context).load(assetPath);
    final Uint8List list = bytes.buffer.asUint8List();

    final Directory tempDir = await getTemporaryDirectory();
    final String tempDocumentPath = '${tempDir.path}/$assetPath';

    final File file = await File(tempDocumentPath).create(recursive: true);
    file.writeAsBytesSync(list);
    return file;
  }

  void showDocument() async {
    try {
      final File extractedDocument = await extractAsset(_documentPath);
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        Navigator.of(context).push<dynamic>(CupertinoPageRoute<dynamic>(builder: (_) => 
          CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(),
            child: SafeArea(
              bottom: false,
              child: PspdfkitWidget(documentPath: extractedDocument.path)))));
      } else {
        // TODO: Android
      }
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void showImage() async {
    try {
      final File extractedImage = await extractAsset(_imagePath);
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        Navigator.of(context).push<dynamic>(CupertinoPageRoute<dynamic>(builder: (_) => 
          CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(),
            child: SafeArea(
              bottom: false,
              child: PspdfkitWidget(documentPath: extractedImage.path)))));
      } else {
        // TODO: Android
      }
    } on PlatformException catch (e) {
      print("Failed to present image document: '${e.message}'.");
    }
  }

  void applyDarkTheme() async {
    try {
      final File extractedDocument = await extractAsset(_documentPath);
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        Navigator.of(context).push<dynamic>(CupertinoPageRoute<dynamic>(builder: (_) => 
          CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(),
            child: SafeArea(
              bottom: false,
              child: PspdfkitWidget(documentPath: extractedDocument.path, configuration: {
                appearanceMode: appearanceModeNight,
                androidDarkThemeResource: 'PSPDFKit.Theme.Example.Dark'
              })))));
      } else {
        // TODO: Android
      }
    } on PlatformException catch (e) {
      print("Failed to present image document: '${e.message}'.");
    }
  }

  void applyCustomConfiguration() async {
    try {
      final File extractedDocument = await extractAsset(_documentPath);
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        Navigator.of(context).push<dynamic>(CupertinoPageRoute<dynamic>(builder: (_) => 
          CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(),
            child: SafeArea(
              bottom: false,
              child: PspdfkitWidget(documentPath: extractedDocument.path, configuration: {
                pageScrollDirection: pageScrollDirectionVertical,
                pageScrollContinuous: false,
                fitPageToWidth: true,
                androidImmersiveMode: false,
                userInterfaceViewMode: userInterfaceViewModeAutomaticBorderPages,
                androidShowSearchAction: true,
                inlineSearch: false,
                showThumbnailBar: showThumbnailBarFloating,
                androidShowThumbnailGridAction: true,
                androidShowOutlineAction: true,
                androidShowAnnotationListAction: true,
                showPageNumberOverlay: false,
                showPageLabels: true,
                showDocumentLabel: false,
                invertColors: false,
                grayScale: false,
                startPage: 2,
                enableAnnotationEditing: true,
                enableTextSelection: false,
                androidEnableBookmarkList: false,
                androidEnableDocumentEditor: false,
                androidShowShareAction: true,
                androidShowPrintAction: false,
                showDocumentInfoView: true,
                appearanceMode: appearanceModeDefault,
                androidDefaultThemeResource: 'PSPDFKit.Theme.Example',
                iOSRightBarButtonItems:['thumbnailsButtonItem', 'activityButtonItem', 'searchButtonItem', 'annotationButtonItem'],
                iOSLeftBarButtonItems:['settingsButtonItem'],
                iOSAllowToolbarTitleChange: false,
                toolbarTitle: 'Custom Title',
                androidSettingsMenuItems:['theme', 'scrolldirection'],
                iOSSettingsMenuItems:['scrollDirection', 'pageTransition', 'appearance', 'brightness', 'pageMode', 'spreadFitting'],
                showActionNavigationButtons: false,
                iOSShowActionNavigationButtonLabels: false,
                pageLayoutMode: 'double',
                isFirstPageAlwaysSingle: true
              })))));
      } else {
        // TODO: Android
      }
    } on PlatformException catch (e) {
      print("Failed to present image document: '${e.message}'.");
    }
  }

  void unlockPasswordProtectedDocument() async {
    try {
      final File extractedLockedDocument = await extractAsset(_lockedDocumentPath);
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        Navigator.of(context).push<dynamic>(CupertinoPageRoute<dynamic>(builder: (_) => 
          CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(),
            child: SafeArea(
              bottom: false,
              child: PspdfkitWidget(documentPath: extractedLockedDocument.path, configuration: {
                password: 'test123'
              })))));
      } else {
        // TODO: Android
      }
    } on PlatformException catch (e) {
      print("Failed to present image document: '${e.message}'.");
    }
  }

  void showFormDocumentExample() async {
    try {
      final File extractedFormDocument = await extractAsset(_formPath);

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        Navigator.of(context).push<dynamic>(CupertinoPageRoute<dynamic>(builder: (_) => 
          PspdfkitFormExampleWidget(documentPath: extractedFormDocument.path, onPspdfkitFormExampleWidgetCreated: onWidgetCreated)
        ));
      } else {
        Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(builder: (_) => 
          PspdfkitFormExampleWidget(documentPath: extractedFormDocument.path, onPspdfkitFormExampleWidgetCreated: onWidgetCreated)
        ));
      }
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void importInstantJsonExample() async {
    try {
      final File extractedFormDocument = await extractAsset(_documentPath);

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        Navigator.of(context).push<dynamic>(CupertinoPageRoute<dynamic>(builder: (_) => 
          PspdfkitInstantJsonExampleWidget(documentPath: extractedFormDocument.path, instantJsonPath: _instantDocumentJsonPath)
        ));
      } else {
        Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(builder: (_) => 
          PspdfkitInstantJsonExampleWidget(documentPath: extractedFormDocument.path, instantJsonPath: _instantDocumentJsonPath)
        ));
      }
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void annotationsExample() async {
    try {
      final File extractedDocument = await extractAsset(_documentPath);

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        Navigator.of(context).push<dynamic>(CupertinoPageRoute<dynamic>(builder: (_) => 
          PspdfkitAnnotationsExampleWidget(documentPath: extractedDocument.path)
        ));
      } else {
        Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(builder: (_) => 
          PspdfkitAnnotationsExampleWidget(documentPath: extractedDocument.path)
        ));
      }
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void annotationProcessingExample() async {
    try {
      final File extractedDocument = await extractAsset(_documentPath);

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        Navigator.of(context).push<dynamic>(CupertinoPageRoute<dynamic>(builder: (_) => 
          PspdfkitAnnotationProcessingExampleWidget(documentPath: extractedDocument.path, exportPath: _processedDocumentPath)
        ));
      } else {
        Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(builder: (_) => 
          PspdfkitAnnotationProcessingExampleWidget(documentPath: extractedDocument.path, exportPath: _processedDocumentPath)
        ));
      }
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void pushTwoPspdfWidgetsSimultaneously() async {
    try {
      final File extractedDocument = await extractAsset(_documentPath);
      final File extractedFormDocument = await extractAsset(_formPath);

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        Navigator.of(context).push<dynamic>(CupertinoPageRoute<dynamic>(builder: (_) => 
          CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(),
            child: SafeArea(
              bottom: false,
              child: Column(children: <Widget>[
                Expanded(child: PspdfkitWidget(documentPath: extractedDocument.path)),
                Expanded(child: PspdfkitWidget(documentPath: extractedFormDocument.path, onPspdfkitWidgetCreated: onWidgetCreated))
              ])))));
      } else {
        // TODO: Android
      }
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void onWidgetCreated(PspdfkitView view) async {
    try {
      view.setFormFieldValue("Lastname", "Name_Last");
      view.setFormFieldValue("0123456789", "Telephone_Home");
      view.setFormFieldValue("City", "City");
      view.setFormFieldValue("selected", "Sex.0");
      view.setFormFieldValue("deselected", "Sex.1");
      view.setFormFieldValue("selected", "HIGH SCHOOL DIPLOMA");
    } on PlatformException catch(e) {
      print("Failed to set form field values '${e.message}'.");
    }

    String lastName;
    try {
      lastName = await view.getFormFieldValue("Name_Last");
    } on PlatformException catch(e) {
      print("Failed to get form field value '${e.message}'.");
    }

    if (lastName != null) {
      print("Retrieved form field for fully qualified name \"Name_Last\" is $lastName.");
    }
  }

  void showDocumentGlobal() async {
    try {
      final File extractedDocument = await extractAsset(_documentPath);
      Pspdfkit.present(extractedDocument.path);
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void showImageGlobal() async {
    try {
      final File extractedImage = await extractAsset(_imagePath);
      Pspdfkit.present(extractedImage.path);
    } on PlatformException catch (e) {
      print("Failed to present image document: '${e.message}'.");
    }
  }

  void applyDarkThemeGlobal() async {
    try {
      final File extractedDocument = await extractAsset(_documentPath);
      Pspdfkit.present(extractedDocument.path, {
        appearanceMode: appearanceModeNight,
        androidDarkThemeResource: 'PSPDFKit.Theme.Example.Dark'
      });
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void applyCustomConfigurationGlobal() async {
    try {
      final File extractedDocument = await extractAsset(_documentPath);
      Pspdfkit.present(extractedDocument.path, {
        pageScrollDirection: pageScrollDirectionVertical,
        pageScrollContinuous: false,
        fitPageToWidth: true,
        androidImmersiveMode: false,
        userInterfaceViewMode: userInterfaceViewModeAutomaticBorderPages,
        androidShowSearchAction: true,
        inlineSearch: false,
        showThumbnailBar: showThumbnailBarFloating,
        androidShowThumbnailGridAction: true,
        androidShowOutlineAction: true,
        androidShowAnnotationListAction: true,
        showPageNumberOverlay: false,
        showPageLabels: true,
        showDocumentLabel: false,
        invertColors: false,
        grayScale: false,
        startPage: 2,
        enableAnnotationEditing: true,
        enableTextSelection: false,
        androidEnableBookmarkList: false,
        androidEnableDocumentEditor: false,
        androidShowShareAction: true,
        androidShowPrintAction: false,
        showDocumentInfoView: true,
        appearanceMode: appearanceModeDefault,
        androidDefaultThemeResource: 'PSPDFKit.Theme.Example',
        iOSRightBarButtonItems:['thumbnailsButtonItem', 'activityButtonItem', 'searchButtonItem', 'annotationButtonItem'],
        iOSLeftBarButtonItems:['settingsButtonItem'],
        iOSAllowToolbarTitleChange: false,
        toolbarTitle: 'Custom Title',
        androidSettingsMenuItems:['theme', 'scrolldirection'],
        iOSSettingsMenuItems:['scrollDirection', 'pageTransition', 'appearance', 'brightness', 'pageMode', 'spreadFitting'],
        showActionNavigationButtons: false,
        iOSShowActionNavigationButtonLabels: false,
        pageLayoutMode: 'double',
        isFirstPageAlwaysSingle: true
      });
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void unlockPasswordProtectedDocumentGlobal() async {
    try {
      final File extractedLockedDocument = await extractAsset(_lockedDocumentPath);
      Pspdfkit.present(extractedLockedDocument.path, {
        password: 'test123'
      });
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void showFormDocumentExampleGlobal() async {
    try {
      final File formDocument = await extractAsset(_formPath);
      await Pspdfkit.present(formDocument.path);
    } on PlatformException catch(e) {
      print("Failed to present document: '${e.message}'.");
    }

    try {
      Pspdfkit.setFormFieldValue("Lastname", "Name_Last");
      Pspdfkit.setFormFieldValue("0123456789", "Telephone_Home");
      Pspdfkit.setFormFieldValue("City", "City");
      Pspdfkit.setFormFieldValue("selected", "Sex.0");
      Pspdfkit.setFormFieldValue("deselected", "Sex.1");
      Pspdfkit.setFormFieldValue("selected", "HIGH SCHOOL DIPLOMA");
    } on PlatformException catch(e) {
      print("Failed to set form field values '${e.message}'.");
    }

    String lastName;
    try {
      lastName = await Pspdfkit.getFormFieldValue("Name_Last");
    } on PlatformException catch(e) {
      print("Failed to get form field value '${e.message}'.");
    }

    if (lastName != null) {
      print("Retrieved form field for fully qualified name \"Name_Last\" is $lastName.");
    }
  }

  void importInstantJsonExampleGlobal() async {
    try {
      final File extractedDocument = await extractAsset(_documentPath);
      await Pspdfkit.present(extractedDocument.path);
    } on PlatformException catch(e) {
      print("Failed to present document: '${e.message}'.");
    }

    // Extract a string from a file.
    final String annotationsJson = await DefaultAssetBundle.of(context).loadString(_instantDocumentJsonPath);

    try {
      Pspdfkit.applyInstantJson(annotationsJson);
    } on PlatformException catch(e) {
      print("Failed to import Instant Document JSON '${e.message}'.");
    }
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    currentTheme = WidgetsBinding.instance.window.platformBrightness == Brightness.light ? lightTheme : darkTheme;
    setState(() {
      build(context);
    });
    super.didChangePlatformBrightness();
  }

  String frameworkVersion() {
    return '$_pspdfkitFor $_frameworkVersion\n';
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    String frameworkVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      frameworkVersion = await Pspdfkit.frameworkVersion;
    } on PlatformException {
      frameworkVersion = 'Failed to get platform version. ';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _frameworkVersion = frameworkVersion;
    });

    Pspdfkit.setLicenseKey(PSPDFKIT_LICENSE_KEY);
  }

  @override
  Widget build(BuildContext context) {
    currentTheme = MediaQuery.of(context).platformBrightness == Brightness.light ? lightTheme : darkTheme;
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      var title = Theme.of(context).textTheme.title.copyWith(color: currentTheme.primaryColor);
      var subhead = Theme.of(context).textTheme.subhead.copyWith(color: currentTheme.primaryColor);      
      var crossAxisAlignment = CrossAxisAlignment.start;
      var padding = EdgeInsets.all(16.0);

      List<Widget> cupertinoListTiles = <Widget>[
        Container(
        color: Colors.grey[200],
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Text("Pspdfkit Widget Examples",
              style: currentTheme.textTheme.display1
                  .copyWith(fontSize: _fontSize, fontWeight: FontWeight.bold)
        )),
        GestureDetector(
          onTap: showDocument,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_basicExample, style: title),
                Text(_basicExampleSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor),
        GestureDetector(
          onTap: showImage,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_imageDocument, style: title),
                Text(_imageDocumentSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor),
        GestureDetector(
          onTap: applyCustomConfiguration,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_customConfiguration, style: title),
                Text(_customConfigurationSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor),
        GestureDetector(
          onTap: applyDarkTheme,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_darkTheme, style: title),
                Text(_darkThemeSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor),
        GestureDetector(
          onTap: unlockPasswordProtectedDocument,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_passwordProtectedDocument, style: title),
                Text(_passwordProtectedDocumentSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor),
        GestureDetector(
          onTap: showFormDocumentExample,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_formExample, style: title),
                Text(_formExampleSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor),
        GestureDetector(
          onTap: annotationsExample,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_annotationsExample, style: title),
                Text(_annotationsExampleSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor),
        GestureDetector(
          onTap: annotationProcessingExample,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_annotationProcessingExample, style: title),
                Text(_annotationProcessingExampleSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor),
        GestureDetector(
          onTap: importInstantJsonExample,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_importInstantJsonExample, style: title),
                Text(_importInstantJsonExampleSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor),
        GestureDetector(
          onTap: pushTwoPspdfWidgetsSimultaneously,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_widgetExampleFullScreen, style: title),
                Text(_widgetExampleFullScreenSub, style: subhead)
              ])),
        ),
        Container(
        color: Colors.grey[200],
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Text("Pspdfkit Global Plugin View Examples",
              style: currentTheme.textTheme.display1
                  .copyWith(fontSize: _fontSize, fontWeight: FontWeight.bold)
        )),
        GestureDetector(
          onTap: showDocumentGlobal,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_basicExampleGlobal, style: title),
                Text(_basicExampleGlobalSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor),
        GestureDetector(
          onTap: showImageGlobal,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_imageDocumentGlobal, style: title),
                Text(_imageDocumentGlobalSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor),
        GestureDetector(
          onTap: applyCustomConfigurationGlobal,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_customConfigurationGlobal, style: title),
                Text(_customConfigurationGlobalSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor),
        GestureDetector(
          onTap: applyDarkThemeGlobal,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_darkThemeGlobal, style: title),
                Text(_darkThemeGlobalSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor),
        GestureDetector(
          onTap: unlockPasswordProtectedDocumentGlobal,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_passwordProtectedDocumentGlobal, style: title),
                Text(_passwordProtectedDocumentGlobalSub, style: subhead)
              ])),
        ),
        Divider(),
        GestureDetector(
          onTap: showFormDocumentExampleGlobal,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_formExampleGlobal, style: title),
                Text(_formExampleGlobalSub, style: subhead)
              ])),
        ),
        Divider(),
        GestureDetector(
          onTap: importInstantJsonExampleGlobal,
          child: Container(
              color: currentTheme.backgroundColor,
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(_importInstantJsonExampleGlobal, style: title),
                Text(_importInstantJsonExampleGlobalSub, style: subhead)
              ])),
        ),
        Divider(color: currentTheme.dividerColor)
      ];
      return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text(_pspdfkitFlutterPluginTitle)),
              child: SafeArea(
                bottom: false,
                child: ExampleListView(currentTheme, frameworkVersion(), cupertinoListTiles))
              );
    } else {
      List<Widget> listTiles = <Widget>[
        ListTile(
            title: Text(_basicExampleGlobal),
            subtitle: Text(_basicExampleGlobalSub),
            onTap: () => showDocumentGlobal()),
        Divider(),
        ListTile(
            title: Text(_imageDocumentGlobal),
            subtitle: Text(_imageDocumentGlobalSub),
            onTap: () => showImageGlobal()),
        Divider(),
        ListTile(
            title: Text(_darkThemeGlobal),
            subtitle: Text(_darkThemeGlobalSub),
            onTap: () => applyDarkThemeGlobal()),
        Divider(),
        ListTile(
            title: Text(_customConfigurationGlobal),
            subtitle: Text(_customConfigurationGlobalSub),
            onTap: () => applyCustomConfigurationGlobal()),
        Divider(),
        ListTile(
            title: Text(_passwordProtectedDocumentGlobal),
            subtitle: Text(_passwordProtectedDocumentGlobalSub),
            onTap: () => unlockPasswordProtectedDocumentGlobal()),
        Divider(),
        ListTile(
            title: Text(_formExampleGlobal),
            subtitle: Text(_formExampleGlobalSub),
            onTap: () => showFormDocumentExampleGlobal()),
        Divider(),
        ListTile(
            title: Text(_importInstantJsonExampleGlobal),
            subtitle: Text(_importInstantJsonExampleGlobalSub),
            onTap: () => importInstantJsonExampleGlobal()),
        Divider(),
      ];
      return Scaffold(
              appBar: AppBar(title: Text(_pspdfkitFlutterPluginTitle)),
              body: ExampleListView(currentTheme, frameworkVersion(), listTiles)
            );
    }
  }
}

class ExampleListView extends StatelessWidget {
  final ThemeData _themeData;
  final String _frameworkVersion;
  final List<Widget> _listTiles;

  ExampleListView(this._themeData, this._frameworkVersion, this._listTiles);

  @override
  Widget build(BuildContext buildContext) {
    return Column(mainAxisSize: MainAxisSize.max, children: [
      Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(top: 24),
        child: Center(
          child: Text(_frameworkVersion,
              style: _themeData.textTheme.display1
                  .copyWith(fontSize: _fontSize, fontWeight: FontWeight.bold, color: _themeData.primaryColor)),
        ),
      ),
      Expanded(
          child: Container(child: ListView(children: _listTiles)))
    ]);
  }
}
