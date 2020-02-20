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
  MethodChannel _channel;  
  
  @override
  void dispose() {
    _channel.invokeMethod<dynamic>('setDocumentURL', null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPageScaffold(child:UiKitView(
        viewType: 'com.pspdfkit.widget',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      ));
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return Scaffold(body: Center(child: AndroidView(
        viewType: 'com.pspdfkit.widget',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      )));
    } else {
      return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    _channel = new MethodChannel('com.pspdfkit.widget.$id');
    _channel.setMethodCallHandler(this._methodCallHandler);
    await _channel.invokeMethod<dynamic>('setDocumentURL', widget.documentPath);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
      switch(call.method) {
        case 'popPlatformView':
          Navigator.pop(context);
      }
  }
}