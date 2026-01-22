///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_example/utils/platform_utils.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

class AnnotationProcessingExampleWidget extends StatefulWidget {
  final String documentPath;
  final String exportPath;
  final PdfConfiguration? configuration;

  const AnnotationProcessingExampleWidget(
      {Key? key,
      required this.documentPath,
      required this.exportPath,
      this.configuration})
      : super(key: key);

  @override
  State<AnnotationProcessingExampleWidget> createState() =>
      _AnnotationProcessingExampleWidgetState();
}

class _AnnotationProcessingExampleWidgetState
    extends State<AnnotationProcessingExampleWidget> {
  late NutrientViewController view;

  Future<String> getExportPath(String assetPath) async {
    final tempDir = await Nutrient.getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/$assetPath';
    return tempDocumentPath;
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS() || PlatformUtils.isAndroid()) {
      return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
              bottom: false,
              child: Column(children: <Widget>[
                Expanded(
                    child: NutrientView(
                  documentPath: widget.documentPath,
                  configuration: widget.configuration,
                  onViewCreated: (NutrientViewController controller) {
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
                          AnnotationType.all,
                          AnnotationProcessingMode.flatten,
                          exportPath,
                        );
                        await Nutrient.present(exportPath);
                      },
                      child: const Text('Flatten Annotations')),
                  CupertinoButton(
                      onPressed: () async {
                        final exportPath =
                            await getExportPath(widget.exportPath);
                        await view.processAnnotations(
                          AnnotationType.all,
                          AnnotationProcessingMode.remove,
                          exportPath,
                        );
                        await Nutrient.present(exportPath);
                      },
                      child: const Text('Remove Annotations')),
                  CupertinoButton(
                      onPressed: () async {
                        final exportPath =
                            await getExportPath(widget.exportPath);
                        await view.processAnnotations(
                          AnnotationType.all,
                          AnnotationProcessingMode.embed,
                          exportPath,
                        );
                        await Nutrient.present(exportPath);
                      },
                      child: const Text('Embed Annotations')),
                  CupertinoButton(
                      onPressed: () async {
                        final exportPath =
                            await getExportPath(widget.exportPath);
                        await view.processAnnotations(
                          AnnotationType.all,
                          AnnotationProcessingMode.print,
                          exportPath,
                        );
                        await Nutrient.present(exportPath);
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
