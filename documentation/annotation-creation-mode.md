# Annotation Creation Mode

This guide explains how to use the annotation creation mode feature in the Nutrient Flutter SDK to programmatically enable annotation tools for users to create PDF annotations.

## Overview

The annotation creation mode API allows you to programmatically enter and exit specific annotation creation modes, enabling users to create various types of PDF annotations such as ink drawings, text highlights, shapes, signatures, and more.

## Basic Usage

To use annotation creation mode, you first need to get a reference to the `NutrientViewController` through the `onViewCreated` callback:

```dart
NutrientViewController? _controller;

NutrientView(
  documentPath: 'path/to/document.pdf',
  configuration: PdfConfiguration(
    enableAnnotationEditing: true, // Required for annotation creation
  ),
  onViewCreated: (controller) {
    setState(() {
      _controller = controller;
    });
  },
)
```

### Entering Annotation Creation Mode

```dart
// Enter annotation creation mode with a specific tool
await controller.enterAnnotationCreationMode(AnnotationTool.inkPen);

// Enter annotation creation mode with default tool 
await controller.enterAnnotationCreationMode();
```

### Exiting Annotation Creation Mode

```dart
// Exit the current annotation creation mode
await controller.exitAnnotationCreationMode();
```

## Available Annotation Tools

The SDK provides annotation tools through the `AnnotationTool` enum. See the [AnnotationTool API documentation](https://pub.dev/documentation/nutrient_flutter/latest/nutrient_flutter/AnnotationTool.html) for the complete list of available tools including drawing, text markup, shapes, measurements, and more.

## Platform Compatibility

### iOS

- **Full support** for all annotation tools
- Special UI dialogs for signature, stamp, and image tools

### Android  

- **Most tools supported** except: `caret`, `richMedia`, `screen`, `file`, `widget`, `link`
- These unsupported tools will return an error when used

### Web

- **All tools have mappings** but some with limitations
- Some tools fall back to similar functionality (e.g., `inkMagic` → regular ink)
- Advanced tools like `richMedia`, `screen` may have limited functionality

## Complete Example

Here's a complete example showing how to implement an annotation toolbar:

```dart
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

class AnnotationToolbarExample extends StatefulWidget {
  final String documentPath;

  const AnnotationToolbarExample({Key? key, required this.documentPath})
      : super(key: key);

  @override
  State<AnnotationToolbarExample> createState() => _AnnotationToolbarExampleState();
}

class _AnnotationToolbarExampleState extends State<AnnotationToolbarExample> {
  NutrientViewController? _controller;
  AnnotationTool? _currentTool;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Annotation'),
        actions: [
          if (_currentTool != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _exitAnnotationMode,
              tooltip: 'Exit annotation mode',
            ),
        ],
      ),
      body: NutrientView(
        documentPath: widget.documentPath,
        configuration: PdfConfiguration(
          enableAnnotationEditing: true,
        ),
        onViewCreated: (controller) {
          setState(() {
            _controller = controller;
          });
        },
      ),
      bottomNavigationBar: _buildAnnotationToolbar(),
    );
  }

  Widget _buildAnnotationToolbar() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildToolButton(AnnotationTool.inkPen, 'Pen', Icons.brush),
            _buildToolButton(AnnotationTool.highlight, 'Highlight', Icons.format_color_fill),
            _buildToolButton(AnnotationTool.freeText, 'Text', Icons.text_fields),
            _buildToolButton(AnnotationTool.square, 'Square', Icons.crop_square),
            _buildToolButton(AnnotationTool.arrow, 'Arrow', Icons.arrow_forward),
            _buildToolButton(AnnotationTool.signature, 'Sign', Icons.draw),
            _buildToolButton(AnnotationTool.eraser, 'Erase', Icons.clear),
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
            onPressed: () => _enterAnnotationMode(tool),
            icon: Icon(icon),
            color: isSelected ? Colors.blue : Colors.black87,
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

  Future<void> _enterAnnotationMode(AnnotationTool tool) async {
    try {
      final success = await _controller.enterAnnotationCreationMode(tool);
      if (success == true) {
        setState(() {
          _currentTool = tool;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _exitAnnotationMode() async {
    try {
      await _controller.exitAnnotationCreationMode();
      setState(() {
        _currentTool = null;
      });
    } catch (e) {
      // Handle error
    }
  }
}
```

## Summary

The annotation creation mode API provides a simple way to programmatically activate annotation tools for PDF editing. With support for 35+ annotation types across iOS, Android, and Web platforms, developers can easily add drawing, text markup, shapes, and other annotation capabilities to their Flutter apps. For a complete working example, see `example/lib/nutrient_annotation_creation_mode_example.dart`.
