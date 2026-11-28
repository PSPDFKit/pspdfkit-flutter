// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';
import '../utils/file_utils.dart';

/// Save As example.
///
/// Demonstrates writing the open document to a **new** file path with
/// `controller.document.save(outputPath: ...)` — the bindings equivalent of
/// the legacy "Save As" example — and then proving the copy landed by opening
/// it headlessly via [NutrientPlatformAdapter.openDocument] and reading its
/// page count back.
///
/// Unlike Manual Save (whose dirty-state transition is driven by canvas edits
/// Maestro can't reach), the whole happy-path here is a single Flutter-owned
/// button, so it's fully Maestro-/Playwright-driveable.
///
/// **Web:** "Save As" writes to a real file path, and the browser has no
/// writable file system ([FileUtils.getOutputPath] returns `null`), so the
/// action degrades to a clear "not available on web" status rather than
/// pretending to write a file.
class SaveAsExamplePage extends StatefulWidget {
  const SaveAsExamplePage({super.key});

  @override
  State<SaveAsExamplePage> createState() => _SaveAsExamplePageState();
}

class _SaveAsExamplePageState extends State<SaveAsExamplePage> {
  Future<String>? _documentPath;
  NutrientController? _controller;

  bool _isSaving = false;
  String _status = 'Ready';
  String? _savedPath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Annotations doc gives the viewer some content to copy.
    _documentPath ??= CatalogDocuments.annotations(context);
  }

  void _onControllerReady(NutrientController controller) {
    if (!mounted) return;
    setState(() => _controller = controller);
  }

  Future<void> _saveAs() async {
    final controller = _controller;
    if (controller == null || _isSaving) return;

    // Capture the messenger synchronously — it's used after awaits below.
    final messenger = ScaffoldMessenger.of(context);

    // No writable file system on web — be explicit rather than writing
    // nowhere and reporting success.
    final outputPath = await FileUtils.getOutputPath('save-as-copy.pdf');
    if (outputPath == null) {
      if (!mounted) return;
      setState(() => _status = 'Save As is not available on web');
      return;
    }

    setState(() {
      _isSaving = true;
      _status = 'Saving copy…';
    });
    try {
      final ok = await controller.document.save(outputPath: outputPath);
      if (!ok) {
        if (!mounted) return;
        setState(() => _status = 'Save failed: save() returned false');
        return;
      }

      // Prove the copy is a real, independent document: open it headlessly
      // and read its page count + on-disk size back.
      final copy = await Nutrient.openDocument(outputPath);
      final pageCount = await copy.getPageCount();
      final bytes = await File(outputPath).length();

      if (!mounted) return;
      setState(() {
        _savedPath = outputPath;
        _status = 'Saved copy · $pageCount pages · ${_formatBytes(bytes)}';
      });
      messenger.showSnackBar(
        SnackBar(content: Text('Saved copy to $outputPath')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Save failed: $error');
      messenger.showSnackBar(SnackBar(content: Text('Save As failed: $error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Save As')),
      // The status bar lives in the bottom slot so it stays Flutter-owned and
      // Maestro-reachable even after the native viewer takes a11y focus.
      bottomNavigationBar: SafeArea(
        top: false,
        child: _SaveAsBar(
          status: _status,
          savedPath: _savedPath,
          isSaving: _isSaving,
          onSaveAs: _controller != null && !_isSaving ? _saveAs : null,
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

String _formatBytes(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '$bytes B';
}

class _SaveAsBar extends StatelessWidget {
  final String status;
  final String? savedPath;
  final bool isSaving;
  final VoidCallback? onSaveAs;

  const _SaveAsBar({
    required this.status,
    required this.savedPath,
    required this.isSaving,
    required this.onSaveAs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            Text(
              'Status',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              status,
              style: theme.textTheme.titleSmall?.copyWith(
                color: BrandColors.codeCoral,
              ),
            ),
            if (savedPath != null) ...[
              const SizedBox(height: BrandSpacing.xxs),
              Text(
                savedPath!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: BrandSpacing.sm),
            FilledButton.icon(
              onPressed: onSaveAs,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_as_outlined),
              label: const Text('Save as copy'),
            ),
          ],
        ),
      ),
    );
  }
}
