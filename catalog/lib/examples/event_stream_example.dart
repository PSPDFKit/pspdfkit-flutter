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

/// Cross-platform event stream demo.
///
/// Subscribes to `controller.events` and renders a live log of typed
/// [NutrientEvent] values. The same code runs on Android, iOS and Web —
/// no platform imports are needed because all events on this stream are
/// part of the cross-platform surface.
class EventStreamExamplePage extends StatefulWidget {
  const EventStreamExamplePage({super.key});

  @override
  State<EventStreamExamplePage> createState() => _EventStreamExamplePageState();
}

class _EventStreamExamplePageState extends State<EventStreamExamplePage> {
  Future<String>? _documentPath;
  StreamSubscription<NutrientEvent>? _eventsSub;
  StreamSubscription<DocumentLoadedEvent>? _docLoadedSub;
  final List<String> _log = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentPath ??= CatalogDocuments.welcome(context);
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    _docLoadedSub?.cancel();
    super.dispose();
  }

  void _onControllerReady(NutrientController controller) {
    _eventsSub?.cancel();
    _eventsSub = controller.events.listen(_appendEvent);

    // The loaded document is now carried on the event itself, so we can act on
    // it directly — no need to reach back through the controller.
    _docLoadedSub?.cancel();
    _docLoadedSub = controller.events.documentLoaded.listen((event) async {
      final pageCount = await event.document.getPageCount();
      _pushLog('Loaded document has $pageCount page(s)');
    });
  }

  void _appendEvent(NutrientEvent event) => _pushLog(_format(event));

  // The annotation events expose full typed [Annotation] objects via
  // `annotations` (parsed from the underlying Instant JSON) — not just the
  // type. Each object carries `id`, `pageIndex`, `bbox`, `creatorName`, etc.
  String _annotationLabel(List<Annotation> annotations) => annotations.isEmpty
      ? '(none)'
      : annotations
          .map((a) => '${a.type.name} p${a.pageIndex}'
              '${a.id != null ? ' (${a.id})' : ''}')
          .join(', ');

  void _pushLog(String line) {
    if (!mounted) return;
    setState(() {
      _log.insert(0, line);
      // Keep the buffer bounded so the list stays responsive.
      if (_log.length > 100) _log.removeLast();
    });
  }

  // Sealed-class exhaustive switch — every cross-platform event has a
  // typed case. Adding a new event class will produce a compile error
  // here, which is the whole point of the typed stream.
  String _format(NutrientEvent event) => switch (event) {
        DocumentLoadedEvent() => 'Document loaded',
        DocumentErrorEvent(:final error) => 'Document error: $error',
        DocumentSavedEvent(:final path) =>
          'Document saved${path == null ? '' : ' → $path'}',
        PageChangedEvent(:final pageIndex) => 'Page → $pageIndex',
        PageClickedEvent(:final pageIndex, :final point) =>
          'Page $pageIndex clicked${point == null ? '' : ' at $point'}',
        AnnotationCreatedEvent(:final annotations) =>
          'Annotation created: ${_annotationLabel(annotations)}',
        AnnotationUpdatedEvent(:final annotations) =>
          'Annotation updated: ${_annotationLabel(annotations)}',
        AnnotationDeletedEvent(:final annotations) =>
          'Annotation deleted: ${_annotationLabel(annotations)}',
        AnnotationSelectedEvent(:final annotations) =>
          'Annotation selected: ${_annotationLabel(annotations)}',
        AnnotationDeselectedEvent(:final annotations) =>
          'Annotation deselected: ${_annotationLabel(annotations)}',
        TextSelectionChangedEvent(:final selectedText) =>
          'Text selection: ${selectedText ?? '(cleared)'}',
        FormFieldUpdatedEvent() => 'Form field updated',
        InstantSyncStartedEvent(:final documentId) =>
          'Instant sync started: $documentId',
        InstantSyncFinishedEvent(:final documentId) =>
          'Instant sync finished: $documentId',
        InstantSyncFailedEvent(:final documentId, :final error) =>
          'Instant sync failed: $documentId — $error',
        InstantAuthFinishedEvent(:final documentId) =>
          'Instant auth finished: $documentId',
        InstantAuthFailedEvent(:final documentId, :final error) =>
          'Instant auth failed: $documentId — $error',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Event Stream'),
        actions: [
          IconButton(
            tooltip: 'Clear log',
            icon: const Icon(Icons.delete_outline),
            onPressed: _log.isEmpty ? null : () => setState(() => _log.clear()),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              flex: 3,
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
            const Divider(height: 1),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(BrandSpacing.md),
                child: _log.isEmpty
                    ? Center(
                        child: Text(
                          'Interact with the document above to see events.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _log.length,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _log[i],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
