///
///  Copyright © 2022-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pspdfkit_flutter/pspdfkit.dart';

import 'utils/platform_utils.dart';

class PspdfkitSaveAsExampleWidget extends StatefulWidget {
  final String documentPath;
  final PdfConfiguration? configuration;

  const PspdfkitSaveAsExampleWidget(
      {Key? key, required this.documentPath, this.configuration})
      : super(key: key);

  @override
  _PspdfkitSaveAsExampleWidgetState createState() =>
      _PspdfkitSaveAsExampleWidgetState();
}

class _PspdfkitSaveAsExampleWidgetState
    extends State<PspdfkitSaveAsExampleWidget> {
  late PspdfkitWidgetController pspdfkitWidgetController;

  Future<String> getExportPath(String assetPath) async {
    final tempDir = await Pspdfkit.getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/$assetPath';
    return tempDocumentPath;
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCurrentPlatformSupported()) {
      return Scaffold(
          extendBodyBehindAppBar: PlatformUtils.isAndroid(),
          appBar: AppBar(),
          body: SafeArea(
              top: false,
              bottom: false,
              child: Container(
                  padding: PlatformUtils.isAndroid()
                      ? const EdgeInsets.only(top: kToolbarHeight)
                      : null,
                  child: Column(children: <Widget>[
                    Expanded(
                        child: PspdfkitWidget(
                      documentPath: widget.documentPath,
                      configuration: widget.configuration,
                      onPspdfkitWidgetCreated: (controller) {
                        pspdfkitWidgetController = controller;
                      },
                    )),
                    SizedBox(
                        child: Column(children: <Widget>[
                      ElevatedButton(
                          onPressed: () async {
                            // Ensure that the path for the new document is a writable path
                            // You can use a package like https://pub.dev/packages/filesystem_picker to allow users select the directory and name of the file to save
                            final newDocumentPath = await getExportPath(
                                'PDFs/Embedded/new_pdf_document.pdf');
                            await pspdfkitWidgetController
                                .processAnnotations(
                              AnnotationType.all,
                              AnnotationProcessingMode.embed,
                              newDocumentPath,
                            )
                                .then((value) async {
                              await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Document Saved!'),
                                  content: Text(
                                      'Document Saved Successfully at $newDocumentPath'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'OK'),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            });
                          },
                          child: const Text('Save Document As'))
                    ]))
                  ]))));
    } else {
      return Text(
          '$defaultTargetPlatform is not yet supported by PSPDFKit for Flutter.');
    }
  }
}
