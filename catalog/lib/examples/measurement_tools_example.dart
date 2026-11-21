// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';

/// Measurement tools example (legacy row #24).
///
/// Opens the bundled architectural plan (`measurements.pdf`, which already
/// carries measurement annotations with a calibrated scale) and activates the
/// `AnnotationTool.measurement*` family via
/// `controller.enterAnnotationCreationMode(tool)`:
///
/// - distance, perimeter, and the three area tools (rectangle / polygon /
///   ellipse).
///
/// `enterAnnotationCreationMode` returns `false` when a platform rejects the
/// tool — the status bar surfaces that instead of pretending it's active.
///
/// **API gap:** [NutrientViewConfiguration] has no measurement-scale /
/// precision configuration yet, so new measurements use the document's
/// embedded scale (or the SDK default). Tracked in the catalog parity
/// checklist.
class MeasurementToolsExamplePage extends StatefulWidget {
  const MeasurementToolsExamplePage({super.key});

  @override
  State<MeasurementToolsExamplePage> createState() =>
      _MeasurementToolsExamplePageState();
}

/// One entry in the measurement tool palette.
class _Tool {
  final AnnotationTool tool;
  final String label;
  final IconData icon;
  const _Tool(this.tool, this.label, this.icon);
}

const _palette = <_Tool>[
  _Tool(
    AnnotationTool.measurementDistance,
    'Distance',
    Icons.straighten_outlined,
  ),
  _Tool(
    AnnotationTool.measurementPerimeter,
    'Perimeter',
    Icons.polyline_outlined,
  ),
  _Tool(
    AnnotationTool.measurementAreaRect,
    'Area (rectangle)',
    Icons.crop_square_outlined,
  ),
  _Tool(
    AnnotationTool.measurementAreaPolygon,
    'Area (polygon)',
    Icons.pentagon_outlined,
  ),
  _Tool(
    AnnotationTool.measurementAreaEllipse,
    'Area (ellipse)',
    Icons.circle_outlined,
  ),
];

class _MeasurementToolsExamplePageState
    extends State<MeasurementToolsExamplePage> {
  Future<String>? _documentPath;
  NutrientController? _controller;

  _Tool? _activeTool;
  String? _lastAction;
  bool _isBusy = false;
  bool _authorSet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentPath ??= CatalogDocuments.measurements(context);
  }

  void _onControllerReady(NutrientController controller) {
    if (!mounted) return;
    setState(() => _controller = controller);
  }

  Future<void> _enter(_Tool tool) async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      // iOS gates tool activation on an annotation author being set; Android
      // shows its own Author Name dialog (setAuthorName throws
      // UnimplementedError there, which is fine).
      if (!_authorSet) {
        try {
          await controller.document.setAuthorName('Nutrient Catalog');
        } on UnimplementedError {
          // Not implemented on this platform — proceed.
        }
        _authorSet = true;
      }
      final result = await controller.enterAnnotationCreationMode(tool.tool);
      if (!mounted) return;
      if (result == false) {
        setState(() => _activeTool = null);
        _setLastAction('${tool.label} is not supported on this platform');
      } else {
        setState(() => _activeTool = tool);
        _setLastAction('Measuring: ${tool.label}');
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
      _setLastAction('Exited measurement mode');
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

  Future<void> _showToolPalette() async {
    if (!mounted || _controller == null) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
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
                  'Measurement tools',
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _controller != null && !_isBusy;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Measurement Tools')),
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
        measuring: _activeTool != null,
        onMeasure: _showToolPalette,
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
  final bool measuring;
  final VoidCallback onMeasure;
  final VoidCallback onExit;

  const _BottomBar({
    required this.activeTool,
    required this.lastAction,
    required this.ready,
    required this.measuring,
    required this.onMeasure,
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  // min — without it the Column expands to the Scaffold's
                  // loose bottomNavigationBar height constraint and the bar
                  // covers the whole screen.
                  mainAxisSize: MainAxisSize.min,
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
                      activeTool ?? 'None — pick a measurement tool',
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
              if (measuring) ...[
                OutlinedButton.icon(
                  onPressed: ready ? onExit : null,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Exit'),
                ),
                const SizedBox(width: BrandSpacing.sm),
              ],
              FilledButton.icon(
                onPressed: ready ? onMeasure : null,
                icon: const Icon(Icons.straighten_outlined, size: 18),
                label: const Text('Measure'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
