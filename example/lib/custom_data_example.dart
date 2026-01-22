///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Example demonstrating custom data operations on annotations.
///
/// This example shows how to:
/// - Get annotation properties including custom data
/// - Add nested custom data to annotations
/// - Save annotations with custom data without type casting errors
///
/// This tests the fix for the inkLines type casting issue that was causing
/// errors when saving custom data.
class CustomDataExample extends StatefulWidget {
  final String documentPath;

  const CustomDataExample({
    Key? key,
    required this.documentPath,
  }) : super(key: key);

  @override
  State<CustomDataExample> createState() => _CustomDataExampleState();
}

class _CustomDataExampleState extends State<CustomDataExample> {
  PdfDocument? _document;
  NutrientViewController? _controller;
  String _statusMessage = 'Tap an annotation to test custom data';
  bool _isLoading = false;
  Map<String, Object?>? _lastCustomData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Data Example'),
      ),
      body: Column(
        children: [
          Expanded(
            child: NutrientView(
              documentPath: widget.documentPath,
              onViewCreated: _onViewCreated,
              onDocumentLoaded: _onDocumentLoaded,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('Error')
                        ? Colors.red
                        : _statusMessage.contains('Success')
                            ? Colors.green
                            : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_lastCustomData != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton.extended(
                heroTag: 'view',
                onPressed: _showCustomDataPreview,
                label: const Text('View Data'),
                icon: const Icon(Icons.visibility),
                backgroundColor: Colors.blue,
              ),
            ),
          FloatingActionButton.extended(
            heroTag: 'test',
            onPressed: _testCustomDataOnFirstAnnotation,
            label: const Text('Test Custom Data'),
            icon: const Icon(Icons.science),
          ),
        ],
      ),
    );
  }

  void _onViewCreated(NutrientViewController controller) {
    _controller = controller;

    // Listen for annotation selection
    _controller?.addEventListener(NutrientEvent.annotationsSelected,
        (event) async {
      final annotations = event?['annotations'] as List?;
      if (annotations != null && annotations.isNotEmpty) {
        final annotation = annotations.first;
        if (annotation is Annotation) {
          await _testCustomData(annotation.pageIndex, annotation.name ?? '');
        }
      }
    });
  }

  void _onDocumentLoaded(PdfDocument document) {
    setState(() {
      _document = document;
      _statusMessage =
          'Document loaded. Tap an annotation or press the button.';
    });
  }

  /// Test custom data on the first annotation found in the document
  Future<void> _testCustomDataOnFirstAnnotation() async {
    final document = _document;
    if (document == null) {
      setState(() => _statusMessage = 'Error: Document not loaded');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Finding annotations...';
    });

    try {
      // Find the first annotation in the document
      final pageCount = await document.getPageCount();

      for (int page = 0; page < pageCount; page++) {
        final annotations =
            await document.getAnnotations(page, AnnotationType.all);

        if (annotations.isNotEmpty) {
          final annotation = annotations.first;
          final annotationId = annotation.name ?? annotation.id ?? '';

          if (annotationId.isNotEmpty) {
            await _testCustomData(page, annotationId);
            return;
          }
        }
      }

      setState(() {
        _isLoading = false;
        _statusMessage = 'No annotations found. Add an annotation first.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  /// Test custom data operations on a specific annotation
  /// This reproduces the exact user scenario that was causing the exception:
  /// ```dart
  /// final properties = await currentDocument
  ///     .getAnnotationProperties(annotation.pageIndex, annotation.name);
  /// final updatedCustomData = properties?.withCustomData(annotCustomData);
  /// ```
  Future<void> _testCustomData(int pageIndex, String annotationId) async {
    final document = _document;
    if (document == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Getting annotation properties...';
    });

    try {
      // Step 1: Get annotation properties (exactly as user reported)
      // This returns properties with inkLines as a CastList from Pigeon
      final properties = await document.getAnnotationProperties(
        pageIndex,
        annotationId,
      );

      if (properties == null) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Error: Could not get annotation properties';
        });
        return;
      }

      setState(() => _statusMessage = 'Adding custom data...');

      // Step 2: Create nested custom data - this is the exact format
      // that was causing the type casting error with inkLines
      //
      // User's original data that triggered the bug:
      // {
      //   "additionalData": {
      //     "type": 3,
      //     "id": "12123"
      //   },
      //   "id": "r34newnke"
      // }
      final annotCustomData = <String, Object?>{
        'additionalData': {
          'type': 3,
          'id': '12123',
        },
        'id': 'r34newnke',
        // Additional nested data for thorough testing
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': {
          'source': 'flutter_sdk',
          'version': '5.3.0',
          'nested': {
            'level1': {
              'level2': {
                'level3': 'deep_value',
                'array': [1, 2, 3, 'mixed', true],
              },
            },
          },
        },
        'tags': ['important', 'reviewed', 'approved'],
        'count': 42,
        'enabled': true,
        'nullValue': null,
      };

      // Step 3: This is the exact call that was throwing the exception:
      // "type 'List<Object?>' is not a subtype of type 'List<List<double>>' in type cast"
      // The fix ensures inkLines (CastList) is passed through without triggering cast errors
      final updatedProperties = properties.withCustomData(annotCustomData);

      setState(() => _statusMessage = 'Saving annotation properties...');

      // Step 4: Save the updated properties back to the document
      final success =
          await document.saveAnnotationProperties(updatedProperties);

      if (success) {
        // Step 5: Verify by reading back the saved properties
        final verifyProperties = await document.getAnnotationProperties(
          pageIndex,
          annotationId,
        );

        if (verifyProperties?.customData != null) {
          setState(() {
            _isLoading = false;
            _lastCustomData = verifyProperties!.customData;
            _statusMessage =
                'Success! Custom data saved and verified.\nTap "View Data" to see formatted JSON.';
          });
        } else {
          setState(() {
            _isLoading = false;
            _lastCustomData = annotCustomData;
            _statusMessage =
                'Success! Custom data saved.\nTap "View Data" to see formatted JSON.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Error: Failed to save annotation properties';
        });
      }
    } catch (e, stackTrace) {
      // Log the error for debugging
      debugPrint('Error while setting custom data: $e');
      debugPrint('Stack trace:\n$stackTrace');

      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: $e\n\nStack trace:\n$stackTrace';
      });
    }
  }

  /// Shows a dialog with the custom data in a formatted JSON view
  void _showCustomDataPreview() {
    final customData = _lastCustomData;
    if (customData == null || customData.isEmpty) {
      setState(() => _statusMessage = 'No custom data to display');
      return;
    }

    // Format the JSON with indentation for readability
    const encoder = JsonEncoder.withIndent('  ');
    final formattedJson = encoder.convert(customData);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.data_object, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Text('Custom Data'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SelectableText(
                    formattedJson,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${customData.length} top-level entries',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
