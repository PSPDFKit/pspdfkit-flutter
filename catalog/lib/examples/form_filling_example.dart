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

/// Form-filling example: drives [FormManagerInterface] against the bundled
/// `form.pdf` (text fields only).
///
/// 1. [NutrientDocumentView] hosts the document; `onControllerReady` hands us
///    a [NutrientController].
/// 2. A "Fill" button calls `controller.document.forms.setFormFieldValue(...)`
///    against three known text fields (`First Name`, `Last Name`, `City`).
/// 3. A "Read" button calls `getFormFieldValue(...)` for each of those
///    fields and shows the current values in a bottom sheet.
/// 4. A "Clear" button writes the empty string to each of those fields.
/// 5. The info bar in `bottomNavigationBar` tracks current page, the
///    total number of AcroForm widgets (from the typed `getFormFields()`), and
///    the last action — same shape as the Document / Bookmarks examples
///    so the Maestro flows can stay Flutter-owned once the native viewer
///    takes a11y focus.
///
/// Non-text fields (checkboxes, radios, listboxes) are out of scope for
/// this example because the cross-platform
/// `setFormFieldValue(String, String)` signature can't represent
/// `List<String>` checkbox values, which is what the Web SDK requires.
/// See the comment on `_sampleData` for details and follow-up.
class FormFillingExamplePage extends StatefulWidget {
  const FormFillingExamplePage({super.key});

  @override
  State<FormFillingExamplePage> createState() => _FormFillingExamplePageState();
}

class _FormFillingExamplePageState extends State<FormFillingExamplePage> {
  Future<String>? _documentPath;
  NutrientController? _controller;
  StreamSubscription<NutrientEvent>? _eventsSub;

  int _currentPage = 0;
  int _fieldsCount = 0;
  bool _isBusy = false;
  String? _lastAction;

  /// Text fields we drive on every Fill / Clear, picked from the
  /// AcroForm widgets in the bundled `form.pdf`.
  ///
  /// Restricted to text fields because the `setFormFieldValue(String, …)`
  /// signature on `FormManagerInterface` is `String`-typed, while the
  /// Web SDK expects checkbox values as `List<String>` and rejects a
  /// plain string with `PSPDFKitError: The type of action value for the
  /// CheckBoxFormField <name> is string, but has to be a List of
  /// strings`. The cross-platform typed-value API for non-text fields
  /// is a follow-up (the legacy `PdfFormField.setFormElementValue` on
  /// `package:nutrient_flutter/nutrient_flutter.dart` handles the
  /// type-coercion; once that's lifted onto the bindings interface,
  /// this example can grow to cover checkboxes and radios too).
  static const Map<String, String> _sampleData = {
    'First Name': 'Ada',
    'Last Name': 'Lovelace',
    'City': 'London',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentPath ??= CatalogDocuments.form(context);
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
    // `canMutate` in `build` keys off `_controller != null`, so wrap the
    // assignment in `setState` to flip the Fill button to enabled once
    // the controller arrives. Same reason as the Bookmarks example.
    setState(() => _controller = controller);
    // iOS / Web have the document ready here; Android races
    // `pdfDocument` ~400 ms after ready, so the count load below is
    // best-effort and the `DocumentLoadedEvent` listener retries.
    _refreshFieldsCount();
  }

  void _handleEvent(NutrientEvent event) {
    if (!mounted) return;
    if (event is DocumentLoadedEvent) {
      _refreshFieldsCount();
      return;
    }
    if (event is PageChangedEvent) {
      if (event.pageIndex == _currentPage) return;
      setState(() => _currentPage = event.pageIndex);
    }
  }

  Future<void> _refreshFieldsCount() async {
    final controller = _controller;
    if (controller == null) return;
    int count;
    try {
      // Typed API: getFormFields() returns List<PdfFormField>, parsing the
      // per-platform JSON and skipping any unrecognized field type internally.
      // (Setting/reading a field's *value* is still done with the string
      // setFormFieldValue/getFormFieldValue below — those are value ops.)
      final fields = await controller.document.forms.getFormFields();
      count = fields.length;
    } catch (_) {
      return; // Wait for DocumentLoadedEvent retry on Android.
    }
    if (!mounted) return;
    setState(() => _fieldsCount = count);
  }

  Future<void> _fillSample() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      var ok = 0;
      var skipped = 0;
      for (final entry in _sampleData.entries) {
        final wrote = await controller.document.forms.setFormFieldValue(
          entry.value,
          entry.key,
        );
        if (wrote) {
          ok++;
        } else {
          skipped++;
        }
      }
      _setLastAction(
        skipped == 0
            ? 'Filled $ok field${ok == 1 ? '' : 's'}'
            : 'Filled $ok, skipped $skipped (field not found)',
      );
    } catch (error) {
      _setLastAction('Fill failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _clearSample() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      var ok = 0;
      for (final fieldName in _sampleData.keys) {
        if (await controller.document.forms.setFormFieldValue('', fieldName)) {
          ok++;
        }
      }
      _setLastAction('Cleared $ok field${ok == 1 ? '' : 's'}');
    } catch (error) {
      _setLastAction('Clear failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _showCurrentValues() async {
    final controller = _controller;
    if (controller == null) return;
    final entries = <MapEntry<String, String?>>[];
    String? errorMessage;
    try {
      for (final name in _sampleData.keys) {
        final value = await controller.document.forms.getFormFieldValue(name);
        entries.add(MapEntry(name, value));
      }
    } catch (error) {
      errorMessage = error.toString();
    }
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(BrandSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Current values',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: BrandSpacing.sm),
                if (errorMessage != null)
                  Text('Read failed: $errorMessage')
                else
                  ...entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: BrandSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(e.key)),
                          Text(
                            e.value == null
                                ? '(not found)'
                                : e.value!.isEmpty
                                    ? '(empty)'
                                    : e.value!,
                            style: TextStyle(color: BrandColors.codeCoral),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: BrandSpacing.md),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
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
    final canMutate = _controller != null && !_isBusy;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Form Filling')),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _InfoBar(
          currentPage: _currentPage,
          fieldsCount: _fieldsCount,
          isBusy: _isBusy,
          lastAction: _lastAction,
          onFill: canMutate ? _fillSample : null,
          onClear: canMutate ? _clearSample : null,
          onRead: _controller != null ? _showCurrentValues : null,
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
  final int currentPage;
  final int fieldsCount;
  final bool isBusy;
  final String? lastAction;
  final VoidCallback? onFill;
  final VoidCallback? onClear;
  final VoidCallback? onRead;

  const _InfoBar({
    required this.currentPage,
    required this.fieldsCount,
    required this.isBusy,
    required this.lastAction,
    required this.onFill,
    required this.onClear,
    required this.onRead,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 600;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCells(isCompact: isCompact),
                const SizedBox(height: BrandSpacing.sm),
                _buildActionRow(isCompact: isCompact),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCells({required bool isCompact}) {
    final cells = [
      _InfoCell(label: 'Page', value: '${currentPage + 1}'),
      _InfoCell(label: 'Fields', value: '$fieldsCount'),
      _InfoCell(label: 'Status', value: lastAction ?? '—'),
    ];
    if (isCompact) {
      return Wrap(
        spacing: BrandSpacing.lg,
        runSpacing: BrandSpacing.sm,
        children: cells,
      );
    }
    return Row(
      children: [
        cells[0],
        const SizedBox(width: BrandSpacing.lg),
        cells[1],
        const SizedBox(width: BrandSpacing.lg),
        Expanded(child: cells[2]),
      ],
    );
  }

  Widget _buildActionRow({required bool isCompact}) {
    final fillIcon = isBusy
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.edit_outlined);
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onFill,
            icon: fillIcon,
            label: const Text('Fill sample', overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(width: BrandSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.cleaning_services_outlined),
            label: const Text('Clear', overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(width: BrandSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRead,
            icon: const Icon(Icons.list_alt_outlined),
            label: const Text('Read', overflow: TextOverflow.ellipsis),
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: BrandColors.codeCoral,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
