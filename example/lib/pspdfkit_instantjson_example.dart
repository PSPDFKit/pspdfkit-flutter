///
///  Copyright © 2018-2023 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pspdfkit_flutter/widgets/pspdfkit_widget_controller.dart';
import 'package:pspdfkit_flutter/widgets/pspdfkit_widget.dart';

import 'utils/platform_utils.dart';

class PspdfkitInstantJsonExampleWidget extends StatefulWidget {
  final String documentPath;
  final String instantJsonPath;
  final dynamic configuration;

  const PspdfkitInstantJsonExampleWidget({
    Key? key,
    required this.documentPath,
    required this.instantJsonPath,
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
    if (PlatformUtils.isIOS() || PlatformUtils.isAndroid()) {
      return Scaffold(
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
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'))
                                        ],
                                      ));
                            });
                          },
                          child: const Text('Export Instant JSON'))
                    ]))
              ])));
    } else {
      return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
    }
  }
}
