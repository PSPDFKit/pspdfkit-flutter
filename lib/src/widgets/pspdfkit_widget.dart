///
///  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
// ignore_for_file: deprecated_member_use_from_same_package

library pspdfkit_widget;

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter/pspdfkit_flutter.dart';
import 'pspdfkit_flutter_widget_controller_impl.dart';
import 'pspdfkit_widget_controller_native.dart';

/// A widget that displays a PDF document using Nutrient.
///
/// @deprecated Use [NutrientView] instead.
@Deprecated('Use NutrientView instead')
class PspdfkitWidget extends StatefulWidget {
  /// The path to the document to display.
  final String documentPath;

  /// The configuration to use for the document.
  final dynamic configuration;

  /// Called when the widget is created.
  final PspdfkitWidgetCreatedCallback? onPspdfkitWidgetCreated;

  /// Called when the document is loaded.
  final PdfDocumentLoadedCallback? onPdfDocumentLoaded;

  /// Called when the document fails to load.
  final PdfDocumentLoadFailedCallback? onPdfDocumentError;

  /// Called when the page changes.
  final PageChangedCallback? onPageChanged;

  /// Called when a page is clicked.
  final PageClickedCallback? onPageClicked;

  /// Called when the document is saved.
  final PdfDocumentSavedCallback? onPdfDocumentSaved;

  /// Custom toolbar items to add to the toolbar.
  final List<CustomToolbarItem> customToolbarItems;

  /// Called when a custom toolbar item is tapped.
  final OnCustomToolbarItemTappedCallback? onCustomToolbarItemTapped;

  /// Creates a new [PspdfkitWidget] widget.
  ///
  /// @deprecated Use [NutrientView] instead.
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
    this.customToolbarItems = const [],
    this.onCustomToolbarItemTapped,
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
    const String viewType = 'com.nutrient.widget';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'document': widget.documentPath,
      'configuration': config ?? {},
      'customToolbarItems':
          widget.customToolbarItems.map((item) => item.toMap()).toList(),
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
          '$defaultTargetPlatform is not yet supported by Nutrient for Flutter.');
    }
  }

  Future<void> _onPlatformViewCreated(int id) async {
    setState(() {
      _id = id;
    });
    MethodChannel channel = MethodChannel('com.nutrient.widget.$id');
    var api = NutrientViewControllerApi(
      binaryMessenger: channel.binaryMessenger,
      messageChannelSuffix: '$id',
    );
    controller = Pspdfkit.useLegacy
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
            onCustomToolbarItemTappedListener: widget.onCustomToolbarItemTapped,
          );
    widget.onPspdfkitWidgetCreated?.call(controller);
    if (controller is PspdfkitFlutterWidgetControllerImpl) {
      NutrientViewCallbacks.setUp(
          controller as PspdfkitFlutterWidgetControllerImpl,
          messageChannelSuffix: 'widget.callbacks.$id');
      NutrientEventsCallbacks.setUp(
          controller as PspdfkitFlutterWidgetControllerImpl,
          messageChannelSuffix: 'events.callbacks.$id');
      CustomToolbarCallbacks.setUp(
          controller as PspdfkitFlutterWidgetControllerImpl,
          messageChannelSuffix: 'customToolbar.callbacks.$id');
    }
  }

  @override
  void dispose() {
    NutrientViewCallbacks.setUp(null,
        messageChannelSuffix: 'widget.callbacks.$_id');
    NutrientEventsCallbacks.setUp(null,
        messageChannelSuffix: 'events.callbacks.$_id');
    CustomToolbarCallbacks.setUp(null,
        messageChannelSuffix: 'customToolbar.callbacks.$_id');
    super.dispose();
  }
}
