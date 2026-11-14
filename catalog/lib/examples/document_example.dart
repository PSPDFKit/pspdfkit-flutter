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

/// Document example: drive [NutrientDocumentInterface] from a live viewer.
///
/// Mirrors the legacy `DocumentExample` but uses the bindings surface only:
///
/// 1. [NutrientDocumentView] hosts the document; `onControllerReady` hands us
///    a [NutrientController].
/// 2. `controller.document.getPageCount()` / `getPageInfo(...)` populate the
///    info bar that lives in the `Scaffold.bottomNavigationBar` slot.
/// 3. `controller.events.pageChanged` keeps the current-page indicator and
///    the cached [PageInfo] in sync as the user navigates.
/// 4. A `FilledButton.icon` inside the info bar calls
///    `controller.document.exportPdf(...)` with a [DocumentSaveOptions]
///    that flattens annotations and optimises output, and reports the
///    resulting byte count both inline in the info bar and via a `SnackBar`.
class DocumentExamplePage extends StatefulWidget {
  const DocumentExamplePage({super.key});

  @override
  State<DocumentExamplePage> createState() => _DocumentExamplePageState();
}

class _DocumentExamplePageState extends State<DocumentExamplePage> {
  Future<String>? _documentPath;
  NutrientController? _controller;
  StreamSubscription<NutrientEvent>? _eventsSub;

  int? _pageCount;
  int _currentPage = 0;
  PageInfo? _currentPageInfo;
  bool _isExporting = false;
  int? _lastExportBytes;
  String? _lastExportError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentPath ??= CatalogDocuments.welcome(context);
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    super.dispose();
  }

  Future<void> _onControllerReady(NutrientController controller) async {
    _controller = controller;
    // Cancel any prior subscription in case the view re-fires ready (e.g.
    // hot-reload re-attaching the platform view) — otherwise we'd leak a
    // listener and double-handle every event.
    await _eventsSub?.cancel();
    _eventsSub = controller.events.listen(_handleEvent);

    // Platforms disagree on whether the document is queryable by the time
    // `onControllerReady` fires:
    //
    // - **iOS / Web**: the document IS loaded — but Web emits
    //   `DocumentLoadedEvent` synchronously inside its `onInstanceLoaded`
    //   hook, *before* this listener attaches, so the event never reaches
    //   us. We have to read here on ready.
    // - **Android**: the controller fires ready ~400 ms before the native
    //   fragment registers `pdfDocument`, so reading here throws. The
    //   `DocumentLoadedEvent` listener below picks it up once the doc lands.
    //
    // Try once on ready (succeeds on iOS / Web). On Android the swallowed
    // exception leaves `_pageCount == null` and the deferred event handler
    // populates it.
    _loadDocumentInfo();
  }

  void _handleEvent(NutrientEvent event) {
    if (event is DocumentLoadedEvent) {
      _loadDocumentInfo();
      return;
    }
    if (event is PageChangedEvent) {
      final pageIndex = event.pageIndex;
      if (pageIndex == _currentPage) return;
      setState(() => _currentPage = pageIndex);
      _refreshPageInfo(pageIndex);
    }
  }

  Future<void> _loadDocumentInfo() async {
    if (_pageCount != null) return; // Idempotent — only the first attempt wins.
    final controller = _controller;
    if (controller == null) return;
    int? count;
    try {
      count = await controller.document.getPageCount();
    } catch (_) {
      // Bindings round-trip failed — leave the page in a safe "not ready"
      // state for the `DocumentLoadedEvent` listener (Android) to retry.
      return;
    }
    if (!mounted) return;
    // Land the page count first so the export button enables even if the
    // user scrolled away from page 0 during the count round-trip.
    setState(() => _pageCount = count);
    // Page info is best-effort — if a platform throws, we still keep the
    // page count and the export button stays enabled.
    if (_currentPage != 0) {
      // The user has navigated; the `PageChangedEvent` handler owns the
      // current page's info now — don't race it with stale page-0 data.
      return;
    }
    PageInfo? info;
    try {
      info = await controller.document.getPageInfo(0);
    } catch (_) {
      info = null;
    }
    if (!mounted || _currentPage != 0) return;
    setState(() => _currentPageInfo = info);
  }

  Future<void> _refreshPageInfo(int pageIndex) async {
    final controller = _controller;
    if (controller == null) return;
    try {
      final info = await controller.document.getPageInfo(pageIndex);
      if (!mounted || _currentPage != pageIndex) return;
      setState(() => _currentPageInfo = info);
    } catch (_) {
      // Same rationale as `_onControllerReady` — keep the last known PageInfo.
    }
  }

  Future<void> _export() async {
    final controller = _controller;
    if (controller == null || _isExporting) return;
    setState(() {
      _isExporting = true;
      _lastExportError = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await controller.document.exportPdf(
        options: const DocumentSaveOptions(
          flatten: true,
          excludeAnnotations: true,
          optimize: true,
        ),
      );
      if (!mounted) return;
      setState(() => _lastExportBytes = bytes.length);
      messenger.showSnackBar(
        SnackBar(content: Text('Exported ${bytes.length} bytes')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _lastExportError = error.toString());
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $error')));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canExport =
        _controller != null && _pageCount != null && !_isExporting;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Document')),
      // The info bar lives in the bottom slot rather than the body so it
      // stays Flutter-owned and Maestro-reachable even after the embedded
      // native viewer takes a11y focus over the body area.
      bottomNavigationBar: SafeArea(
        top: false,
        child: _InfoBar(
          pageCount: _pageCount,
          currentPage: _currentPage,
          pageInfo: _currentPageInfo,
          lastExportBytes: _lastExportBytes,
          lastExportError: _lastExportError,
          onExport: canExport ? _export : null,
          isExporting: _isExporting,
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

class _InfoBar extends StatelessWidget {
  final int? pageCount;
  final int currentPage;
  final PageInfo? pageInfo;
  final int? lastExportBytes;
  final String? lastExportError;
  final VoidCallback? onExport;
  final bool isExporting;

  const _InfoBar({
    required this.pageCount,
    required this.currentPage,
    required this.pageInfo,
    required this.lastExportBytes,
    required this.lastExportError,
    required this.onExport,
    required this.isExporting,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = pageInfo != null
        ? '${pageInfo!.width.toStringAsFixed(0)} × '
            '${pageInfo!.height.toStringAsFixed(0)} pt'
        : '—';
    final rotation = pageInfo != null ? '${pageInfo!.rotation}°' : '—';
    final pageLabel =
        pageCount != null ? '${currentPage + 1} / $pageCount' : '— / —';
    final exportLabel = lastExportError != null
        ? 'Export failed: $lastExportError'
        : lastExportBytes != null
            ? 'Exported $lastExportBytes bytes'
            : '—';
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BrandSpacing.lg,
          vertical: BrandSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _InfoCell(label: 'Page', value: pageLabel),
                const SizedBox(width: BrandSpacing.lg),
                _InfoCell(label: 'Size', value: size),
                const SizedBox(width: BrandSpacing.lg),
                _InfoCell(label: 'Rotation', value: rotation),
                const SizedBox(width: BrandSpacing.lg),
                Expanded(
                  child: _InfoCell(label: 'Export', value: exportLabel),
                ),
              ],
            ),
            const SizedBox(height: BrandSpacing.sm),
            FilledButton.icon(
              onPressed: onExport,
              icon: isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_download_outlined),
              label: const Text('Export flattened PDF'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: BrandColors.codeCoral,
          ),
        ),
      ],
    );
  }
}
