///
///  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
// ignore_for_file: deprecated_member_use_from_same_package

library pspdfkit_widget_web;

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import '../document/pdf_document_web.dart';
import '../web/nutrient_web.dart';
import '../web/nutrient_web_instance.dart';
import 'pspdfkit_widget_controller_web.dart';

@Deprecated('Use NutrientView instead')
class PspdfkitWidget extends StatefulWidget {
  final String documentPath;
  final dynamic configuration;
  final PspdfkitWidgetCreatedCallback? onPspdfkitWidgetCreated;
  final PdfDocumentLoadedCallback? onPdfDocumentLoaded;
  final PdfDocumentLoadFailedCallback? onPdfDocumentLoadFailure;
  final PageChangedCallback? onPageChanged;
  final PageClickedCallback? onPageClicked;
  final PdfDocumentSavedCallback? onPdfDocumentSaved;
  //Not used on web
  final List<CustomToolbarItem> customToolbarItems;
  //Not used on web
  final OnCustomToolbarItemTappedCallback? onCustomToolbarItemTapped;

  const PspdfkitWidget({
    Key? key,
    required this.documentPath,
    this.configuration,
    this.onPspdfkitWidgetCreated,
    this.onPdfDocumentLoaded,
    this.onPdfDocumentLoadFailure,
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
  late PspdfkitWidgetControllerWeb controller;
  bool _isInitialized = false;
  NutrientWebInstance? _webInstance;
  final Map<String, Function> _eventListeners = {};

  @override
  void initState() {
    super.initState();
    // Wait for the first frame to be rendered before initializing the viewer.
    // This is likely to affect performace a bit but will guarantee that the pdfview loads every time.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    // Register the view factory
    ui.platformViewRegistry.registerViewFactory('pspdfkit-widget',
        (int viewId) {
      return html.DivElement()
        ..id = 'pspdfkit-$viewId'
        ..style.width = '100%'
        ..style.height = '100%';
    });

    // Wrap HtmlElementView in a container with explicit dimensions
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: HtmlElementView(
            viewType: 'pspdfkit-widget',
            onPlatformViewCreated: (int id) {
              var element =
                  (ui.platformViewRegistry.getViewById(id) as html.Element)
                    ..style.width = '100%'
                    ..style.height = '100%';
              _onPlatformViewCreated(element);
            },
          ),
        );
      },
    );
  }

  /// Load the document and create the PSPDFKit instance.
  Future<void> _onPlatformViewCreated(html.Element id) async {
    // Prepare the configuration object.
    // Only pass the configuration if it is a PdfConfiguration.
    PdfConfiguration? configuration;

    if (widget.configuration != null) {
      if (widget.configuration is PdfConfiguration) {
        configuration = widget.configuration;
      } else {
        throw ArgumentError(
            'The configuration must be either a PdfConfiguration on the web platform.');
      }
    } else {
      configuration = null;
    }
    // Use addPostFrameCallback to ensure the view is properly added to the widget tree
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final value =
            await NutrientWeb.load(widget.documentPath, id, configuration);
        if (!mounted) return;
        _addDefaultEventListeners(value);
        controller = PspdfkitWidgetControllerWeb(value);
        widget.onPspdfkitWidgetCreated?.call(controller);
        widget.onPdfDocumentLoaded
            ?.call(PdfDocumentWeb(documentId: '', instance: value));
      } catch (error) {
        if (!mounted) return;
        widget.onPdfDocumentLoadFailure?.call(error.toString());
      }
    });
  }

  @override
  void dispose() {
    _removeEventListeners();
    super.dispose();
  }

  void _removeEventListeners() {
    // Clean up event listeners to prevent memory leaks
    if (_webInstance != null) {
      for (final entry in _eventListeners.entries) {
        try {
          _webInstance!.removeEventListener(entry.key, entry.value);
        } catch (e) {
          // Silently handle potential errors during cleanup
          debugPrint('Error removing event listener: $e');
        }
      }
      _eventListeners.clear();
    }
  }

  void _addDefaultEventListeners(NutrientWebInstance webInstance) {
    _webInstance = webInstance;

    // Page change event listener
    void pageChangeListener(pageIndex) {
      if (!mounted) return;
      widget.onPageChanged?.call(pageIndex);
    }

    webInstance.addEventListener(
        'viewState.currentPageIndex.change', pageChangeListener);
    _eventListeners['viewState.currentPageIndex.change'] = pageChangeListener;

    // Page press event listener with safety checks
    void pagePressListener(dynamic event) {
      if (!mounted) return;

      try {
        // Check if event and point exist
        if (event == null ||
            event['point'] == null ||
            event['pageIndex'] == null) {
          return;
        }

        final x = event['point']['x'];
        final y = event['point']['y'];

        if (x != null && y != null) {
          final point = PointF(
              x: x is num ? x.toDouble() : 0.0,
              y: y is num ? y.toDouble() : 0.0);
          widget.onPageClicked?.call('', event['pageIndex'], point, null);
        }
      } catch (e) {
        debugPrint('Error processing page press event: $e');
      }
    }

    webInstance.addEventListener('page.press', pagePressListener);
    _eventListeners['page.press'] = pagePressListener;

    // Document save state change event listener
    void saveStateListener(dynamic event) {
      if (!mounted) return;

      try {
        // Only proceed if event exists and has the right property
        if (event == null) return;

        final hasUnsavedChanges = event['hasUnsavedChanges'];
        if (hasUnsavedChanges == false) {
          widget.onPdfDocumentSaved?.call('', widget.documentPath);
        }
      } catch (e) {
        debugPrint('Error processing save state change event: $e');
      }
    }

    webInstance.addEventListener('document.saveStateChange', saveStateListener);
    _eventListeners['document.saveStateChange'] = saveStateListener;
  }
}
