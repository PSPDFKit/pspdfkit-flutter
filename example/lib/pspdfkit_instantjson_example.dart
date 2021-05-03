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

class PspdfkitInstantJsonExampleWidget extends StatefulWidget {
  final String documentPath;
  final String instantJsonPath;
  final dynamic configuration;

  PspdfkitInstantJsonExampleWidget({
    Key? key,
    required this.documentPath,
    required this.instantJsonPath,
    this.configuration,
  }) : super(key: key);

  @override
  PspdfkitInstantJsonExampleWidgetState createState() =>
      PspdfkitInstantJsonExampleWidgetState();
}

class PspdfkitInstantJsonExampleWidgetState
    extends State<PspdfkitInstantJsonExampleWidget> {
  late PspdfkitView view;

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
                          onPressed: () async {
                            final annotationsJson =
                                await DefaultAssetBundle.of(context)
                                    .loadString(widget.instantJsonPath);
                            await view.applyInstantJson(annotationsJson);
                          },
                          child: Text('Apply Instant JSON')),
                      Container(width: 20),
                      CupertinoButton(
                          onPressed: () async {
                            final title = 'Exported Instant JSON';
                            final exportedInstantJson =
                                await view.exportInstantJson() ?? '';
                            await showCupertinoDialog<CupertinoAlertDialog>(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoAlertDialog(
                                      title: Text(title),
                                      content: Text(exportedInstantJson),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('OK'))
                                      ],
                                    ));
                          },
                          child: Text('Export Instant JSON'))
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
  }
}
