///
///  Copyright @ 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

import 'utils/file_utils.dart';
import 'widgets/pdf_viewer_scaffold.dart';
import 'widgets/annotation_flags_panel.dart';

const String _documentPath = 'PDFs/PSPDFKit.pdf';

class AnnotationFlagsExample extends StatefulWidget {
  const AnnotationFlagsExample({Key? key}) : super(key: key);

  @override
  State<AnnotationFlagsExample> createState() => _AnnotationFlagsExampleState();
}

class _AnnotationFlagsExampleState extends State<AnnotationFlagsExample> {
  NutrientViewController? widgetController;
  PdfDocument? document;
  String? documentPath;
  late bool documentLoaded = false;
  Annotation? selectedAnnotation;
  Set<AnnotationFlag> selectedFlags = {};

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  @override
  void dispose() {
    if (widgetController != null) {
      widgetController?.removeEventListener(
        NutrientEvent.annotationsSelected,
      );
    }
    super.dispose();
  }

  Future<void> _loadDocument() async {
    try {
      final file = await extractAsset(context, _documentPath);
      documentPath = file.path;
      setState(() {
        documentLoaded = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading document: $e');
      }
    }
  }

  void _setWidgetController(NutrientViewController controller) {
    setState(() {
      widgetController = controller;
    });

    controller.addEventListener(
      NutrientEvent.annotationsSelected,
      _handleAnnotationSelected,
    );
  }

  void _handleAnnotationSelected(dynamic event) async {
    try {
      // Parse the event data - it can be a Map or Annotation object directly
      if (event is Annotation) {
        // Directly use the annotation object
        setState(() {
          selectedAnnotation = event;
          selectedFlags = Set<AnnotationFlag>.from(event.flags ?? []);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected annotation: ${event.id ?? 'Unknown'}'),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Handle the case where event is a Map
      final Map<String, dynamic> eventData = event is Map<String, dynamic>
          ? event
          : Map<String, dynamic>.from(event);

      // The event data contains an 'annotation' field with the annotation object
      final dynamic annotationData = eventData['annotation'];
      if (annotationData == null) {
        if (kDebugMode) {
          print('Annotation data not found in event');
        }
        return;
      }

      // If annotationData is already an Annotation object, use it directly
      if (annotationData is Annotation) {
        setState(() {
          selectedAnnotation = annotationData;
          selectedFlags = Set<AnnotationFlag>.from(annotationData.flags ?? []);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected annotation: ${annotationData.type}'),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // If it's a Map, extract page index and ID
      final int pageIndex = annotationData['pageIndex'] as int;
      final String annotationId = annotationData['id'] as String;

      // Get all annotations on the page to find the selected one
      final List<Annotation> pageAnnotations =
          await document?.getAnnotations(pageIndex, AnnotationType.all) ?? [];

      // Find the annotation with matching ID
      Annotation? matchingAnnotation;

      for (final annotation in pageAnnotations) {
        if (annotation.id == annotationId) {
          matchingAnnotation = annotation;
          break;
        }
      }

      if (matchingAnnotation != null) {
        setState(() {
          selectedAnnotation = matchingAnnotation;
          selectedFlags =
              Set<AnnotationFlag>.from(matchingAnnotation?.flags ?? []);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Selected annotation: ${matchingAnnotation.id ?? 'Unknown'}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling annotation selection: $e');
      }
    }
  }

  // Called when an annotation is added from the panel
  void _handleAnnotationAdded(Annotation annotation) async {
    // Make sure we get the fully initialized annotation from the document
    if (document != null) {
      final List<Annotation> annotations = await document!
          .getAnnotations(annotation.pageIndex, AnnotationType.all);

      // Find the newly added annotation by comparing properties
      for (final docAnnotation in annotations) {
        if (docAnnotation.id == annotation.id) {
          setState(() {
            selectedAnnotation = docAnnotation;
            selectedFlags = Set<AnnotationFlag>.from(docAnnotation.flags ?? []);
          });
          break;
        }
      }
    }
  }

  // Called when an annotation is updated from the panel
  void _handleAnnotationUpdated(Annotation annotation) async {
    // Refresh the selected annotation to get the latest state
    if (document != null && selectedAnnotation != null) {
      final List<Annotation> annotations = await document!
          .getAnnotations(annotation.pageIndex, AnnotationType.all);

      // Find the updated annotation
      for (final docAnnotation in annotations) {
        if (docAnnotation.id == annotation.id) {
          setState(() {
            selectedAnnotation = docAnnotation;
            selectedFlags = Set<AnnotationFlag>.from(docAnnotation.flags ?? []);
          });
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!documentLoaded || documentPath == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PdfViewerScaffold(
      documentPath: documentPath!,
      appBar: AppBar(
        title: const Text('Annotation Flags Example'),
      ),
      onNutrientWidgetCreated: _setWidgetController,
      onPdfDocumentLoaded: (doc) {
        setState(() {
          document = doc;
        });
      },
      controlPanels: [
        // Annotation flags panel
        AnnotationFlagsPanel(
          document: document,
          selectedAnnotation: selectedAnnotation,
          selectedFlags: selectedFlags,
          onAnnotationSelected: (annotation) {
            setState(() {
              selectedAnnotation = annotation;
              selectedFlags = Set<AnnotationFlag>.from(annotation?.flags ?? []);
            });
          },
          onAnnotationAdded: _handleAnnotationAdded,
          onAnnotationUpdated: _handleAnnotationUpdated,
          onFlagsChanged: (flags) {
            setState(() {
              selectedFlags = flags;
            });
          },
          initialPosition: const Offset(20, 20),
          initiallyExpanded: selectedAnnotation != null,
        ),

        // Document properties panel (just an example of adding multiple panels)
      ],
    );
  }
}
