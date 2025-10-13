///
///  Copyright @ 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

import 'draggable_control_panel.dart';

/// A specialized control panel for managing annotation flags
class AnnotationFlagsPanel extends StatefulWidget {
  /// The current document being viewed
  final PdfDocument? document;

  /// Initial position for the panel
  final Offset initialPosition;

  /// Flag indicating if the panel should start expanded
  final bool initiallyExpanded;

  /// Callback when an annotation is added
  final Function(Annotation)? onAnnotationAdded;

  /// Callback when an annotation is updated
  final Function(Annotation)? onAnnotationUpdated;

  /// Currently selected annotation
  final Annotation? selectedAnnotation;

  /// Function to set the selected annotation
  final Function(Annotation?)? onAnnotationSelected;

  /// Currently selected flags
  final Set<AnnotationFlag>? selectedFlags;

  /// Function to notify when flags are changed
  final Function(Set<AnnotationFlag>)? onFlagsChanged;

  const AnnotationFlagsPanel({
    Key? key,
    required this.document,
    this.initialPosition = const Offset(20, 20),
    this.initiallyExpanded = false,
    this.onAnnotationAdded,
    this.onAnnotationUpdated,
    this.selectedAnnotation,
    this.onAnnotationSelected,
    this.selectedFlags,
    this.onFlagsChanged,
  }) : super(key: key);

  @override
  State<AnnotationFlagsPanel> createState() => _AnnotationFlagsPanelState();
}

class _AnnotationFlagsPanelState extends State<AnnotationFlagsPanel> {
  late Set<AnnotationFlag> _selectedFlags;

  // Flag descriptions for better UI presentation
  final Map<AnnotationFlag, String> flagDescriptions = {
    AnnotationFlag.invisible: 'Invisible',
    AnnotationFlag.hidden: 'Hidden',
    AnnotationFlag.print: 'Print',
    AnnotationFlag.noZoom: 'No Zoom',
    AnnotationFlag.noRotate: 'No Rotate',
    AnnotationFlag.noView: 'No View',
    AnnotationFlag.readOnly: 'Read Only',
    AnnotationFlag.locked: 'Locked',
    AnnotationFlag.toggleNoView: 'Toggle No View',
    AnnotationFlag.lockedContents: 'Locked Contents',
  };

  @override
  void initState() {
    super.initState();
    _selectedFlags = widget.selectedFlags ??
        Set<AnnotationFlag>.from(widget.selectedAnnotation?.flags ?? []);
  }

  @override
  void didUpdateWidget(AnnotationFlagsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update selected flags if provided from outside
    if (widget.selectedFlags != null &&
        widget.selectedFlags != oldWidget.selectedFlags) {
      setState(() {
        _selectedFlags = widget.selectedFlags!;
      });
    }
    // Otherwise update from annotation if it changed
    else if (oldWidget.selectedAnnotation?.id !=
        widget.selectedAnnotation?.id) {
      setState(() {
        _selectedFlags =
            Set<AnnotationFlag>.from(widget.selectedAnnotation?.flags ?? []);
      });
    }
  }

  // Build the checkboxes for each flag
  Widget _buildFlagCheckboxes() {
    // Determine if checkboxes should be enabled based on annotation selection
    final bool enabled = widget.selectedAnnotation != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: flagDescriptions.entries.map((entry) {
        final flag = entry.key;
        final description = entry.value;

        return CheckboxListTile(
          title: Text(
            description,
            style: TextStyle(
              color: enabled ? null : Colors.grey,
            ),
          ),
          value: _selectedFlags.contains(flag),
          onChanged: enabled
              ? (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedFlags.add(flag);
                    } else {
                      _selectedFlags.remove(flag);
                    }

                    // Notify parent about flag changes
                    if (widget.onFlagsChanged != null) {
                      widget.onFlagsChanged!(_selectedFlags);
                    }
                  });
                }
              : null, // Disabled when no annotation is selected
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }

  Future<void> _updateAnnotationFlags(BuildContext context) async {
    if (widget.selectedAnnotation == null || widget.document == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No annotation selected'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // Get the annotation manager for the document

      // Convert selected flags to list of strings
      final flagStrings = _selectedFlags.map((flag) => flag.name).toList();

      // Create annotation properties with only the flags we want to update
      final properties = AnnotationProperties(
        annotationId: widget.selectedAnnotation!.id ??
            widget.selectedAnnotation!.name ??
            '',
        pageIndex: widget.selectedAnnotation!.pageIndex,
        flags: flagStrings,
      );

      // Update the annotation properties
      final success =
          await widget.document!.saveAnnotationProperties(properties);

      if (success) {
        // Create an updated annotation object for the callbacks
        final updatedAnnotation = _createUpdatedAnnotation();

        if (updatedAnnotation != null && widget.onAnnotationUpdated != null) {
          widget.onAnnotationUpdated!(updatedAnnotation);
        }

        // Refresh the annotation to see the updates
        final pageIndex = widget.selectedAnnotation!.pageIndex;
        final annotations = await widget.document
                ?.getAnnotations(pageIndex, AnnotationType.all) ??
            [];

        // Find the updated annotation
        Annotation? refreshedAnnotation;
        for (final annotation in annotations) {
          if (annotation.id == widget.selectedAnnotation!.id) {
            refreshedAnnotation = annotation;
            break;
          }
        }

        // Update selected annotation with refreshed data
        if (refreshedAnnotation != null &&
            widget.onAnnotationSelected != null) {
          widget.onAnnotationSelected!(refreshedAnnotation);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Annotation flags updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to update annotation flags');
      }
    } catch (e) {
      // Error updating annotation flags
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating annotation flags: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Annotation? _createUpdatedAnnotation() {
    if (widget.selectedAnnotation == null) return null;

    // Use the copyWithFlags helper method to create a copy with updated flags
    return widget.selectedAnnotation?..flags = widget.selectedFlags?.toList();
  }

  @override
  Widget build(BuildContext context) {
    // Build the content for the panel
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected annotation info
        if (widget.selectedAnnotation != null) ...[
          Text(
            'Selected: ${widget.selectedAnnotation?.id ?? 'None'}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Type: ${widget.selectedAnnotation.runtimeType}',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          const Divider(),
          const Text(
            'Flags:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Flags checkboxes
          _buildFlagCheckboxes(),
          const SizedBox(height: 16),

          // Update button
          ElevatedButton.icon(
            onPressed: () => _updateAnnotationFlags(context),
            icon: const Icon(Icons.update),
            label: const Text('Update Flags'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ] else ...[
          const Text(
            'No annotation selected.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select an annotation to edit its flags.',
          ),
          const SizedBox(height: 16),

          // Show disabled flags checkboxes with empty set when no annotation is selected
          const Text(
            'Flags (disabled):',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),

          // Disabled flags checkboxes
          _buildFlagCheckboxes(),
        ],
      ],
    );

    // Return the draggable control panel with this content
    return DraggableControlPanel(
      title: 'Annotation Flags',
      headerIcon: Icons.flag_outlined,
      content: content,
      initialPosition: widget.initialPosition,
      initiallyExpanded: widget.initiallyExpanded,
    );
  }
}
