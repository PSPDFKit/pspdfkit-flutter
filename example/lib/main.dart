import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

const String DOCUMENT_PATH = 'PDFs/Guide_v4.pdf';
const String IMAGE_PATH = 'PDFs/PSPDFKit Image Example.jpg';
const String PSPDFKIT_FLUTTER_PLUGIN_TITLE = 'PSPDFKit Flutter Plugin example app';
const String BASIC_EXAMPLE = 'Basic Example';
const String BASIC_EXAMPLE_SUB = 'Opens a PDF Document.';
const String IMAGE_DOCUMENT = 'Image Document';
const String IMAGE_DOCUMENT_SUB = 'Opens an image document.';
const String DARK_THEME = 'Dark Theme';
const String DARK_THEME_SUB = 'Opens a document in night mode with custom dark theme.';
const String CUSTOM_CONFIGURATION = 'Custom configuration options';
const String CUSTOM_CONFIGURATION_SUB = 'Opens a document with custom configuration options.';
const String PSPDFKIT_FOR = 'PSPDFKit for';
const double FONT_SIZE = 21.0;

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _frameworkVersion = '';

  void showDocument() async {
    try {
      final ByteData bytes =
          await DefaultAssetBundle.of(context).load(DOCUMENT_PATH);
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempDocumentPath = '${tempDir.path}/$DOCUMENT_PATH';

      final file = await new File(tempDocumentPath).create(recursive: true);
      file.writeAsBytesSync(list);

      Pspdfkit.present(tempDocumentPath);
    } on PlatformException catch (e) {
      print("Failed to open document: '${e.message}'.");
    }
  }

  void showImage() async {
    try {
      final ByteData bytes =
          await DefaultAssetBundle.of(context).load(IMAGE_PATH);
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempDocumentPath = '${tempDir.path}/$IMAGE_PATH';

      final file = await new File(tempDocumentPath).create(recursive: true);
      file.writeAsBytesSync(list);

      Pspdfkit.present(tempDocumentPath);
    } on PlatformException catch (e) {
      print("Failed to open document: '${e.message}'.");
    }
  }

  void darkTheme() async {
    try {
      final ByteData bytes =
          await DefaultAssetBundle.of(context).load(DOCUMENT_PATH);
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempDocumentPath = '${tempDir.path}/$DOCUMENT_PATH';

      final file = await new File(tempDocumentPath).create(recursive: true);
      file.writeAsBytesSync(list);

      Pspdfkit.present(tempDocumentPath, {
        THEME_MODE: THEME_MODE_NIGHT,
        DARK_THEME_RESOURCE: 'PSPDFCatalog.Theme.Dark'
      });
    } on PlatformException catch (e) {
      print("Failed to open document: '${e.message}'.");
    }
  }

  void customConfiguration() async {
    try {
      final ByteData bytes =
          await DefaultAssetBundle.of(context).load(DOCUMENT_PATH);
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempDocumentPath = '${tempDir.path}/$DOCUMENT_PATH';

      final file = await new File(tempDocumentPath).create(recursive: true);
      file.writeAsBytesSync(list);

      Pspdfkit.present(tempDocumentPath, {
        PAGE_SCROLL_DIRECTION: PAGE_SCROLL_DIRECTION_VERTICAL,
        PAGE_SCROLL_CONTINUOUS: true,
        FIT_PAGE_TO_WIDTH: true,
        IMMERSIVE_MODE: false,
        USER_INTERFACE_VIEW_MODE: USER_INTERFACE_VIEW_MODE_AUTOMATIC_BORDER_PAGES,
        SHOW_SEARCH_ACTION: true,
        INLINE_SEARCH: false,
        SHOW_THUMBNAIL_BAR: SHOW_THUMBNAIL_BAR_SCROLLABLE,
        SHOW_THUMBNAIL_GRID_ACTION: true,
        SHOW_OUTLINE_ACTION: true,
        SHOW_ANNOTATION_LIST_ACTION: true,
        SHOW_PAGE_NUMBER_OVERLAY: false,
        SHOW_PAGE_LABELS: true,
        INVERT_COLORS: false,
        GRAY_SCALE: false,
        START_PAGE: 2,
        ENABLE_ANNOTATION_EDITING: true,
        ENABLE_TEXT_SELECTION: false,
        SHOW_SHARE_ACTION: true,
        SHOW_PRINT_ACTION: false,
        SHOW_DOCUMENT_INFO_VIEW: true,
        THEME_MODE: THEME_MODE_DEFAULT,
        DEFAULT_THEME_RESOURCE: 'PSPDFCatalog.Theme.Custom'
      });
    } on PlatformException catch (e) {
      print("Failed to open document: '${e.message}'.");
    }
  }

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  String frameworkVersion() {
    return '$PSPDFKIT_FOR $_frameworkVersion\n';
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    String frameworkVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      frameworkVersion = (await Pspdfkit.frameworkVersion) as String;
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
                Text(BASIC_EXAMPLE, style: title),
                Text(BASIC_EXAMPLE_SUB, style: subhead)
              ])),
        ),
        Divider(),
        GestureDetector(
          onTap: showImage,
          child: Container(
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(IMAGE_DOCUMENT, style: title),
                Text(IMAGE_DOCUMENT_SUB, style: subhead)
              ])),
        ),
        Divider(),
        GestureDetector(
          onTap: darkTheme,
          child: Container(
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [
                Text(DARK_THEME, style: title),
                Text(DARK_THEME_SUB, style: subhead)
              ])),
        ),
        Divider(),
        GestureDetector(
          onTap: customConfiguration,
          child: Container(
              padding: padding,
              child: Column(crossAxisAlignment: crossAxisAlignment, children: [

                Text(CUSTOM_CONFIGURATION, style: title),
                Text(CUSTOM_CONFIGURATION_SUB, style: subhead)
              ])),
        ),
        Divider(),
      ];
      return new CupertinoApp(
          home: new CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                  middle: Text(PSPDFKIT_FLUTTER_PLUGIN_TITLE,
                      style: themeData.textTheme.title)),
              child: new ExampleListView(
                  themeData, frameworkVersion(), cupertinoListTiles)));
    } else {
      List<Widget> listTiles = <Widget>[
        Divider(),
        ListTile(
            title: Text(BASIC_EXAMPLE),
            subtitle: Text(BASIC_EXAMPLE_SUB),
            onTap: () => showDocument()),
        Divider(),
        ListTile(
            title: Text(IMAGE_DOCUMENT),
            subtitle: Text(IMAGE_DOCUMENT_SUB),
            onTap: () => showImage()),
        Divider(),
        ListTile(
            title: Text(DARK_THEME),
            subtitle: Text(DARK_THEME_SUB),
            onTap: () => darkTheme()),
        Divider(),
        ListTile(
            title: Text(CUSTOM_CONFIGURATION),
            subtitle: Text(CUSTOM_CONFIGURATION_SUB),
            onTap: () => customConfiguration()),
        Divider(),
      ];
      return new MaterialApp(
        home: new Scaffold(
            appBar: new AppBar(
              title: new Text(PSPDFKIT_FLUTTER_PLUGIN_TITLE),
            ),
            body:
                new ExampleListView(themeData, frameworkVersion(), listTiles)),
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
    return new Column(mainAxisSize: MainAxisSize.max, children: [
      new Container(
        padding: EdgeInsets.only(top: 24),
        child: Center(
          child: new Text(_frameworkVersion,
              style: _themeData.textTheme.display1
                  .copyWith(fontSize: FONT_SIZE, fontWeight: FontWeight.bold)),
        ),
      ),
      new Expanded(
          child: new Container(child: new ListView(children: _listTiles)))
    ]);
  }
}
