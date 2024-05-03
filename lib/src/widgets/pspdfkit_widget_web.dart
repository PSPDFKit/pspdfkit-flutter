///
///  Copyright © 2018-2023 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
library pspdfkit_widget_web;

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:pspdfkit_flutter/src/web/pspdfkit_web_instance.dart';
import '../document/pdf_document_web.dart';
import '../web/pspdfkit_web.dart';
import 'pspdfkit_widget_controller_web.dart';

class PspdfkitWidget extends StatefulWidget {
  final String documentPath;
  final dynamic configuration;
  final PspdfkitWidgetCreatedCallback? onPspdfkitWidgetCreated;
  final PdfDocumentLoadedCallback? onPdfDocumentLoaded;
  final PdfDocumentLoadFailedCallback? onPdfDocumentLoadFailure;
  final PageChangedCallback? onPageChanged;

  const PspdfkitWidget({
    Key? key,
    required this.documentPath,
    this.configuration,
    this.onPspdfkitWidgetCreated,
    this.onPdfDocumentLoaded,
    this.onPdfDocumentLoadFailure,
    this.onPageChanged,
  }) : super(key: key);

  @override
  State<PspdfkitWidget> createState() {
    return _PspdfkitWidgetState();
  }
}

class _PspdfkitWidgetState extends State<PspdfkitWidget> {
  late PspdfkitWidgetControllerWeb controller;

  @override
  Widget build(BuildContext context) {
    ui.platformViewRegistry.registerViewFactory('pspdfkit-widget',
        (int viewId) {
      return html.DivElement()..id = 'pspdfkit-$viewId';
    });
    return HtmlElementView(
        viewType: 'pspdfkit-widget',
        onPlatformViewCreated: (int id) {
          // Elements are no longer available when onPlatformViewCreated is called.
          // Therefore we need to pass the element to the PSPDFKit.load method instead of the id.
          // See this GH issue for more details: https://github.com/flutter/flutter/issues/143922#issuecomment-1960133128
          var div = (ui.platformViewRegistry.getViewById(id) as html.Element)
            ..style.width = '100%'
            ..style.height = '100%';
          _onPlatformViewCreated(div);
        });
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
    // Adding a delay to ensure that the view is properly registered before we try to create the PSPDFKit instance.
    Future.delayed(const Duration(milliseconds: 10), () async {
      await PSPDFKitWeb.load(widget.documentPath, id, configuration)
          .then((value) {
        _addDefaultEventListeners(value);
        var controller = PspdfkitWidgetControllerWeb(
          value,
        );
        widget.onPspdfkitWidgetCreated?.call(controller);
        widget.onPdfDocumentLoaded
            ?.call(PdfDocumentWeb(documentId: '', instance: value));
      }).catchError((error) {
        widget.onPdfDocumentLoadFailure?.call(error.toString());
        throw Exception('Failed to load: $error');
      });
    });
  }

  void _addDefaultEventListeners(PspdfkitWebInstance webInstance) {
    webInstance.addEventListener('viewState.currentPageIndex.change',
        (pageIndex) {
      widget.onPageChanged?.call(pageIndex);
    });
  }
}
