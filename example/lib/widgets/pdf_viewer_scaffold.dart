///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

import '../utils/platform_utils.dart';

/// A scaffold widget that hosts a PSPDFKit viewer and can contain multiple floating control panels.
class PdfViewerScaffold extends StatefulWidget {
  /// Path to the PDF document
  final String documentPath;

  /// Configuration for the PDF viewer
  final PdfConfiguration? configuration;

  /// List of widgets to display as floating controls
  final List<Widget> controlPanels;

  /// Callback when the PSPDFKit widget is created
  final Function(NutrientViewController)? onNutrientWidgetCreated;

  /// Callback when the PDF document is loaded
  final Function(PdfDocument)? onPdfDocumentLoaded;

  /// Optional app bar to display
  final PreferredSizeWidget? appBar;

  /// Optional FloatingActionButton to display
  final Widget? floatingActionButton;

  /// Optional bottom navigation bar
  final Widget? bottomNavigationBar;

  /// Optional drawer widget
  final Widget? drawer;

  /// Optional endDrawer widget
  final Widget? endDrawer;

  const PdfViewerScaffold({
    Key? key,
    required this.documentPath,
    this.configuration,
    this.controlPanels = const [],
    this.onNutrientWidgetCreated,
    this.onPdfDocumentLoaded,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
  }) : super(key: key);

  @override
  State<PdfViewerScaffold> createState() => _PdfViewerScaffoldState();
}

class _PdfViewerScaffoldState extends State<PdfViewerScaffold> {
  PdfDocument? _document;
  bool _documentLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: PlatformUtils.isAndroid(),
      // Do not resize the the document view on Android or
      // it won't be rendered correctly when filling forms.
      resizeToAvoidBottomInset: PlatformUtils.isIOS(),
      appBar: widget.appBar,
      drawer: widget.drawer,
      endDrawer: widget.endDrawer,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // PDF viewer takes full screen
          _documentLoaded
              ? NutrientView(
                  documentPath: widget.documentPath,
                  configuration: widget.configuration ?? PdfConfiguration(),
                  onViewCreated: (controller) {
                    widget.onNutrientWidgetCreated?.call(controller);
                  },
                  onDocumentLoaded: (document) {
                    setState(() {
                      _document = document;
                    });
                    widget.onPdfDocumentLoaded?.call(document);
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),

          // Control panels, only shown when document is loaded
          if (_documentLoaded && _document != null) ...widget.controlPanels,
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Set document loaded to true - actual document loading happens in PspdfkitWidget
    setState(() {
      _documentLoaded = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
