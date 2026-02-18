///  Copyright © 2025-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'widgets/annotation_property_editor.dart';

/// Example demonstrating the Annotation Properties API.
///
/// This example shows how to:
/// - Get annotation properties without losing attachment data
/// - Update properties safely using the new API
/// - Use annotation selection events
/// - Handle custom data and flags
///
/// The key improvement over the deprecated updateAnnotation method is that
/// this API preserves attachment data for FileAnnotation and ImageAnnotation.
class NutrientAnnotationPropertiesExample extends StatefulWidget {
  final String documentPath;

  const NutrientAnnotationPropertiesExample({
    Key? key,
    required this.documentPath,
  }) : super(key: key);

  @override
  State<NutrientAnnotationPropertiesExample> createState() =>
      _NutrientAnnotationPropertiesExampleState();
}

class _NutrientAnnotationPropertiesExampleState
    extends State<NutrientAnnotationPropertiesExample> {
  PdfDocument? _document;
  NutrientViewController? _controller;
  Annotation? _selectedAnnotation;
  AnnotationProperties? _selectedProperties;
  bool _isPropertyEditorVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // PDF Viewer - Expands to fill available space
              Expanded(
                child: NutrientView(
                  documentPath: widget.documentPath,
                  onViewCreated: _onNutrientViewCreated,
                  onDocumentLoaded: _onDocumentLoaded,
                  configuration: PdfConfiguration(
                    startPage: 18, // Start on page with annotations
                  ),
                ),
              ),
              // Property Editor Panel - Shows at bottom when annotation is selected
              if (_isPropertyEditorVisible &&
                  _selectedAnnotation != null &&
                  _selectedProperties != null)
                _buildPropertyEditorPanel(),
            ],
          ),
          // Instructional message when no annotation is selected
          if (_selectedAnnotation == null && _document != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap any annotation to customize its properties',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton:
          _selectedAnnotation != null && !_isPropertyEditorVisible
              ? FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      _isPropertyEditorVisible = true;
                    });
                  },
                  label: const Text('Edit Properties'),
                  icon: const Icon(Icons.edit),
                )
              : null,
    );
  }

  Widget _buildPropertyEditorPanel() {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = screenHeight * 0.5; // 50% of screen height

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: panelHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar and header
          GestureDetector(
            onVerticalDragEnd: (details) {
              // Allow swipe down to close
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 100) {
                setState(() {
                  _isPropertyEditorVisible = false;
                });
              }
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Annotation Properties',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _isPropertyEditorVisible = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: AnnotationPropertyEditor(
                annotation: _selectedAnnotation!,
                properties: _selectedProperties!,
                onColorChanged: (color) async {
                  await _updateColor(color);
                  if (mounted) {
                    setState(() {});
                  }
                },
                onOpacityChanged: (opacity) async {
                  await _updateOpacity(opacity);
                  if (mounted) {
                    setState(() {});
                  }
                },
                onLineWidthChanged: (lineWidth) async {
                  await _updateLineWidth(lineWidth);
                  if (mounted) {
                    setState(() {});
                  }
                },
                onFlagToggled: (flag) async {
                  await _toggleFlag(flag);
                  if (mounted) {
                    setState(() {});
                  }
                },
                onAddCustomData: () {
                  setState(() {
                    _isPropertyEditorVisible = false;
                  });
                  _addCustomData();
                },
                onViewCustomData: _showCustomDataPreview,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================
  // ANNOTATION EVENT HANDLERS
  // ===========================

  // ===========================
  // API DEMONSTRATION METHODS
  // ===========================

  /// Demonstrates updating annotation color
  Future<void> _updateColor(Color color) async {
    final properties = _selectedProperties;
    if (properties == null) return;

    try {
      // API: Update color while preserving attachments
      final updated = properties.withColor(color);
      final success =
          await _document?.saveAnnotationProperties(updated) ?? false;

      if (success) {
        setState(() {
          _selectedProperties = updated;
        });
        _showMessage('Color updated');
      }
    } catch (e) {
      _showError('Failed to update color: $e');
    }
  }

  /// Demonstrates updating annotation opacity
  Future<void> _updateOpacity(double opacity) async {
    final properties = _selectedProperties;
    if (properties == null) return;

    try {
      // API: Update opacity while preserving attachments
      final updated = properties.withOpacity(opacity);
      final success =
          await _document?.saveAnnotationProperties(updated) ?? false;

      if (success) {
        setState(() {
          _selectedProperties = updated;
        });
      }
    } catch (e) {
      _showError('Failed to update opacity: $e');
    }
  }

  /// Demonstrates updating line width
  Future<void> _updateLineWidth(double lineWidth) async {
    final properties = _selectedProperties;
    if (properties == null) return;

    try {
      // API: Update line width for applicable annotations
      final updated = properties.withLineWidth(lineWidth);
      final success =
          await _document?.saveAnnotationProperties(updated) ?? false;

      if (success) {
        setState(() {
          _selectedProperties = updated;
        });
      }
    } catch (e) {
      _showError('Failed to update line width: $e');
    }
  }

  /// Demonstrates toggling annotation flags
  Future<void> _toggleFlag(AnnotationFlag flag) async {
    final properties = _selectedProperties;
    if (properties == null) return;

    try {
      final currentFlags = properties.flagsSet ?? {};
      final newFlags = Set<AnnotationFlag>.from(currentFlags);

      if (newFlags.contains(flag)) {
        newFlags.remove(flag);
      } else {
        newFlags.add(flag);
      }

      // API: Update flags while preserving attachments
      final updated = properties.withFlags(newFlags);
      final success =
          await _document?.saveAnnotationProperties(updated) ?? false;

      if (success) {
        setState(() {
          _selectedProperties = updated;
        });
        _showMessage('Flags updated');
      }
    } catch (e) {
      _showError('Failed to update flags: $e');
    }
  }

  /// Demonstrates adding custom data to annotations
  Future<void> _addCustomData() async {
    final properties = _selectedProperties;
    if (properties == null) return;

    final result = await _showCustomDataDialog();
    if (result == null) return;

    try {
      // Merge with existing custom data
      final existingData = properties.customData ?? {};
      final updatedData = {
        ...existingData,
        ...result,
        'lastModified': DateTime.now().toIso8601String(),
      };

      // API: Update custom data while preserving attachments
      final updated = properties.withCustomData(updatedData);
      final success =
          await _document?.saveAnnotationProperties(updated) ?? false;

      if (success) {
        setState(() {
          _selectedProperties = updated;
        });
        _showMessage('Custom data added');
      }
    } catch (e) {
      _showError('Failed to add custom data: $e');
    }
  }

  // ===========================
  // UI HELPER METHODS
  // ===========================

  /// Handles annotation selection from events
  Future<void> _handleAnnotationSelection(dynamic annotationData) async {
    final document = _document;
    if (document == null) {
      debugPrint(
          '[AnnotationPropertiesExample] _handleAnnotationSelection: document is null');
      return;
    }

    debugPrint(
        '[AnnotationPropertiesExample] _handleAnnotationSelection called');
    debugPrint(
        '[AnnotationPropertiesExample] annotationData type: ${annotationData.runtimeType}');

    try {
      // If annotationData is already an Annotation object, use it directly
      if (annotationData is Annotation) {
        debugPrint(
            '[AnnotationPropertiesExample] annotationData is Annotation');
        final annotationId = annotationData.id ?? annotationData.name ?? '';
        debugPrint(
            '[AnnotationPropertiesExample] annotationId: $annotationId, pageIndex: ${annotationData.pageIndex}');

        if (annotationId.isNotEmpty) {
          debugPrint(
              '[AnnotationPropertiesExample] Calling getAnnotationProperties...');
          final properties = await document.getAnnotationProperties(
            annotationData.pageIndex,
            annotationId,
          );
          debugPrint(
              '[AnnotationPropertiesExample] getAnnotationProperties returned: ${properties != null ? "non-null" : "null"}');

          if (properties != null) {
            debugPrint(
                '[AnnotationPropertiesExample] Properties: strokeColor=${properties.strokeColor}, opacity=${properties.opacity}, lineWidth=${properties.lineWidth}');
            setState(() {
              _selectedAnnotation = annotationData;
              _selectedProperties = properties;
              _isPropertyEditorVisible = true;
            });
          }
        }
        return;
      }

      // If it's a Map, extract page index and ID, then fetch full annotation
      final Map<String, dynamic> annotationMap;
      if (annotationData is Map) {
        debugPrint('[AnnotationPropertiesExample] annotationData is Map');
        annotationMap = Map<String, dynamic>.from(annotationData);
        debugPrint(
            '[AnnotationPropertiesExample] annotationMap keys: ${annotationMap.keys.toList()}');
      } else {
        debugPrint(
            '[AnnotationPropertiesExample] annotationData is unknown type: ${annotationData.runtimeType}, trying Annotation.fromJson');
        // Try to parse as Annotation
        final annotation = Annotation.fromJson(annotationData);
        final annotationId = annotation.id ?? annotation.name ?? '';

        if (annotationId.isNotEmpty) {
          final properties = await document.getAnnotationProperties(
            annotation.pageIndex,
            annotationId,
          );

          if (properties != null) {
            setState(() {
              _selectedAnnotation = annotation;
              _selectedProperties = properties;
              _isPropertyEditorVisible = true;
            });
          }
        }
        return;
      }

      // Extract page index and ID from the map
      final int? pageIndex = annotationMap['pageIndex'] as int?;
      final String? annotationId =
          (annotationMap['id'] ?? annotationMap['name']) as String?;
      debugPrint(
          '[AnnotationPropertiesExample] From map: pageIndex=$pageIndex, annotationId=$annotationId');

      if (pageIndex != null && annotationId != null) {
        // Get all annotations on the page to find the selected one
        debugPrint(
            '[AnnotationPropertiesExample] Fetching annotations for page $pageIndex...');
        final annotations =
            await document.getAnnotations(pageIndex, AnnotationType.all);
        debugPrint(
            '[AnnotationPropertiesExample] Got ${annotations.length} annotations');

        // Find the annotation with matching ID
        Annotation? matchingAnnotation;
        for (final annotation in annotations) {
          if (annotation.id == annotationId ||
              annotation.name == annotationId) {
            matchingAnnotation = annotation;
            break;
          }
        }

        debugPrint(
            '[AnnotationPropertiesExample] matchingAnnotation: ${matchingAnnotation != null ? "found" : "not found"}');

        if (matchingAnnotation != null) {
          // Get properties
          debugPrint(
              '[AnnotationPropertiesExample] Calling getAnnotationProperties...');
          final properties = await document.getAnnotationProperties(
            pageIndex,
            annotationId,
          );
          debugPrint(
              '[AnnotationPropertiesExample] getAnnotationProperties returned: ${properties != null ? "non-null" : "null"}');

          if (properties != null) {
            debugPrint(
                '[AnnotationPropertiesExample] Properties: strokeColor=${properties.strokeColor}, opacity=${properties.opacity}, lineWidth=${properties.lineWidth}');
            setState(() {
              _selectedAnnotation = matchingAnnotation;
              _selectedProperties = properties;
              _isPropertyEditorVisible = true;
            });
          }
        }
      }
    } catch (e, st) {
      debugPrint(
          '[AnnotationPropertiesExample] _handleAnnotationSelection error: $e');
      debugPrint('[AnnotationPropertiesExample] Stack trace: $st');
      _showError('Failed to select annotation: $e');
    }
  }

  void _onNutrientViewCreated(NutrientViewController controller) {
    setState(() {
      _controller = controller;
    });

    // Listen for annotation selection events
    _controller?.addEventListener(NutrientEvent.annotationsSelected,
        (event) async {
      try {
        debugPrint(
            '[AnnotationPropertiesExample] annotationsSelected event received');
        debugPrint(
            '[AnnotationPropertiesExample] event type: ${event.runtimeType}');
        debugPrint('[AnnotationPropertiesExample] event: $event');

        // Get the selected annotation from the event
        // The event contains an 'annotation' field with the annotation object
        final dynamic annotationData = event?['annotation'];
        debugPrint(
            '[AnnotationPropertiesExample] annotationData type: ${annotationData.runtimeType}');
        debugPrint(
            '[AnnotationPropertiesExample] annotationData: $annotationData');

        if (annotationData == null) {
          debugPrint(
              '[AnnotationPropertiesExample] annotationData is null, checking annotations (plural)');
          // Sometimes the event might have 'annotations' (plural) instead
          final annotations = event?['annotations'] as List?;
          debugPrint('[AnnotationPropertiesExample] annotations: $annotations');
          if (annotations != null && annotations.isNotEmpty) {
            await _handleAnnotationSelection(annotations.first);
          }
          return;
        }

        await _handleAnnotationSelection(annotationData);
      } catch (e, st) {
        debugPrint(
            '[AnnotationPropertiesExample] Error in annotationsSelected: $e');
        debugPrint('[AnnotationPropertiesExample] Stack trace: $st');
        _showError('Failed to handle annotation selection: $e');
      }
    });

    // Listen for annotation deselection events
    _controller?.addEventListener(NutrientEvent.annotationsDeselected, (event) {
      setState(() {
        _selectedAnnotation = null;
        _selectedProperties = null;
      });
    });
  }

  Future<void> _onDocumentLoaded(PdfDocument document) async {
    setState(() {
      _document = document;
    });

    _showMessage('Tap any annotation to edit its properties');
  }

  /// Shows a dialog with the full custom data in a formatted JSON view
  void _showCustomDataPreview() {
    final customData = _selectedProperties?.customData;
    if (customData == null || customData.isEmpty) {
      _showMessage('No custom data to display');
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

  Future<Map<String, String>?> _showCustomDataDialog() async {
    final keyController = TextEditingController();
    final valueController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Key',
                hintText: 'e.g., department',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value',
                hintText: 'e.g., engineering',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (keyController.text.isNotEmpty &&
                  valueController.text.isNotEmpty) {
                Navigator.of(context).pop({
                  keyController.text: valueController.text,
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
