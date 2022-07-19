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
import 'package:pspdfkit_example/platform_utils.dart';

import 'package:pspdfkit_flutter/widgets/pspdfkit_widget_controller.dart';

typedef PspdfkitFormExampleWidgetCreatedCallback = void Function(
    PspdfkitWidgetController view);

class PspdfkitFormExampleWidget extends StatefulWidget {
  final String documentPath;
  final dynamic configuration;
  final PspdfkitFormExampleWidgetCreatedCallback?
      onPspdfkitFormExampleWidgetCreated;

  const PspdfkitFormExampleWidget(
      {Key? key,
      required this.documentPath,
      this.configuration,
      this.onPspdfkitFormExampleWidgetCreated})
      : super(key: key);

  @override
  _PspdfkitFormExampleWidgetState createState() =>
      _PspdfkitFormExampleWidgetState();
}

class _PspdfkitFormExampleWidgetState extends State<PspdfkitFormExampleWidget> {
  late PspdfkitWidgetController view;
  bool _keyboardVisible = false;

  @override
  Widget build(BuildContext context) {
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
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
          // Do not resize the the document view on Android or
          // it won't be rendered correctly when filling forms.
          resizeToAvoidBottomInset: PlatformUtils.isIOS(),
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
                                },
                              )
                            : UiKitView(
                                viewType: viewType,
                                layoutDirection: TextDirection.ltr,
                                creationParams: creationParams,
                                onPlatformViewCreated: onPlatformViewCreated,
                                creationParamsCodec:
                                    const StandardMessageCodec())),
                    // On Android do not show the buttons when the Keyboard
                    // is visible. PSPDFKit for Android automatically
                    // fills the space available and re-render the document view.
                    if (!_keyboardVisible || PlatformUtils.isIOS())
                      SizedBox(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                            ElevatedButton(
                                onPressed: () {
                                  view.setFormFieldValue(
                                      'Updated Form Field Value', 'Name_Last');
                                },
                                child: const Text('Set form field value')),
                            ElevatedButton(
                                onPressed: () async {
                                  const title = 'Form Field Value';
                                  final formFieldValue = await view
                                          .getFormFieldValue('Name_Last') ??
                                      '';
                                  await showDialog<AlertDialog>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                            title: const Text(title),
                                            content: Text(formFieldValue),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('OK'))
                                            ],
                                          ));
                                },
                                child: const Text('Get form field value'))
                          ]))
                  ]))));
    } else {
      return Text(
          '$defaultTargetPlatform is not yet supported by PSPDFKit for Flutter.');
    }
  }

  bool isKeyboardVisible() {
    return MediaQuery.of(context).viewInsets.bottom == 0;
  }

  Future<void> onPlatformViewCreated(int id) async {
    view = PspdfkitWidgetController(id);
    if (widget.onPspdfkitFormExampleWidgetCreated != null) {
      widget.onPspdfkitFormExampleWidgetCreated!(view);
    }
  }
}
