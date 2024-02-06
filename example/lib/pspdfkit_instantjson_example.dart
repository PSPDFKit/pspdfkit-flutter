///
///  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

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
  _PspdfkitInstantJsonExampleWidgetState createState() =>
      _PspdfkitInstantJsonExampleWidgetState();
}

class _PspdfkitInstantJsonExampleWidgetState
    extends State<PspdfkitInstantJsonExampleWidget> {
  late PspdfkitWidgetController view;

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
                        onPspdfkitWidgetCreated:
                            (PspdfkitWidgetController controller) {
                          setState(() {
                            view = controller;
                          });
                        })),
                SizedBox(
                    height: 80,
                    child: Row(children: <Widget>[
                      MaterialButton(
                          onPressed: () async {
                            final annotationsJson =
                                await DefaultAssetBundle.of(context)
                                    .loadString(widget.instantJsonPath);
                            await view.applyInstantJson(annotationsJson);
                          },
                          child: const Text('Apply Instant JSON')),
                      MaterialButton(
                          onPressed: () async {
                            const title = 'Exported Instant JSON';
                            await view
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
                            await view.importXfdf(xfdfString);
                          },
                          child: const Text('Apply XFDF')),
                      MaterialButton(
                          onPressed: () async {
                            await view.exportXfdf('xfdf_export.xfdf');
                          },
                          child: const Text('Export XFDF')),
                    ]))
              ])));
    } else {
      return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
    }
  }
}
