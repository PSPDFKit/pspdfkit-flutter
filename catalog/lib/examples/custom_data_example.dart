// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';

/// Custom Data round-trip example.
///
/// Annotations can carry an arbitrary `customData` dictionary — opaque
/// application metadata the SDK persists verbatim through InstantJSON. This
/// example proves that round-trip through the bindings annotation API:
///
/// 1. **Write** — `controller.document.annotations.addAnnotationJson(json)` adds
///    an ink scribble whose InstantJSON carries a `customData` object
///    (`source` / `tag` / `revision` / `nonce`).
/// 2. **Read back** — `getAnnotationsJson(page, 'all')` lists the page's
///    annotations with their data; we find the one we just wrote by matching
///    the unique `nonce` we embedded (the SDK assigns its own id on insert,
///    so we can't rely on the id we sent), and surface its `customData`
///    through the typed [AnnotationProperties.fromJson] →
///    [AnnotationProperties.customDataJson] model (the surface fixed in
///    HYB-951). Every key/value pair is rendered on a card.
///
/// The read-back is compared against what we wrote so the status line states
/// plainly whether the dictionary survived the round-trip on this platform.
///
/// **Note on persistence:** the round-trip is in-memory only — the example
/// doesn't call `document.save()`, so reopening the document starts fresh.
class CustomDataExamplePage extends StatefulWidget {
  const CustomDataExamplePage({super.key});

  @override
  State<CustomDataExamplePage> createState() => _CustomDataExamplePageState();
}

/// Marker written into every annotation's `customData.source` so the Clear
/// action can find (and only remove) annotations this example created.
const _kSource = 'nutrient-catalog';

class _CustomDataExamplePageState extends State<CustomDataExamplePage> {
  Future<String>? _documentPath;
  NutrientController? _controller;
  StreamSubscription<NutrientEvent>? _eventsSub;

  int _currentPage = 0;
  bool _isBusy = false;
  int _revision = 0;
  String? _lastAction;

  /// The `customData` map we last wrote, and the one we last read back —
  /// rendered side-by-side on the card so the round-trip is visible.
  Map<String, dynamic>? _written;
  Map<String, dynamic>? _readBack;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentPath ??= CatalogDocuments.annotations(context);
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    super.dispose();
  }

  Future<void> _onControllerReady(NutrientController controller) async {
    await _eventsSub?.cancel();
    if (!mounted) return;
    _eventsSub = controller.events.listen(_handleEvent);
    setState(() => _controller = controller);
  }

  void _handleEvent(NutrientEvent event) {
    if (!mounted) return;
    if (event case PageChangedEvent(:final pageIndex)) {
      if (pageIndex != _currentPage) {
        setState(() => _currentPage = pageIndex);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Writes an annotation carrying `customData`, then reads it back via the
  /// typed properties API and reports whether the dictionary survived.
  Future<void> _writeAndRead() async {
    final controller = controllerOrNull();
    if (controller == null) return;
    setState(() => _isBusy = true);
    try {
      final page = _currentPage;
      final nonce = DateTime.now().microsecondsSinceEpoch.toString();
      final customData = <String, dynamic>{
        'source': _kSource,
        'tag': 'demo',
        'revision': ++_revision,
        'nonce': nonce,
      };

      // 1. Write — add an ink scribble whose InstantJSON carries customData.
      await controller.document.annotations.addAnnotationJson(
        _inkAnnotationJson(
          page: page,
          name: 'catalog-customdata-$nonce',
          customData: customData,
        ),
      );

      // 2. Read back — getAnnotationsJson carries each annotation's data;
      //    find ours by the embedded nonce and surface its customData via
      //    the typed AnnotationProperties model.
      final readBack = await _readCustomDataByNonce(controller, page, nonce);

      _finish(
        written: customData,
        readBack: readBack,
        message: readBack == null
            ? 'Wrote rev $_revision, but could not read it back'
            : _verdict(customData, readBack),
      );
    } catch (error) {
      _setLastAction('Write & read failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Removes every annotation this example created (those whose
  /// `customData.source` is our marker), leaving the bundled ones alone.
  Future<void> _clearAdded() async {
    final controller = controllerOrNull();
    if (controller == null) return;
    setState(() => _isBusy = true);
    int removed = 0;
    try {
      final pageCount = await controller.document.getPageCount();
      for (var p = 0; p < pageCount; p++) {
        final json = await controller.document.annotations.getAnnotationsJson(
          p,
          'all',
        );
        for (final entry in _entries(json)) {
          final data = _decodeCustomData(_customDataOf(entry));
          if (data?['source'] != _kSource) continue;
          final id = _idOf(entry);
          if (id == null) continue;
          if (await controller.document.annotations.removeAnnotation(p, id)) {
            removed++;
          }
        }
      }
      setState(() {
        _written = null;
        _readBack = null;
      });
      _setLastAction(
        removed == 0 ? 'Nothing to clear' : 'Removed $removed annotation(s)',
      );
    } catch (error) {
      _setLastAction('Clear failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Round-trip helpers
  // ---------------------------------------------------------------------------

  NutrientController? controllerOrNull() {
    if (_isBusy) return null;
    return _controller;
  }

  /// Scans the page's annotations for the one carrying our [nonce] and
  /// returns its `customData`. Each entry is parsed through the typed
  /// [AnnotationProperties] model so the read goes through
  /// [AnnotationProperties.customDataJson] (the surface fixed in HYB-951).
  /// Matching on the opaque `customData.nonce` is platform-agnostic — unlike
  /// the `name`/`id` we sent, which the SDK may reassign on insert.
  Future<Map<String, dynamic>?> _readCustomDataByNonce(
    NutrientController controller,
    int page,
    String nonce,
  ) async {
    final json = await controller.document.annotations.getAnnotationsJson(
      page,
      'all',
    );
    for (final entry in _entries(json)) {
      final data = _decodeCustomData(
        AnnotationProperties.fromJson(entry).customDataJson,
      );
      if (data?['nonce'] == nonce) return data;
    }
    return null;
  }

  /// Compares the written and read-back dictionaries and produces a status
  /// line. A platform that drops or mangles `customData` shows up here.
  String _verdict(Map<String, dynamic> written, Map<String, dynamic>? read) {
    if (read == null || read.isEmpty) {
      return 'Round-trip failed — no customData read back';
    }
    return _flatMapsEqual(written, read)
        ? 'Round-trip OK · ${read.length} keys (tag=${read['tag']})'
        : 'Round-trip mismatch · wrote ${written.length}, read ${read.length}';
  }

  /// Flat key/value equality — `customData` here is a flat map of JSON
  /// primitives, so comparing each key's `toString()` sidesteps int-vs-num
  /// decoding differences across platforms without pulling in
  /// `package:collection`.
  bool _flatMapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (a[key].toString() != b[key].toString()) return false;
    }
    return true;
  }

  void _finish({
    required Map<String, dynamic> written,
    required Map<String, dynamic>? readBack,
    required String message,
  }) {
    if (!mounted) return;
    setState(() {
      _written = written;
      _readBack = readBack;
    });
    _setLastAction(message);
  }

  // ---------------------------------------------------------------------------
  // JSON shape helpers — getAnnotationsJson returns an array on Web and an
  // object with an `annotations` array on Android/iOS. customData lives on
  // each entry (native InstantJSON) or under an `annotation` wrapper (Web).
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> _entries(String json) {
    if (json.isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      final List items;
      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map && decoded['annotations'] is List) {
        items = decoded['annotations'] as List;
      } else {
        return const [];
      }
      return [
        for (final item in items)
          if (item is Map<String, dynamic>) item,
      ];
    } catch (_) {
      return const [];
    }
  }

  Object? _customDataOf(Map<String, dynamic> entry) {
    final inner =
        entry['annotation'] is Map ? entry['annotation'] as Map : entry;
    return inner['customData'] ?? inner['customDataJson'];
  }

  String? _idOf(Map<String, dynamic> entry) {
    final inner =
        entry['annotation'] is Map ? entry['annotation'] as Map : entry;
    return (inner['id'] ?? inner['name'] ?? inner['uuid']) as String?;
  }

  Map<String, dynamic>? _decodeCustomData(Object? raw) {
    if (raw == null) return null;
    Object? decoded = raw;
    if (raw is String) {
      if (raw.isEmpty) return null;
      try {
        decoded = jsonDecode(raw);
      } catch (_) {
        return null;
      }
    }
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  /// A small ink scribble in the upper-left of [page], carrying [customData].
  /// The bbox is in PDF coordinates (origin bottom-left).
  String _inkAnnotationJson({
    required int page,
    required String name,
    required Map<String, dynamic> customData,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return jsonEncode({
      'v': 1,
      'type': 'pspdfkit/ink',
      'id': name,
      'name': name,
      'pageIndex': page,
      'bbox': [60.0, 700.0, 80.0, 40.0],
      'lines': {
        'points': [
          [
            [60.0, 720.0],
            [90.0, 740.0],
            [120.0, 720.0],
            [140.0, 740.0],
          ],
        ],
        'intensities': [
          [1.0, 1.0, 1.0, 1.0],
        ],
      },
      'lineWidth': 3,
      'strokeColor': '#2492FB',
      'opacity': 1.0,
      'isDrawnNaturally': false,
      'creatorName': 'Nutrient Catalog',
      'createdAt': now,
      'updatedAt': now,
      'customData': customData,
    });
  }

  void _setLastAction(String message) {
    if (!mounted) return;
    setState(() => _lastAction = message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final canMutate = _controller != null && !_isBusy;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Custom Data'),
        actions: [
          IconButton(
            tooltip: 'Clear added',
            onPressed: canMutate ? _clearAdded : null,
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
        ],
      ),
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
        currentPage: _currentPage,
        lastAction: _lastAction,
        written: _written,
        readBack: _readBack,
        canMutate: canMutate,
        isBusy: _isBusy,
        onWriteAndRead: _writeAndRead,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom bar
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  final int currentPage;
  final String? lastAction;
  final Map<String, dynamic>? written;
  final Map<String, dynamic>? readBack;
  final bool canMutate;
  final bool isBusy;
  final VoidCallback onWriteAndRead;

  const _BottomBar({
    required this.currentPage,
    required this.lastAction,
    required this.written,
    required this.readBack,
    required this.canMutate,
    required this.isBusy,
    required this.onWriteAndRead,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (readBack != null) ...[
                _CustomDataCard(data: readBack!),
                const SizedBox(height: BrandSpacing.sm),
              ],
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _InfoRow(
                        currentPage: currentPage,
                        lastAction: lastAction,
                      ),
                    ),
                    const SizedBox(width: BrandSpacing.md),
                    FilledButton.icon(
                      onPressed: canMutate ? onWriteAndRead : null,
                      icon: isBusy
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.data_object_rounded, size: 18),
                      label: const Text('Write & read'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final int currentPage;
  final String? lastAction;

  const _InfoRow({required this.currentPage, required this.lastAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCell(label: 'Page', value: '${currentPage + 1}'),
        const SizedBox(width: BrandSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: BrandSpacing.xxs),
              Text(
                lastAction ?? 'Tap Write & read to round-trip customData',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: BrandColors.codeCoral,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: BrandSpacing.xxs),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: BrandColors.codeCoral,
          ),
        ),
      ],
    );
  }
}

/// Renders the round-tripped `customData` dictionary as a list of
/// `key: value` rows so the surviving payload is visible (and assertable).
class _CustomDataCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _CustomDataCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keys = data.keys.toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BrandSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BrandRadius.brMd,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'customData (read back)',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: BrandSpacing.xs),
          for (final key in keys)
            Padding(
              padding: const EdgeInsets.only(bottom: BrandSpacing.xxs),
              child: Text(
                '$key: ${data[key]}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
