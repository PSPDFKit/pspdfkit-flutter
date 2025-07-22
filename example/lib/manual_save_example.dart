///
///  Copyright © 2022-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

import 'utils/platform_utils.dart';

class ManualSaveExampleWidget extends StatefulWidget {
  final String documentPath;
  final PdfConfiguration configuration;

  const ManualSaveExampleWidget(
      {Key? key, required this.documentPath, required this.configuration})
      : super(key: key);

  @override
  State<ManualSaveExampleWidget> createState() =>
      _ManualSaveExampleWidgetState();
}

class _ManualSaveExampleWidgetState extends State<ManualSaveExampleWidget> {
  late PdfDocument document;

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
                      child: NutrientView(
                        documentPath: widget.documentPath,
                        configuration: widget.configuration,
                        onDocumentLoaded: (document) {
                          this.document = document;
                        },
                        onDocumentSaved: (documentId, path) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Document saved: $path'),
                          ));
                        },
                      ),
                    ),
                    SizedBox(
                        child: Column(children: <Widget>[
                      ElevatedButton(
                          onPressed: () async {
                            await document.save();
                          },
                          child: const Text('Save Document'))
                    ]))
                  ]))));
    } else {
      return Text(
          '$defaultTargetPlatform is not yet supported by PSPDFKit for Flutter.');
    }
  }
}
