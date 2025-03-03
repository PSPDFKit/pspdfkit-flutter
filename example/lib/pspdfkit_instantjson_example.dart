///
///  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

import 'utils/platform_utils.dart';

class PspdfkitInstantJsonExampleWidget extends StatefulWidget {
  final String documentPath;
  final String instantJsonPath;
  final String? xfaPath;
  final PdfConfiguration? configuration;

  const PspdfkitInstantJsonExampleWidget({
    Key? key,
    required this.documentPath,
    required this.instantJsonPath,
    required this.xfaPath,
    this.configuration,
  }) : super(key: key);

  @override
  State<PspdfkitInstantJsonExampleWidget> createState() =>
      _PspdfkitInstantJsonExampleWidgetState();
}

class _PspdfkitInstantJsonExampleWidgetState
    extends State<PspdfkitInstantJsonExampleWidget> {
  // late PspdfkitWidgetController view;
  late PdfDocument document;

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCurrentPlatformSupported()) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('PSPDFKit Instant JSON Example'),
          ),
          body: SafeArea(
              bottom: false,
              child: Column(children: <Widget>[
                Expanded(
                    child: PspdfkitWidget(
                  documentPath: widget.documentPath,
                  configuration: widget.configuration,
                  onPdfDocumentLoaded: (document) {
                    setState(() {
                      this.document = document;
                    });
                  },
                )),
                SizedBox(
                    height: 80,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: <Widget>[
                        MaterialButton(
                            onPressed: () async {
                              final annotationsJson =
                                  await DefaultAssetBundle.of(context)
                                      .loadString(widget.instantJsonPath);
                              try {
                                await document
                                    .applyInstantJson(annotationsJson);
                              } catch (e) {
                                if (kDebugMode) {
                                  print('Error applying Instant JSON: $e');
                                }
                              }
                            },
                            child: const Text('Apply Instant JSON')),
                        MaterialButton(
                            onPressed: () async {
                              const title = 'Exported Instant JSON';
                              await document
                                  .exportInstantJson()
                                  .then((exportedInstantJson) async {
                                await showDialog<AlertDialog>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: const Text(title),
                                          content: Text(exportedInstantJson ??
                                              'No Instant JSON found.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: false)
                                                      .pop();
                                                },
                                                child: const Text('OK'))
                                          ],
                                        ));
                              });
                            },
                            child: const Text('Export Instant JSON')),

                        // xfdf example:
                        MaterialButton(
                            onPressed: () async {
                              if (widget.xfaPath == null) {
                                return;
                              }
                              final xfdfString =
                                  await DefaultAssetBundle.of(context)
                                      .loadString(widget.xfaPath!);
                              await document.importXfdf(xfdfString);
                            },
                            child: const Text('Apply XFDF')),
                        MaterialButton(
                            onPressed: () async {
                              await document.exportXfdf('xfdf_export.xfdf');
                            },
                            child: const Text('Export XFDF')),
                      ]),
                    ))
              ])));
    } else {
      return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
    }
  }
}
