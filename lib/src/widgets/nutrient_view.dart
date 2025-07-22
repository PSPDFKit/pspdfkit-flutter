///
///  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
library nutrient_viewer;

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'nutrient_view_controller_native.dart';

/// A widget that displays a PDF document using Nutrient.
class NutrientView extends StatefulWidget {
  /// The path to the document to display.
  final String documentPath;

  /// The configuration to use for the document.
  final dynamic configuration;

  /// Called when the widget is created.
  final NutrientViewCreatedCallback? onViewCreated;

  /// Called when the document is loaded.
  final OnDocumentLoadedCallback? onDocumentLoaded;

  /// Called when the document fails to load.
  final OnDocumentLoadingFailedCallback? onDocumentError;

  /// Called when the page changes.
  final PageChangedCallback? onPageChanged;

  /// Called when a page is clicked.
  final PageClickedCallback? onPageClicked;

  /// Called when the document is saved.
  final OnDocumentSavedCallback? onDocumentSaved;

  /// Custom toolbar items to add to the toolbar.
  final List<CustomToolbarItem> customToolbarItems;

  /// Called when a custom toolbar item is tapped.
  final OnCustomToolbarItemTappedCallback? onCustomToolbarItemTapped;

  /// Creates a new [NutrientView] widget.
  const NutrientView({
    Key? key,
    required this.documentPath,
    this.configuration,
    this.onViewCreated,
    this.onDocumentLoaded,
    this.onDocumentError,
    this.onPageChanged,
    this.onPageClicked,
    this.onDocumentSaved,
    this.customToolbarItems = const [],
    this.onCustomToolbarItemTapped,
  }) : super(key: key);

  @override
  State<NutrientView> createState() {
    return _NutrientViewState();
  }
}

class _NutrientViewState extends State<NutrientView> {
  late NutrientViewController controller;
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
    controller = NutrientViewControllerNative(
      api,
      onPageChangedListener: widget.onPageChanged,
      onDocumentLoadingFailedListener: widget.onDocumentError,
      onDocumentLoadedListener: widget.onDocumentLoaded,
      onPageClickedListener: widget.onPageClicked,
      onDocumentSavedListener: widget.onDocumentSaved,
      onCustomToolbarItemTappedListener: widget.onCustomToolbarItemTapped,
    );
    widget.onViewCreated?.call(controller);
    if (controller is NutrientViewControllerNative) {
      NutrientViewCallbacks.setUp(controller as NutrientViewControllerNative,
          messageChannelSuffix: 'widget.callbacks.$id');
      NutrientEventsCallbacks.setUp(controller as NutrientViewControllerNative,
          messageChannelSuffix: 'events.callbacks.$id');
      CustomToolbarCallbacks.setUp(controller as NutrientViewControllerNative,
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
