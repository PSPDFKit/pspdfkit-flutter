///
///  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:pspdfkit_flutter/src/widgets/pspdfkit_view.dart';

typedef PspdfkitInstantJsonExampleWidgetCreatedCallback = void Function(PspdfkitView view);

class PspdfkitInstantJsonExampleWidget extends StatefulWidget {
  final String documentPath;
  final String instantJsonPath;
  final dynamic configuration;

  PspdfkitInstantJsonExampleWidget({
    Key key,
    @required this.documentPath,
    @required this.instantJsonPath,
    this.configuration = null,
  }) : super(key: key);

  @override
  PspdfkitInstantJsonExampleWidgetState createState() => PspdfkitInstantJsonExampleWidgetState();
}

class PspdfkitInstantJsonExampleWidgetState extends State<PspdfkitInstantJsonExampleWidget> {
  PspdfkitView view;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(),
        child: SafeArea(
          bottom: false,
          child: Column(children: <Widget>[
            Expanded(child: UiKitView(
              viewType: 'com.pspdfkit.widget',
              onPlatformViewCreated: onPlatformViewCreated,
              creationParamsCodec: const StandardMessageCodec())),
            Container(
              height: 80,
              child: Row(
                children: <Widget>[
                  Container(width: 20),
                  CupertinoButton(child: Text('Apply Instant JSON'), onPressed: () async {
                    final String annotationsJson = await DefaultAssetBundle.of(context).loadString(widget.instantJsonPath);
                    this.view.applyInstantJson(annotationsJson);
                  }),
                  Container(width: 20),
                  CupertinoButton(child: Text('Export Instant JSON'), onPressed: () async {
                    String title = "Exported Instant JSON";
                    String exportedInstantJson = await this.view.exportInstantJson();
                    showCupertinoDialog<CupertinoAlertDialog>(
                      context: context, 
                      builder: (BuildContext context) => new CupertinoAlertDialog(
                        title: new Text(title),
                        content: new Text(exportedInstantJson),
                        actions: [
                           new FlatButton(onPressed: () {Navigator.of(context).pop();}, child: new Text("OK"))
                          ],
                      ));
                    })
                ]))]))
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'com.pspdfkit.widget',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    this.view = PspdfkitView.init(id, widget.documentPath, widget.configuration);
  }
}
