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

typedef PspdfkitWidgetCreatedCallback = void Function(PspdfkitView view);

class PspdfkitWidget extends StatefulWidget {
  final String documentPath;
  final dynamic configuration;
  final PspdfkitWidgetCreatedCallback onPspdfkitWidgetCreated;

  PspdfkitWidget({
    Key key,
    @required this.documentPath,
    this.configuration = null,
    this.onPspdfkitWidgetCreated = null
  }) : super(key: key);

  @override
  PspdfkitWidgetState createState() => PspdfkitWidgetState();
}

class PspdfkitWidgetState extends State<PspdfkitWidget> {
  PspdfkitView view;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'com.pspdfkit.widget',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
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
    this.view = PspdfkitView._init(id, widget.documentPath, widget.configuration);
    if (widget.onPspdfkitWidgetCreated != null) {
          widget.onPspdfkitWidgetCreated(this.view);
    }
  }
}

class PspdfkitView {
  MethodChannel _channel;  
  
  PspdfkitView._init(
    int id,
    String documentPath,
    dynamic configuration
  ) {
    _channel = new MethodChannel('com.pspdfkit.widget.$id');
    _channel.invokeMethod<dynamic>('initializePlatformView', <String, dynamic>{'document': documentPath, 'configuration': configuration});
  }

  /// Sets the value of a form field by specifying its fully qualified field name.
  Future<bool> setFormFieldValue(String value, String fullyQualifiedName) async =>
    _channel.invokeMethod('setFormFieldValue', <String, dynamic>{'value': value, 'fullyQualifiedName': fullyQualifiedName});

  /// Gets the form field value by specifying its fully qualified name.
  Future<String> getFormFieldValue(String fullyQualifiedName) async =>
    _channel.invokeMethod('getFormFieldValue', <String, dynamic>{'fullyQualifiedName': fullyQualifiedName});

  /// Applies Instant document JSON to the presented document.
  Future<bool> applyInstantJson(String annotationsJson) async =>
    _channel.invokeMethod('applyInstantJson', <String, String>{'annotationsJson': annotationsJson});

  /// Exports Instant document JSON from the presented document.
  Future<String> exportInstantJson() async => _channel.invokeMethod('exportInstantJson');

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  Future<bool> save() async => _channel.invokeMethod('save');
}