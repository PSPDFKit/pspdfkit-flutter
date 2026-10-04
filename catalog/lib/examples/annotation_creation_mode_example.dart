// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';

/// Annotation Creation Mode example.
///
/// Demonstrates programmatically driving the viewer's annotation creation
/// tools from Flutter:
///
/// - **Tools** opens a palette of [AnnotationTool]s. Tapping one calls
///   `controller.enterAnnotationCreationMode(tool)`, which activates that
///   tool on the native viewer so the next gesture on the page draws it.
/// - **Exit** calls `controller.exitAnnotationCreationMode()` to return the
///   viewer to normal (pan/select) interaction.
///
/// `enterAnnotationCreationMode` returns `true` when the mode was entered,
/// `false` when the request was rejected (e.g. the tool isn't supported on
/// this platform), or `null` when the platform doesn't report a result. The
/// palette surfaces that outcome in the status bar rather than assuming
/// success — some tools (notably the measurement family) aren't available on
/// every platform.
class AnnotationCreationModeExamplePage extends StatefulWidget {
  const AnnotationCreationModeExamplePage({super.key});

  @override
  State<AnnotationCreationModeExamplePage> createState() =>
      _AnnotationCreationModeExamplePageState();
}

/// One entry in the tool palette.
class _Tool {
  final AnnotationTool tool;
  final String label;
  final IconData icon;
  const _Tool(this.tool, this.label, this.icon);
}

/// Curated subset of [AnnotationTool] — the common creation tools plus one
/// measurement tool to exercise the "unsupported on this platform" path.
const _palette = <_Tool>[
  _Tool(AnnotationTool.inkPen, 'Ink Pen', Icons.draw_outlined),
  _Tool(AnnotationTool.inkHighlighter, 'Ink Highlighter', Icons.brush_outlined),
  _Tool(AnnotationTool.freeText, 'Text', Icons.text_fields_outlined),
  _Tool(AnnotationTool.note, 'Note', Icons.sticky_note_2_outlined),
  _Tool(AnnotationTool.highlight, 'Highlight', Icons.highlight),
  _Tool(AnnotationTool.line, 'Line', Icons.show_chart_outlined),
  _Tool(AnnotationTool.arrow, 'Arrow', Icons.arrow_outward),
  _Tool(AnnotationTool.square, 'Rectangle', Icons.crop_square),
  _Tool(AnnotationTool.circle, 'Ellipse', Icons.circle_outlined),
  _Tool(AnnotationTool.eraser, 'Eraser', Icons.cleaning_services_outlined),
  _Tool(
    AnnotationTool.measurementDistance,
    'Measure (distance)',
    Icons.straighten_outlined,
  ),
];

class _AnnotationCreationModeExamplePageState
    extends State<AnnotationCreationModeExamplePage> {
  Future<String>? _documentPath;
  NutrientController? _controller;

  _Tool? _activeTool;
  String? _lastAction;
  bool _isBusy = false;
  bool _authorSet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentPath ??= CatalogDocuments.welcome(context);
  }

  void _onControllerReady(NutrientController controller) {
    if (!mounted) return;
    setState(() => _controller = controller);
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _enter(_Tool tool) async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      // Annotation tools only engage once an annotation author is set — on
      // iOS the SDK gates tool activation on it, so without an author the
      // tool never becomes active in the toolbar. Set one before entering
      // creation mode. Android throws UnimplementedError here (HYB-959);
      // that's fine — the native Author Name dialog covers it there, so
      // don't let it abort the tool activation.
      if (!_authorSet) {
        try {
          await controller.document.setAuthorName('Nutrient Catalog');
        } on UnimplementedError {
          // setAuthorName isn't implemented on this platform — proceed.
        }
        _authorSet = true;
      }
      final result = await controller.enterAnnotationCreationMode(tool.tool);
      if (!mounted) return;
      if (result == false) {
        // The platform explicitly rejected the tool — surface it instead of
        // pretending it's active (measurement tools hit this on some
        // platforms).
        setState(() => _activeTool = null);
        _setLastAction('${tool.label} is not supported on this platform');
      } else {
        // true (entered) or null (entered, platform doesn't report) — either
        // way the tool is now active on the viewer.
        setState(() => _activeTool = tool);
        _setLastAction('Entered creation mode: ${tool.label}');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _activeTool = null);
      _setLastAction('${tool.label} failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _exit() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      await controller.exitAnnotationCreationMode();
      if (!mounted) return;
      setState(() => _activeTool = null);
      _setLastAction('Exited creation mode');
    } catch (error) {
      _setLastAction('Exit failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _setLastAction(String message) {
    if (!mounted) return;
    setState(() => _lastAction = message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------------------
  // Tool palette sheet
  // ---------------------------------------------------------------------------

  Future<void> _showToolPalette() async {
    if (!mounted || _controller == null) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: BrandSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      BrandSpacing.lg,
                      0,
                      BrandSpacing.lg,
                      BrandSpacing.sm,
                    ),
                    child: Text(
                      'Annotation tools',
                      style: Theme.of(sheetContext).textTheme.titleMedium,
                    ),
                  ),
                  for (final t in _palette)
                    ListTile(
                      leading: Icon(
                        t.icon,
                        color: t.tool == _activeTool?.tool
                            ? Theme.of(sheetContext).colorScheme.primary
                            : null,
                      ),
                      title: Text(t.label),
                      trailing: t.tool == _activeTool?.tool
                          ? Icon(
                              Icons.check_rounded,
                              color: Theme.of(sheetContext).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _enter(t);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ready = _controller != null && !_isBusy;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Annotation Creation Mode')),
      body: SafeArea(
        top: false,
        bottom: false,
        child: FutureBuilder<String>(
          future: _documentPath,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Failed: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return NutrientDocumentView(
              documentPath: snapshot.data!,
              onControllerReady: _onControllerReady,
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomBar(
        activeTool: _activeTool?.label,
        lastAction: _lastAction,
        ready: ready,
        inCreationMode: _activeTool != null,
        onTools: _showToolPalette,
        onExit: _exit,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom bar
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  final String? activeTool;
  final String? lastAction;
  final bool ready;
  final bool inCreationMode;
  final VoidCallback onTools;
  final VoidCallback onExit;

  const _BottomBar({
    required this.activeTool,
    required this.lastAction,
    required this.ready,
    required this.inCreationMode,
    required this.onTools,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            BrandSpacing.md,
            BrandSpacing.sm,
            BrandSpacing.md,
            BrandSpacing.md,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active tool',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: BrandSpacing.xxs),
                      Text(
                        activeTool ?? 'None — pick a tool',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: BrandColors.codeCoral,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (lastAction != null) ...[
                        const SizedBox(height: BrandSpacing.xxs),
                        Text(
                          lastAction!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: BrandSpacing.md),
                if (inCreationMode) ...[
                  OutlinedButton.icon(
                    onPressed: ready ? onExit : null,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Exit'),
                  ),
                  const SizedBox(width: BrandSpacing.sm),
                ],
                FilledButton.icon(
                  onPressed: ready ? onTools : null,
                  icon: const Icon(Icons.brush_rounded, size: 18),
                  label: const Text('Tools'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
