import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

const String DOCUMENT_PATH = 'PDFs/Guide_v4.pdf';
const String PSPDFKIT_FLUTTER_PLUGIN_TITLE = 'PSPDFKit Flutter Plugin example app';
const String OPEN_DOCUMENT_BUTTON = 'Tap to Open Document';
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
    
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
        Pspdfkit.setLicenseKey("YOUR_LICENSE_KEY_GOES_HERE");
    }
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new Text(frameworkVersion(),
                        style: themeData.textTheme.display1.copyWith(fontSize: FONT_SIZE)),
                    new CupertinoButton(
                        child: new Text(OPEN_DOCUMENT_BUTTON),
                        onPressed: showDocument)
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new Text(frameworkVersion(),
                        style: themeData.textTheme.display1.copyWith(fontSize: 21.0)),
                    new RaisedButton(
                        child: new Text(OPEN_DOCUMENT_BUTTON,
                            style: themeData.textTheme.display1
                                .copyWith(fontSize: FONT_SIZE)),
                        onPressed: showDocument)
                  ])),
        ),
      );
    }
  }
}
