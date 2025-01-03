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

const imageAnnotationJson = {
  'annotations': [
    {
      'bbox': [
        167.8721923828125,
        380.95831298828125,
        249.99996948242188,
        250.00009155273438
      ],
      'createdAt': '2024-12-09T07:39:21Z',
      'creatorName': 'demo',
      'id': '01JEN5R3R96PNCG3956MGMMZ48',
      'imageAttachmentId':
          '303c4baa3d6adfcb12cd71e7060d6714850fa9c5404270fde637e43606352580',
      'name': '65dc5234-577b-4b8f-a60c-ecea64171d8b',
      'opacity': 1,
      'pageIndex': 0,
      'rotation': 0,
      'type': 'pspdfkit/image',
      'updatedAt': '2024-12-09T07:39:23Z',
      'v': 2
    }
  ],
  'attachments': {
    '303c4baa3d6adfcb12cd71e7060d6714850fa9c5404270fde637e43606352580': {
      'binary':
          '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCADIAMgDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD5yooopFhRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABXp/wE+HEfxC8SzjUHdNH09VkufLOGkLZCxg9s7WJPYA9Oo8wr6D/ZC8T2Wm67q+hX0qQzamsclsznG903AoPchsj6H6UAz34fCzwMunfYv+EV0nydu3cbcGT/AL+ffz75r5S+P/w1i+H3iG2fS2d9G1BWa3DklomXG5Ce4+YYJ5IODnGT9xV8p/tf+J7K+1TR/D9nIktxYeZPdFTny2fAVD6HAJI9xQyUz51ooooKCiiigAr1P4AfDWL4g+Ibl9UaRdG09Ve4EZ2tKzE7UB6gHBJPUYxxnI8sr6K/ZA8T2VjqmseH7yRIri/8ue1LHG9k3BkB7nBBA9jQDPdz8LPAzad9iPhXSRDt27vs4EmP+un38++c18mfHv4bx/D3xLANPkkfR9QVpLbzDloypAaMnvjcpB7gjryT90V8m/te+J7LUtd0jQrGVJptNEslyUOQjvtwnHcBST9R6UMlM+e6KKKCgooooAKKKKACiiigAooooAKKKKACiiigApUZkYOjFWBBBBwQR6e9dz8LPhlrXxEvpk00x21jbkCe8mBKIT0VQPvN7cADrjivVNd/ZevYNOaXRPEUV5eKufIuLbyRIcdA25sHtyMc9e9AXSPJR8U/HI077EPFGqeRjbnzfnA6f6z7361xkjvI7SSMzuxJZmJJYk9TnvnvU+o2Nzpt/cWV/C9vd27mOWJxgow4I+tV6APaPgt8EJ/HOnDWtau5bDRmYrEIVHmz4OGK5BCqDxnBOQR7133jD9mXTv7Lll8JaperfouUgvmR0lP93cqqVPuQf6j1j4KXdpe/Cnww9gVMcdjHE+3tIg2v/wCPBq7imS2z8zru3ms7ue2uo2iuIHaKSNxgo6nBU+hyMGoq7P4zXdpe/FPxNPpxU27XjgMmMMwwrEY4wWDfXrXGUigp0bvHIskbMkincrKSCCDnIPUHNNooA7M/FLxydP8AsX/CUap5GNufO+fH/XT7361xrszuXclmY5JPJJPOfrU+nWVzqV/b2VhC893cOIookHLs3AFfQ2h/svXs+nJLrXiKKzvHGTBb23nLHx0LFlyfXAx15oC6R840V3XxT+GWs/Du/iTUSlzYXBIgvIQQjkclSD91gO3I9CcHHC0BuFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAfbf7La2g+D2nG12+cbic3OOvmeYcZ99nl/pXrdfBPwm+KWr/Dq8m+xxpeaZckGeylYqCw6MjD7rep5yOMcAj1fXf2oWk0500Pw8Yb11wst1cb0jOOu0AbvzFMlo4L9qQWg+L+oG02+abeH7Rj/nps7/APANleS1a1XULrVtSub/AFGd7i8uZGlllfqzHr7D6dAOBgVVpFLQ7r4afFHxD8PpJU0iSKewmbdLZ3Kloy2Mblwcq2OMg4PfPFdb4x/aH8Va9pcthYwWmkRzKVkltyzSkHqAx+7+Az6EV4xRQFgPXJ61694P+AHi/wAR6XFqEps9KgmUPEl4zeYwPQ7VB28epz04rk/g3Y2mpfFHw1a6iqtbPeKWVwCHK5YKexBYAY/Cv0EFCQmz8/fiL8NfEXgCaP8Aty2ja0lbbFd27b4XbGducAg9eCB0OM4NcXX378bbC01D4U+J475VMcdlJOhPaRAWQ/8AfQFfAVAJ3PWv2XFtG+L1h9r2+aLeY2+7HMmzt77d9fblfmnpWoXWk6la3+nTvb3ltIssUqdVYdPY/ToRwcivo3Qv2oHj05E1zw8Zr1AAZbWfYkh9dpBK/mf6UA1c9E/akW0Pwe1E3W3zhPAbbPXzPMAOPfZ5n618SV6B8WPijq/xFvIftkaWemW7FoLKJiwDH+JmP3mwcdgB0A5Nef0DSCiiigAooooAKKKKACiiigAooooAKKKKACgAk4GSeg460V7/APsjeFLHV9f1XXNQiSZ9LEaWyuMhZH3fPj1AXA9Mk9qAbseVD4deMjp/20eGNY+zY3bvsr52+u3Gce+MVyrKVYhgQw4IIxj2Ir9Nq+T/ANrvwpY6bq+leILCJIZdR8yK6VRgPImCH/3iGIP+6O+aBJnzzRRRQMmsrqexvLe7tJWhuYJFlikTqjqQQw9wea+qvB/7S+iy6XFH4rsLy31FFw8logkikPqASCufTke9fJ9FANXPb/jb8cD410ttC8P2s9npDsGnlnIEs+CCF2gkKoPPUk4HTnPiCgswVQSx6Adz7UV9DfsieFLHUtX1XxBfxJNLpxjitVcZCOwJL/7wAGPqe+DRuGyPIz8OvGS6eb4+GNYFsF3bvsr5A9duM4/DFcqQQcHIPQ8dK/Tavkj9rjwnY6T4g0vXdPiSF9UEiXKIMBpE2nf9SHwfoO5NAkzwCiiigYUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAV6n+z98R4Ph/4luV1RXOj6iqx3DIu4wsudsgHcDcwI9D3xg+WUUA0foUPiL4NOnfbR4o0b7PjOftabvptzuz7YzXyb+0J8Sbfx94htYdI3/wBjacrLC7jaZnbG58dhwAAfc8ZxXk9FAkrBRRRQMKKKKACvWP2eviTbeAfEF1Dq+/8AsbUVVZpEBYwOudr46kfMQQB6HnGD5PRQDVz9Cm+Ivg0ad9uPijR/s2M5+1pu+m3O7PtjNfJH7QPxHg+IHiW2XSlcaPpytHbs42mZmxukI7A7VAHXA7ZwPLKKBJWCiiigYUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAf/2Q==',
      'contentType': 'image/jpeg'
    }
  },
  'format': 'https://pspdfkit.com/instant-json/v1',
  'pdfId': {
    'changing': 'aGa/7dtWOk4HPDunwZp7OA==',
    'permanent': 'J+h3K9erBwoHPDunwZp7OA=='
  }
};

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

                            // Apply Instant JSON with image annotation.
                            await document?.applyInstantJson(const JsonEncoder()
                                .convert(imageAnnotationJson));
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
