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
const String OPEN_DOCUMENT_BUTTON = 'Tap to Open PDF Document';
const String OPEN_IMAGE_BUTTON = 'Tap to Open Image Document';
const String OPEN_DARK_THEME_BUTTON = 'Tap to Open PSPDFKit with a dark theme';
const String CUSTOM_THEME_BUTTON = 'Tap to Open PSPDFKit with custom configuration options';
const String PSPDFKIT_FOR = 'PSPDFKit for';
const double FONT_SIZE = 21.0;

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _frameworkVersion = '';

  showDocument() async {
    try {
      final ByteData bytes = await DefaultAssetBundle.of(context).load(DOCUMENT_PATH);
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
  
  showImage() async {
    try {
      final ByteData bytes = await DefaultAssetBundle.of(context).load(IMAGE_PATH);
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

  darkTheme() async {
    try {
      final ByteData bytes = await DefaultAssetBundle.of(context).load(DOCUMENT_PATH);
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempDocumentPath = '${tempDir.path}/$DOCUMENT_PATH';

      final file = await new File(tempDocumentPath).create(recursive: true);
      file.writeAsBytesSync(list);

      Pspdfkit.present(tempDocumentPath,
          {
            THEME_MODE: THEME_MODE_NIGHT,
            DARK_THEME_RESOURCE: 'PSPDFCatalog.Theme.Dark'
          });
    } on PlatformException catch (e) {
      print("Failed to open document: '${e.message}'.");
    }
  }

  customConfiguration() async {
    try {
      final ByteData bytes = await DefaultAssetBundle.of(context).load(DOCUMENT_PATH);
      final Uint8List list = bytes.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempDocumentPath = '${tempDir.path}/$DOCUMENT_PATH';

      final file = await new File(tempDocumentPath).create(recursive: true);
      file.writeAsBytesSync(list);

      Pspdfkit.present(tempDocumentPath,
          {
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

  frameworkVersion() {
    return '$PSPDFKIT_FOR $_frameworkVersion\n';
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
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
      return new CupertinoApp(
        home: new CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
              middle: Text(PSPDFKIT_FLUTTER_PLUGIN_TITLE,
              style: themeData.textTheme.title
              )
          ),
          child: new Center(
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    new Text(frameworkVersion(),
                        style: themeData.textTheme.display1.copyWith(fontSize: FONT_SIZE)),
                    new CupertinoButton(
                        child: new Text(OPEN_DOCUMENT_BUTTON),
                        onPressed: showDocument),
                    new CupertinoButton(
                        child: new Text(OPEN_IMAGE_BUTTON),
                        onPressed: showImage)
                  ])),
        ),
      );
    } else {
      return new MaterialApp(
        home: new Scaffold(
          appBar: new AppBar(
            title: new Text(PSPDFKIT_FLUTTER_PLUGIN_TITLE),
          ),
          body: new Center(
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    new Text(frameworkVersion(),
                        style: themeData.textTheme.display1.copyWith(fontSize: FONT_SIZE)),
                    new RaisedButton(
                        child: new Text(OPEN_DOCUMENT_BUTTON,
                            style: themeData.textTheme.display1
                                .copyWith(fontSize: FONT_SIZE)),
                        onPressed: showDocument),
                    new RaisedButton(
                        child: new Text(OPEN_IMAGE_BUTTON,
                            style: themeData.textTheme.display1
                                .copyWith(fontSize: FONT_SIZE)),
                        onPressed: showImage),
                    new RaisedButton(
                        child: new Text(OPEN_DARK_THEME_BUTTON,
                            style: themeData.textTheme.display1
                                .copyWith(fontSize: FONT_SIZE)),
                        onPressed: darkTheme),
                    new RaisedButton(
                        child: new Text(CUSTOM_THEME_BUTTON,
                            style: themeData.textTheme.display1
                                .copyWith(fontSize: FONT_SIZE)),
                        onPressed: customConfiguration)
                  ])),
        ),
      );
    }
  }
}
