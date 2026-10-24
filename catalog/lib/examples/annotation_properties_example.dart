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

/// Annotation Properties round-trip example.
///
/// 1. [NutrientDocumentView] hosts the bundled `annotations.pdf`.
/// 2. `controller.events` exposes typed [AnnotationSelectedEvent]s when
///    the user taps an annotation. We parse the JSON for `id` and
///    `pageIndex` and immediately fetch typed properties via
///    `controller.document.annotations.getAnnotationProperties(...)`.
/// 3. The editor (modal bottom sheet) lets the user adjust the three
///    universally-supported properties — stroke colour, fill colour,
///    opacity, line width — and a free-text contents field. Tapping
///    Save calls `saveAnnotationProperties(...)` with only the fields
///    we changed (the model's null-omission semantics mean unchanged
///    fields are left alone).
/// 4. After save we re-read with `getAnnotationProperties` and surface
///    the round-tripped values so the user sees what landed.
///
/// **Re-opening the editor:** the native SDK keeps an annotation *selected*
/// after the editor closes, and only emits `AnnotationSelectedEvent` on a
/// selection *change* — so tapping the same (already-selected) annotation
/// again fires nothing. The bottom-bar **Edit** button is the reliable
/// re-open path for the still-selected annotation; tapping a *different*
/// annotation (or deselecting and re-tapping) selects afresh and re-opens.
///
/// **Out of scope:** annotation creation, deletion, and free-text font
/// editing — those are covered by other catalog rows. This example is
/// strictly the get/save properties surface.
class AnnotationPropertiesExamplePage extends StatefulWidget {
  const AnnotationPropertiesExamplePage({super.key});

  @override
  State<AnnotationPropertiesExamplePage> createState() =>
      _AnnotationPropertiesExamplePageState();
}

class _AnnotationPropertiesExamplePageState
    extends State<AnnotationPropertiesExamplePage> {
  Future<String>? _documentPath;
  NutrientController? _controller;
  StreamSubscription<NutrientEvent>? _eventsSub;

  int _currentPage = 0;
  String? _selectedId;
  AnnotationProperties? _selectedProperties;
  String? _lastAction;
  bool _isBusy = false;
  bool _editorOpen = false;

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
    switch (event) {
      case PageChangedEvent(:final pageIndex):
        if (pageIndex != _currentPage) {
          setState(() => _currentPage = pageIndex);
        }
      case AnnotationSelectedEvent(:final annotationsJson):
        // The native viewer can fire selection events with multiple
        // annotations (lasso-select). We only edit one at a time; pick
        // the first.
        if (annotationsJson.isEmpty) return;
        final parsed = _extractIdAndPage(annotationsJson.first);
        if (parsed == null) {
          // Selection fired but the payload didn't carry a usable
          // id/pageIndex. This example exists to validate the bindings
          // payload shape across platforms, so surface the failure
          // rather than leaving the user stuck on "Tap an annotation".
          _setLastAction('Unsupported selection payload — see logs');
          debugPrint(
            '[AnnotationProperties] could not extract id/pageIndex from '
            'selection payload: ${annotationsJson.first}',
          );
          return;
        }
        _selectAndLoad(parsed.$1, parsed.$2);
      case AnnotationDeselectedEvent():
        // Don't drop the editor on deselect — the user may still want
        // to tweak the values. They can close it explicitly.
        break;
      default:
        break;
    }
  }

  /// Extracts `(id, pageIndex)` from an annotation JSON string.
  ///
  /// Each platform serializes selection payloads slightly differently:
  /// - **Web** wraps the annotation in `{"annotation": {...}, "nativeEvent": ...}`
  /// - **Android / iOS** publish the annotation object at the top level
  ///
  /// Walk both shapes and prefer `id` / `name` / `uuid` (Web exports
  /// `name`, native exports `id`).
  (String, int)? _extractIdAndPage(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map) return null;
      // Unwrap a top-level `annotation` key if present (Web).
      final inner =
          decoded['annotation'] is Map ? decoded['annotation'] as Map : decoded;
      final id = (inner['id'] ?? inner['name'] ?? inner['uuid']) as String?;
      final page = inner['pageIndex'] as int?;
      if (id == null || page == null) return null;
      return (id, page);
    } catch (_) {
      return null;
    }
  }

  Future<void> _selectAndLoad(String id, int pageIndex) async {
    final controller = _controller;
    if (controller == null) return;
    setState(() {
      _selectedId = id;
      _isBusy = true;
    });
    AnnotationProperties? props;
    try {
      props = await controller.document.annotations.getAnnotationProperties(
        pageIndex,
        id,
      );
    } catch (error) {
      _setLastAction('Read failed: $error');
      if (mounted) setState(() => _isBusy = false);
      return;
    }
    if (!mounted) return;
    setState(() {
      _selectedProperties = props;
      _isBusy = false;
    });
    if (props != null) {
      _openEditor();
    } else {
      _setLastAction('Annotation $id not found on page ${pageIndex + 1}');
    }
  }

  void _openEditor() {
    if (_editorOpen || !mounted) return;
    _editorOpen = true;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return _PropertyEditor(
          initial: _selectedProperties!,
          onSave: (updated) async {
            Navigator.of(sheetContext).pop();
            await _save(updated);
          },
        );
      },
    ).whenComplete(() {
      _editorOpen = false;
    });
  }

  Future<void> _save(AnnotationProperties updated) async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    // The editor sheet always emits annotationId + pageIndex from the
    // selected annotation, but the model types them as nullable. Bail
    // defensively rather than crashing if the editor ever changes.
    final id = updated.annotationId;
    final pageIndex = updated.pageIndex;
    if (id == null || pageIndex == null) {
      _setLastAction('Save aborted — missing id/page');
      return;
    }
    setState(() => _isBusy = true);
    try {
      final ok = await controller.document.annotations.saveAnnotationProperties(
        updated,
      );
      if (!ok) {
        _setLastAction('Save returned false');
        return;
      }
      // Re-read to confirm the round-trip.
      final fresh = await controller.document.annotations
          .getAnnotationProperties(pageIndex, id);
      if (!mounted) return;
      setState(() => _selectedProperties = fresh);
      _setLastAction(_summarise(fresh ?? updated));
    } catch (error) {
      _setLastAction('Save failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  String _summarise(AnnotationProperties props) {
    final parts = <String>[];
    if (props.strokeColor != null) {
      parts.add('stroke ${_hex(props.strokeColor!)}');
    }
    if (props.opacity != null) {
      parts.add('opacity ${(props.opacity! * 100).round()}%');
    }
    if (props.lineWidth != null) {
      parts.add('width ${props.lineWidth!.toStringAsFixed(1)}');
    }
    // Flags now round-trip through getAnnotationProperties, so surface them
    // after a save + re-read to make a flag change visible.
    if (props.flagsJson != null && props.flagsJson!.isNotEmpty) {
      try {
        final names =
            (jsonDecode(props.flagsJson!) as List).map((e) => '$e').toList();
        if (names.isNotEmpty) parts.add('flags ${names.join(',')}');
      } catch (_) {}
    }
    return parts.isEmpty ? 'Saved' : 'Saved · ${parts.join(' · ')}';
  }

  String _hex(int argb) {
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return '#${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  void _setLastAction(String message) {
    if (!mounted) return;
    setState(() => _lastAction = message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Annotation Properties')),
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
        selectedId: _selectedId,
        lastAction: _lastAction,
        canEdit: _selectedProperties != null && !_isBusy,
        isBusy: _isBusy,
        onEdit: _openEditor,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom bar
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  final int currentPage;
  final String? selectedId;
  final String? lastAction;
  final bool canEdit;
  final bool isBusy;
  final VoidCallback onEdit;

  const _BottomBar({
    required this.currentPage,
    required this.selectedId,
    required this.lastAction,
    required this.canEdit,
    required this.isBusy,
    required this.onEdit,
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
          // IntrinsicHeight keeps the row from expanding to the parent's
          // unbounded vertical space (same regression we hit on row 7).
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _InfoRow(
                    currentPage: currentPage,
                    selectedId: selectedId,
                    lastAction: lastAction,
                  ),
                ),
                const SizedBox(width: BrandSpacing.md),
                FilledButton.icon(
                  onPressed: canEdit ? onEdit : null,
                  icon: isBusy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Edit'),
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
  final String? selectedId;
  final String? lastAction;

  const _InfoRow({
    required this.currentPage,
    required this.selectedId,
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: BrandSpacing.xxs),
              Text(
                selectedId == null
                    ? 'Tap an annotation in the viewer'
                    : _shortId(selectedId!),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: BrandColors.codeCoral,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (lastAction != null) ...[
                const SizedBox(height: BrandSpacing.xxs),
                Text(
                  lastAction!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else if (selectedId != null) ...[
                // The annotation stays selected after the editor closes, so a
                // second tap on it fires no new selection event (the native
                // SDK only emits on a selection *change*). Point the user at
                // the Edit button — the reliable way to re-open the editor for
                // the still-selected annotation.
                const SizedBox(height: BrandSpacing.xxs),
                Text(
                  'Tap Edit to change its properties',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _shortId(String id) {
    if (id.length <= 18) return id;
    return '${id.substring(0, 8)}…${id.substring(id.length - 6)}';
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

// ---------------------------------------------------------------------------
// Property editor sheet
// ---------------------------------------------------------------------------

/// Editable subset of [AnnotationProperties]. The full model has 16
/// fields; this editor exposes stroke colour, opacity, line width,
/// contents (free text), and annotation flags. The sheet emits a
/// fully-populated [AnnotationProperties] (with the original
/// `annotationId` + `pageIndex` preserved) on Save.
class _PropertyEditor extends StatefulWidget {
  final AnnotationProperties initial;
  final ValueChanged<AnnotationProperties> onSave;

  const _PropertyEditor({required this.initial, required this.onSave});

  @override
  State<_PropertyEditor> createState() => _PropertyEditorState();
}

class _PropertyEditorState extends State<_PropertyEditor> {
  late int _strokeColor;
  late double _opacity;
  late double _lineWidth;
  late TextEditingController _contents;

  // Per-control dirty flags. The Save handler only forwards fields the
  // user actually touched — otherwise we'd silently stamp defaults onto
  // annotations that never had a stroke colour / line width (e.g. plain
  // Note widgets), corrupting the bundled annotations.pdf state during
  // the demo.
  bool _strokeColorTouched = false;
  bool _opacityTouched = false;
  bool _lineWidthTouched = false;
  // `_contents` uses a TextEditingController listener — set on any
  // edit (including clearing the field), so we can distinguish "user
  // emptied the field" (explicit clear) from "user never touched it".
  bool _contentsTouched = false;
  // The currently-selected flag set, seeded from the annotation's flags on
  // open. Sent as the complete set on Save (see `_save`), so toggling one
  // flag preserves the others.
  late Set<AnnotationFlag> _flags;
  bool _flagsTouched = false;

  /// Brand-friendly swatches; ARGB ints to match the model.
  static const _palette = <int>[
    0xFF2492FB, // Nutrient blue
    0xFFFF6B35, // Coral
    0xFF4CAF50, // Green
    0xFFFFC107, // Amber
    0xFFE91E63, // Pink
    0xFF7C4DFF, // Deep purple
    0xFF212121, // Near-black
  ];

  /// The user-meaningful flags exposed as toggles, with labels. The
  /// "[Not supported]" flags (noRotate, toggleNoView) and the niche
  /// invisible/noZoom are intentionally omitted.
  static const _editableFlags = <(AnnotationFlag, String)>[
    (AnnotationFlag.hidden, 'Hidden'),
    (AnnotationFlag.noView, 'No view'),
    (AnnotationFlag.print, 'Print'),
    (AnnotationFlag.readOnly, 'Read only'),
    (AnnotationFlag.locked, 'Locked'),
    (AnnotationFlag.lockedContents, 'Locked contents'),
  ];

  @override
  void initState() {
    super.initState();
    _strokeColor = widget.initial.strokeColor ?? _palette.first;
    _opacity = (widget.initial.opacity ?? 1.0).clamp(0.0, 1.0);
    _lineWidth = (widget.initial.lineWidth ?? 2.0).clamp(0.5, 20.0);
    _contents = TextEditingController(text: widget.initial.contents ?? '')
      ..addListener(() {
        if (!_contentsTouched) setState(() => _contentsTouched = true);
      });
    _flags = _decodeInitialFlags(widget.initial.flagsJson);
  }

  /// Parses the annotation's `flagsJson` (a JSON array of flag-name strings)
  /// into the [AnnotationFlag] set the chips render from. Defensive: an absent
  /// or malformed value yields an empty set.
  Set<AnnotationFlag> _decodeInitialFlags(String? flagsJson) {
    if (flagsJson == null || flagsJson.isEmpty) return <AnnotationFlag>{};
    try {
      final names =
          (jsonDecode(flagsJson) as List).map((e) => e.toString()).toSet();
      return AnnotationFlag.values.where((f) => names.contains(f.name)).toSet();
    } catch (_) {
      return <AnnotationFlag>{};
    }
  }

  @override
  void dispose() {
    _contents.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(
      AnnotationProperties(
        annotationId: widget.initial.annotationId,
        pageIndex: widget.initial.pageIndex,
        // Each field is null unless the user explicitly touched its
        // control. `AnnotationProperties.toJson()` omits nulls, so the
        // platform manager leaves untouched properties alone.
        strokeColor: _strokeColorTouched ? _strokeColor : null,
        opacity: _opacityTouched ? _opacity : null,
        lineWidth: _lineWidthTouched ? _lineWidth : null,
        // Contents: send the raw value (including empty string) when
        // the user has touched the field. Empty string is the explicit
        // "clear contents" gesture — we don't collapse it to null,
        // which would mean "leave contents alone".
        contents: _contentsTouched ? _contents.text : null,
        // Flags: send the complete selected set (JSON-encoded flag names)
        // only if the user touched a toggle. The set was seeded from the
        // annotation's existing flags, so untouched flags are preserved and
        // an emptied set explicitly clears them.
        flagsJson: _flagsTouched
            ? jsonEncode(_flags.map((f) => f.name).toList())
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          BrandSpacing.lg,
          0,
          BrandSpacing.lg,
          MediaQuery.of(context).viewInsets.bottom + BrandSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Annotation properties',
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Builder(
                  builder: (_) {
                    final pageIndex = widget.initial.pageIndex;
                    return Text(
                      pageIndex == null ? 'page ?' : 'page ${pageIndex + 1}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: BrandSpacing.md),
            _SectionLabel('Stroke colour'),
            const SizedBox(height: BrandSpacing.sm),
            Wrap(
              spacing: BrandSpacing.sm,
              runSpacing: BrandSpacing.sm,
              children: [
                for (final c in _palette)
                  _Swatch(
                    color: Color(c),
                    selected: c == _strokeColor,
                    onTap: () => setState(() {
                      _strokeColor = c;
                      _strokeColorTouched = true;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: BrandSpacing.lg),
            _SectionLabel('Opacity (${(_opacity * 100).round()}%)'),
            Slider(
              value: _opacity,
              onChanged: (v) => setState(() {
                _opacity = v;
                _opacityTouched = true;
              }),
              divisions: 20,
            ),
            const SizedBox(height: BrandSpacing.sm),
            _SectionLabel('Line width (${_lineWidth.toStringAsFixed(1)})'),
            Slider(
              value: _lineWidth,
              min: 0.5,
              max: 20,
              divisions: 39,
              onChanged: (v) => setState(() {
                _lineWidth = v;
                _lineWidthTouched = true;
              }),
            ),
            const SizedBox(height: BrandSpacing.md),
            _SectionLabel('Contents'),
            const SizedBox(height: BrandSpacing.xs),
            TextField(
              controller: _contents,
              maxLines: 2,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Optional note text',
                border: OutlineInputBorder(borderRadius: BrandRadius.brMd),
              ),
            ),
            const SizedBox(height: BrandSpacing.md),
            _SectionLabel('Flags'),
            const SizedBox(height: BrandSpacing.xs),
            Wrap(
              spacing: BrandSpacing.sm,
              runSpacing: BrandSpacing.xs,
              children: [
                for (final (flag, label) in _editableFlags)
                  FilterChip(
                    label: Text(label),
                    selected: _flags.contains(flag),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _flags.add(flag);
                      } else {
                        _flags.remove(flag);
                      }
                      _flagsTouched = true;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: BrandSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: BrandSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelLarge);
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}
