import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pspdfkit/pspdfkit.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _frameworkVersion = '';

  openExternalDocument() async {
    try {
      Pspdfkit.openExternalDocument("document.pdf");
    } on PlatformException catch (e) {
      print("Failed to open document: '${e.message}'.");
    }
  }

  @override
  initState() {
    super.initState();
    initPlatformState();
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
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('PSPDFKit Flutter Plugin example app'),
        ),
        body: new Center(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              new Text('PSPDFKit for $_frameworkVersion\n',
                  style: themeData.textTheme.display1.copyWith(fontSize: 21.0)),
              new RaisedButton(
                  child: new Text('Tap to Open Document',
                      style: themeData.textTheme.display1
                          .copyWith(fontSize: 21.0)),
                  onPressed: openExternalDocument)
            ])),
      ),
    );
  }
}
