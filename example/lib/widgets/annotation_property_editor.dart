///  Copyright © 2025-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Widget that provides UI for editing annotation properties
class AnnotationPropertyEditor extends StatelessWidget {
  final Annotation annotation;
  final AnnotationProperties properties;
  final Function(Color) onColorChanged;
  final Function(double) onOpacityChanged;
  final Function(double) onLineWidthChanged;
  final Function(AnnotationFlag) onFlagToggled;
  final VoidCallback onAddCustomData;
  final VoidCallback? onViewCustomData;

  const AnnotationPropertyEditor({
    Key? key,
    required this.annotation,
    required this.properties,
    required this.onColorChanged,
    required this.onOpacityChanged,
    required this.onLineWidthChanged,
    required this.onFlagToggled,
    required this.onAddCustomData,
    this.onViewCustomData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: 20),

          // Color Picker
          _buildColorPicker(),
          const SizedBox(height: 20),

          // Opacity Slider
          _buildOpacitySlider(),
          const SizedBox(height: 20),

          // Line Width (for applicable annotations)
          if (_canHaveLineWidth(annotation)) ...[
            _buildLineWidthSlider(),
            const SizedBox(height: 20),
          ],

          // Annotation Flags
          _buildFlags(),
          const SizedBox(height: 20),

          // Custom Data
          if (properties.customData != null &&
              properties.customData!.isNotEmpty)
            _buildCustomDataSection(),

          // Add Custom Data Button
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Custom Data'),
            onPressed: onAddCustomData,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          // Attachment Info (for annotations with attachments)
          if (annotation is ImageAnnotation ||
              annotation is FileAnnotation) ...[
            const SizedBox(height: 20),
            _buildAttachmentInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _getAnnotationIcon(annotation.type),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  annotation.type.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Page ${annotation.pageIndex}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    final currentColor =
        properties.strokeColor != null ? Color(properties.strokeColor!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
            if (currentColor != null)
              Row(
                children: [
                  Text(
                    'Current: ',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: currentColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[400]!, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _colorToHex(currentColor),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...Colors.primaries.take(10).map((color) => InkWell(
                  onTap: () => onColorChanged(color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  ),
                )),
            InkWell(
              onTap: () => onColorChanged(Colors.black),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ),
            ),
            InkWell(
              onTap: () => onColorChanged(Colors.white),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOpacitySlider() {
    final opacity = properties.opacity ?? 1.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Opacity',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Text('${(opacity * 100).round()}%',
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
        Slider(
          value: opacity,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          label: '${(opacity * 100).round()}%',
          onChanged: onOpacityChanged,
        ),
      ],
    );
  }

  Widget _buildLineWidthSlider() {
    final lineWidth = (properties.lineWidth ?? 2.0).clamp(0.5, 50.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Line Width',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Text('${lineWidth.toStringAsFixed(1)}pt',
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
        Slider(
          value: lineWidth,
          min: 0.5,
          max: 50.0,
          divisions: 99,
          label: '${lineWidth.toStringAsFixed(1)}pt',
          onChanged: onLineWidthChanged,
        ),
      ],
    );
  }

  Widget _buildFlags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Flags', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFlagChip('Read Only', AnnotationFlag.readOnly),
            _buildFlagChip('Hidden', AnnotationFlag.hidden),
            _buildFlagChip('Print', AnnotationFlag.print),
            _buildFlagChip('Locked', AnnotationFlag.locked),
          ],
        ),
      ],
    );
  }

  Widget _buildFlagChip(String label, AnnotationFlag flag) {
    final isSelected = properties.flagsSet?.contains(flag) ?? false;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (_) => onFlagToggled(flag),
      showCheckmark: true,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildCustomDataSection() {
    final customData = properties.customData!;
    final hasNestedData = customData.values.any((v) => v is Map || v is List);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.data_object, size: 18, color: Colors.blue[700]),
                  const SizedBox(width: 6),
                  const Text('Custom Data',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
              if (onViewCustomData != null)
                TextButton.icon(
                  onPressed: onViewCustomData,
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Show summary of entries
          ...customData.entries.take(5).map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${entry.key}: ',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 12)),
                    Expanded(
                      child: Text(
                        _formatValue(entry.value),
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
          if (customData.length > 5) ...[
            const SizedBox(height: 4),
            Text(
              '... and ${customData.length - 5} more entries',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic),
            ),
          ],
          if (hasNestedData) ...[
            const SizedBox(height: 4),
            Text(
              'Contains nested data. Tap "View All" for details.',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue[600],
                  fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  /// Formats a value for display, handling nested structures
  String _formatValue(Object? value) {
    if (value == null) return 'null';
    if (value is Map) return '{...} (${value.length} items)';
    if (value is List) return '[...] (${value.length} items)';
    return value.toString();
  }

  /// Converts a Color to a hex string representation
  String _colorToHex(Color color) {
    final r = (color.r * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0');
    final g = (color.g * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0');
    final b = (color.b * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  Widget _buildAttachmentInfo() {
    final hasAttachment =
        annotation is ImageAnnotation || annotation is FileAnnotation;
    if (!hasAttachment) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attachment Preserved',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  'Property updates preserve attachment data',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canHaveLineWidth(Annotation annotation) {
    return annotation is InkAnnotation ||
        annotation is LineAnnotation ||
        annotation is SquareAnnotation ||
        annotation is CircleAnnotation ||
        annotation is PolylineAnnotation ||
        annotation is PolygonAnnotation;
  }

  Icon _getAnnotationIcon(AnnotationType type) {
    switch (type) {
      case AnnotationType.ink:
        return const Icon(Icons.draw, size: 24, color: Colors.purple);
      case AnnotationType.highlight:
        return const Icon(Icons.highlight, size: 24, color: Colors.yellow);
      case AnnotationType.note:
        return const Icon(Icons.note, size: 24, color: Colors.orange);
      case AnnotationType.freeText:
        return const Icon(Icons.text_fields, size: 24, color: Colors.blue);
      case AnnotationType.square:
        return const Icon(Icons.crop_square, size: 24, color: Colors.red);
      case AnnotationType.circle:
        return const Icon(Icons.circle_outlined, size: 24, color: Colors.green);
      case AnnotationType.line:
        return const Icon(Icons.remove, size: 24, color: Colors.teal);
      case AnnotationType.file:
        return const Icon(Icons.attach_file, size: 24, color: Colors.indigo);
      case AnnotationType.stamp:
        return const Icon(Icons.approval, size: 24, color: Colors.deepPurple);
      case AnnotationType.image:
        return const Icon(Icons.image, size: 24, color: Colors.cyan);
      default:
        return const Icon(Icons.edit_note, size: 24, color: Colors.grey);
    }
  }
}
