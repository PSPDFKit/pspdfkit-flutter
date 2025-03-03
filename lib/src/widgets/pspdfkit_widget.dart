///
///  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
library pspdfkit_widget;

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'pspdfkit_flutter_widget_controller_impl.dart';
import 'pspdfkit_widget_controller_native.dart';

class PspdfkitWidget extends StatefulWidget {
  final String documentPath;
  final dynamic configuration;
  final PspdfkitWidgetCreatedCallback? onPspdfkitWidgetCreated;
  final PdfDocumentLoadedCallback? onPdfDocumentLoaded;
  final PdfDocumentLoadFailedCallback? onPdfDocumentError;
  final PageChangedCallback? onPageChanged;
  final PageClickedCallback? onPageClicked;
  final PdfDocumentSavedCallback? onPdfDocumentSaved;
  const PspdfkitWidget({
    Key? key,
    required this.documentPath,
    this.configuration,
    this.onPspdfkitWidgetCreated,
    this.onPdfDocumentLoaded,
    this.onPdfDocumentError,
    this.onPageChanged,
    this.onPageClicked,
    this.onPdfDocumentSaved,
  }) : super(key: key);

  @override
  State<PspdfkitWidget> createState() {
    return _PspdfkitWidgetState();
  }
}

class _PspdfkitWidgetState extends State<PspdfkitWidget> {
  late PspdfkitWidgetController controller;
  late int? _id;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? config;

    // Convert the configuration to a map.
    if (widget.configuration != null) {
      if (widget.configuration is PdfConfiguration) {
        config = widget.configuration.toMap();
      } else if (widget.configuration is Map<String, dynamic>) {
        config = widget.configuration;
      } else {
        throw ArgumentError(
            'The configuration must be either a PdfConfiguration or a Map<String, dynamic>.');
      }
    } else {
      config = null;
    }

    // This is used in the platform side to register the view.
    const String viewType = 'com.pspdfkit.widget';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'document': widget.documentPath,
      'configuration': config ?? {},
    };

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        onPlatformViewCreated: _onPlatformViewCreated,
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
            ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
            ..create();
        },
      );
    } else {
      return Text(
          '$defaultTargetPlatform is not yet supported by PSPDFKit for Flutter.');
    }
  }

  Future<void> _onPlatformViewCreated(int id) async {
    setState(() {
      _id = id;
    });
    MethodChannel channel = MethodChannel('com.pspdfkit.widget.$id');
    var api = PspdfkitWidgetControllerApi(
      binaryMessenger: channel.binaryMessenger,
      messageChannelSuffix: '$id',
    );
    controller = Pspdfkit.useLegacy
        // ignore: deprecated_member_use_from_same_package
        ? PspdfkitWidgetControllerNative(
            channel,
            onPageChanged: widget.onPageChanged,
            onPdfDocumentLoadFailed: widget.onPdfDocumentError,
            onPdfDocumentLoaded: widget.onPdfDocumentLoaded,
          )
        : PspdfkitFlutterWidgetControllerImpl(
            api,
            onPdfPageChanged: widget.onPageChanged,
            onPdfDocumentLoadFailed: widget.onPdfDocumentError,
            onPdfDocumentLoaded: widget.onPdfDocumentLoaded,
            onPageClicked: widget.onPageClicked,
            onPdfDocumentSaved: widget.onPdfDocumentSaved,
          );
    widget.onPspdfkitWidgetCreated?.call(controller);
    if (controller is PspdfkitFlutterWidgetControllerImpl) {
      PspdfkitWidgetCallbacks.setUp(
          controller as PspdfkitFlutterWidgetControllerImpl,
          messageChannelSuffix: 'widget.callbacks.$id');
      NutrientEventsCallbacks.setUp(
          controller as PspdfkitFlutterWidgetControllerImpl,
          messageChannelSuffix: 'events.callbacks.$id');
    }
  }

  @override
  void dispose() {
    PspdfkitWidgetCallbacks.setUp(null,
        messageChannelSuffix: 'widget.callbacks.$_id');
    NutrientEventsCallbacks.setUp(null,
        messageChannelSuffix: 'events.callbacks.$_id');
    super.dispose();
  }
}
