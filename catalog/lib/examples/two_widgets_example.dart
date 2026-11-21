// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../adapters/catalog_adapter_controller.dart';
import '../adapters/catalog_adapters.dart';
import '../design/design.dart';

/// Two Widgets example.
///
/// Renders two [NutrientDocumentView]s on the same screen, each showing a
/// different document. The key detail is that each view is handed its **own**
/// adapter instance via [NutrientDocumentView.adapter] (created with
/// `createCatalogAdapter()` and disposed by this page) — so the two viewers
/// have independent controllers and their state (current page, zoom, document)
/// never leaks between panes.
///
/// Two PlatformViews live on screen at once; the page splits along the long
/// axis so both stay usable on a phone.
class TwoWidgetsExamplePage extends StatefulWidget {
  const TwoWidgetsExamplePage({super.key});

  @override
  State<TwoWidgetsExamplePage> createState() => _TwoWidgetsExamplePageState();
}

class _TwoWidgetsExamplePageState extends State<TwoWidgetsExamplePage> {
  // One adapter per view — independent controllers, no shared state.
  CatalogAdapterController? _adapterA;
  CatalogAdapterController? _adapterB;

  Future<String>? _pathA;
  Future<String>? _pathB;

  @override
  void initState() {
    super.initState();
    _adapterA = createCatalogAdapter();
    _adapterB = createCatalogAdapter();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Two visibly different documents so it's obvious the panes are
    // independent.
    _pathA ??= CatalogDocuments.welcome(context);
    _pathB ??= CatalogDocuments.scientificPaper(context);
  }

  @override
  void dispose() {
    _adapterA?.dispose();
    _adapterB?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_adapterA == null || _adapterB == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Two Widgets')),
        body: const Center(child: Text('No platform adapter registered.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Two Widgets')),
      body: SafeArea(
        top: false,
        // Split along the longer axis: side-by-side in landscape, stacked
        // in portrait.
        child: OrientationBuilder(
          builder: (context, orientation) {
            final panes = [
              Expanded(
                child: _ViewerPane(
                  label: 'Document A · Welcome',
                  documentPath: _pathA,
                  adapter: _adapterA!,
                ),
              ),
              const _PaneDivider(),
              Expanded(
                child: _ViewerPane(
                  label: 'Document B · Scientific Paper',
                  documentPath: _pathB,
                  adapter: _adapterB!,
                ),
              ),
            ];
            return orientation == Orientation.landscape
                ? Row(children: panes)
                : Column(children: panes);
          },
        ),
      ),
    );
  }
}

class _PaneDivider extends StatelessWidget {
  const _PaneDivider();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.outlineVariant,
      child: const SizedBox(width: 1, height: 1),
    );
  }
}

class _ViewerPane extends StatelessWidget {
  final String label;
  final Future<String>? documentPath;
  final CatalogAdapterController adapter;

  const _ViewerPane({
    required this.label,
    required this.documentPath,
    required this.adapter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Flutter-owned pane header — stays reachable even after the native
        // viewer takes a11y focus over the body.
        Container(
          color: theme.colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(
            horizontal: BrandSpacing.md,
            vertical: BrandSpacing.xs,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: BrandColors.codeCoral,
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<String>(
            future: documentPath,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Failed: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return NutrientDocumentView<CatalogAdapterController>(
                documentPath: snapshot.data!,
                adapter: adapter,
              );
            },
          ),
        ),
      ],
    );
  }
}
