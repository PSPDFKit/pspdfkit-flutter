///
///  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:pspdfkit_example/utils/platform_utils.dart';

import 'package:pspdfkit_flutter/pspdfkit.dart';

class PspdfkitAnnotationProcessingExampleWidget extends StatefulWidget {
  final String documentPath;
  final String exportPath;
  final PdfConfiguration? configuration;

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

  Future<String> getExportPath(String assetPath) async {
    final tempDir = await Pspdfkit.getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/$assetPath';
    return tempDocumentPath;
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS()) {
      return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(),
          child: SafeArea(
              bottom: false,
              child: Column(children: <Widget>[
                Expanded(
                    child: PspdfkitWidget(
                  documentPath: widget.documentPath,
                  configuration: widget.configuration,
                  onPspdfkitWidgetCreated:
                      (PspdfkitWidgetController controller) {
                    setState(() {
                      view = controller;
                    });
                  },
                )),
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
}
