///
///  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

import 'package:pspdfkit_flutter/widgets/pspdfkit_widget_controller.dart';

import 'platform_utils.dart';

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
  final dynamic configuration;

  const PspdfkitAnnotationsExampleWidget(
      {Key? key, required this.documentPath, this.configuration})
      : super(key: key);

  @override
  _PspdfkitAnnotationsExampleWidgetState createState() =>
      _PspdfkitAnnotationsExampleWidgetState();
}

class _PspdfkitAnnotationsExampleWidgetState
    extends State<PspdfkitAnnotationsExampleWidget> {
  late PspdfkitWidgetController view;

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'com.pspdfkit.widget';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'document': widget.documentPath,
      'configuration': widget.configuration
    };
    if (PlatformUtils.isCurrentPlatformSupported()) {
      return Scaffold(
          extendBodyBehindAppBar: PlatformUtils.isAndroid(),
          appBar: AppBar(),
          body: SafeArea(
              top: false,
              bottom: false,
              child: Container(
                  padding: PlatformUtils.isIOS()
                      ? null
                      : const EdgeInsets.only(top: kToolbarHeight),
                  child: Column(children: <Widget>[
                    Expanded(
                        child: PlatformUtils.isAndroid()
                            ? PlatformViewLink(
                                viewType: viewType,
                                surfaceFactory: (BuildContext context,
                                    PlatformViewController controller) {
                                  return AndroidViewSurface(
                                    controller:
                                        controller as AndroidViewController,
                                    gestureRecognizers: const <
                                        Factory<
                                            OneSequenceGestureRecognizer>>{},
                                    hitTestBehavior:
                                        PlatformViewHitTestBehavior.opaque,
                                  );
                                },
                                onCreatePlatformView:
                                    (PlatformViewCreationParams params) {
                                  return PlatformViewsService
                                      .initSurfaceAndroidView(
                                    id: params.id,
                                    viewType: viewType,
                                    layoutDirection: TextDirection.ltr,
                                    creationParams: creationParams,
                                    creationParamsCodec:
                                        const StandardMessageCodec(),
                                    onFocus: () {
                                      params.onFocusChanged(true);
                                    },
                                  )
                                    ..addOnPlatformViewCreatedListener(
                                        params.onPlatformViewCreated)
                                    ..addOnPlatformViewCreatedListener(
                                        onPlatformViewCreated)
                                    ..create();
                                })
                            : UiKitView(
                                viewType: viewType,
                                layoutDirection: TextDirection.ltr,
                                creationParams: creationParams,
                                onPlatformViewCreated: onPlatformViewCreated,
                                creationParamsCodec:
                                    const StandardMessageCodec())),
                    SizedBox(
                        child: Column(children: <Widget>[
                      ElevatedButton(
                          onPressed: () async {
                            await view.addAnnotation(annotationJsonHashMap);
                            // To test the `view#addAnnotation` method with an InstantJSON string
                            // simply use `annotationJsonString` instead or `annotationJsonHashMap`.
                            // E.g: `await view.addAnnotation(annotationJsonString);`
                          },
                          child: const Text('Add Annotation')),
                      if (PlatformUtils.isIOS())
                        ElevatedButton(
                            onPressed: () async {
                              dynamic annotationsJson =
                                  await view.getAnnotations(0, 'all');
                              await view.removeAnnotation({
                                'uuid': annotationsJson[0]['uuid'] as String
                              });
                            },
                            child: const Text('Remove Annotation')),
                      ElevatedButton(
                          onPressed: () async {
                            const title = 'Annotation JSON';
                            dynamic annotationsJson =
                                await view.getAnnotations(0, 'all');
                            await showDialog<AlertDialog>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                        title: const Text(title),
                                        content: Text('$annotationsJson'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'))
                                        ]));
                          },
                          child: const Text('Get Annotations')),
                      ElevatedButton(
                          onPressed: () async {
                            const title = 'Unsaved Annotations';
                            dynamic annotationsJson =
                                await view.getAllUnsavedAnnotations();
                            print(annotationsJson);
                            await showDialog<AlertDialog>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
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
                          },
                          child: const Text('Get All Unsaved Annotations'))
                    ]))
                  ]))));
    } else {
      return Text(
          '$defaultTargetPlatform is not yet supported by PSPDFKit for Flutter.');
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    view = PspdfkitWidgetController(id);
  }
}
