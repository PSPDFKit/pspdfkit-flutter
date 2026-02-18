///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

import 'adapters.dart';

/// Platform Adapter Example
///
/// Demonstrates the adapter-as-controller pattern with responsive layout:
/// - **Narrow** (<600dp): bottom nav bar, overlay event log
/// - **Wide** (≥600dp): side panel with navigation + live event log
class PlatformAdapterExample extends StatefulWidget {
  final String documentPath;

  const PlatformAdapterExample({super.key, required this.documentPath});

  @override
  State<PlatformAdapterExample> createState() => _PlatformAdapterExampleState();
}

class _PlatformAdapterExampleState extends State<PlatformAdapterExample> {
  ExampleAdapterController? _controller;
  NutrientPlatformAdapter? _adapter;
  final List<_Event> _events = [];
  bool _showEventLog = false;
  final _pageInputController = TextEditingController();

  int _pageCount = 0;
  int _currentPage = 0;
  String _documentTitle = '';
  bool _isDocumentReady = false;

  @override
  void initState() {
    super.initState();
    _controller = createExampleAdapter(
      onStatusChanged: _handleStatusChanged,
      onDocumentInfo: _handleDocumentInfo,
    );
    _adapter = _controller as NutrientPlatformAdapter?;
  }

  @override
  void dispose() {
    _pageInputController.dispose();
    super.dispose();
  }

  void _handleStatusChanged(String status) {
    if (!mounted) return;
    setState(() {
      _events.insert(0, _Event.parse(status));
      if (_events.length > 100) _events.removeLast();
    });
  }

  void _handleDocumentInfo({
    int? pageCount,
    int? currentPage,
    String? title,
    bool? isReady,
  }) {
    if (!mounted) return;
    setState(() {
      if (pageCount != null) _pageCount = pageCount;
      if (currentPage != null) _currentPage = currentPage;
      if (title != null) _documentTitle = title;
      if (isReady != null) _isDocumentReady = isReady;
    });
  }

  Future<void> _goToPage(int index) async {
    if (_controller != null && index >= 0 && index < _pageCount) {
      await _controller!.setPageIndex(index);
    }
  }

  void _submitPageInput() {
    final text = _pageInputController.text.trim();
    final page = int.tryParse(text);
    if (page != null && page >= 1 && page <= _pageCount) {
      _goToPage(page - 1);
      _pageInputController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  String get _platformLabel {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      default:
        return 'Unknown';
    }
  }

  Color get _platformColor {
    if (kIsWeb) return Colors.deepPurple;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return Colors.green.shade700;
      case TargetPlatform.iOS:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData get _platformIcon {
    if (kIsWeb) return Icons.language;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return Icons.android;
      case TargetPlatform.iOS:
        return Icons.apple;
      default:
        return Icons.device_unknown;
    }
  }

  static const double _wideBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _wideBreakpoint;
          return isWide ? _buildWideLayout() : _buildNarrowLayout();
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  Narrow layout: full-width viewer + bottom bar + overlay
  // ──────────────────────────────────────────────────────────

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: Stack(
            children: [
              NutrientView(
                documentPath: widget.documentPath,
                adapter: _adapter,
              ),
              if (_showEventLog) _buildEventLogOverlay(),
            ],
          ),
        ),
        if (_isDocumentReady) _buildBottomBar(),
      ],
    );
  }

  Widget _buildAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
            Icon(_platformIcon, color: _platformColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isDocumentReady ? _documentTitle : 'Loading...',
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _platformLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _platformColor,
                        ),
                  ),
                ],
              ),
            ),
            _buildEventBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBadge() {
    return Badge(
      label: Text('${_events.length}'),
      isLabelVisible: _events.isNotEmpty,
      child: IconButton(
        icon: Icon(_showEventLog ? Icons.close : Icons.terminal),
        onPressed: () => setState(() => _showEventLog = !_showEventLog),
        tooltip: _showEventLog ? 'Hide Events' : 'Show Events',
      ),
    );
  }

  Widget _buildBottomBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              iconSize: 20,
              onPressed: _currentPage > 0 ? () => _goToPage(0) : null,
              tooltip: 'First',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              iconSize: 20,
              onPressed:
                  _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
              tooltip: 'Previous',
            ),
            Expanded(child: _buildPageIndicator()),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              iconSize: 20,
              onPressed: _currentPage < _pageCount - 1
                  ? () => _goToPage(_currentPage + 1)
                  : null,
              tooltip: 'Next',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              iconSize: 20,
              onPressed: _currentPage < _pageCount - 1
                  ? () => _goToPage(_pageCount - 1)
                  : null,
              tooltip: 'Last',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return GestureDetector(
      onTap: _showGoToPageDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _platformColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '${_currentPage + 1} / $_pageCount',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: _platformColor,
          ),
        ),
      ),
    );
  }

  void _showGoToPageDialog() {
    _pageInputController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: _pageInputController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '1 – $_pageCount',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            _submitPageInput();
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _submitPageInput();
              Navigator.pop(ctx);
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  Wide layout: viewer + side panel
  // ──────────────────────────────────────────────────────────

  Widget _buildWideLayout() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: NutrientView(
                  documentPath: widget.documentPath,
                  adapter: _adapter,
                ),
              ),
              Container(
                width: 280,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    left: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: _buildSidePanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidePanel() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      children: [
        // Navigation controls
        if (_isDocumentReady) ...[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton.outlined(
                      icon: const Icon(Icons.first_page, size: 18),
                      onPressed: _currentPage > 0 ? () => _goToPage(0) : null,
                      tooltip: 'First',
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    IconButton.outlined(
                      icon: const Icon(Icons.chevron_left, size: 18),
                      onPressed: _currentPage > 0
                          ? () => _goToPage(_currentPage - 1)
                          : null,
                      tooltip: 'Previous',
                      visualDensity: VisualDensity.compact,
                    ),
                    Expanded(child: _buildPageIndicator()),
                    IconButton.outlined(
                      icon: const Icon(Icons.chevron_right, size: 18),
                      onPressed: _currentPage < _pageCount - 1
                          ? () => _goToPage(_currentPage + 1)
                          : null,
                      tooltip: 'Next',
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    IconButton.outlined(
                      icon: const Icon(Icons.last_page, size: 18),
                      onPressed: _currentPage < _pageCount - 1
                          ? () => _goToPage(_pageCount - 1)
                          : null,
                      tooltip: 'Last',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _pageInputController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Go to page (1–$_pageCount)',
                      hintStyle: const TextStyle(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        onPressed: _submitPageInput,
                        tooltip: 'Go',
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    onSubmitted: (_) => _submitPageInput(),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
        ],
        // Event log header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.terminal,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'Events',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (_events.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _events.clear()),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: colorScheme.outlineVariant),
        // Event list
        Expanded(
          child: _events.isEmpty
              ? Center(
                  child: Text(
                    'Interact with the\ndocument to see events',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _events.length,
                  itemBuilder: (_, i) => _buildEventTile(_events[i]),
                ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  //  Event log overlay (narrow mode)
  // ──────────────────────────────────────────────────────────

  Widget _buildEventLogOverlay() {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 200,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Icon(Icons.terminal,
                        size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('Events',
                        style: Theme.of(context).textTheme.labelLarge),
                    const Spacer(),
                    if (_events.isNotEmpty)
                      InkWell(
                        onTap: () => setState(() => _events.clear()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          child: Text('Clear',
                              style: TextStyle(
                                  fontSize: 12, color: _platformColor)),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _events.isEmpty
                    ? Center(
                        child: Text('No events yet',
                            style: Theme.of(context).textTheme.bodySmall),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: _events.length,
                        itemBuilder: (_, i) => _buildEventTile(_events[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventTile(_Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(event.icon, size: 12, color: event.color),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              event.message,
              style: TextStyle(fontSize: 11, color: event.color),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
//  Lightweight event model
// ──────────────────────────────────────────────────────────

class _Event {
  final String message;
  final IconData icon;
  final Color color;

  const _Event(this.message, this.icon, this.color);

  factory _Event.parse(String raw) {
    if (raw.contains('[Event]')) {
      return _Event(raw, Icons.bolt, Colors.orange.shade700);
    }
    if (raw.contains('[UI]')) {
      return _Event(raw, Icons.palette, Colors.teal);
    }
    return _Event(raw, Icons.settings, Colors.blueGrey);
  }
}
