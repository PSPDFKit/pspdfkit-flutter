///
///  Copyright © 2018-2021 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'package:pspdfkit_flutter/src/main.dart';
import 'package:pspdfkit_flutter/src/pspdfkit_view.dart';

class PspdfkitAnnotationProcessingExampleWidget extends StatefulWidget {
  final String documentPath;
  final String exportPath;
  final dynamic configuration;

  PspdfkitAnnotationProcessingExampleWidget({
    Key key,
    @required this.documentPath,
    @required this.exportPath,
    this.configuration = null
  }) : super(key: key);

  @override
  PspdfkitAnnotationProcessingExampleWidgetState createState() => PspdfkitAnnotationProcessingExampleWidgetState();
}

class PspdfkitAnnotationProcessingExampleWidgetState extends State<PspdfkitAnnotationProcessingExampleWidget> {
  PspdfkitView view;

  Future<File> extractAsset(String assetPath) async {
    final ByteData bytes = await DefaultAssetBundle.of(context).load(assetPath);
    final Uint8List list = bytes.buffer.asUint8List();
    final String tempDocumentPath = await getExportPath(assetPath);
    final File file = await File(tempDocumentPath).create(recursive: true);
    file.writeAsBytesSync(list);
    return file;
  }

  Future<String> getExportPath(String assetPath) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String tempDocumentPath = '${tempDir.path}/$assetPath';
    return tempDocumentPath;
  }

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
                  CupertinoButton(child: Text('Flatten Annotations'), onPressed: () async {
                    String exportPath = await getExportPath(widget.exportPath);
                    this.view.processAnnotations("all", "flatten", exportPath);
                    Pspdfkit.present(exportPath);
                  }),
                  Container(width: 20),
                  CupertinoButton(child: Text('Remove Annotations'), onPressed: () async {
                    String exportPath = await getExportPath(widget.exportPath);
                    this.view.processAnnotations("all", "remove", exportPath);
                    Pspdfkit.present(exportPath);
                  }),
                  Container(width: 20),
                  CupertinoButton(child: Text('Embed Annotations'), onPressed: () async {
                    String exportPath = await getExportPath(widget.exportPath);
                    this.view.processAnnotations("all", "embed", exportPath);
                    Pspdfkit.present(exportPath);
                  }),
                  Container(width: 20),
                  CupertinoButton(child: Text('Print Annotations'), onPressed: () async {
                    String exportPath = await getExportPath(widget.exportPath);
                    this.view.processAnnotations("all", "print", exportPath);
                    Pspdfkit.present(exportPath);
                  })
                ]))]))
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // PspdfkitView is only supported in iOS at the moment.
      // Support for Android is coming soon.
      return Text('Unsupported Widget');
    } else {
      return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    this.view = PspdfkitView.init(id, widget.documentPath, widget.configuration);
  }
}
