///
///  Copyright © 2018-2021 PSPDFKit GmbH. All rights reserved.
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

import 'package:pspdfkit_flutter/src/pspdfkit_view.dart';

typedef PspdfkitFormExampleWidgetCreatedCallback = void Function(
    PspdfkitView view);

class PspdfkitFormExampleWidget extends StatefulWidget {
  final String documentPath;
  final dynamic configuration;
  final PspdfkitFormExampleWidgetCreatedCallback
      onPspdfkitFormExampleWidgetCreated;

  PspdfkitFormExampleWidget(
      {Key key,
      @required this.documentPath,
      this.configuration,
      this.onPspdfkitFormExampleWidgetCreated})
      : super(key: key);

  @override
  PspdfkitFormExampleWidgetState createState() =>
      PspdfkitFormExampleWidgetState();
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
                Expanded(
                    child: UiKitView(
                        viewType: 'com.pspdfkit.widget',
                        onPlatformViewCreated: onPlatformViewCreated,
                        creationParamsCodec: const StandardMessageCodec())),
                Container(
                    height: 80,
                    child: Row(children: <Widget>[
                      Container(width: 20),
                      CupertinoButton(
                          onPressed: () {
                            view.setFormFieldValue(
                                'Updated Form Field Value', 'Name_Last');
                          },
                          child: Text('Set form field value')),
                      Container(width: 20),
                      CupertinoButton(
                          onPressed: () async {
                            final title = 'Form Field Value';
                            final formFieldValue =
                                await view.getFormFieldValue('Name_Last');
                            await showCupertinoDialog<CupertinoAlertDialog>(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoAlertDialog(
                                      title: Text(title),
                                      content: Text(formFieldValue),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('OK'))
                                      ],
                                    ));
                          },
                          child: Text('Get form field value'))
                    ]))
              ])));
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // PspdfkitView is only supported in iOS at the moment.
      // Support for Android is coming soon.
      return Text('Unsupported Widget');
    } else {
      return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    view = PspdfkitView.init(id, widget.documentPath, widget.configuration);
    if (widget.onPspdfkitFormExampleWidgetCreated != null) {
      widget.onPspdfkitFormExampleWidgetCreated(view);
    }
  }
}
