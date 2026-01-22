///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Example demonstrating copying annotations between documents.
///
/// This example shows how to:
/// 1. Add annotations to the source document
/// 2. Preview documents before and after copying
/// 3. Copy annotations using getAnnotations() + addAnnotations()
/// 4. Save and view the result
class CopyAnnotationsExample extends StatefulWidget {
  final String sourceDocumentPath;
  final String targetDocumentPath;

  const CopyAnnotationsExample({
    super.key,
    required this.sourceDocumentPath,
    required this.targetDocumentPath,
  });

  @override
  State<CopyAnnotationsExample> createState() => _CopyAnnotationsExampleState();
}

class _CopyAnnotationsExampleState extends State<CopyAnnotationsExample> {
  String _status = 'Ready - Add annotations to source, then copy to target';
  bool _isProcessing = false;
  String? _outputPath;
  int _annotationsAdded = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Copy Annotations Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _status,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),

            // Add Annotations button
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _addMultipleAnnotations,
              icon: const Icon(Icons.add_circle),
              label: const Text('Add Annotations'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),

            // Copy Annotations button
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _copyAnnotations,
              icon: const Icon(Icons.copy),
              label: const Text('Copy Annotations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),

            // Preview Source button
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _previewSource,
              icon: const Icon(Icons.visibility),
              label: const Text('Preview Source'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),

            // Preview Target button
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _previewTarget,
              icon: const Icon(Icons.article),
              label: const Text('Preview Target'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Add multiple annotations at once (ink, shape, and image).
  Future<void> _addMultipleAnnotations() async {
    setState(() {
      _isProcessing = true;
      _status = 'Adding annotations to source...';
    });

    PdfDocument? document;

    try {
      document = await Nutrient.openDocument(widget.sourceDocumentPath);

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 1. Ink annotation (red drawing)
      final inkAnnotation = InkAnnotation(
        id: 'ink-annotation-$timestamp',
        bbox: [50.0, 50.0, 250.0, 150.0],
        createdAt: DateTime.now().toIso8601String(),
        pageIndex: 0,
        creatorName: 'Copy Annotations Example',
        lines: InkLines(
          points: [
            [
              [50.0, 100.0],
              [100.0, 70.0],
              [150.0, 130.0],
              [200.0, 80.0],
              [250.0, 110.0],
            ],
          ],
          intensities: [
            [1.0, 1.0, 1.0, 1.0, 1.0],
          ],
        ),
        lineWidth: 3,
        strokeColor: const Color(0xFFFF0000),
      );

      // 2. Square annotation (blue border, yellow fill)
      final squareAnnotation = SquareAnnotation(
        id: 'square-annotation-$timestamp',
        bbox: [50.0, 200.0, 200.0, 300.0],
        pageIndex: 0,
        creatorName: 'Copy Annotations Example',
        strokeColor: const Color(0xFF0000FF),
        fillColor: const Color(0x33FFFF00),
        strokeWidth: 2,
      );

      // 3. Circle annotation (green)
      final circleAnnotation = CircleAnnotation(
        id: 'circle-annotation-$timestamp',
        bbox: [250.0, 200.0, 400.0, 300.0],
        createdAt: DateTime.now().toIso8601String(),
        pageIndex: 0,
        creatorName: 'Copy Annotations Example',
        strokeColor: const Color(0xFF00FF00),
        strokeWidth: 3,
      );

      // 4. Image annotation - use a minimal 1x1 red PNG as base64
      const imageBase64 =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==';
      final attachmentId = 'attachment-$timestamp';
      final imageAnnotation = ImageAnnotation(
        id: 'image-annotation-$timestamp',
        bbox: [300.0, 50.0, 450.0, 150.0],
        createdAt: DateTime.now().toIso8601String(),
        pageIndex: 0,
        creatorName: 'Copy Annotations Example',
        contentType: 'image/png',
        imageAttachmentId: attachmentId,
        attachment: AnnotationAttachment(
          id: attachmentId,
          binary: imageBase64,
          contentType: 'image/png',
        ),
      );

      // Add all annotations
      await document.addAnnotation(inkAnnotation);
      await document.addAnnotation(squareAnnotation);
      await document.addAnnotation(circleAnnotation);
      await document.addAnnotation(imageAnnotation);
      await document.save();

      setState(() {
        _annotationsAdded += 4;
        _status =
            'Added 4 annotations (ink, square, circle, image) to source!\n'
            'Total annotations added: $_annotationsAdded';
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      await document?.close();
      setState(() => _isProcessing = false);
    }
  }

  /// Preview the source document.
  Future<void> _previewSource() async {
    try {
      await Nutrient.present(widget.sourceDocumentPath);
    } catch (e) {
      setState(() => _status = 'Error opening source: $e');
    }
  }

  /// Preview the target document (shows result after copy if available, otherwise original).
  Future<void> _previewTarget() async {
    try {
      // Show the result if annotations have been copied, otherwise show original target
      final pathToShow = _outputPath ?? widget.targetDocumentPath;
      await Nutrient.present(pathToShow);
    } catch (e) {
      setState(() => _status = 'Error opening target: $e');
    }
  }

  /// Copy annotations from page 1 of source to target using getAnnotations() + addAnnotations().
  Future<void> _copyAnnotations() async {
    setState(() {
      _isProcessing = true;
      _status = 'Opening documents...';
    });

    PdfDocument? sourceDoc;
    PdfDocument? targetDoc;

    try {
      sourceDoc = await Nutrient.openDocument(widget.sourceDocumentPath);
      targetDoc = await Nutrient.openDocument(widget.targetDocumentPath);

      setState(() => _status = 'Collecting annotations from page 1...');

      // Collect all annotations from page 1
      // getAnnotations() includes attachment binary data for image/stamp/file annotations
      final annotations = await sourceDoc.getAnnotations(0, AnnotationType.all);

      if (annotations.isEmpty) {
        setState(() => _status = 'No annotations found on page 1.');
        return;
      }

      setState(() => _status =
          'Found ${annotations.length} annotations. Adding to target...');

      // Bulk add all annotations to the target document
      // Annotations with attachments (image, stamp, file) now include their binary data
      await targetDoc.addAnnotations(annotations);

      // Save to new file
      final tempDir = await Nutrient.getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/target_with_annotations_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await targetDoc.save(outputPath: outputPath);

      setState(() {
        _outputPath = outputPath;
        _status =
            'Success! Copied ${annotations.length} annotations to target.\n'
            'Use "Preview Target" to see the result.';
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      await sourceDoc?.close();
      await targetDoc?.close();
      setState(() => _isProcessing = false);
    }
  }
}
