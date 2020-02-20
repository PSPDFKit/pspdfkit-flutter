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

class PspdfWidgetController {
  MethodChannel _channel;
  Function _callbackHandler;

  PspdfWidgetController.init(int id) {
    _channel = new MethodChannel('pspdf_widget_$id');
  }

  void setCallbackHandler(Future<dynamic> handler(MethodCall call)) {
    _callbackHandler = handler;
    _channel.setMethodCallHandler(_callbackHandler);
  }

  Future<void> present(String url) async {
    assert(url != null);
    return _channel.invokeMethod('present', url);
  }

  Future<void> dismiss() async {
    return _channel.invokeMethod('dismiss');
  }
}

class PspdfWidget extends StatefulWidget {
  final String documentPath;

  PspdfWidget({
    Key key,
    @required this.documentPath,
  });

  @override
  _PspdfWidgetState createState() => _PspdfWidgetState();
}

class _PspdfWidgetState extends State<PspdfWidget> {
  PspdfWidgetController controller;
  
  @override
  void dispose() {
    super.dispose();
    this.controller.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Scaffold(body: Center(child: AndroidView(
        viewType: 'pspdf_widget',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      )));
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPageScaffold(child:UiKitView(
        viewType: 'pspdf_widget',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      ));
    }
    return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
  }

  Future<void> onPlatformViewCreated(int id) async {
    this.controller = new PspdfWidgetController.init(id);
    this.controller.present(widget.documentPath);
  }
}