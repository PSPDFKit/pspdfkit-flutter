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

/// Annotation Toolbar Customization example (HYB-951 annotation-toolbar work).
///
/// Demonstrates the cross-platform annotation-toolbar APIs from
/// `onControllerReady`:
///
/// - [NutrientController.setAnnotationToolbarItems] reorders/groups the
///   **creation** tool picker (ink, highlight, shapes…). Tap "Annotate" to open
///   it — the tools appear in the configured order with a grouped markup slot.
///   Supported on **Android & iOS** (on Web the tools are in the main toolbar).
/// - [NutrientController.setAnnotationEditingToolbarItems] reorders/trims the
///   **editing** bar shown when an annotation is selected. Supported on **Web &
///   Android** (iOS editing-bar customization is a follow-up).
class AnnotationToolbarCustomizationExamplePage extends StatefulWidget {
  const AnnotationToolbarCustomizationExamplePage({super.key});

  @override
  State<AnnotationToolbarCustomizationExamplePage> createState() =>
      _AnnotationToolbarCustomizationExamplePageState();
}

class _AnnotationToolbarCustomizationExamplePageState
    extends State<AnnotationToolbarCustomizationExamplePage> {
  /// `NutrientDocumentView<CatalogAdapterController>` builds a fresh adapter per
  /// mount from the factory registered in `main.dart`
  /// (`Nutrient.addAdapterClass<CatalogAdapterController>(…)`) and owns its
  /// lifecycle — this page just captures the ready controller to customize the
  /// annotation toolbars.
  CatalogAdapterController? _controller;

  // A curated creation toolbar: a few single tools plus a grouped "markup" slot.
  static const _creationItems = <AnnotationToolbarItem>[
    AnnotationTool.inkPen,
    AnnotationTool.square,
    AnnotationTool.circle,
    AnnotationTool.line,
    AnnotationToolGroup(
      representative: AnnotationTool.highlight,
      items: [
        AnnotationTool.highlight,
        AnnotationTool.underline,
        AnnotationTool.strikeOut,
      ],
    ),
  ];

  /// Android-only: hides the stylus tool button on the creation toolbar.
  ///
  /// The button is only rendered on devices the SDK detects a stylus on (e.g. a
  /// Samsung S Pen), so on other hardware there is nothing to hide. Read each
  /// time the annotation toolbar is prepared, not at configuration time.
  static const _configuration = NutrientViewConfiguration(
    androidConfig: AndroidViewConfiguration(showStylusButton: false),
  );

  // A curated editing bar (shown when an annotation is selected).
  static const _editingItems = <AnnotationEditingItem>[
    AnnotationEditingItem.color,
    AnnotationEditingItem.opacity,
    AnnotationEditingItem.thickness,
    AnnotationEditingItem.note,
    AnnotationEditingItem.delete,
  ];

  void _onControllerReady(CatalogAdapterController controller) {
    _controller = controller;
    controller.setAnnotationToolbarItems(_creationItems);
    controller.setAnnotationEditingToolbarItems(_editingItems);
  }

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
      appBar: AppBar(
        title: const Text('Annotation Toolbar Customization'),
        actions: [
          // Opens the (customized) creation tool picker.
          TextButton(
            onPressed: () => _controller?.enterAnnotationCreationMode(),
            child: const Text('Annotate'),
          ),
        ],
      ),
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
                // No `adapter:` — the view builds a CatalogAdapterController
                // from the registered factory and owns its lifecycle.
                return NutrientDocumentView<CatalogAdapterController>(
                  documentPath: snapshot.data!,
                  configuration: _configuration,
                  onControllerReady: _onControllerReady,
                );
              },
            ),
          ),
          const Divider(height: 1),
          const _StatusBar(),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

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
            Text(
              'Creation toolbar: ink · square · circle · line · markup group '
              '(Android & iOS), with the stylus button hidden on Android.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: BrandSpacing.xs),
            Text(
              'Tap “Annotate” to open the customized tool picker, then draw and '
              'select an annotation to see the trimmed editing bar (Web & '
              'Android). The same setAnnotation*ToolbarItems code runs on every '
              'platform.',
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
