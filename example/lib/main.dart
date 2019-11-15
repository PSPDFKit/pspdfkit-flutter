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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

const String _documentPath = 'PDFs/PSPDFKit.pdf';
const String _lockedDocumentPath = 'PDFs/protected.pdf';
const String _imagePath = 'PDFs/PSPDFKit Image Example.jpg';
const String _formPath = 'PDFs/Form_example.pdf';
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
const String _pspdfkitFor = 'PSPDFKit for';
const double _fontSize = 21.0;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _frameworkVersion = '';

  void showDocument() async {
    try {
      final ByteData bytes = await DefaultAssetBundle.of(context).load(_documentPath);
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempDocumentPath = '${tempDir.path}/$_documentPath';

      final file = await File(tempDocumentPath).create(recursive: true);
      file.writeAsBytesSync(list);

      Pspdfkit.present(tempDocumentPath);
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void showImage() async {
    try {
      final ByteData bytes =
      await DefaultAssetBundle.of(context).load(_imagePath);
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempDocumentPath = '${tempDir.path}/$_imagePath';

      final file = await File(tempDocumentPath).create(recursive: true);
      file.writeAsBytesSync(list);

      Pspdfkit.present(tempDocumentPath);
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void applyDarkTheme() async {
    try {
      final ByteData bytes = await DefaultAssetBundle.of(context).load(_documentPath);
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempDocumentPath = '${tempDir.path}/$_documentPath';

      final file = await File(tempDocumentPath).create(recursive: true);
      file.writeAsBytesSync(list);

      Pspdfkit.present(tempDocumentPath, {
        appearanceMode: appearanceModeNight,
        androidDarkThemeResource: 'PSPDFKit.Theme.Example.Dark'
      });
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void applyCustomConfiguration() async {
    try {
      final ByteData bytes = await DefaultAssetBundle.of(context).load(_documentPath);
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempDocumentPath = '${tempDir.path}/$_documentPath';

      final file = await File(tempDocumentPath).create(recursive: true);
      file.writeAsBytesSync(list);

      Pspdfkit.present(tempDocumentPath, {
        pageScrollDirection: pageScrollDirectionVertical,
        pageScrollContinuous: true,
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
        showActionNavigationButtons: false,
        iOSShowActionNavigationButtonLabels: false
      });
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void unlockPasswordProtectedDocument() async {
    try {
      final ByteData bytes = await DefaultAssetBundle.of(context).load(_lockedDocumentPath);
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempDocumentPath = '${tempDir.path}/$_lockedDocumentPath';

      final file = await File(tempDocumentPath).create(recursive: true);
      file.writeAsBytesSync(list);

      Pspdfkit.present(tempDocumentPath, {
        password: 'test123'
      });
    } on PlatformException catch (e) {
      print("Failed to present document: '${e.message}'.");
    }
  }

  void showFormDocumentExample() async {
    final ByteData bytes = await DefaultAssetBundle.of(context).load(_formPath);
    final Uint8List list = bytes.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/$_formPath';

    final file = await File(tempDocumentPath).create(recursive: true);
    file.writeAsBytesSync(list);

    try {
      await Pspdfkit.present(tempDocumentPath);
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

  @override
  initState() {
    super.initState();
    initPlatformState();
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
    final ThemeData themeData = Theme.of(context);
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      var title = themeData.textTheme.title;
      var subhead = themeData.textTheme.subhead;
      var crossAxisAlignment = CrossAxisAlignment.start;
      var padding = EdgeInsets.all(16.0);
      List<Widget> cupertinoListTiles = <Widget>[
        Divider(),
        GestureDetector(
          onTap: showDocument,
          child: Container(
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
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [

                Text(_formExample, style: title),
                Text(_formExampleSub, style: subhead)
              ])),
        ),
        Divider()
      ];
      return CupertinoApp(
          home: CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                  middle: Text(_pspdfkitFlutterPluginTitle,
                      style: themeData.textTheme.title)),
              child: ExampleListView(
                  themeData, frameworkVersion(), cupertinoListTiles)));
    } else {
      List<Widget> listTiles = <Widget>[
        Divider(),
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
      ];
      return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text(_pspdfkitFlutterPluginTitle),
            ),
            body: ExampleListView(themeData, frameworkVersion(), listTiles)),
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
        padding: EdgeInsets.only(top: 24),
        child: Center(
          child: Text(_frameworkVersion,
              style: _themeData.textTheme.display1
                  .copyWith(fontSize: _fontSize, fontWeight: FontWeight.bold)),
        ),
      ),
      Expanded(
          child: Container(child: ListView(children: _listTiles)))
    ]);
  }
}
