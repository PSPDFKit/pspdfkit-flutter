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
import '../utils/file_utils.dart';

/// Manual Save + Dirty State example.
///
/// Demonstrates the autosave-off workflow on the bindings surface:
///
/// 1. [NutrientDocumentView] opens the document with
///    `NutrientViewConfiguration(disableAutosave: true)`, so edits are *not*
///    persisted until the user explicitly saves.
/// 2. Annotation create / update / delete events on `controller.events` flip
///    a `_isDirty` flag (and the info bar + Save button react to it).
/// 3. A `PopScope` guards the back gesture while dirty — popping is blocked
///    and a discard / save confirmation dialog is shown instead.
/// 4. The Save button calls `controller.document.save()`. The flag is cleared
///    when the resulting [DocumentSavedEvent] arrives — not optimistically on
///    the button tap — so the UI reflects the real persisted state.
///
/// **Why clear on the event, not the await?** `save()` returning `true` tells
/// us the call succeeded, but a `DocumentSavedEvent` is the platform's own
/// signal that the write landed. Keying the dirty flag off the event keeps the
/// example honest about what "saved" means and mirrors how a production app
/// would reconcile its own state with the SDK.
class ManualSaveExamplePage extends StatefulWidget {
  const ManualSaveExamplePage({super.key});

  @override
  State<ManualSaveExamplePage> createState() => _ManualSaveExamplePageState();
}

class _ManualSaveExamplePageState extends State<ManualSaveExamplePage> {
  Future<String>? _documentPath;
  NutrientController? _controller;
  StreamSubscription<NutrientEvent>? _eventsSub;

  bool _isDirty = false;
  bool _isSaving = false;
  String? _lastError;
  int _editCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Annotations doc gives the user something to edit immediately.
    //
    // Manual Save is the one example where persistence across opens is the
    // whole point, so we extract a *stable working copy* rather than the
    // shared `CatalogDocuments.annotations(context)` path. That helper
    // overwrites the temp file with the pristine asset on every open
    // (`shouldOverwrite: true`) — fine for read-only examples, but here it
    // would wipe a saved annotation before the viewer reopens it. With
    // `shouldOverwrite: false` and a dedicated prefix, the first open seeds
    // the file and `controller.document.save()` writes land for good; later
    // opens reuse the saved copy. (No-op on web — `extractAsset` returns the
    // asset path unchanged there and the Web SDK keeps edits in-session.)
    _documentPath ??= FileUtils.extractAsset(
      context,
      CatalogDocuments.annotations.assetPath,
      shouldOverwrite: false,
      prefix: 'manual-save/',
    );
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
    // listener and double-count every edit.
    await _eventsSub?.cancel();
    _eventsSub = controller.events.listen(_handleEvent);
  }

  void _handleEvent(NutrientEvent event) {
    switch (event) {
      // Any annotation mutation means the document diverged from disk.
      case AnnotationCreatedEvent():
      case AnnotationUpdatedEvent():
      case AnnotationDeletedEvent():
        if (!mounted) return;
        setState(() {
          _isDirty = true;
          _editCount++;
        });
      // The platform confirmed the write landed — the document now matches
      // disk again.
      case DocumentSavedEvent():
        if (!mounted) return;
        setState(() {
          _isDirty = false;
          _lastError = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Document saved')));
      default:
        break;
    }
  }

  Future<void> _save() async {
    final controller = _controller;
    if (controller == null || _isSaving) return;
    setState(() {
      _isSaving = true;
      _lastError = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await controller.document.save();
      if (!mounted) return;
      // On platforms that don't emit a DocumentSavedEvent, fall back to the
      // boolean return so the flag still clears.
      if (ok) {
        setState(() => _isDirty = false);
      } else {
        setState(() => _lastError = 'save() returned false');
        messenger.showSnackBar(
          const SnackBar(content: Text('Save failed: save() returned false')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _lastError = error.toString());
      messenger.showSnackBar(SnackBar(content: Text('Save failed: $error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Back-press handler — only reached while `_isDirty` blocks the auto-pop.
  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
    final navigator = Navigator.of(context);
    final action = await showDialog<_DiscardAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text(
          'You have unsaved annotation edits. Save them before leaving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_DiscardAction.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_DiscardAction.discard),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_DiscardAction.save),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _DiscardAction.save:
        await _save();
        // Only leave if the save actually cleared the dirty state.
        if (mounted && !_isDirty) navigator.pop();
      case _DiscardAction.discard:
        navigator.pop();
      case _DiscardAction.cancel:
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _controller != null && _isDirty && !_isSaving;
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Manual Save')),
        // The info bar lives in the bottom slot rather than the body so it
        // stays Flutter-owned and Maestro-reachable even after the embedded
        // native viewer takes a11y focus over the body area.
        bottomNavigationBar: SafeArea(
          top: false,
          child: _SaveBar(
            isDirty: _isDirty,
            isSaving: _isSaving,
            editCount: _editCount,
            lastError: _lastError,
            onSave: canSave ? _save : null,
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
              configuration: const NutrientViewConfiguration(
                disableAutosave: true,
              ),
              onControllerReady: _onControllerReady,
            );
          },
        ),
      ),
    );
  }
}

enum _DiscardAction { save, discard, cancel }

class _SaveBar extends StatelessWidget {
  final bool isDirty;
  final bool isSaving;
  final int editCount;
  final String? lastError;
  final VoidCallback? onSave;

  const _SaveBar({
    required this.isDirty,
    required this.isSaving,
    required this.editCount,
    required this.lastError,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = lastError != null
        ? 'Save failed'
        : isDirty
            ? 'Unsaved changes'
            : 'No changes';
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
                _StatusCell(label: 'Status', value: statusLabel),
                const SizedBox(width: BrandSpacing.lg),
                _StatusCell(label: 'Edits', value: '$editCount'),
                const SizedBox(width: BrandSpacing.lg),
                Expanded(
                  child: _StatusCell(label: 'Autosave', value: 'disabled'),
                ),
              ],
            ),
            const SizedBox(height: BrandSpacing.sm),
            FilledButton.icon(
              onPressed: onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(isDirty ? Icons.save : Icons.save_outlined),
              label: const Text('Save document'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  final String label;
  final String value;

  const _StatusCell({required this.label, required this.value});

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
