///
///  Copyright © 2018-2021 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:pspdfkit_flutter/src/pspdfkit_view.dart';

class PspdfkitAnnotationsExampleWidget extends StatefulWidget {
  final String documentPath;
  final dynamic configuration;

  PspdfkitAnnotationsExampleWidget({
    Key key,
    @required this.documentPath,
    this.configuration
  }) : super(key: key);

  @override
  PspdfkitAnnotationsExampleWidgetState createState() => PspdfkitAnnotationsExampleWidgetState();
}

class PspdfkitAnnotationsExampleWidgetState extends State<PspdfkitAnnotationsExampleWidget> {
  PspdfkitView view;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(),
        child: SafeArea(
          bottom: false,
          child: Column(children: <Widget>[
            Expanded(child: UiKitView(
              viewType: 'com.pspdfkit.widget',
              onPlatformViewCreated: onPlatformViewCreated,
              creationParamsCodec: const StandardMessageCodec())),
            Container(
              height: 80,
              child: Row(
                children: <Widget>[
                  Container(width: 20),
                  CupertinoButton(child: Text('Add Annotation'), onPressed: () async {
                    dynamic annotation = {
                      'uuid': 'A92AA288-B11D-490C-847B-D1A0BC64D3E9',
                      'bbox': [267.4294738769531, 335.1297607421875, 97.16720581054688, 10.305419921875],
                      'blendMode': 'normal',
                      'updatedAt': '2020-04-01T12:31:15Z',
                      'pageIndex': 0,
                      'lineWidth': 4,
                      'lines': {
                        'points': [[[269.4294738769531, 343.4351806640625], [308.458984375, 341.7537841796875], [341.19342041015625, 339.6519775390625], [358.81964111328125, 339.6519775390625], [360.9179992675781, 339.2315673828125], [362.5966796875, 338.81121826171875], [361.7573547363281, 337.1297607421875]]],
                        'intensities': [[1, 0.42835134267807007, 0.635690450668335, 0.827924370765686, 0.9846339821815491, 0.9947978258132935, 0.9675101041793823]]},
                        'strokeColor': '#2492FB',
                        'isDrawnNaturally': false,
                        'opacity': 1,
                        'type': 'pspdfkit/ink',
                        'creatorName': 'pspdfkit',
                        'createdAt': '2020-04-01T12:31:15Z',
                        'name': 'A92AA288-B11D-490C-847B-D1A0BC64D3E9',
                        'v': 1};
                      await view.addAnnotation(annotation);
                  }),
                  Container(width: 20),
                  CupertinoButton(child: Text('Remove Annotation'), onPressed: () async {
                    dynamic annotationsJson = await view.getAnnotations(0, 'all');
                    await view.removeAnnotation({'uuid': annotationsJson[0]['uuid'] as String});
                  }),
                  Container(width: 20),
                  CupertinoButton(child: Text('Get Annotations'), onPressed: () async {
                    final title = 'Annotation JSON';
                    dynamic annotationsJson = await view.getAnnotations(0, 'all');
                    print(annotationsJson);
                    await showCupertinoDialog<CupertinoAlertDialog>(
                      context: context,
                      builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Text(title),
                        content: Text('$annotationsJson'),
                        actions: [
                           TextButton(onPressed: () {Navigator.of(context).pop();}, child: Text('OK'))
                          ],
                      ));
                  }),
                  Container(width: 20),
                  CupertinoButton(child: Text('Get All Unsaved Annotations'), onPressed: () async {
                    final title = 'Unsaved Annotations';
                    dynamic annotationsJson = await view.getAllUnsavedAnnotations();
                    print(annotationsJson);
                    await showCupertinoDialog<CupertinoAlertDialog>(
                      context: context,
                      builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Text(title),
                        content: Text('$annotationsJson'),
                        actions: [
                           TextButton(onPressed: () {Navigator.of(context).pop();}, child: Text('OK'))
                          ],
                      ));
                  })
                ]))]))
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // PspdfkitView is only supported in iOS at the moment.
      // Support for Android is coming soon.
      return Text('Unsupported Widget');
    } else {
      return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    view = PspdfkitView.init(id, widget.documentPath, widget.configuration);
  }
}
