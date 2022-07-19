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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:pspdfkit_flutter/widgets/pspdfkit_widget_controller.dart';

typedef PspdfkitWidgetCreatedCallback = void Function(
    PspdfkitWidgetController view);

class PspdfkitWidget extends StatefulWidget {
  final String? documentPath;
  final dynamic configuration;
  final PspdfkitWidgetCreatedCallback? onPspdfkitWidgetCreated;

  const PspdfkitWidget(
      {Key? key,
      this.documentPath,
      this.configuration,
      this.onPspdfkitWidgetCreated})
      : super(key: key);

  @override
  _PspdfkitWidgetState createState() => _PspdfkitWidgetState();
}

class _PspdfkitWidgetState extends State<PspdfkitWidget> {
  late PspdfkitWidgetController controller;

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'com.pspdfkit.widget';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'document': widget.documentPath,
      'configuration': widget.configuration
    };

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory:
            (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () {
              params.onFocusChanged(true);
            },
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener(onPlatformViewCreated)
            ..create();
        },
      );
    } else {
      return Text(
          '$defaultTargetPlatform is not yet supported by PSPDFKit for Flutter.');
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    controller = PspdfkitWidgetController(id);
    if (widget.onPspdfkitWidgetCreated != null) {
      widget.onPspdfkitWidgetCreated!(controller);
    }
  }
}
