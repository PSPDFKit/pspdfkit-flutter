///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

import 'utils/platform_utils.dart';

/// Example demonstrating the document dirty state tracking APIs.
///
/// This example shows how to:
/// - Use the cross-platform `hasUnsavedChanges()` API
/// - Use platform-specific dirty state APIs
/// - Prompt the user before closing with unsaved changes
class DirtyStateExample extends StatefulWidget {
  final String documentPath;

  const DirtyStateExample({Key? key, required this.documentPath})
      : super(key: key);

  @override
  State<DirtyStateExample> createState() => _DirtyStateExampleState();
}

class _DirtyStateExampleState extends State<DirtyStateExample> {
  PdfDocument? _document;
  bool _hasUnsavedChanges = false;
  String _statusMessage = 'Make changes to the document to see dirty state';
  final List<String> _logMessages = [];

  @override
  Widget build(BuildContext context) {
    if (!PlatformUtils.isCurrentPlatformSupported()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dirty State Example')),
        body: Center(
          child: Text(
              '$defaultTargetPlatform is not yet supported by Nutrient Flutter.'),
        ),
      );
    }

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldDiscard = await _showDiscardDialog();
        if (shouldDiscard && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dirty State Example'),
          actions: [
            IconButton(
              icon: Icon(_hasUnsavedChanges ? Icons.save : Icons.save_outlined),
              onPressed: _hasUnsavedChanges ? _saveDocument : null,
              tooltip: 'Save Document',
            ),
          ],
        ),
        body: Column(
          children: [
            // Status bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color:
                  _hasUnsavedChanges ? Colors.orange[100] : Colors.green[100],
              child: Row(
                children: [
                  Icon(
                    _hasUnsavedChanges
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    color: _hasUnsavedChanges ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _hasUnsavedChanges
                            ? Colors.orange[900]
                            : Colors.green[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // PDF Viewer
            Expanded(
              flex: 3,
              child: NutrientView(
                documentPath: widget.documentPath,
                configuration: PdfConfiguration(disableAutosave: true),
                onDocumentLoaded: _onDocumentLoaded,
              ),
            ),
            // Control panel
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                children: [
                  // Buttons row
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _checkDirtyState,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Check State'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showPlatformDetails,
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Platform Details'),
                        ),
                        if (!kIsWeb && Platform.isIOS)
                          ElevatedButton.icon(
                            onPressed: _checkAnnotationsDirtyState,
                            icon: const Icon(Icons.edit_note),
                            label: const Text('Check Annotations'),
                          ),
                        if (!kIsWeb)
                          ElevatedButton.icon(
                            onPressed: _clearDirtyState,
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear State'),
                          ),
                      ],
                    ),
                  ),
                  // Log messages
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: _logMessages.length,
                        itemBuilder: (context, index) {
                          final reversedIndex = _logMessages.length - 1 - index;
                          return Text(
                            _logMessages[reversedIndex],
                            style: const TextStyle(
                                fontSize: 12, fontFamily: 'monospace'),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDocumentLoaded(PdfDocument document) {
    _document = document;
    _log('Document loaded');
    _checkDirtyState();
  }

  void _log(String message) {
    setState(() {
      _logMessages
          .add('[${DateTime.now().toString().substring(11, 19)}] $message');
    });
  }

  Future<void> _checkDirtyState() async {
    final document = _document;
    if (document == null) {
      _log('No document loaded');
      return;
    }

    try {
      // Use the cross-platform API
      final hasChanges = await document.hasUnsavedChanges();
      setState(() {
        _hasUnsavedChanges = hasChanges;
        _statusMessage =
            hasChanges ? 'Document has unsaved changes' : 'No unsaved changes';
      });
      _log('hasUnsavedChanges: $hasChanges');
    } catch (e) {
      _log('Error checking dirty state: $e');
    }
  }

  Future<void> _checkAnnotationsDirtyState() async {
    final document = _document;
    if (document == null) {
      _log('No document loaded');
      return;
    }

    if (!Platform.isIOS) {
      _log('Annotation dirty state is only available on iOS');
      return;
    }

    _log('--- Checking Annotation Dirty States ---');

    try {
      // Get page count
      final pageCount = await document.getPageCount();
      _log('Document has $pageCount pages');

      // Check annotations on first page (page 0)
      final annotations = await document.getAnnotations(0, AnnotationType.all);
      _log('Page 0 has ${annotations.length} annotations');

      for (final annotation in annotations) {
        final annotationId = annotation.name ?? annotation.id ?? 'unknown';
        try {
          final isDirty =
              await document.iOSGetAnnotationIsDirty(0, annotationId);
          _log('  ${annotation.type.name} ($annotationId): isDirty=$isDirty');
        } catch (e) {
          _log('  ${annotation.type.name}: Error checking dirty state');
        }
      }

      // If there are annotations, demonstrate toggling dirty state
      if (annotations.isNotEmpty) {
        final firstAnnotation = annotations.first;
        final annotationId =
            firstAnnotation.name ?? firstAnnotation.id ?? 'unknown';
        _log('--- Toggle first annotation dirty state ---');

        final currentState =
            await document.iOSGetAnnotationIsDirty(0, annotationId);
        _log('Current state: $currentState');

        await document.iOSSetAnnotationIsDirty(0, annotationId, !currentState);
        _log('Set to: ${!currentState}');

        final newState =
            await document.iOSGetAnnotationIsDirty(0, annotationId);
        _log('Verified new state: $newState');
      }
    } catch (e) {
      _log('Error checking annotation dirty states: $e');
    }

    await _checkDirtyState();
  }

  Future<void> _showPlatformDetails() async {
    final document = _document;
    if (document == null) {
      _log('No document loaded');
      return;
    }

    _log('--- Platform Details ---');

    try {
      if (!kIsWeb && Platform.isIOS) {
        // iOS-specific APIs
        final hasDirtyAnnotations = await document.iOSHasDirtyAnnotations();
        _log('iOS hasDirtyAnnotations: $hasDirtyAnnotations');
      } else if (!kIsWeb && Platform.isAndroid) {
        // Android-specific APIs
        final annotationChanges =
            await document.androidHasUnsavedAnnotationChanges();
        final formChanges = await document.androidHasUnsavedFormChanges();
        final bookmarkChanges =
            await document.androidHasUnsavedBookmarkChanges();

        _log('Android annotation changes: $annotationChanges');
        _log('Android form changes: $formChanges');
        _log('Android bookmark changes: $bookmarkChanges');
      } else if (kIsWeb) {
        // Web-specific API
        final hasChanges = await document.webHasUnsavedChanges();
        _log('Web hasUnsavedChanges: $hasChanges');
      }
    } catch (e) {
      _log('Error getting platform details: $e');
    }
  }

  Future<void> _clearDirtyState() async {
    final document = _document;
    if (document == null) {
      _log('No document loaded');
      return;
    }

    try {
      if (!kIsWeb && Platform.isIOS) {
        // iOS: Clear the needs-save flag
        await document.iOSClearNeedsSaveFlag();
        _log('iOS: Cleared needs-save flag');
      } else if (!kIsWeb && Platform.isAndroid) {
        // Android: Can only clear bookmark dirty state
        _log('Android: Cannot clear annotation/form dirty state');
        _log('Android: Only bookmark dirty state can be cleared');
      }
      await _checkDirtyState();
    } catch (e) {
      _log('Error clearing dirty state: $e');
    }
  }

  Future<void> _saveDocument() async {
    final document = _document;
    if (document == null) return;

    try {
      await document.save();
      _log('Document saved');
      await _checkDirtyState();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document saved successfully')),
        );
      }
    } catch (e) {
      _log('Error saving document: $e');
    }
  }

  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
                'You have unsaved changes. Do you want to discard them?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
