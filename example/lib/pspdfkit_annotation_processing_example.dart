///
///  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:pspdfkit_example/platform_utils.dart';

import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:pspdfkit_flutter/widgets/pspdfkit_widget_controller.dart';

class PspdfkitAnnotationProcessingExampleWidget extends StatefulWidget {
  final String documentPath;
  final String exportPath;
  final dynamic configuration;

  const PspdfkitAnnotationProcessingExampleWidget(
      {Key? key,
      required this.documentPath,
      required this.exportPath,
      this.configuration})
      : super(key: key);

  @override
  _PspdfkitAnnotationProcessingExampleWidgetState createState() =>
      _PspdfkitAnnotationProcessingExampleWidgetState();
}

class _PspdfkitAnnotationProcessingExampleWidgetState
    extends State<PspdfkitAnnotationProcessingExampleWidget> {
  late PspdfkitWidgetController view;

  Future<File> extractAsset(String assetPath) async {
    final bytes = await DefaultAssetBundle.of(context).load(assetPath);
    final list = bytes.buffer.asUint8List();
    final tempDocumentPath = await getExportPath(assetPath);
    final file = await File(tempDocumentPath).create(recursive: true);
    file.writeAsBytesSync(list);
    return file;
  }

  Future<String> getExportPath(String assetPath) async {
    final tempDir = await Pspdfkit.getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/$assetPath';
    return tempDocumentPath;
  }

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'com.pspdfkit.widget';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'document': widget.documentPath,
      'configuration': widget.configuration
    };

    if (PlatformUtils.isIOS()) {
      return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(),
          child: SafeArea(
              bottom: false,
              child: Column(children: <Widget>[
                Expanded(
                    child: UiKitView(
                        viewType: viewType,
                        layoutDirection: TextDirection.ltr,
                        creationParams: creationParams,
                        onPlatformViewCreated: onPlatformViewCreated,
                        creationParamsCodec: const StandardMessageCodec())),
                SizedBox(
                    child: Column(children: <Widget>[
                  CupertinoButton(
                      onPressed: () async {
                        final exportPath =
                            await getExportPath(widget.exportPath);
                        await view.processAnnotations(
                            'all', 'flatten', exportPath);
                        await Pspdfkit.present(exportPath);
                      },
                      child: const Text('Flatten Annotations')),
                  CupertinoButton(
                      onPressed: () async {
                        final exportPath =
                            await getExportPath(widget.exportPath);
                        await view.processAnnotations(
                            'all', 'remove', exportPath);
                        await Pspdfkit.present(exportPath);
                      },
                      child: const Text('Remove Annotations')),
                  CupertinoButton(
                      onPressed: () async {
                        final exportPath =
                            await getExportPath(widget.exportPath);
                        await view.processAnnotations(
                            'all', 'embed', exportPath);
                        await Pspdfkit.present(exportPath);
                      },
                      child: const Text('Embed Annotations')),
                  CupertinoButton(
                      onPressed: () async {
                        final exportPath =
                            await getExportPath(widget.exportPath);
                        await view.processAnnotations(
                            'all', 'print', exportPath);
                        await Pspdfkit.present(exportPath);
                      },
                      child: const Text('Print Annotations'))
                ]))
              ])));
    } else if (PlatformUtils.isAndroid()) {
      // This example is only supported in iOS at the moment.
      // Support for Android is coming soon.
      return const Text('Unsupported Widget');
    } else {
      return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    view = PspdfkitWidgetController(id);
  }
}
