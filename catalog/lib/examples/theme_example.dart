// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';

/// Dark Theme + Custom Theme example (legacy rows #18 and #19).
///
/// A preset picker remounts the [NutrientDocumentView] with a different
/// [NutrientViewConfiguration] per preset (theme configuration is
/// creation-time, so the view is keyed by preset):
///
/// - **Night** sets the cross-platform `appearanceMode:`
///   [AppearanceMode.night] — Android maps it to the activity-config
///   `themeMode(NIGHT)`, iOS applies it via the view controller's
///   `appearanceModeManager`, web maps it to the Web SDK `theme: 'DARK'`.
/// - **Sepia** is an iOS-only render style (`appearanceModeManager`);
///   Android and web fall back to their defaults.
/// - **Custom (Android)** / **Custom dark (Android)** set
///   `androidConfig.defaultThemeResource` / `darkThemeResource` to the
///   catalog's `NutrientCatalog.Theme.Custom*` styles
///   (`android/app/src/main/res/values/styles.xml`) — resolved by name via
///   `Resources.getIdentifier` and applied with the activity-config
///   `theme()` / `themeDark()` builders. Other platforms ignore these
///   fields, so the presets note the platform scope.
class ThemeExamplePage extends StatefulWidget {
  const ThemeExamplePage({super.key});

  @override
  State<ThemeExamplePage> createState() => _ThemeExamplePageState();
}

/// One theme preset entry.
class _Preset {
  final String label;

  /// Short platform-scope note shown under the label.
  final String note;
  final IconData icon;
  final NutrientViewConfiguration? configuration;

  const _Preset({
    required this.label,
    required this.note,
    required this.icon,
    required this.configuration,
  });
}

const _presets = <_Preset>[
  _Preset(
    label: 'Default',
    note: 'SDK default appearance on all platforms',
    icon: Icons.light_mode_outlined,
    configuration: null,
  ),
  _Preset(
    label: 'Night',
    note: 'appearanceMode: night — Android themeMode, '
        'iOS appearanceModeManager, web theme: DARK',
    icon: Icons.dark_mode_outlined,
    configuration: NutrientViewConfiguration(
      appearanceMode: AppearanceMode.night,
    ),
  ),
  _Preset(
    label: 'Sepia',
    note: 'appearanceMode: sepia — iOS render style; '
        'Android/web fall back to default',
    icon: Icons.tonality_outlined,
    configuration: NutrientViewConfiguration(
      appearanceMode: AppearanceMode.sepia,
    ),
  ),
  _Preset(
    label: 'Custom theme',
    note: 'androidConfig.defaultThemeResource — Android only',
    icon: Icons.palette_outlined,
    configuration: NutrientViewConfiguration(
      androidConfig: AndroidViewConfiguration(
        defaultThemeResource: 'NutrientCatalog.Theme.Custom',
      ),
    ),
  ),
  _Preset(
    label: 'Custom dark theme',
    note: 'androidConfig.darkThemeResource + night — Android only',
    icon: Icons.nightlight_outlined,
    configuration: NutrientViewConfiguration(
      appearanceMode: AppearanceMode.night,
      androidConfig: AndroidViewConfiguration(
        darkThemeResource: 'NutrientCatalog.Theme.CustomDark',
      ),
    ),
  ),
];

class _ThemeExamplePageState extends State<ThemeExamplePage> {
  Future<String>? _documentPath;
  int _presetIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentPath ??= CatalogDocuments.welcome(context);
  }

  void _apply(int index) {
    if (index == _presetIndex) return;
    setState(() => _presetIndex = index);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Theme: ${_presets[index].label}')),
      );
  }

  Future<void> _showPresetPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  BrandSpacing.lg,
                  0,
                  BrandSpacing.lg,
                  BrandSpacing.sm,
                ),
                child: Text(
                  'Theme presets',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              for (var i = 0; i < _presets.length; i++)
                ListTile(
                  leading: Icon(
                    _presets[i].icon,
                    color: i == _presetIndex
                        ? Theme.of(sheetContext).colorScheme.primary
                        : null,
                  ),
                  title: Text(_presets[i].label),
                  subtitle: Text(_presets[i].note),
                  trailing: i == _presetIndex
                      ? Icon(
                          Icons.check_rounded,
                          color: Theme.of(sheetContext).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _apply(i);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final preset = _presets[_presetIndex];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Themes')),
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
            // Theme configuration is creation-time — remount per preset.
            return NutrientDocumentView(
              key: ValueKey('theme-preset-$_presetIndex'),
              documentPath: snapshot.data!,
              configuration: preset.configuration,
            );
          },
        ),
      ),
      bottomNavigationBar: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              BrandSpacing.md,
              BrandSpacing.sm,
              BrandSpacing.md,
              BrandSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    // min — without it the Column expands to the Scaffold's
                    // loose bottomNavigationBar height constraint and the bar
                    // covers the whole screen.
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active preset',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: BrandSpacing.xxs),
                      Text(
                        preset.label,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: BrandColors.codeCoral),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: BrandSpacing.xxs),
                      Text(
                        preset.note,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: BrandSpacing.md),
                FilledButton.icon(
                  onPressed: _showPresetPicker,
                  icon: const Icon(Icons.palette_outlined, size: 18),
                  label: const Text('Presets'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
