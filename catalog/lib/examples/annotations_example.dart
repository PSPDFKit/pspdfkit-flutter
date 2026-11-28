// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';

/// Annotations + Instant JSON + XFDF round-trip example.
///
/// Drives the full annotation surface from a live viewer:
///
/// 1. [NutrientDocumentView] hosts the bundled `annotations.pdf` so the
///    user can see imported / exported annotations side-by-side with the
///    page content.
/// 2. `controller.document.annotations.getAnnotationsJson(0, "all")`
///    populates the info-bar's annotation count on load and after every
///    mutation. `controller.events` keeps it fresh as the user (or our
///    own buttons) creates / updates / deletes annotations.
/// 3. The action row exercises:
///    - **Import Instant JSON** → `document.applyInstantJson(bundledJson)`
///    - **Export Instant JSON** → `document.exportInstantJson()`
///    - **Import XFDF** → `document.annotations.importXfdf(bundledXfdf)`
///    - **Export XFDF** → `document.annotations.exportXfdf()`
///    - **Clear all** → `document.annotations.getAnnotationsJson` →
///      `removeAnnotation` per id, so we exercise the bindings remove path
///      end-to-end.
///
/// **Note on persistence:** the round-trip is in-memory only. The catalog
/// doesn't call `document.save()` because we want each press of Import to
/// reset to a known baseline (Clear All → Import). Production code would
/// call `save()` after each mutation; here we deliberately keep the
/// in-memory model.
class AnnotationsExamplePage extends StatefulWidget {
  const AnnotationsExamplePage({super.key});

  @override
  State<AnnotationsExamplePage> createState() => _AnnotationsExamplePageState();
}

/// Bundled InstantJSON asset path — six richly-typed annotations on page 0
/// (Ink, Square, Highlight, Note, …) authored by the legacy example.
const _instantJsonAsset = 'assets/documents/instant-document.json';

/// Bundled XFDF asset path — a smaller XFDF payload, distinct from the
/// InstantJSON one so the round-trips are visibly different.
const _xfdfAsset = 'assets/documents/document.xfdf';

/// A tiny 64×64 PNG (a Nutrient-orange disc), Base64-encoded. Used to
/// demonstrate adding an image annotation whose binary attachment is carried
/// through the typed `addAnnotation()` write path.
const _sampleImagePngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAuUlEQVR42u3bwQ3DIAxAUfbpMtl/'
    'jt7bGUICtvGzlAH+k3IBM4YxxgTO9/r8WkTOfi2jS2OsCC8BsSM8LUREfAqEyPBwiEzx2xEyxm9'
    'DyBy/HKFC/DKESvFLEFoDVIx/DaFy/CsIrQFOiH+E0BrgpPgpBACdAU6Mv4UAAAAAAAC6ApwcD8E'
    'vAAAAAAAAnAcAAOBUGICbIQBuh+0HALAjZEvMnqBNUbvCtsW9F/BixJshr8ZicYYxJmr+AFRJYMA'
    'KAloAAAAASUVORK5CYII=';

class _AnnotationsExamplePageState extends State<AnnotationsExamplePage> {
  Future<String>? _documentPath;
  NutrientController? _controller;
  StreamSubscription<NutrientEvent>? _eventsSub;

  int _currentPage = 0;
  int _annotationCountAllPages = 0;
  bool _isBusy = false;
  // Cycles the "Add sample annotation" action through a variety of typed
  // annotation types so repeated taps seed a wider sample space.
  int _sampleIndex = 0;
  // Guards against overlapping count refreshes: each refresh iterates
  // every page, so a burst of annotation events (or a refresh racing an
  // action's own final refresh) would otherwise stack up redundant
  // round-trips. Drop new requests while one is in flight.
  bool _isRefreshingCount = false;
  String? _lastAction;

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
    // iOS / Web have the document ready here; Android races the document
    // load (~400 ms after `onControllerReady`), so we also retry from the
    // `DocumentLoadedEvent` branch below.
    _refreshAnnotationCount();
  }

  void _handleEvent(NutrientEvent event) {
    if (!mounted) return;
    switch (event) {
      case DocumentLoadedEvent():
        _refreshAnnotationCount();
      case PageChangedEvent(:final pageIndex):
        if (pageIndex != _currentPage) {
          setState(() => _currentPage = pageIndex);
        }
      // Any of these change the on-page annotation set — re-count so the
      // info bar stays accurate even when the user adds an annotation
      // through the toolbar (not via our buttons).
      //
      // Skip while a button-initiated action is in flight: bulk Import /
      // Clear fire one of these events *per annotation*, which would
      // otherwise kick off N concurrent full-document recounts (each
      // iterating every page). Every action handler runs an explicit
      // `_refreshAnnotationCount()` at the end, so the count is still
      // correct once the action settles — and `_refreshAnnotationCount`
      // itself drops re-entrant calls (see `_isRefreshingCount`).
      case AnnotationCreatedEvent():
      case AnnotationUpdatedEvent():
      case AnnotationDeletedEvent():
        if (_isBusy) return;
        _refreshAnnotationCount();
      default:
        // Don't act on other events.
        break;
    }
  }

  /// Counts annotations across the whole document. For the info-bar we
  /// want a single number, not a per-page list. Uses the typed
  /// `getAnnotations(page)` which returns `List<Annotation>` — it parses the
  /// per-platform Instant JSON (bare array vs. envelope) and skips
  /// unknown/malformed entries internally, so the example doesn't hand-roll
  /// JSON parsing. The document only has a handful of pages so the per-page
  /// cost is negligible.
  Future<void> _refreshAnnotationCount() async {
    final controller = _controller;
    if (controller == null || _isRefreshingCount) return;
    _isRefreshingCount = true;
    try {
      int total = 0;
      int pageCount;
      try {
        pageCount = await controller.document.getPageCount();
      } catch (_) {
        return; // Document not ready yet — retry on DocumentLoadedEvent.
      }
      for (int p = 0; p < pageCount; p++) {
        try {
          final List<Annotation> annotations =
              await controller.document.annotations.getAnnotations(p);
          total += annotations.length;
        } catch (_) {
          // Ignore per-page failures; the count is informational.
        }
      }
      if (!mounted) return;
      setState(() => _annotationCountAllPages = total);
    } finally {
      _isRefreshingCount = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Adds a single bright-blue ink annotation to the current page via the
  /// per-annotation [AnnotationManagerInterface.addAnnotation] path —
  /// distinct from the whole-document Import flows. Useful to show the
  /// finer-grained surface and to seed annotations for Export Instant JSON
  /// / Export XFDF when the document starts empty.
  Future<void> _addSampleAnnotation() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      // Cycle through a variety of TYPED annotations on successive taps so the
      // sample space is wide. Each is a strongly-typed model handed to the
      // typed `addAnnotation()` — no hand-built Instant JSON. Compare
      // `custom_data_example`, which uses the raw-JSON `addAnnotationJson()`
      // escape hatch to embed arbitrary `customData`.
      final id = 'catalog-${DateTime.now().microsecondsSinceEpoch}';
      final page = _currentPage;
      final (annotation, label) = _sampleAnnotation(_sampleIndex, id, page);
      _sampleIndex++;
      await controller.document.annotations.addAnnotation(annotation);
      _setLastAction('Added $label on page ${page + 1}');
      await _refreshAnnotationCount();
    } catch (error) {
      _setLastAction('Add failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Builds the [index]-th sample annotation (cycling through the supported
  /// types), returning it with a short human label. Demonstrates constructing
  /// several typed annotation models directly. Coordinates are PDF-space
  /// (origin bottom-left).
  (Annotation, String) _sampleAnnotation(int index, String id, int page) {
    switch (index % 5) {
      case 0:
        return (
          InkAnnotation(
            id: id,
            name: id,
            pageIndex: page,
            bbox: const [60.0, 700.0, 80.0, 40.0],
            lines: InkLines(
              points: const [
                [
                  [60.0, 720.0],
                  [90.0, 740.0],
                  [120.0, 720.0],
                  [140.0, 740.0],
                ],
              ],
              intensities: const [
                [1.0, 1.0, 1.0, 1.0],
              ],
            ),
            lineWidth: 3,
            strokeColor: const Color(0xFF2492FB),
            creatorName: 'Nutrient Catalog',
          ),
          'an ink scribble',
        );
      case 1:
        return (
          NoteAnnotation(
            id: id,
            pageIndex: page,
            bbox: const [160.0, 700.0, 32.0, 32.0],
            text: TextContent(format: TextFormat.plain, value: 'Catalog note'),
            icon: NoteIcon.comment,
            color: const Color(0xFFFFC107),
          ),
          'a note',
        );
      case 2:
        return (
          HighlightAnnotation(
            id: id,
            pageIndex: page,
            bbox: const [60.0, 640.0, 200.0, 20.0],
            rects: const [
              [60.0, 640.0, 200.0, 20.0],
            ],
            color: const Color(0xFFFFF176),
          ),
          'a highlight',
        );
      case 3:
        return (
          FreeTextAnnotation(
            id: id,
            pageIndex: page,
            bbox: const [60.0, 580.0, 220.0, 40.0],
            text: TextContent(format: TextFormat.plain, value: 'Free text'),
            fontSize: 16,
            fontColor: const Color(0xFFF4502B),
          ),
          'free text',
        );
      default:
        return (
          SquareAnnotation(
            id: id,
            pageIndex: page,
            bbox: const [60.0, 500.0, 120.0, 60.0],
            strokeColor: const Color(0xFF2E7D32),
            strokeWidth: 2,
            fillColor: const Color(0x332E7D32),
          ),
          'a rectangle',
        );
    }
  }

  /// Adds an IMAGE annotation whose binary lives in an [AnnotationAttachment].
  /// The typed `addAnnotation()` forwards the Base64 bytes + `contentType` to
  /// the platform (Android/iOS/Web) so the image actually renders — this is the
  /// attachment write path.
  Future<void> _addImageAnnotation() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      final id = 'catalog-image-${DateTime.now().microsecondsSinceEpoch}';
      final image = ImageAnnotation(
        id: id,
        name: id,
        pageIndex: _currentPage,
        bbox: const [60.0, 420.0, 64.0, 64.0],
        contentType: 'image/png',
        imageAttachmentId: id,
        attachment: const AnnotationAttachment(
          id: 'catalog-image',
          binary: _sampleImagePngBase64,
          contentType: 'image/png',
        ),
        creatorName: 'Nutrient Catalog',
      );
      await controller.document.annotations.addAnnotation(image);
      _setLastAction('Added an image annotation on page ${_currentPage + 1}');
      await _refreshAnnotationCount();
    } catch (error) {
      _setLastAction('Add image failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _importInstantJson() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      final json = await rootBundle.loadString(_instantJsonAsset);
      final ok = await controller.document.applyInstantJson(json);
      _setLastAction(
        ok ? 'Imported Instant JSON' : 'Import returned false',
      );
      await _refreshAnnotationCount();
    } catch (error) {
      _setLastAction('Import Instant JSON failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _exportInstantJson() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      final json = await controller.document.exportInstantJson();
      final length = json?.length ?? 0;
      _setLastAction(
        json == null
            ? 'Export returned null'
            : 'Exported Instant JSON ($length chars)',
      );
    } catch (error) {
      _setLastAction('Export Instant JSON failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _importXfdf() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      final xfdf = await rootBundle.loadString(_xfdfAsset);
      final ok = await controller.document.annotations.importXfdf(xfdf);
      _setLastAction(ok ? 'Imported XFDF' : 'Import returned false');
      await _refreshAnnotationCount();
    } catch (error) {
      _setLastAction('Import XFDF failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _exportXfdf() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      final xfdf = await controller.document.annotations.exportXfdf();
      _setLastAction('Exported XFDF (${xfdf.length} chars)');
    } catch (error) {
      _setLastAction('Export XFDF failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Removes every annotation on every page by iterating the JSON, parsing
  /// each entry's id, and calling `removeAnnotation(pageIndex, id)`.
  /// Exercises the bindings remove path end-to-end without going through
  /// the platform-specific `processAnnotations` shortcut.
  Future<void> _clearAll() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    int removed = 0;
    // Track per-annotation removal failures so we don't report success
    // while annotations remain in the document. We still attempt every
    // sibling (one bad id shouldn't abort the sweep), but the final
    // status reflects how many failed.
    int failed = 0;
    try {
      final pageCount = await controller.document.getPageCount();
      for (int p = 0; p < pageCount; p++) {
        final json = await controller.document.annotations.getAnnotationsJson(
          p,
          'all',
        );
        final ids = _annotationIdsFromJson(json);
        for (final id in ids) {
          try {
            final ok = await controller.document.annotations.removeAnnotation(
              p,
              id,
            );
            if (ok) {
              removed++;
            } else {
              // The bindings returned false (annotation not found / not
              // removable) — count it as a failure rather than a no-op.
              failed++;
            }
          } catch (_) {
            // Keep sweeping siblings, but record the failure.
            failed++;
          }
        }
      }
      _setLastAction(
        failed == 0
            ? 'Removed $removed annotations'
            : 'Removed $removed, $failed failed — some annotations remain',
      );
      await _refreshAnnotationCount();
    } catch (error) {
      _setLastAction('Clear all failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  List<String> _annotationIdsFromJson(String json) {
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
          if (item is Map && item['id'] is String) item['id'] as String,
      ];
    } catch (_) {
      return const [];
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
  // Actions sheet
  // ---------------------------------------------------------------------------

  /// Opens a modal bottom sheet listing all five actions. We use a sheet
  /// (rather than stacking buttons in the bottom bar) because the action
  /// list grows quickly — even at five entries the bar got cramped and
  /// noisy. The sheet keeps the viewer maximised, lists each action as a
  /// row with a clear icon + label, and dismisses on tap.
  Future<void> _showActionsSheet() async {
    if (!mounted) return;
    final controller = _controller;
    if (controller == null) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      // Six rows + header push past the default sheet height on phone
      // viewports; isScrollControlled lets the sheet expand to fit while
      // still respecting the user's drag.
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: BrandSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      BrandSpacing.lg,
                      0,
                      BrandSpacing.lg,
                      BrandSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Annotation actions',
                          style: Theme.of(sheetContext).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          '$_annotationCountAllPages on document',
                          style: Theme.of(sheetContext)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  sheetContext,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  _ActionRow(
                    icon: Icons.add_circle_outline,
                    label: 'Add sample annotation',
                    description:
                        'Cycles through typed ink / note / highlight / free text / '
                        'rectangle annotations via addAnnotation().',
                    enabled: !_isBusy,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _addSampleAnnotation();
                    },
                  ),
                  const Divider(height: 1),
                  _ActionRow(
                    icon: Icons.image_outlined,
                    label: 'Add image (with attachment)',
                    description:
                        'Adds an ImageAnnotation whose PNG bytes ride along as an '
                        'AnnotationAttachment through addAnnotation().',
                    enabled: !_isBusy,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _addImageAnnotation();
                    },
                  ),
                  const Divider(height: 1),
                  _ActionRow(
                    icon: Icons.download_outlined,
                    label: 'Import Instant JSON',
                    description: 'Apply the bundled Instant JSON payload.',
                    enabled: !_isBusy,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _importInstantJson();
                    },
                  ),
                  _ActionRow(
                    icon: Icons.upload_outlined,
                    label: 'Export Instant JSON',
                    description:
                        'Serialize the current annotations to Instant JSON.',
                    enabled: !_isBusy,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _exportInstantJson();
                    },
                  ),
                  const Divider(height: 1),
                  _ActionRow(
                    icon: Icons.file_download_outlined,
                    label: 'Import XFDF',
                    description: 'Apply the bundled XFDF payload.',
                    enabled: !_isBusy,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _importXfdf();
                    },
                  ),
                  _ActionRow(
                    icon: Icons.file_upload_outlined,
                    label: 'Export XFDF',
                    description: 'Serialize the current annotations to XFDF.',
                    enabled: !_isBusy,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _exportXfdf();
                    },
                  ),
                  const Divider(height: 1),
                  _ActionRow(
                    icon: Icons.cleaning_services_outlined,
                    label: 'Clear all',
                    description:
                        'Remove every annotation on every page via removeAnnotation().',
                    destructive: true,
                    enabled: !_isBusy,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _clearAll();
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
    final canMutate = _controller != null && !_isBusy;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Annotations')),
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
        annotationCount: _annotationCountAllPages,
        lastAction: _lastAction,
        canMutate: canMutate,
        isBusy: _isBusy,
        onOpenActions: _showActionsSheet,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom bar
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  final int currentPage;
  final int annotationCount;
  final String? lastAction;
  final bool canMutate;
  final bool isBusy;
  final VoidCallback onOpenActions;

  const _BottomBar({
    required this.currentPage,
    required this.annotationCount,
    required this.lastAction,
    required this.canMutate,
    required this.isBusy,
    required this.onOpenActions,
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
          // Wrap in IntrinsicHeight: `_InfoRow` contains a nested Row with
          // an `Expanded` Column, which inside a parent Row tries to
          // expand to infinite height. Without an intrinsic height the
          // bottom bar swells to fill the viewport (regression seen
          // during web verification of the bottom-sheet refactor).
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _InfoRow(
                    currentPage: currentPage,
                    annotationCount: annotationCount,
                    lastAction: lastAction,
                  ),
                ),
                const SizedBox(width: BrandSpacing.md),
                FilledButton.icon(
                  onPressed: canMutate ? onOpenActions : null,
                  icon: isBusy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.expand_less_rounded, size: 18),
                  label: const Text('Actions'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final int currentPage;
  final int annotationCount;
  final String? lastAction;

  const _InfoRow({
    required this.currentPage,
    required this.annotationCount,
    required this.lastAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCell(label: 'Page', value: '${currentPage + 1}'),
        const SizedBox(width: BrandSpacing.md),
        _InfoCell(label: 'Annotations', value: '$annotationCount'),
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
                lastAction ?? '—',
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

/// One row in the actions bottom sheet — leading icon, two-line title /
/// description, tap callback. Destructive rows tint the icon + title to
/// the theme's error color so Clear stands apart from the round-trip
/// operations above it.
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool enabled;
  final bool destructive;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.enabled,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        destructive ? theme.colorScheme.error : theme.colorScheme.primary;
    final disabledColor = theme.colorScheme.onSurface.withValues(alpha: 0.38);
    return ListTile(
      enabled: enabled,
      leading: Icon(icon, color: enabled ? accent : disabledColor),
      title: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: enabled
              ? (destructive ? accent : theme.colorScheme.onSurface)
              : disabledColor,
        ),
      ),
      subtitle: Text(
        description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: enabled ? theme.colorScheme.onSurfaceVariant : disabledColor,
        ),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}
