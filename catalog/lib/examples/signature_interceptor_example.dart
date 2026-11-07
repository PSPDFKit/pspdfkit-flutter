// Copyright © 2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

/// Steps into the native signature flow from Flutter with a [SignatureInterceptor].
///
/// The stroke thickness and opacity are set once, with the sliders above the
/// viewer, and every signature created afterwards starts with those values:
/// the interceptor hands them to the native signing UI right before it opens.
/// Persisting them is a matter of storing two numbers with the app's
/// preferences. Once a signature is created, a Flutter sheet decides where on
/// the page it goes; signatures for form fields keep the field's position.
library;

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';

class SignatureInterceptorExamplePage extends StatefulWidget {
  const SignatureInterceptorExamplePage({super.key});

  @override
  State<SignatureInterceptorExamplePage> createState() =>
      _SignatureInterceptorExamplePageState();
}

class _SignatureInterceptorExamplePageState
    extends State<SignatureInterceptorExamplePage>
    implements SignatureInterceptor {
  Future<String>? _documentPath;

  // The appearance every new signature starts with. Persist these in your app.
  double _thickness = 4;
  double _opacity = 1;
  _Status _status = const _Status(
    Icons.touch_app_outlined,
    'Tap the signature tool, or the signature field.',
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A form with a signature field, so both entry points can be tried.
    _documentPath ??= CatalogDocuments.form(context);
  }

  Future<void> _onControllerReady(NutrientController controller) async {
    // This is the whole integration.
    controller.setSignatureInterceptor(this);
    // Only the signature tool, so the flow this example shows is one tap away.
    await controller
        .setAnnotationToolbarItems(const [AnnotationTool.signature]);
  }

  // SignatureInterceptor

  @override
  Future<SignatureResponse> onSignatureRequested(
      SignatureRequest request) async {
    // No UI of our own here: the values were chosen up front, so the native
    // signing UI opens straight away and draws with them.
    final where = request.isFormField
        ? 'field "${request.formFieldName}"'
        : 'from the toolbar';
    _setStatus(Icons.draw_outlined,
        'Signing $where · ${_formatThickness(_thickness)} · ${_formatOpacity(_opacity)}');
    return SignatureResponse.proceed(
      style: SignatureStyle(thickness: _thickness, opacity: _opacity),
    );
  }

  @override
  Future<SignaturePlacementResponse> onSignaturePlacementRequested(
      SignaturePlacementProposal proposal) async {
    // A form field has a fixed location, so there is nothing to ask.
    if (proposal.isFormField) {
      _setStatus(Icons.check_circle_outline,
          'Signed field "${proposal.formFieldName}"');
      return const SignaturePlacementResponse.proceed();
    }

    final choice = await showModalBottomSheet<_PlacementChoice>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _PlacementSheet(),
    );
    // PDF page coordinates: the origin is the page's bottom-left corner.
    final box = proposal.boundingBox;
    final page = proposal.pageSize;
    const margin = 24.0;
    switch (choice) {
      case null:
      case _PlacementChoice.discard:
        _setStatus(Icons.remove_circle_outline, 'Signature not added');
        return const SignaturePlacementResponse.cancel();
      case _PlacementChoice.proposed:
        _setStatus(
            Icons.check_circle_outline, 'Placed at the default position');
        return const SignaturePlacementResponse.proceed();
      case _PlacementChoice.bottomRight:
        _setStatus(Icons.check_circle_outline, 'Placed bottom-right');
        return SignaturePlacementResponse.proceed(
          boundingBox: Rect.fromLTWH(
              page.width - box.width - margin, margin, box.width, box.height),
        );
      case _PlacementChoice.topLeft:
        _setStatus(Icons.check_circle_outline, 'Placed top-left');
        return SignaturePlacementResponse.proceed(
          boundingBox: Rect.fromLTWH(
              margin, page.height - margin - box.height, box.width, box.height),
        );
    }
  }

  void _setStatus(IconData icon, String message) {
    if (!mounted) return;
    setState(() => _status = _Status(icon, message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signature Interceptor')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<String>(
              future: _documentPath,
              builder: (context, snapshot) {
                final path = snapshot.data;
                if (path == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return NutrientDocumentView(
                  documentPath: path,
                  onControllerReady: _onControllerReady,
                );
              },
            ),
          ),
          // Status and settings share one collapsible panel under the document.
          _SettingsPanel(
            status: _status,
            thickness: _thickness,
            opacity: _opacity,
            onThicknessChanged: (v) => setState(() => _thickness = v),
            onOpacityChanged: (v) => setState(() => _opacity = v),
          ),
        ],
      ),
    );
  }
}

String _formatThickness(double thickness) => '${thickness.round()} pt';
String _formatOpacity(double opacity) => '${(opacity * 100).round()}%';

/// The latest event, and the stroke thickness and opacity new signatures start
/// with. Collapses to its header, which then summarises the style.
class _SettingsPanel extends StatefulWidget {
  final _Status status;
  final double thickness;
  final double opacity;
  final ValueChanged<double> onThicknessChanged;
  final ValueChanged<double> onOpacityChanged;

  const _SettingsPanel({
    required this.status,
    required this.thickness,
    required this.opacity,
    required this.onThicknessChanged,
    required this.onOpacityChanged,
  });

  @override
  State<_SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<_SettingsPanel> {
  bool _expanded = true;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary =
        '${_formatThickness(widget.thickness)} · ${_formatOpacity(widget.opacity)}';
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  BrandSpacing.lg,
                  BrandSpacing.xs,
                  BrandSpacing.xs,
                  BrandSpacing.xs,
                ),
                child: Row(
                  children: [
                    Icon(widget.status.icon,
                        size: 20, color: BrandColors.codeCoral),
                    const SizedBox(width: BrandSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.status.message,
                        key: const Key('status'),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    if (!_expanded) ...[
                      const SizedBox(width: BrandSpacing.sm),
                      Text(
                        summary,
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: BrandColors.codeCoral),
                      ),
                    ],
                    IconButton(
                      onPressed: _toggle,
                      tooltip: _expanded
                          ? 'Hide signature settings'
                          : 'Show signature settings',
                      icon: Icon(_expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(
                        BrandSpacing.lg,
                        0,
                        BrandSpacing.sm,
                        BrandSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          _StrokePreview(
                            thickness: widget.thickness,
                            opacity: widget.opacity,
                          ),
                          const SizedBox(width: BrandSpacing.md),
                          Expanded(
                            child: Column(
                              children: [
                                _SliderRow(
                                  label: 'Thickness',
                                  value: _formatThickness(widget.thickness),
                                  child: Slider(
                                    key: const Key('thickness'),
                                    min: 1,
                                    max: 20,
                                    divisions: 19,
                                    value: widget.thickness,
                                    onChanged: widget.onThicknessChanged,
                                  ),
                                ),
                                _SliderRow(
                                  label: 'Opacity',
                                  value: _formatOpacity(widget.opacity),
                                  child: Slider(
                                    key: const Key('opacity'),
                                    min: 0.1,
                                    max: 1,
                                    divisions: 9,
                                    value: widget.opacity,
                                    onChanged: widget.onOpacityChanged,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget child;

  const _SliderRow(
      {required this.label, required this.value, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: BrandColors.codeCoral),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// A sample stroke drawn with the chosen thickness and opacity.
class _StrokePreview extends StatelessWidget {
  final double thickness;
  final double opacity;

  const _StrokePreview({required this.thickness, required this.opacity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BrandRadius.brLg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: CustomPaint(
        painter: _StrokePainter(
          thickness: thickness,
          color: theme.colorScheme.onSurface.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  final double thickness;
  final Color color;

  const _StrokePainter({required this.thickness, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // A loose, signature-like loop across the tile.
    final path = Path()
      ..moveTo(w * 0.14, h * 0.62)
      ..cubicTo(w * 0.26, h * 0.20, w * 0.42, h * 0.22, w * 0.40, h * 0.58)
      ..cubicTo(w * 0.38, h * 0.84, w * 0.56, h * 0.80, w * 0.62, h * 0.48)
      ..cubicTo(w * 0.68, h * 0.24, w * 0.80, h * 0.34, w * 0.86, h * 0.56);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        // The tile is smaller than a signing canvas, so scale the stroke down.
        ..strokeWidth = thickness * 0.6,
    );
  }

  @override
  bool shouldRepaint(_StrokePainter old) =>
      old.thickness != thickness || old.color != color;
}

class _Status {
  final IconData icon;
  final String message;

  const _Status(this.icon, this.message);
}

enum _PlacementChoice { proposed, bottomRight, topLeft, discard }

class _PlacementSheet extends StatelessWidget {
  const _PlacementSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    void choose(_PlacementChoice choice) => Navigator.of(context).pop(choice);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                BrandSpacing.lg, 0, BrandSpacing.lg, BrandSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Place signature', style: theme.textTheme.titleMedium),
                const SizedBox(height: BrandSpacing.xxs),
                Text(
                  'Decided in Flutter, before the signature is added.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.ads_click),
            title: const Text('Default position'),
            onTap: () => choose(_PlacementChoice.proposed),
          ),
          ListTile(
            leading: const Icon(Icons.south_east),
            title: const Text('Bottom-right of the page'),
            onTap: () => choose(_PlacementChoice.bottomRight),
          ),
          ListTile(
            leading: const Icon(Icons.north_west),
            title: const Text('Top-left of the page'),
            onTap: () => choose(_PlacementChoice.topLeft),
          ),
          const Divider(height: BrandSpacing.lg),
          ListTile(
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text("Don't add it",
                style: TextStyle(color: theme.colorScheme.error)),
            onTap: () => choose(_PlacementChoice.discard),
          ),
          const SizedBox(height: BrandSpacing.sm),
        ],
      ),
    );
  }
}
