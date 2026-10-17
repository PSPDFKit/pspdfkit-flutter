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

/// Zoom to Rect example: drive the viewport-control surface of
/// [NutrientController] from a live viewer.
///
/// Mirrors the legacy `ZoomExample` but uses the bindings surface only and
/// reports the controller state back into a Flutter-owned info bar:
///
/// 1. [NutrientDocumentView] hosts a multi-page document; `onControllerReady`
///    hands us a [NutrientController].
/// 2. **Zoom to region** computes a centered rect from the current page's
///    [PageInfo] and calls `controller.zoomToRect(page, rect)`.
/// 3. **Reset** zooms back out to the full-page rect.
/// 4. **Read viewport** calls `controller.getZoomScale(page)` and
///    `controller.getVisibleRect(page)` and surfaces both in the info bar.
///
/// All three viewport methods work on Android, iOS, and Web. Web has no single
/// "visible rect" API, so the web adapter composes it from the content-frame
/// DOM + `transformContentClientToPageSpace` (see [WebPlatformAdapter]). When a
/// page isn't currently visible the platforms return [Rect.zero], which the
/// info bar renders as "—".
class ZoomToRectExamplePage extends StatefulWidget {
  const ZoomToRectExamplePage({super.key});

  @override
  State<ZoomToRectExamplePage> createState() => _ZoomToRectExamplePageState();
}

class _ZoomToRectExamplePageState extends State<ZoomToRectExamplePage> {
  Future<String>? _documentPath;
  NutrientController? _controller;
  StreamSubscription<NutrientEvent>? _eventsSub;

  int _currentPage = 0;
  PageInfo? _pageInfo;
  double? _zoomScale;
  Rect? _visibleRect;
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
    // setState so the controls enable as soon as the controller is ready —
    // on Android getPageInfo below throws until the document registers, so we
    // can't rely on its setState to trigger the rebuild.
    if (mounted) {
      setState(() => _controller = controller);
    } else {
      _controller = controller;
    }
    await _eventsSub?.cancel();
    _eventsSub = controller.events.listen(_handleEvent);
    await _refreshPageInfo(_currentPage);
  }

  void _handleEvent(NutrientEvent event) {
    if (event is DocumentLoadedEvent) {
      // Android fires the controller ready ~400 ms before the document is
      // queryable, so the getPageInfo in `_onControllerReady` throws there.
      // This event lands once the document is attached — read it now so the
      // page-derived target rect + Reset become available.
      unawaited(_refreshPageInfo(_currentPage));
    } else if (event is PageChangedEvent) {
      if (mounted) setState(() => _currentPage = event.pageIndex);
      unawaited(_refreshPageInfo(_currentPage));
    }
  }

  Future<void> _refreshPageInfo(int pageIndex) async {
    final controller = _controller;
    if (controller == null) return;
    try {
      final info = await controller.document.getPageInfo(pageIndex);
      if (!mounted || _currentPage != pageIndex) return;
      setState(() => _pageInfo = info);
    } catch (_) {
      // Keep the last known PageInfo — Android can fire ready before the
      // document is queryable; the next page change retries.
    }
  }

  /// A centered region (the middle 40%) of the current page, in PDF points.
  /// Falls back to a fixed rect if the page size isn't known yet.
  Rect get _targetRect {
    final info = _pageInfo;
    if (info == null) return const Rect.fromLTWH(100, 200, 300, 300);
    return Rect.fromLTWH(
      info.width * 0.3,
      info.height * 0.3,
      info.width * 0.4,
      info.height * 0.4,
    );
  }

  Future<void> _zoomToRegion() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    final page = _currentPage;
    try {
      await controller.zoomToRect(page, _targetRect);
      // The zoom applies asynchronously (notably on Android, where it hops to
      // the platform main thread), so wait for the scale to settle before
      // reading it back rather than guessing with a fixed delay.
      await _waitForZoomToSettle(page);
      await _readViewport(silent: true);
      _setAction('Zoomed to region on page ${page + 1}');
    } catch (error) {
      _setAction('Zoom failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _resetZoom() async {
    final controller = _controller;
    final info = _pageInfo;
    if (controller == null || info == null || _isBusy) return;
    setState(() => _isBusy = true);
    final page = _currentPage;
    try {
      await controller.zoomToRect(
        page,
        Rect.fromLTWH(0, 0, info.width, info.height),
      );
      await _waitForZoomToSettle(page);
      await _readViewport(silent: true);
      _setAction('Reset zoom on page ${page + 1}');
    } catch (error) {
      _setAction('Reset failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Polls `getZoomScale` until it stabilises (two consecutive equal reads) or
  /// the bounded attempt budget is exhausted. `zoomToRect` returns before the
  /// zoom has actually applied, so reading the scale immediately can catch a
  /// stale value — polling-to-settle is robust on slow hardware where a single
  /// fixed delay isn't.
  Future<void> _waitForZoomToSettle(int page) async {
    final controller = _controller;
    if (controller == null) return;
    double? previous;
    for (var attempt = 0; attempt < 10; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final double current;
      try {
        current = await controller.getZoomScale(page);
      } catch (_) {
        return;
      }
      if (previous != null && (current - previous).abs() < 0.001) return;
      previous = current;
    }
  }

  Future<void> _readViewport({bool silent = false}) async {
    final controller = _controller;
    if (controller == null) return;
    final page = _currentPage;

    double? zoom;
    try {
      zoom = await controller.getZoomScale(page);
    } catch (_) {
      zoom = null;
    }

    Rect? visible;
    try {
      final r = await controller.getVisibleRect(page);
      // Rect.zero is the platforms' "page not currently visible" sentinel.
      visible = r == Rect.zero ? null : r;
    } catch (_) {
      visible = null;
    }

    if (!mounted) return;
    setState(() {
      _zoomScale = zoom;
      _visibleRect = visible;
    });
    if (!silent) _setAction('Read viewport on page ${page + 1}');
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
      appBar: AppBar(title: const Text('Zoom to Rect')),
      // Info bar + controls live in the bottom slot so they stay Flutter-owned
      // and Maestro-reachable once the native viewer takes a11y focus.
      bottomNavigationBar: SafeArea(
        top: false,
        child: _ZoomInfoBar(
          currentPage: _currentPage,
          targetRect: _pageInfo == null ? null : _targetRect,
          zoomScale: _zoomScale,
          visibleRect: _visibleRect,
          lastAction: _lastAction,
          onZoomToRegion: ready ? _zoomToRegion : null,
          onReset: ready && _pageInfo != null ? _resetZoom : null,
          onReadViewport: ready ? () => _readViewport() : null,
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

class _ZoomInfoBar extends StatelessWidget {
  final int currentPage;
  final Rect? targetRect;
  final double? zoomScale;
  final Rect? visibleRect;
  final String? lastAction;
  final VoidCallback? onZoomToRegion;
  final VoidCallback? onReset;
  final VoidCallback? onReadViewport;

  const _ZoomInfoBar({
    required this.currentPage,
    required this.targetRect,
    required this.zoomScale,
    required this.visibleRect,
    required this.lastAction,
    required this.onZoomToRegion,
    required this.onReset,
    required this.onReadViewport,
  });

  String _fmtRect(Rect r) =>
      '${r.left.toStringAsFixed(0)}, ${r.top.toStringAsFixed(0)} · '
      '${r.width.toStringAsFixed(0)}×${r.height.toStringAsFixed(0)}';

  String get _visibleRectLabel {
    final r = visibleRect;
    return r == null ? '—' : _fmtRect(r);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = targetRect;
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
              label: 'Zoom',
              value:
                  zoomScale == null ? '—' : '${zoomScale!.toStringAsFixed(2)}×',
            ),
            _Row(label: 'Visible rect', value: _visibleRectLabel),
            _Row(
              label: 'Target region',
              value: target == null ? '—' : _fmtRect(target),
            ),
            if (lastAction != null) ...[
              const SizedBox(height: 4),
              Text(
                lastAction!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onZoomToRegion,
                  icon: const Icon(Icons.zoom_in),
                  label: const Text('Zoom to region'),
                ),
                OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.zoom_out_map),
                  label: const Text('Reset'),
                ),
                OutlinedButton.icon(
                  onPressed: onReadViewport,
                  icon: const Icon(Icons.straighten),
                  label: const Text('Read viewport'),
                ),
              ],
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
            width: 110,
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
