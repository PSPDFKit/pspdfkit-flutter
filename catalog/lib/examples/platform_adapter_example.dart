// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../adapters/catalog_adapter_controller.dart';
import '../adapters/catalog_adapters.dart';
import '../design/design.dart';

/// Platform Adapter example.
///
/// Shows the **adapter-as-controller** pattern that the bindings runtime
/// uses to expose per-platform extensibility:
///
/// 1. The page constructs its own [CatalogAdapterController] in
///    `initState` and passes it to [NutrientDocumentView.adapter] — the
///    page owns the adapter's lifetime.
/// 2. Cross-platform events flow through `controller.events`.
/// 3. Platform-only events (Android contextual-toolbar lifecycle, iOS
///    UI/view-mode delegate callbacks, Web zoom changes) flow through
///    the adapter's `attachListeners` hook.
/// 4. `adapter.goToPage(...)` reaches through to the native viewer's
///    page-navigation API until `NutrientControllerInterface` exposes
///    one publicly.
class PlatformAdapterExamplePage extends StatefulWidget {
  const PlatformAdapterExamplePage({super.key});

  @override
  State<PlatformAdapterExamplePage> createState() =>
      _PlatformAdapterExamplePageState();
}

class _PlatformAdapterExamplePageState
    extends State<PlatformAdapterExamplePage> {
  // ─────────────────────────────────────────────────────────────────────
  // Nutrient SDK usage — the part this example exists to demonstrate.
  // ─────────────────────────────────────────────────────────────────────

  /// Per-view adapter. `createCatalogAdapter()` returns the right
  /// Catalog{Android,IOS,Web}Adapter for the current platform.
  CatalogAdapterController? _adapter;

  /// Subscription to `controller.events` (the cross-platform typed stream).
  StreamSubscription<NutrientEvent>? _eventsSub;

  // Document state surfaced by the adapter as the native viewer reports
  // lifecycle changes.
  int _pageCount = 0;
  int _currentPage = 0;
  String _title = 'Loading…';
  bool _isReady = false;

  // Event log entries (newest first).
  final List<String> _log = [];

  @override
  void initState() {
    super.initState();
    _adapter = createCatalogAdapter()
      ?..attachListeners(
        onLog: (entry) => _appendLog(entry.message),
        onDocumentInfoChanged: (info) {
          if (!mounted) return;
          setState(() {
            if (info.pageCount != null) _pageCount = info.pageCount!;
            if (info.currentPage != null) _currentPage = info.currentPage!;
            if (info.title != null) _title = info.title!;
            if (info.isReady != null) _isReady = info.isReady!;
          });
        },
      );
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    _adapter
      ?..detachListeners()
      ..dispose();
    super.dispose();
  }

  Widget _buildDocumentView(String documentPath) {
    return NutrientDocumentView<CatalogAdapterController>(
      documentPath: documentPath,
      adapter: _adapter,
      onControllerReady: (controller) {
        _eventsSub = controller.events.listen((event) {
          final line = switch (event) {
            DocumentLoadedEvent() => 'Document loaded',
            DocumentErrorEvent(:final error) => 'Document error: $error',
            DocumentSavedEvent() => 'Document saved',
            PageChangedEvent(:final pageIndex) => 'Page → ${pageIndex + 1}',
            PageClickedEvent(:final pageIndex) =>
              'Page ${pageIndex + 1} clicked',
            AnnotationCreatedEvent() => 'Annotation created',
            AnnotationUpdatedEvent() => 'Annotation updated',
            AnnotationDeletedEvent() => 'Annotation deleted',
            AnnotationSelectedEvent() => 'Annotation selected',
            AnnotationDeselectedEvent() => 'Annotation deselected',
            TextSelectionChangedEvent(:final selectedText) =>
              'Text selection: ${selectedText ?? '(cleared)'}',
            _ => null,
          };
          if (line != null) _appendLog(line);
        });
      },
    );
  }

  Future<void> _goToPage(int index) async {
    if (index < 0 || index >= _pageCount) return;
    await _adapter?.goToPage(index);
  }

  // ─────────────────────────────────────────────────────────────────────
  // Page chrome — not specific to Nutrient. Layout + log rendering.
  // ─────────────────────────────────────────────────────────────────────

  Future<String>? _documentPath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentPath ??= CatalogDocuments.scientificPaper(context);
  }

  void _appendLog(String message) {
    if (!mounted) return;
    setState(() {
      _log.insert(0, message);
      if (_log.length > 100) _log.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_adapter == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Platform Adapter')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(BrandSpacing.xl),
            child: Text(
              'Platform Adapter examples run on Android, iOS, and Web.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<String>(
                future: _documentPath,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Failed: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildDocumentView(snapshot.data!);
                },
              ),
            ),
            const Divider(height: 1),
            SizedBox(
              height: 160,
              child: _log.isEmpty
                  ? const Center(
                      child: Text('Interact with the document to see events.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _log.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        child: Text(
                          _log[i],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
            ),
            if (_isReady)
              SafeArea(
                top: false,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Previous page',
                      onPressed: _currentPage > 0
                          ? () => _goToPage(_currentPage - 1)
                          : null,
                    ),
                    Expanded(
                      child: Center(
                        child: Text('${_currentPage + 1} / $_pageCount'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Next page',
                      onPressed: _currentPage < _pageCount - 1
                          ? () => _goToPage(_currentPage + 1)
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
