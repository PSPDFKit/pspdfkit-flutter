// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';
import '../utils/file_utils.dart';

/// Semantic label surfaced once the headless operations complete successfully.
const String headlessExampleReadyLabel = 'headless_example_ready';

/// Headless document example: open a PDF without a viewer, read its metadata,
/// and export it — all via [NutrientPlatformAdapter.openDocument].
///
/// This example demonstrates the adapter-based headless API introduced in
/// HYB-956. No [NutrientDocumentView] is rendered; the document is opened,
/// inspected, and closed entirely in Dart code.
///
/// Platform implementations of [NutrientPlatformAdapter.openDocument] are
/// pending (HYB-961 Android / HYB-965 iOS). Until then, the page shows an
/// "implementation pending" banner instead of crashing.
class HeadlessDocumentExamplePage extends StatefulWidget {
  const HeadlessDocumentExamplePage({super.key});

  @override
  State<HeadlessDocumentExamplePage> createState() =>
      _HeadlessDocumentExamplePageState();
}

class _HeadlessDocumentExamplePageState
    extends State<HeadlessDocumentExamplePage> {
  _PageState _state = const _Idle();

  Future<void> _run() async {
    setState(() => _state = const _Loading());

    // Every setState below an `await` is guarded with `if (!mounted) return;`
    // so backing out of the example mid-run doesn't crash the catalog (and
    // doesn't model a bad pattern for users who copy this file as a
    // reference).
    try {
      final path = await CatalogDocuments.annotations(context);
      if (!mounted) return;

      // Headless open via the platform default adapter — no viewer, no global
      // adapter registration needed.
      final doc = await Nutrient.openDocument(path);
      try {
        final pageCount = await doc.getPageCount();
        final annotationsJson = await doc.annotations.getAnnotationsJson(
          0,
          'all',
        );
        final bookmarks = await doc.bookmarks.getBookmarks();
        final outputPath = await FileUtils.getOutputPath('headless_export.pdf');
        final saved =
            outputPath != null ? await doc.save(outputPath: outputPath) : false;

        if (!mounted) return;
        setState(
          () => _state = _Done(
            pageCount: pageCount,
            annotationsJson: annotationsJson,
            bookmarkCount: bookmarks.length,
            outputPath: outputPath,
            saved: saved,
          ),
        );
      } finally {
        await doc.close();
      }
    } on UnimplementedError catch (e) {
      if (!mounted) return;
      setState(() => _state = _Pending(e.message ?? e.toString()));
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = _Error(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Headless Document')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(BrandSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DescriptionCard(),
              const SizedBox(height: BrandSpacing.lg),
              FilledButton.icon(
                onPressed: _state is _Loading ? null : _run,
                icon: _state is _Loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(_state is _Loading ? 'Running…' : 'Run'),
              ),
              const SizedBox(height: BrandSpacing.xl),
              Expanded(child: _StateView(state: _state)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Description card
// ---------------------------------------------------------------------------

class _DescriptionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BrandSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: BrandColors.codeCoral.withValues(alpha: 0.12),
                    borderRadius: BrandRadius.brMd,
                  ),
                  child: const Icon(
                    Icons.code_rounded,
                    size: 18,
                    color: BrandColors.codeCoral,
                  ),
                ),
                const SizedBox(width: BrandSpacing.md),
                Text('API used', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: BrandSpacing.md),
            _CodeLine('final doc = await adapter.openDocument(path);'),
            _CodeLine('final count = await doc.getPageCount();'),
            _CodeLine(
              'final json  = await doc.annotations.getAnnotationsJson(0, "all");',
            ),
            _CodeLine('final marks = await doc.bookmarks.getBookmarks();'),
            _CodeLine('await doc.save(outputPath: outPath);'),
            _CodeLine('await doc.close();'),
          ],
        ),
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  final String code;
  const _CodeLine(this.code);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: BrandSpacing.xs),
      child: Text(
        code,
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          color: BrandColors.codeCoral,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// State views
// ---------------------------------------------------------------------------

class _StateView extends StatelessWidget {
  final _PageState state;
  const _StateView({required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      _Idle() => _EmptyState(),
      _Loading() => const Center(child: CircularProgressIndicator()),
      _Pending(:final message) => _PendingBanner(message),
      _Error(:final message) => _ErrorBanner(message),
      _Done() => _ResultsView(state: state as _Done),
    };
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.description_outlined,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: BrandSpacing.md),
          Text(
            'Tap Run to open the annotations.pdf headlessly',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingBanner extends StatelessWidget {
  final String message;
  const _PendingBanner(this.message);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(BrandSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: BrandSpacing.sm),
                Text(
                  'Platform implementation pending',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: BrandSpacing.sm),
            Text(
              'openDocument() is defined in NutrientPlatformAdapter but the '
              'concrete Android / iOS implementations are tracked in '
              'HYB-961 and HYB-965.\n\n$message',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(BrandSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: BrandSpacing.sm),
                Text(
                  'Error',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: BrandSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  final _Done state;
  const _ResultsView({required this.state});

  @override
  Widget build(BuildContext context) {
    final annotationCount = _countAnnotations(state.annotationsJson);
    return Semantics(
      label: headlessExampleReadyLabel,
      child: ListView(
        children: [
          _ResultRow(
            icon: Icons.auto_stories_outlined,
            label: 'Page count',
            value: '${state.pageCount}',
          ),
          _ResultRow(
            icon: Icons.edit_outlined,
            label: 'Annotations on page 0',
            value: '$annotationCount',
          ),
          _ResultRow(
            icon: Icons.bookmark_outline,
            label: 'Bookmarks',
            value: '${state.bookmarkCount}',
          ),
          _ResultRow(
            icon: state.saved ? Icons.check_circle_outline : Icons.info_outline,
            label: 'Saved',
            value: state.saved
                ? (state.outputPath ?? 'in-place')
                : 'skipped (web)',
          ),
        ],
      ),
    );
  }

  int _countAnnotations(String json) {
    // Quick count: each annotation object has a "type" key.
    return 'type'.allMatches(json).length;
  }
}

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ResultRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: BrandSpacing.sm),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(BrandSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, color: BrandColors.codeCoral, size: 20),
              ),
              const SizedBox(width: BrandSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: BrandSpacing.xxs),
                    Text(
                      value,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: BrandColors.codeCoral,
                      ),
                      softWrap: true,
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

// ---------------------------------------------------------------------------
// Page state ADT
// ---------------------------------------------------------------------------

sealed class _PageState {
  const _PageState();
}

class _Idle extends _PageState {
  const _Idle();
}

class _Loading extends _PageState {
  const _Loading();
}

class _Pending extends _PageState {
  final String message;
  const _Pending(this.message);
}

class _Error extends _PageState {
  final String message;
  const _Error(this.message);
}

class _Done extends _PageState {
  final int pageCount;
  final String annotationsJson;
  final int bookmarkCount;
  final String? outputPath;
  final bool saved;

  const _Done({
    required this.pageCount,
    required this.annotationsJson,
    required this.bookmarkCount,
    required this.outputPath,
    required this.saved,
  });
}
