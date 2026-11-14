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

/// Coordinate Conversion example: `convertViewPointToPdfPoint` +
/// `convertPdfPointToViewPoint` from a live viewer.
///
/// 1. [NutrientDocumentView] hosts the document; `onControllerReady` hands us a
///    [NutrientController].
/// 2. **Convert sample point** runs a fixed view point through
///    `convertViewPointToPdfPoint` → `convertPdfPointToViewPoint` and shows the
///    PDF point plus the round-trip result. This path is Flutter-owned and
///    Maestro-reachable.
/// 3. Tapping the page emits a [PageClickedEvent]; when it carries a `point`
///    the same conversion runs on the tapped point (verified manually — Maestro
///    can't drive taps on the native viewer canvas).
///
/// The **round-trip closure** — `convertPdfPointToViewPoint(
/// convertViewPointToPdfPoint(p)) ≈ p` — is the cross-platform invariant the
/// example demonstrates (the two conversions are inverses), surfaced as a small
/// "Δ" in the info bar. The exact coordinate space of a tapped point differs by
/// platform (iOS reports view points, Android PDF points, Web omits the point),
/// but the round-trip closes on every platform regardless.
class CoordinateConversionExamplePage extends StatefulWidget {
  const CoordinateConversionExamplePage({super.key});

  @override
  State<CoordinateConversionExamplePage> createState() =>
      _CoordinateConversionExamplePageState();
}

class _CoordinateConversionExamplePageState
    extends State<CoordinateConversionExamplePage> {
  /// A fixed point (in view coordinates) used by "Convert sample point" so the
  /// demo is deterministic and Maestro-reachable.
  static const _sampleViewPoint = Offset(120, 200);

  Future<String>? _documentPath;
  NutrientController? _controller;
  StreamSubscription<NutrientEvent>? _eventsSub;

  int _currentPage = 0;
  String? _inputSource; // 'sample' or 'tap'
  Offset? _inputPoint;
  Offset? _pdfPoint;
  Offset? _roundTripPoint;
  String? _lastAction;
  bool _isBusy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentPath ??= CatalogDocuments.scientificPaper(context);
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    super.dispose();
  }

  Future<void> _onControllerReady(NutrientController controller) async {
    if (mounted) {
      setState(() => _controller = controller);
    } else {
      _controller = controller;
    }
    await _eventsSub?.cancel();
    _eventsSub = controller.events.listen(_handleEvent);
  }

  void _handleEvent(NutrientEvent event) {
    if (event is PageChangedEvent) {
      if (mounted) setState(() => _currentPage = event.pageIndex);
    } else if (event is PageClickedEvent && event.point != null) {
      _convert(event.point!, source: 'tap', page: event.pageIndex);
    }
  }

  Future<void> _convertSamplePoint() =>
      _convert(_sampleViewPoint, source: 'sample', page: _currentPage);

  Future<void> _convert(
    Offset viewPoint, {
    required String source,
    required int page,
  }) async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() {
      _isBusy = true;
      _inputSource = source;
      _inputPoint = viewPoint;
      _pdfPoint = null;
      _roundTripPoint = null;
    });
    try {
      final pdf = await controller.convertViewPointToPdfPoint(page, viewPoint);
      final roundTrip = await controller.convertPdfPointToViewPoint(page, pdf);
      if (!mounted) return;
      setState(() {
        _pdfPoint = pdf;
        _roundTripPoint = roundTrip;
      });
      _setAction('Converted $source point on page ${page + 1}');
    } catch (error) {
      _setAction('Conversion failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _setAction(String message) {
    if (!mounted) return;
    setState(() => _lastAction = message);
  }

  @override
  Widget build(BuildContext context) {
    final ready = _controller != null && !_isBusy;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Coordinate Conversion')),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _ConversionInfoBar(
          currentPage: _currentPage,
          inputSource: _inputSource,
          inputPoint: _inputPoint,
          pdfPoint: _pdfPoint,
          roundTripPoint: _roundTripPoint,
          lastAction: _lastAction,
          onConvertSample: ready ? _convertSamplePoint : null,
        ),
      ),
      body: FutureBuilder<String>(
        future: _documentPath,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
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
    );
  }
}

class _ConversionInfoBar extends StatelessWidget {
  final int currentPage;
  final String? inputSource;
  final Offset? inputPoint;
  final Offset? pdfPoint;
  final Offset? roundTripPoint;
  final String? lastAction;
  final VoidCallback? onConvertSample;

  const _ConversionInfoBar({
    required this.currentPage,
    required this.inputSource,
    required this.inputPoint,
    required this.pdfPoint,
    required this.roundTripPoint,
    required this.lastAction,
    required this.onConvertSample,
  });

  String _fmt(Offset? p) => p == null
      ? '—'
      : '(${p.dx.toStringAsFixed(1)}, ${p.dy.toStringAsFixed(1)})';

  /// Distance between the original input point and the round-tripped point —
  /// ~0 proves the two conversions are inverses.
  String get _delta {
    final a = inputPoint, b = roundTripPoint;
    if (a == null || b == null) return '—';
    return '${(a - b).distance.toStringAsFixed(2)} px';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Row(label: 'Page', value: '${currentPage + 1}'),
            _Row(
              label: 'Input (${inputSource ?? 'view'})',
              value: _fmt(inputPoint),
            ),
            _Row(label: 'PDF point', value: _fmt(pdfPoint)),
            _Row(label: 'Round-trip', value: _fmt(roundTripPoint)),
            _Row(label: 'Δ round-trip', value: _delta),
            if (lastAction != null) ...[
              const SizedBox(height: 4),
              Text(
                lastAction!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Tap the page to convert the tapped point, or:',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onConvertSample,
              icon: const Icon(Icons.my_location),
              label: const Text('Convert sample point'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
