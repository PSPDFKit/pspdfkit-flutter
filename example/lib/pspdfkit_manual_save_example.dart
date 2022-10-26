///
///  Copyright © 2022 PSPDFKit GmbH. All rights reserved.
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

import 'utils/platform_utils.dart';

class PspdfkitManualSaveExampleWidget extends StatefulWidget {
  final String documentPath;
  final dynamic configuration;

  const PspdfkitManualSaveExampleWidget(
      {Key? key, required this.documentPath, this.configuration})
      : super(key: key);

  @override
  _PspdfkitManualSaveExampleWidgetState createState() =>
      _PspdfkitManualSaveExampleWidgetState();
}

class _PspdfkitManualSaveExampleWidgetState
    extends State<PspdfkitManualSaveExampleWidget> {
  late PspdfkitWidgetController pspdfkitWidgetController;

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
                            await pspdfkitWidgetController.save();
                          },
                          child: const Text('Save Document'))
                    ]))
                  ]))));
    } else {
      return Text(
          '$defaultTargetPlatform is not yet supported by PSPDFKit for Flutter.');
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    pspdfkitWidgetController = PspdfkitWidgetController(id);
  }
}
