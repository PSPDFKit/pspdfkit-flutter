// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../adapters/catalog_adapter_controller.dart';
import '../design/design.dart';

/// Toolbar Customization example (HYB-951 coverage Tracks 2.2 / 2.3 / 2.4).
///
/// Demonstrates the **cross-platform** [NutrientController.setMainToolbarItems]:
/// from `onControllerReady` the page hands the controller a list of
/// [ToolbarItem]s — a few built-ins plus a [CustomToolbarItem] button backed
/// by a Dart `onPressed`. Tapping the custom button (in the native or web
/// viewer toolbar) increments a counter in the Flutter-owned status bar below,
/// proving the tap round-trips back into Dart on **Android, iOS, and Web** with
/// the exact same call.
///
/// A "Show custom button" switch re-invokes `setMainToolbarItems` at runtime to
/// show how items can be added/removed/enabled dynamically.
///
/// ## Platform parity
///
/// - The **custom button** works on all three platforms.
/// - The **built-in items** in the list reorder/trim the toolbar on **Web
///   only**; Android and iOS keep their native toolbar and ignore the built-in
///   entries (the custom button is still added). Including the built-ins keeps
///   the toolbar looking consistent across platforms.
class ToolbarCustomizationExamplePage extends StatefulWidget {
  const ToolbarCustomizationExamplePage({super.key});

  @override
  State<ToolbarCustomizationExamplePage> createState() =>
      _ToolbarCustomizationExamplePageState();
}

class _ToolbarCustomizationExamplePageState
    extends State<ToolbarCustomizationExamplePage> {
  // ─────────────────────────────────────────────────────────────────────
  // Nutrient SDK usage — the part this example exists to demonstrate.
  // ─────────────────────────────────────────────────────────────────────

  /// The ready controller, captured in [NutrientDocumentView.onControllerReady].
  ///
  /// `NutrientDocumentView<CatalogAdapterController>` builds a fresh adapter per
  /// mount from the factory registered in `main.dart`
  /// (`Nutrient.addAdapterClass<CatalogAdapterController>(…)`) and owns its
  /// lifecycle — so this page never constructs or disposes the adapter; it just
  /// captures the ready controller to drive the toolbar.
  CatalogAdapterController? _controller;

  /// How many times the custom toolbar button has been tapped — bumped from
  /// the Dart `onPressed` the SDK wires to the native/web button.
  int _greetCount = 0;

  /// Whether the custom "Greet" button is currently in the toolbar. Toggling
  /// this re-applies the toolbar to show dynamic add/remove.
  bool _showGreet = true;

  /// Built-in items to keep (Web honors these to reorder/trim the toolbar;
  /// Android/iOS ignore them and keep their native toolbar).
  static const _builtInItems = <ToolbarItem>[
    ToolbarItemType.sidebarThumbnails,
    ToolbarItemType.pager,
    ToolbarItemType.zoomOut,
    ToolbarItemType.zoomIn,
    ToolbarItemType.spacer,
    ToolbarItemType.search,
  ];

  /// Pushes the current toolbar configuration to the viewer. Safe to call any
  /// time after the controller is ready — re-callable to add/remove items.
  void _applyToolbarItems() {
    _controller?.setMainToolbarItems([
      ..._builtInItems,
      if (_showGreet)
        CustomToolbarItem(
          id: 'greet',
          title: 'Greet',
          onPressed: () {
            if (!mounted) return;
            setState(() => _greetCount++);
          },
        ),
    ]);
  }

  void _onControllerReady(CatalogAdapterController controller) {
    _controller = controller;
    _applyToolbarItems();
  }

  Widget _buildDocumentView(String documentPath) {
    // No `adapter:` — the view builds a CatalogAdapterController from the
    // registered factory (Nutrient.addAdapterClass) and owns its lifecycle.
    return NutrientDocumentView<CatalogAdapterController>(
      documentPath: documentPath,
      onControllerReady: _onControllerReady,
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Page chrome — not specific to Nutrient.
  // ─────────────────────────────────────────────────────────────────────

  Future<String>? _documentPath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentPath ??= CatalogDocuments.scientificPaper(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Toolbar Customization')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<String>(
              future: _documentPath,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Failed: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildDocumentView(snapshot.data!);
              },
            ),
          ),
          const Divider(height: 1),
          _StatusBar(
            greetCount: _greetCount,
            showGreet: _showGreet,
            onToggleGreet: (value) {
              setState(() => _showGreet = value);
              _applyToolbarItems();
            },
          ),
        ],
      ),
    );
  }
}

/// Flutter-owned status bar describing the custom toolbar, surfacing the Dart
/// callback's tap count, and offering the dynamic add/remove toggle.
class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.greetCount,
    required this.showGreet,
    required this.onToggleGreet,
  });

  final int greetCount;
  final bool showGreet;
  final ValueChanged<bool> onToggleGreet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BrandSpacing.lg,
          vertical: BrandSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: BrandSpacing.sm),
                Expanded(
                  child: Text(
                    'Greet button tapped: $greetCount',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Switch(value: showGreet, onChanged: onToggleGreet),
              ],
            ),
            const SizedBox(height: BrandSpacing.xs),
            Text(
              showGreet
                  ? (greetCount == 0
                      ? 'Tap “Greet” in the viewer toolbar above. The same '
                          'setMainToolbarItems call works on Android, iOS, and Web.'
                      : 'The toolbar button’s onPressed reached Flutter.')
                  : 'Custom button removed — toggle the switch to re-add it '
                      '(setMainToolbarItems re-applied at runtime).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
