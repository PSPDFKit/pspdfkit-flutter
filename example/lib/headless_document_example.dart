///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Example demonstrating the Headless Document API.
///
/// This example shows how to:
/// 1. Open a document without displaying a viewer
/// 2. Read document properties (page count, annotations, etc.)
/// 3. Preview the document when needed
///
/// For annotation copying examples, see [copy_annotations_example.dart].
class HeadlessDocumentExample extends StatefulWidget {
  final String documentPath;

  const HeadlessDocumentExample({
    super.key,
    required this.documentPath,
  });

  @override
  State<HeadlessDocumentExample> createState() =>
      _HeadlessDocumentExampleState();
}

class _HeadlessDocumentExampleState extends State<HeadlessDocumentExample> {
  String _status = 'Ready';
  bool _isProcessing = false;
  int? _pageCount;
  int? _annotationCount;
  Map<String, int>? _annotationsByType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Headless Document API'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing ? null : _getDocumentProperties,
              child: const Text('Get Document Properties'),
            ),
            const SizedBox(height: 20),
            if (_pageCount != null || _annotationCount != null)
              _buildPropertiesCard(),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _previewDocument,
              icon: const Icon(Icons.visibility),
              label: const Text('Preview Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Document Properties',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (_pageCount != null) Text('Pages: $_pageCount'),
          if (_annotationCount != null)
            Text('Total Annotations: $_annotationCount'),
          if (_annotationsByType != null && _annotationsByType!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('By Type:'),
            ..._annotationsByType!.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text('• ${e.key}: ${e.value}'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get document properties without opening a viewer.
  Future<void> _getDocumentProperties() async {
    setState(() {
      _isProcessing = true;
      _status = 'Opening document...';
    });

    PdfDocument? document;

    try {
      document = await Nutrient.openDocument(widget.documentPath);

      setState(() => _status = 'Reading properties...');

      final pageCount = await document.getPageCount();
      int totalAnnotations = 0;
      final annotationsByType = <String, int>{};

      for (int i = 0; i < pageCount; i++) {
        final annotations =
            await document.getAnnotations(i, AnnotationType.all);
        totalAnnotations += annotations.length;

        for (final annotation in annotations) {
          final type = annotation.type.toString();
          annotationsByType[type] = (annotationsByType[type] ?? 0) + 1;
        }
      }

      setState(() {
        _pageCount = pageCount;
        _annotationCount = totalAnnotations;
        _annotationsByType = annotationsByType;
        _status = 'Done';
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      await document?.close();
      setState(() => _isProcessing = false);
    }
  }

  /// Preview the document using the standard viewer.
  Future<void> _previewDocument() async {
    try {
      await Nutrient.present(widget.documentPath);
    } catch (e) {
      setState(() => _status = 'Error opening document: $e');
    }
  }
}
