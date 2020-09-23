///
///  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
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
import 'package:pspdfkit_flutter/pspdfkit.dart';

const String _documentPath = 'PDFs/PSPDFKit.pdf';
const String _lockedDocumentPath = 'PDFs/protected.pdf';
const String _imagePath = 'PDFs/PSPDFKit_Image_Example.jpg';
const String _formPath = 'PDFs/Form_example.pdf';
const String _instantDocumentJsonPath = 'PDFs/Instant/instant-document.json';
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
const String _formExampleSub = 'Programmatically set and get the value of a form field.';
const String _importInstantJsonExample = 'Import Instant Document JSON';
const String _importInstantJsonExampleSub = 'Shows how to programmatically import Instant Document JSON.';
const String _pspdfkitFor = 'PSPDFKit for';
const double _fontSize = 21.0;

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
    primaryColor: Colors.black
  );

  static final ThemeData darkTheme = ThemeData(
    backgroundColor: Colors.grey[900],
    primaryColor: Colors.white
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
      Pspdfkit.present(extractedDocument.path);
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void showImage() async {
    try {
      final File extractedImage = await extractAsset(_imagePath);
      Pspdfkit.present(extractedImage.path);
    } on PlatformException catch (e) {
      print("Failed to present image document: '${e.message}'.");
    }
  }

  void applyDarkTheme() async {
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

  void applyCustomConfiguration() async {
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

  void unlockPasswordProtectedDocument() async {
    try {
      final File extractedLockedDocument = await extractAsset(_lockedDocumentPath);
      Pspdfkit.present(extractedLockedDocument.path, {
        password: 'test123'
      });
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void showFormDocumentExample() async {
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

  void importInstantJsonExample() async {
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

    Pspdfkit.setLicenseKey("LICENSE_KEY_GOES_HERE");
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
        Divider(),
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
        Divider(),
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
        Divider(),
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
        Divider(),
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
        Divider(),
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
        Divider(),
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
        Divider()
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
            title: Text(_basicExample),
            subtitle: Text(_basicExampleSub),
            onTap: () => showDocument()),
        Divider(),
        ListTile(
            title: Text(_imageDocument),
            subtitle: Text(_imageDocumentSub),
            onTap: () => showImage()),
        Divider(),
        ListTile(
            title: Text(_darkTheme),
            subtitle: Text(_darkThemeSub),
            onTap: () => applyDarkTheme()),
        Divider(),
        ListTile(
            title: Text(_customConfiguration),
            subtitle: Text(_customConfigurationSub),
            onTap: () => applyCustomConfiguration()),
        Divider(),
        ListTile(
            title: Text(_passwordProtectedDocument),
            subtitle: Text(_passwordProtectedDocumentSub),
            onTap: () => unlockPasswordProtectedDocument()),
        Divider(),
        ListTile(
            title: Text(_formExample),
            subtitle: Text(_formExampleSub),
            onTap: () => showFormDocumentExample()),
        Divider(),
        ListTile(
            title: Text(_importInstantJsonExample),
            subtitle: Text(_importInstantJsonExampleSub),
            onTap: () => importInstantJsonExample()),
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
