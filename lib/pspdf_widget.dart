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

typedef void PspdfWidgetCreatedCallback(PspdfWidgetController controller);

class PspdfWidget extends StatefulWidget {
  final PspdfWidgetCreatedCallback onCreate;

  PspdfWidget({
    Key key,
    @required this.onCreate,
  });

  @override
  _PspdfWidgetState createState() => _PspdfWidgetState();
}

class _PspdfWidgetState extends State<PspdfWidget> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'pspdf_widget',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'pspdf_widget',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
  }

  Future<void> onPlatformViewCreated(int id) async {
    if (widget.onCreate == null) { return; }
    widget.onCreate(new PspdfWidgetController.init(id));
  }
}

class PspdfWrapperWidget extends StatefulWidget {
  final String documentPath;

  PspdfWrapperWidget({
    Key key,
    @required this.documentPath,
  });

  @override
  _PspdfWrapperWidgetState createState() => _PspdfWrapperWidgetState();
}

class _PspdfWrapperWidgetState extends State<PspdfWrapperWidget> {
  PspdfWidgetController pspdfWidgetController;
  PspdfWidget pspdfWidget;

  @override
  void initState() {
    super.initState();
    pspdfWidget = new PspdfWidget(onCreate: onCreate);
  }
  
  @override
  void dispose() {
    this.pspdfWidgetController.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Scaffold(body: Center(child: pspdfWidget));
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPageScaffold(child: pspdfWidget);
    } 

    return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
  }

  void onCreate(PspdfWidgetController pspdfWidgetController) async {
    this.pspdfWidgetController = pspdfWidgetController;
    pspdfWidgetController.present(widget.documentPath);
  }
}