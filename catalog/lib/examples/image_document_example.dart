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

/// Image Document example.
///
/// Demonstrates opening a JPG photo through the **same** [NutrientDocumentView]
/// used for PDFs — image documents are auto-detected by file extension, so the
/// integration is identical to the Basic example, just with an image path.
/// The image renders as a single annotatable page.
///
/// To prove the image really loaded as a document (not just that the page
/// navigated), the Flutter-owned status bar reads
/// `controller.document.getPageCount()` once the controller is ready and
/// reports `Image loaded · 1 page` — Maestro asserts on that text. The bar
/// also subscribes to `controller.events` and surfaces the latest typed
/// event, proving the cross-platform event stream works for image documents
/// too (draw an annotation to see `AnnotationCreatedEvent`).
///
/// **Platform note:** on Android, image documents can't be written to a new
/// path with `document.save(outputPath:)` — annotations are persisted into
/// the image's XMP metadata by the native autosave instead.
class ImageDocumentExamplePage extends StatefulWidget {
  const ImageDocumentExamplePage({super.key});

  @override
  State<ImageDocumentExamplePage> createState() =>
      _ImageDocumentExamplePageState();
}

class _ImageDocumentExamplePageState extends State<ImageDocumentExamplePage> {
  Future<String>? _documentPath;
  String _status = 'Loading image…';
  String? _lastEvent;
  StreamSubscription<NutrientEvent>? _eventsSub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resolve once — the future is reused across rebuilds.
    _documentPath ??= CatalogDocuments.imageDocument(context);
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    super.dispose();
  }

  Future<void> _onControllerReady(NutrientController controller) async {
    _eventsSub ??= controller.events.listen((event) {
      if (!mounted) return;
      setState(() => _lastEvent = _eventName(event));
    });
    try {
      final pageCount = await controller.document.getPageCount();
      if (!mounted) return;
      setState(() {
        _status = 'Image loaded · $pageCount page${pageCount == 1 ? '' : 's'}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Failed to read page count: $error');
    }
  }

  // A readable event label — `runtimeType` is unusable here because dart2js
  // minifies class names in release web builds (it renders as "minified:oK").
  // Non-exhaustive on purpose: this example only highlights the common
  // viewer events; anything else falls back to a generic label.
  String _eventName(NutrientEvent event) => switch (event) {
        DocumentLoadedEvent() => 'DocumentLoadedEvent',
        DocumentSavedEvent() => 'DocumentSavedEvent',
        PageChangedEvent() => 'PageChangedEvent',
        PageClickedEvent() => 'PageClickedEvent',
        AnnotationCreatedEvent() => 'AnnotationCreatedEvent',
        AnnotationUpdatedEvent() => 'AnnotationUpdatedEvent',
        AnnotationDeletedEvent() => 'AnnotationDeletedEvent',
        AnnotationSelectedEvent() => 'AnnotationSelectedEvent',
        AnnotationDeselectedEvent() => 'AnnotationDeselectedEvent',
        _ => 'NutrientEvent',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Image Document')),
      // The status bar lives in the bottom slot so it stays Flutter-owned and
      // Maestro-reachable even after the native viewer takes a11y focus.
      bottomNavigationBar: SafeArea(
        top: false,
        child: _ImageStatusBar(status: _status, lastEvent: _lastEvent),
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
          // A .jpg path — the view opens it as an image document.
          return NutrientDocumentView(
            documentPath: snapshot.data!,
            onControllerReady: _onControllerReady,
          );
        },
      ),
    );
  }
}

class _ImageStatusBar extends StatelessWidget {
  final String status;
  final String? lastEvent;

  const _ImageStatusBar({required this.status, required this.lastEvent});

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
            const SizedBox(height: BrandSpacing.xxs),
            Text(
              lastEvent == null
                  ? 'Last event: none yet — draw an annotation'
                  : 'Last event: $lastEvent',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
