// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import 'design/design.dart';
import 'examples/ai_assistant_example.dart';
import 'examples/annotation_creation_mode_example.dart';
import 'examples/annotation_properties_example.dart';
import 'examples/annotation_toolbar_customization_example.dart';
import 'examples/annotations_example.dart';
import 'examples/basic_example.dart';
import 'examples/bookmarks_example.dart';
import 'examples/coordinate_conversion_example.dart';
import 'examples/custom_configuration_example.dart';
import 'examples/custom_data_example.dart';
import 'examples/document_example.dart';
import 'examples/document_from_bytes_example.dart';
import 'examples/event_stream_example.dart';
import 'examples/form_filling_example.dart';
import 'examples/headless_document_example.dart';
import 'examples/image_document_example.dart';
import 'examples/instant_example.dart';
import 'examples/manual_save_example.dart';
import 'examples/measurement_tools_example.dart';
import 'examples/password_protected_example.dart';
import 'examples/platform_adapter_example.dart';
import 'examples/platform_style_example.dart';
import 'examples/save_as_example.dart';
import 'examples/theme_example.dart';
import 'examples/toolbar_customization_example.dart';
import 'examples/two_widgets_example.dart';
import 'examples/zoom_to_rect_example.dart';

/// Platform-qualified SDK label for the running platform — e.g.
/// "Nutrient Android SDK". Falls back to "Nutrient SDK" off the three
/// supported platforms.
String get _nutrientSdkLabel {
  final platform = kIsWeb
      ? 'Web'
      : switch (defaultTargetPlatform) {
          TargetPlatform.android => 'Android',
          TargetPlatform.iOS => 'iOS',
          _ => '',
        };
  return platform.isEmpty ? 'Nutrient SDK' : 'Nutrient $platform SDK';
}

/// Catalog home page.
///
/// Renders the Nutrient wordmark above a list of catalog examples. Tap an
/// example to navigate to its dedicated page.
class CatalogHomePage extends StatelessWidget {
  const CatalogHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(BrandSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wordmark — switches to inverse on dark backgrounds.
              Image.asset(
                isDark ? BrandAssets.logoInverse : BrandAssets.logo,
                height: 28,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: BrandSpacing.xl),
              Text('Flutter SDK Catalog', style: theme.textTheme.displaySmall),
              const SizedBox(height: BrandSpacing.sm),
              Text(
                'Tap an example to see the Nutrient Flutter SDK in action.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: BrandSpacing.md),
              // The underlying native SDK version for the running platform,
              // resolved from the active platform adapter — e.g.
              // "Nutrient Android SDK 11.5.1". Rendered as an accent badge so
              // it's easy to spot.
              FutureBuilder<String?>(
                future: Nutrient.frameworkVersion,
                builder: (context, snapshot) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BrandSpacing.md,
                    vertical: BrandSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: BrandColors.codeCoral.withValues(alpha: 0.12),
                    borderRadius: BrandRadius.brMd,
                  ),
                  child: Text(
                    '$_nutrientSdkLabel ${snapshot.data ?? '…'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: BrandColors.codeCoral,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: BrandSpacing.xl),
              Expanded(
                child: ListView(
                  children: [
                    // Main features — ordered by SDK feature prominence (viewing, document, annotations, forms, AI, collaboration).
                    _ExampleTile(
                      title: 'Basic Example',
                      description:
                          'Load and display a PDF in the default viewer.',
                      icon: Icons.picture_as_pdf_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BasicExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Document',
                      description:
                          'Read the page count and dimensions, then export a flattened copy.',
                      icon: Icons.description_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DocumentExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Headless Document',
                      description:
                          'Open a PDF without a viewer to read its pages, annotations, and bookmarks.',
                      icon: Icons.code_rounded,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HeadlessDocumentExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Document from Bytes',
                      description:
                          'Open a PDF from in-memory bytes, in the viewer and headlessly, with no file path.',
                      icon: Icons.memory_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DocumentFromBytesExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Image Document',
                      description:
                          'Open a JPG photo as a single annotatable page, detected by its file extension.',
                      icon: Icons.image_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ImageDocumentExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Password Protected',
                      description:
                          'Unlock and open an encrypted PDF by supplying its password.',
                      icon: Icons.lock_open_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PasswordProtectedExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Annotations',
                      description:
                          'Import, export, and clear annotations using Instant JSON and XFDF.',
                      icon: Icons.draw_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AnnotationsExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Annotation Creation Mode',
                      description:
                          'Activate ink, text, shape, and measurement tools, then return to viewing.',
                      icon: Icons.brush_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const AnnotationCreationModeExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Annotation Properties',
                      description:
                          'Select an annotation and edit its colour, opacity, line width, and note.',
                      icon: Icons.tune_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const AnnotationPropertiesExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Measurement Tools',
                      description:
                          'Measure distances, perimeters, and areas on a scaled drawing.',
                      icon: Icons.straighten_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MeasurementToolsExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Form Filling',
                      description:
                          'Read, set, and list form field values on a fillable PDF.',
                      icon: Icons.edit_note_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FormFillingExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'AI Assistant',
                      description:
                          'Chat with an AI assistant to summarise, translate, and ask about the document.',
                      icon: Icons.smart_toy_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AiAssistantExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Instant View',
                      description:
                          'Open a document with real-time collaboration from a Document Engine.',
                      icon: Icons.sync_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InstantExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Bookmarks',
                      description:
                          'Add, rename, remove, and list bookmarks, and check whether a page is bookmarked.',
                      icon: Icons.bookmarks_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BookmarksExamplePage(),
                        ),
                      ),
                    ),
                    // Customization features — viewer configuration, theming, toolbars.
                    _ExampleTile(
                      title: 'Custom Configuration',
                      description:
                          'Live-switch scroll direction, page layout, appearance, and autosave.',
                      icon: Icons.tune_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const CustomConfigurationExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Custom Data',
                      description:
                          'Attach custom data to an annotation and read it back to confirm the round-trip.',
                      icon: Icons.data_object_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CustomDataExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Themes',
                      description:
                          'Switch between light, night, and sepia appearances, with custom Android themes.',
                      icon: Icons.palette_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ThemeExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Platform Style',
                      description:
                          'Wrap the viewer in platform-idiomatic chrome: Cupertino on iOS, Material elsewhere.',
                      icon: Icons.style_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PlatformStyleExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Toolbar Customization',
                      description:
                          'Add a custom main-toolbar button wired to a callback, shared across platforms.',
                      icon: Icons.build_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const ToolbarCustomizationExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Annotation Toolbar Customization',
                      description:
                          'Reorder and group the annotation tools and trim the selected-annotation editing bar.',
                      icon: Icons.draw_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const AnnotationToolbarCustomizationExamplePage(),
                        ),
                      ),
                    ),
                    // Utility features — events, adapter, navigation, saving, advanced layout.
                    _ExampleTile(
                      title: 'Event Stream',
                      description:
                          'Watch a live log of typed document, page, and annotation events.',
                      icon: Icons.bolt_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EventStreamExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Platform Adapter',
                      description:
                          'Combine cross-platform events with platform-only hooks and page navigation.',
                      icon: Icons.layers_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PlatformAdapterExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Coordinate Conversion',
                      description:
                          'Convert a point between view and PDF coordinate spaces and back.',
                      icon: Icons.my_location_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const CoordinateConversionExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Zoom to Rect',
                      description:
                          'Zoom the viewport to a page region, then read back the zoom and visible area.',
                      icon: Icons.zoom_in,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ZoomToRectExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Manual Save',
                      description:
                          'Disable autosave, track unsaved changes, guard the back button, and save on demand.',
                      icon: Icons.save_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ManualSaveExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Save As',
                      description:
                          'Write the document to a new file, then reopen the copy to confirm its page count.',
                      icon: Icons.save_as_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SaveAsExamplePage(),
                        ),
                      ),
                    ),
                    _ExampleTile(
                      title: 'Two Widgets',
                      description:
                          'Render two document viewers at once, each kept independent.',
                      icon: Icons.splitscreen_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TwoWidgetsExamplePage(),
                        ),
                      ),
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

/// A single example list tile, rendered as a card with the brand styling.
class _ExampleTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ExampleTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: BrandSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(BrandSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: BrandColors.codeCoral.withValues(alpha: 0.12),
                  borderRadius: BrandRadius.brMd,
                ),
                child: Icon(icon, size: 22, color: BrandColors.codeCoral),
              ),
              const SizedBox(width: BrandSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: BrandSpacing.xxs),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: BrandSpacing.sm),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
