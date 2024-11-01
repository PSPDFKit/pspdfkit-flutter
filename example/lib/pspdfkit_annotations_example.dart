///
///  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

import 'utils/platform_utils.dart';

const annotationJsonHashMap = {
  'uuid': 'A92AA288-B11D-490C-847B-D1A0BC64D3E9',
  'bbox': [
    267.4294738769531,
    335.1297607421875,
    97.16720581054688,
    10.305419921875
  ],
  'blendMode': 'normal',
  'updatedAt': '2020-04-01T12:31:15Z',
  'pageIndex': 0,
  'lineWidth': 4,
  'lines': {
    'points': [
      [
        [269.4294738769531, 343.4351806640625],
        [308.458984375, 341.7537841796875],
        [341.19342041015625, 339.6519775390625],
        [358.81964111328125, 339.6519775390625],
        [360.9179992675781, 339.2315673828125],
        [362.5966796875, 338.81121826171875],
        [361.7573547363281, 337.1297607421875]
      ]
    ],
    'intensities': [
      [
        1,
        0.42835134267807007,
        0.635690450668335,
        0.827924370765686,
        0.9846339821815491,
        0.9947978258132935,
        0.9675101041793823
      ]
    ]
  },
  'strokeColor': '#2492FB',
  'isDrawnNaturally': false,
  'opacity': 1,
  'type': 'pspdfkit/ink',
  'creatorName': 'pspdfkit',
  'createdAt': '2020-04-01T12:31:15Z',
  'name': 'A92AA288-B11D-490C-847B-D1A0BC64D3E9',
  'v': 1
};

const annotationJsonString = '''
{
"uuid": "F5EBE614-0917-49E8-89FE-4C0DDB467DC3", 
"bbox": [
  267.4294738769531, 
  335.1297607421875, 
  97.16720581054688, 
  10.305419921875
  ], 
  "updatedAt": "2020-04-01T12:31:15Z", 
  "pageIndex": 0, 
  "lineWidth": 4, 
  "lines": {
    "points": [
      [
        [269.4294738769531, 343.4351806640625], 
        [308.458984375, 341.7537841796875], 
        [341.19342041015625, 339.6519775390625], 
        [358.81964111328125, 339.6519775390625], 
        [360.9179992675781, 339.2315673828125], 
        [362.5966796875, 338.81121826171875], 
        [361.7573547363281, 337.1297607421875]
      ]
    ], 
    "intensities": 
    [
      [1, 0.42835134267807007, 0.635690450668335, 0.827924370765686, 0.9846339821815491, 0.9947978258132935, 0.9675101041793823]
      ]
    
  }, 
  "strokeColor": "#2492FB", 
  "isDrawnNaturally": false, 
  "opacity": 1, 
  "type": "pspdfkit/ink", 
  "creatorName": "pspdfkit", 
  "createdAt": "2020-04-01T12:31:15Z", 
  "name": "A92AA288-B11D-490C-847B-D1A0BC64D3E9", 
  "v": 1
}''';

class PspdfkitAnnotationsExampleWidget extends StatefulWidget {
  final String documentPath;
  final PdfConfiguration? configuration;

  const PspdfkitAnnotationsExampleWidget(
      {Key? key, required this.documentPath, this.configuration})
      : super(key: key);

  @override
  State<PspdfkitAnnotationsExampleWidget> createState() =>
      _PspdfkitAnnotationsExampleWidgetState();
}

class _PspdfkitAnnotationsExampleWidgetState
    extends State<PspdfkitAnnotationsExampleWidget> {
  late PspdfkitWidgetController view;
  late PdfDocument? document;

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
                        configuration: widget.configuration,
                        documentPath: widget.documentPath,
                        onPdfDocumentLoaded: (document) {
                          setState(() {
                            this.document = document;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                        child: Column(children: <Widget>[
                      ElevatedButton(
                          onPressed: () async {
                            await document?.addAnnotation(annotationJsonString);
                            // To test the `view#addAnnotation` method with an InstantJSON string
                            // simply use `annotationJsonString` instead or `annotationJsonHashMap`.
                            // E.g: `await document?.addAnnotation(annotationJsonString);`
                          },
                          child: const Text('Add Annotation')),
                      ElevatedButton(
                          onPressed: () async {
                            const title = 'Annotation JSON';
                            await document
                                ?.getAnnotations(0, 'all')
                                .then((dynamic annotationsJson) {
                              showDialog<AlertDialog>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                          title: const Text(title),
                                          content: Text('$annotationsJson'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('OK'))
                                          ]));
                            });
                          },
                          child: const Text('Get Annotations')),
                      ElevatedButton(
                          onPressed: () async {
                            const title = 'Unsaved Annotations';
                            await document
                                ?.getAllUnsavedAnnotations()
                                .then((dynamic annotationsJson) {
                              showDialog<AlertDialog>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        title: const Text(title),
                                        content: Text('$annotationsJson'),
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
                          child: const Text('Get All Unsaved Annotations')),
                      ElevatedButton(
                          onPressed: () async {
                            dynamic annotationsJson =
                                await document?.getAnnotations(0, 'all');
                            for (var annotation in annotationsJson) {
                              await document
                                  ?.removeAnnotation(jsonEncode(annotation));
                            }
                          },
                          child: const Text('Remove Annotation')),
                    ]))
                  ]))));
    } else {
      return Text(
          '$defaultTargetPlatform is not yet supported by PSPDFKit for Flutter.');
    }
  }
}
