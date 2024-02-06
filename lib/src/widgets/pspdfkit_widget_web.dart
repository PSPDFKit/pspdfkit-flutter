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
import 'dart:html';
import 'dart:ui_web' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

import '../web/pspdfkit_web.dart';
import 'pspdfkit_widget_controller.dart';
import 'pspdfkit_widget_controller_web.dart';

typedef PspdfkitWidgetCreatedCallback = void Function(
    PspdfkitWidgetController view);

class PspdfkitWidget extends StatefulWidget {
  final String documentPath;
  final dynamic configuration;
  final PspdfkitWidgetCreatedCallback? onPspdfkitWidgetCreated;

  const PspdfkitWidget({
    Key? key,
    required this.documentPath,
    this.configuration,
    this.onPspdfkitWidgetCreated,
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
      return DivElement()..id = 'pspdfkit-$viewId';
    });
    return HtmlElementView(
        viewType: 'pspdfkit-widget',
        onPlatformViewCreated: (int id) {
          _onPlatformViewCreated(id);
        });
  }

  /// Load the document and create the PSPDFKit instance.
  Future<void> _onPlatformViewCreated(int id) async {
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

    await PSPDFKitWeb.load(widget.documentPath, id, configuration)
        .then((value) {
      var controller = PspdfkitWidgetControllerWeb(id, value);
      widget.onPspdfkitWidgetCreated?.call(controller);
    }).catchError((error) {
      throw Exception('Failed to load: $error');
    });
  }
}
