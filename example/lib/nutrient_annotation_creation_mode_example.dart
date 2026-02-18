///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

import 'widgets/pdf_viewer_scaffold.dart';

/// Example demonstrating how to use annotation creation mode
class AnnotationCreationModeExampleWidget extends StatefulWidget {
  final String documentPath;

  const AnnotationCreationModeExampleWidget(
      {Key? key, required this.documentPath})
      : super(key: key);

  @override
  State<AnnotationCreationModeExampleWidget> createState() =>
      _AnnotationCreationModeExampleWidgetState();
}

class _AnnotationCreationModeExampleWidgetState
    extends State<AnnotationCreationModeExampleWidget> {
  NutrientViewController? _controller;
  AnnotationTool? _currentTool;

  @override
  Widget build(BuildContext context) {
    return PdfViewerScaffold(
      documentPath: widget.documentPath,
      configuration: PdfConfiguration(
        enableAnnotationEditing: true,
      ),
      onNutrientWidgetCreated: (controller) {
        setState(() {
          _controller = controller;
        });
      },
      appBar: AppBar(
        title: const Text('Annotation Creation Mode Example'),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildToolbar(),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _exitAnnotationCreationMode,
      backgroundColor: Colors.red,
      child: const Icon(Icons.close),
    );
  }

  Widget _buildToolbar() {
    // Top 20 essential annotation tools that work well across all platforms
    final toolButtons = <Widget>[
      // Drawing tools (3)
      _buildToolButton(AnnotationTool.inkPen, 'Pen', Icons.brush),
      _buildToolButton(
          AnnotationTool.inkHighlighter, 'Highlighter', Icons.highlight),
      _buildToolButton(AnnotationTool.eraser, 'Eraser', Icons.auto_fix_normal),

      // Text markup tools (4)
      _buildToolButton(
          AnnotationTool.highlight, 'Highlight', Icons.format_color_fill),
      _buildToolButton(
          AnnotationTool.underline, 'Underline', Icons.format_underlined),
      _buildToolButton(
          AnnotationTool.strikeOut, 'Strike Out', Icons.format_strikethrough),
      _buildToolButton(AnnotationTool.squiggly, 'Squiggly', Icons.waves),

      // Text annotation tools (3)
      _buildToolButton(AnnotationTool.freeText, 'Text', Icons.text_fields),
      _buildToolButton(AnnotationTool.note, 'Note', Icons.note_add),
      _buildToolButton(
          AnnotationTool.freeTextCallOut, 'Callout', Icons.chat_bubble_outline),

      // Shape tools (4)
      _buildToolButton(AnnotationTool.square, 'Square', Icons.crop_square),
      _buildToolButton(AnnotationTool.circle, 'Circle', Icons.circle_outlined),
      _buildToolButton(AnnotationTool.line, 'Line', Icons.show_chart),
      _buildToolButton(AnnotationTool.arrow, 'Arrow', Icons.arrow_forward),

      // Media & interactive tools (3)
      _buildToolButton(AnnotationTool.stamp, 'Stamp', Icons.approval),
      _buildToolButton(AnnotationTool.image, 'Image', Icons.image),
      _buildToolButton(AnnotationTool.signature, 'Signature', Icons.draw),

      // Advanced tools (3)
      _buildToolButton(
          AnnotationTool.polygon, 'Polygon', Icons.pentagon_outlined),
      _buildToolButton(AnnotationTool.polyline, 'Polyline', Icons.polyline),
      _buildToolButton(
          AnnotationTool.measurementDistance, 'Measure', Icons.straighten),
    ];

    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: toolButtons,
        ),
      ),
    );
  }

  Widget _buildToolButton(AnnotationTool tool, String label, IconData icon) {
    final isSelected = _currentTool == tool;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _toggleAnnotationCreationMode(tool),
            icon: Icon(icon),
            color: isSelected ? Colors.blue : Colors.black87,
            tooltip: label,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAnnotationCreationMode(AnnotationTool tool) async {
    if (_controller == null) return;

    // If the same tool is already selected, exit annotation mode
    if (_currentTool == tool) {
      await _exitAnnotationCreationMode();
      return;
    }

    // Otherwise, enter the new annotation mode
    try {
      final result = await _controller!.enterAnnotationCreationMode(tool);
      if (result == true) {
        setState(() {
          _currentTool = tool;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Entered annotation mode: ${tool.toString().split('.').last}'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error entering annotation mode: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exitAnnotationCreationMode() async {
    if (_controller != null && _currentTool != null) {
      try {
        final result = await _controller!.exitAnnotationCreationMode();
        if (result == true) {
          setState(() {
            _currentTool = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exited annotation mode'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exiting annotation mode: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
