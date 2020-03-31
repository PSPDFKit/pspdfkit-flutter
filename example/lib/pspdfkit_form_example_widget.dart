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

typedef PspdfkitFormExampleWidgetCreatedCallback = void Function(PspdfkitView view);

class PspdfkitFormExampleWidget extends StatefulWidget {
  final String documentPath;
  final dynamic configuration;
  final PspdfkitFormExampleWidgetCreatedCallback onPspdfkitFormExampleWidgetCreated;

  PspdfkitFormExampleWidget({
    Key key,
    @required this.documentPath,
    this.configuration = null,
    this.onPspdfkitFormExampleWidgetCreated = null
  }) : super(key: key);

  @override
  PspdfkitFormExampleWidgetState createState() => PspdfkitFormExampleWidgetState();
}

class PspdfkitFormExampleWidgetState extends State<PspdfkitFormExampleWidget> {
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
                  CupertinoButton(child: Text('Set form field value'), onPressed: () {
                    this.view.setFormFieldValue("Updated Form Field Value", "Name_Last");
                  }),
                  Container(width: 20),
                  CupertinoButton(child: Text('Get form field value'), onPressed: () async {
                    String title = "Form Field Value";
                    String formFieldValue = await this.view.getFormFieldValue("Name_Last");
                    showCupertinoDialog<CupertinoAlertDialog>(
                      context: context, 
                      builder: (BuildContext context) => new CupertinoAlertDialog(
                        title: new Text(title),
                        content: new Text(formFieldValue),
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
    if (widget.onPspdfkitFormExampleWidgetCreated != null) {
          widget.onPspdfkitFormExampleWidgetCreated(this.view);
    }
  }
}
