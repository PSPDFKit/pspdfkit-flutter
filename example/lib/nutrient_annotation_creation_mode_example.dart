///
///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
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
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToolButton(AnnotationTool.inkPen, 'Ink Pen', Icons.brush),
            _buildToolButton(
                AnnotationTool.inkHighlighter, 'Highlighter', Icons.highlight),
            _buildToolButton(
                AnnotationTool.inkMagic, 'Magic Ink', Icons.auto_fix_high),
            _buildToolButton(
                AnnotationTool.freeText, 'Free Text', Icons.text_fields),
            _buildToolButton(
                AnnotationTool.square, 'Square', Icons.crop_square),
            _buildToolButton(
                AnnotationTool.circle, 'Circle', Icons.circle_outlined),
            _buildToolButton(AnnotationTool.line, 'Line', Icons.show_chart),
            _buildToolButton(
                AnnotationTool.arrow, 'Arrow', Icons.arrow_forward),
            _buildToolButton(AnnotationTool.signature, 'Signature', Icons.draw),
            _buildToolButton(
                AnnotationTool.eraser, 'Eraser', Icons.auto_fix_normal),
          ],
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
            onPressed: () => _enterAnnotationCreationMode(tool),
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

  Future<void> _enterAnnotationCreationMode(AnnotationTool tool) async {
    if (_controller != null) {
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
