// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';

/// Custom Configuration example.
///
/// Demonstrates driving the viewer's [NutrientViewConfiguration] from Flutter:
/// scroll direction, page layout, appearance (theme), autosave, and the
/// signature creation UI (saving strategy, creation modes, color presets).
/// To see the signature options take effect, enter annotation mode and pick
/// the signature tool.
///
/// `NutrientViewConfiguration` is read once when the platform view is created
/// — there's no live "set config" call. To apply a change we rebuild the
/// [NutrientDocumentView] with a new `configuration` **and a new [ValueKey]**,
/// which forces the platform view (and its controller) to be recreated with
/// the new settings. A bump counter ([_configVersion]) drives that key.
///
/// The document path is resolved once and reused across rebuilds so we don't
/// re-extract the bundled asset every time the config changes.
class CustomConfigurationExamplePage extends StatefulWidget {
  const CustomConfigurationExamplePage({super.key});

  @override
  State<CustomConfigurationExamplePage> createState() =>
      _CustomConfigurationExamplePageState();
}

class _CustomConfigurationExamplePageState
    extends State<CustomConfigurationExamplePage> {
  Future<String>? _documentPath;
  NutrientController? _controller;

  // Each change bumps this; it keys the NutrientDocumentView so the platform
  // view is recreated with the new configuration.
  int _configVersion = 0;

  // Current configuration selections (cross-platform fields).
  ScrollDirection _scrollDirection = ScrollDirection.horizontal;
  PageLayoutMode _pageLayout = PageLayoutMode.automatic;
  AppearanceMode _appearance = AppearanceMode.defaultMode;
  bool _autosave = true;
  SignatureSavingStrategy _signatureSaving = SignatureSavingStrategy.neverSave;
  bool _customSignatureUi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resolve once — reused across config rebuilds.
    _documentPath ??= CatalogDocuments.scientificPaper(context);
  }

  void _onControllerReady(NutrientController controller) {
    if (!mounted) return;
    setState(() => _controller = controller);
  }

  NutrientViewConfiguration get _configuration => NutrientViewConfiguration(
        scrollDirection: _scrollDirection,
        pageLayoutMode: _pageLayout,
        appearanceMode: _appearance,
        disableAutosave: !_autosave,
        signatureSavingStrategy: _signatureSaving,
        signatureCreationConfiguration:
            _customSignatureUi ? _customSignatureConfiguration : null,
      );

  /// A curated signature creation UI: draw + type only (no image tab), three
  /// brand-ish ink colors, landscape dialog on Android, square signing area
  /// on iOS. Compare against the platform defaults by toggling the switch.
  static final _customSignatureConfiguration = SignatureCreationConfiguration(
    creationModes: [
      SignatureCreationMode.draw,
      SignatureCreationMode.type,
    ],
    colorOptions: SignatureColorOptions(
      option1: SignatureColorPreset(color: Colors.black, id: 'black'),
      option2: SignatureColorPreset(color: Colors.indigo, id: 'indigo'),
      option3: SignatureColorPreset(color: Colors.teal, id: 'teal'),
    ),
    androidSignatureOrientation: NutrientAndroidSignatureOrientation.landscape,
    iosSignatureAspectRatio: const AspectRatio(aspectRatio: 1),
  );

  /// A single-line summary of the active configuration, shown in both the
  /// bottom bar and the Configure sheet so the live state is always visible.
  String get _summary => 'Scroll: ${_scrollLabel(_scrollDirection)} / '
      'Layout: ${_layoutLabel(_pageLayout)} / '
      'Theme: ${_appearanceLabel(_appearance)} / '
      'Autosave: ${_autosave ? 'on' : 'off'} / '
      'Sig: ${_signatureSavingLabel(_signatureSaving)}'
      '${_customSignatureUi ? ' (custom UI)' : ''}';

  // ---------------------------------------------------------------------------
  // Configure sheet
  // ---------------------------------------------------------------------------

  Future<void> _showConfigureSheet() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      // Rebuild the sheet's own contents when config changes so the selected
      // chips reflect the live state.
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Apply on the page (mutate the field + bump the view key so the
            // viewer is recreated with the new config) and rebuild the sheet
            // so its chips and the summary line reflect the new state.
            void choose(VoidCallback apply) {
              setState(() {
                apply();
                _configVersion++;
              });
              setSheetState(() {});
            }

            final theme = Theme.of(context);
            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    BrandSpacing.lg,
                    0,
                    BrandSpacing.lg,
                    BrandSpacing.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Viewer configuration',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: BrandSpacing.xs),
                      // Live summary — updates as chips are tapped, and stays
                      // visible while the sheet is open (the bottom-bar copy is
                      // occluded by the sheet).
                      Text(
                        _summary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: BrandColors.codeCoral,
                        ),
                      ),
                      const SizedBox(height: BrandSpacing.md),
                      _ChoiceGroup<ScrollDirection>(
                        label: 'Scroll direction',
                        value: _scrollDirection,
                        options: const {
                          ScrollDirection.horizontal: 'Horizontal',
                          ScrollDirection.vertical: 'Vertical',
                        },
                        onSelected: (v) => choose(() => _scrollDirection = v),
                      ),
                      const SizedBox(height: BrandSpacing.md),
                      _ChoiceGroup<PageLayoutMode>(
                        label: 'Page layout',
                        value: _pageLayout,
                        options: const {
                          PageLayoutMode.single: 'Single',
                          PageLayoutMode.double: 'Double',
                          PageLayoutMode.automatic: 'Auto',
                        },
                        onSelected: (v) => choose(() => _pageLayout = v),
                      ),
                      const SizedBox(height: BrandSpacing.md),
                      _ChoiceGroup<AppearanceMode>(
                        label: 'Appearance',
                        value: _appearance,
                        options: const {
                          AppearanceMode.defaultMode: 'Default',
                          AppearanceMode.sepia: 'Sepia',
                          AppearanceMode.night: 'Night',
                        },
                        onSelected: (v) => choose(() => _appearance = v),
                      ),
                      const SizedBox(height: BrandSpacing.xs),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Autosave'),
                        subtitle: const Text(
                          'Persist edits automatically (disableAutosave)',
                        ),
                        value: _autosave,
                        onChanged: (v) => choose(() => _autosave = v),
                      ),
                      const SizedBox(height: BrandSpacing.md),
                      _ChoiceGroup<SignatureSavingStrategy>(
                        label: 'Signature saving (Android & iOS)',
                        value: _signatureSaving,
                        options: const {
                          SignatureSavingStrategy.neverSave: 'Never',
                          SignatureSavingStrategy.alwaysSave: 'Always',
                          SignatureSavingStrategy.saveIfSelected: 'If selected',
                        },
                        onSelected: (v) => choose(() => _signatureSaving = v),
                      ),
                      const SizedBox(height: BrandSpacing.xs),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Custom signature UI'),
                        subtitle: const Text(
                          'Draw + type only, custom ink colors '
                          '(signatureCreationConfiguration)',
                        ),
                        value: _customSignatureUi,
                        onChanged: (v) => choose(() => _customSignatureUi = v),
                      ),
                      const SizedBox(height: BrandSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Custom Configuration')),
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
              // New key on every config change → platform view is recreated
              // with the new configuration.
              key: ValueKey(_configVersion),
              documentPath: snapshot.data!,
              configuration: _configuration,
              onControllerReady: _onControllerReady,
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomBar(
        summary: _summary,
        ready: _controller != null,
        onConfigure: _showConfigureSheet,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Label helpers
// ---------------------------------------------------------------------------

String _scrollLabel(ScrollDirection v) =>
    v == ScrollDirection.horizontal ? 'Horizontal' : 'Vertical';

String _layoutLabel(PageLayoutMode v) => switch (v) {
      PageLayoutMode.single => 'Single',
      PageLayoutMode.double => 'Double',
      PageLayoutMode.automatic => 'Auto',
    };

String _appearanceLabel(AppearanceMode v) => switch (v) {
      AppearanceMode.defaultMode => 'Default',
      AppearanceMode.sepia => 'Sepia',
      AppearanceMode.night => 'Night',
      AppearanceMode.allCustomColors => 'Custom',
    };

String _signatureSavingLabel(SignatureSavingStrategy v) => switch (v) {
      SignatureSavingStrategy.neverSave => 'never',
      SignatureSavingStrategy.alwaysSave => 'always',
      SignatureSavingStrategy.saveIfSelected => 'if selected',
    };

// ---------------------------------------------------------------------------
// Choice group (label + chips)
// ---------------------------------------------------------------------------

class _ChoiceGroup<T> extends StatelessWidget {
  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onSelected;

  const _ChoiceGroup({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: BrandSpacing.xs),
        Wrap(
          spacing: BrandSpacing.sm,
          children: [
            for (final entry in options.entries)
              ChoiceChip(
                label: Text(entry.value),
                selected: entry.key == value,
                onSelected: (_) => onSelected(entry.key),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom bar
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  final String summary;
  final bool ready;
  final VoidCallback onConfigure;

  const _BottomBar({
    required this.summary,
    required this.ready,
    required this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Material(
      color: t.colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            BrandSpacing.md,
            BrandSpacing.sm,
            BrandSpacing.md,
            BrandSpacing.md,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuration',
                        style: t.textTheme.labelSmall?.copyWith(
                          color: t.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: BrandSpacing.xxs),
                      Text(
                        summary,
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: BrandColors.codeCoral,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: BrandSpacing.md),
                FilledButton.icon(
                  onPressed: ready ? onConfigure : null,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Configure'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
