///
///  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/material.dart';

/// A draggable and expandable control panel widget that can be positioned anywhere on the screen.
class DraggableControlPanel extends StatefulWidget {
  /// Title displayed in the panel header
  final String title;

  /// Initial position of the panel
  final Offset initialPosition;

  /// Initial expanded state of the panel
  final bool initiallyExpanded;

  /// Content to display inside the panel when expanded
  final Widget content;

  /// Optional icon to display in the header
  final IconData? headerIcon;

  /// Optional width for the panel
  final double? width;

  /// Optional height for the panel when expanded
  final double? expandedHeight;

  /// Optional minimum height for the panel when collapsed
  final double collapsedHeight;

  /// Optional color for the panel header
  final Color? headerColor;

  /// Optional color for the panel background
  final Color? backgroundColor;

  /// Callback when the panel is expanded or collapsed
  final Function(bool)? onExpandStateChanged;

  /// Controls whether to show the drag indicator button
  final bool showDragIndicator;

  const DraggableControlPanel({
    Key? key,
    required this.title,
    required this.content,
    this.initialPosition = const Offset(20, 20),
    this.initiallyExpanded = false,
    this.headerIcon,
    this.width = 280,
    this.expandedHeight = 400,
    this.collapsedHeight = 60,
    this.headerColor,
    this.backgroundColor = Colors.white,
    this.onExpandStateChanged,
    this.showDragIndicator = true,
  }) : super(key: key);

  @override
  State<DraggableControlPanel> createState() => _DraggableControlPanelState();
}

class _DraggableControlPanelState extends State<DraggableControlPanel> {
  late Offset _position;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (widget.onExpandStateChanged != null) {
        widget.onExpandStateChanged!(_isExpanded);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use theme color if headerColor is not provided
    final headerColor = widget.headerColor ?? Theme.of(context).primaryColor;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: widget.width,
          height: _isExpanded ? widget.expandedHeight : widget.collapsedHeight,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with expand/collapse control
              InkWell(
                onTap: _toggleExpanded,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side - Icon and title
                      Expanded(
                        child: Row(
                          children: [
                            if (widget.showDragIndicator) ...[
                              _buildDragIndicator(),
                              const SizedBox(width: 8),
                            ],
                            if (widget.headerIcon != null) ...[
                              Icon(
                                widget.headerIcon,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right side - Expand/collapse button
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable content
              if (_isExpanded)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: widget.content,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates a drag indicator icon that visually suggests the panel can be dragged
  Widget _buildDragIndicator() {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: const Icon(
        Icons.drag_indicator,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}
