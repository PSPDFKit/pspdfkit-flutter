import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class PspdfkitEventListenerExample extends StatefulWidget {
  final String documentPath;
  const PspdfkitEventListenerExample({super.key, required this.documentPath});

  @override
  State<PspdfkitEventListenerExample> createState() =>
      _PspdfkitEventListenerExampleState();
}

class _PspdfkitEventListenerExampleState
    extends State<PspdfkitEventListenerExample> {
  var selectedText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PSPDFKit Event Listeners Example'),
      ),
      body: Stack(
        children: [
          PspdfkitWidget(
              documentPath: widget.documentPath,
              onPdfDocumentSaved: (documentId, path) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Document saved: $path'),
                ));
              },
              onPageClicked: (documentId, pageIndex, point, annotation) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Page clicked: $pageIndex'),
                ));
              },
              onPageChanged: (pageIndex) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Page changed: $pageIndex'),
                ));
              },
              onPspdfkitWidgetCreated: (controller) {
                controller.addEventListener(NutrientEvent.annotationsCreated,
                    (event) {
                  if (event is Map && event.containsKey('annotations')) {
                    final annotations =
                        event['annotations'] as List<Annotation>;
                    if (annotations.isNotEmpty) {
                      final annotation = annotations.first;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Annotation created: ${annotation.type} on page ${annotation.pageIndex}'),
                      ));
                    }
                  }
                });
                controller.addEventListener(NutrientEvent.annotationsUpdated,
                    (event) {
                  if (event is Map && event.containsKey('annotations')) {
                    final annotations =
                        event['annotations'] as List<Annotation>;
                    if (annotations.isNotEmpty) {
                      final annotation = annotations.first;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Annotation updated: ${annotation.type} on page ${annotation.pageIndex}'),
                      ));
                    }
                  }
                });
                controller.addEventListener(NutrientEvent.annotationsDeleted,
                    (event) {
                  if (event is Map && event.containsKey('annotations')) {
                    final annotations =
                        event['annotations'] as List<Annotation>;
                    if (annotations.isNotEmpty) {
                      final annotation = annotations.first;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Annotation deleted: ${annotation.type} on page ${annotation.pageIndex}'),
                      ));
                    }
                  }
                });
                controller.addEventListener(NutrientEvent.annotationsSelected,
                    (event) {
                  if (event is Map && event.containsKey('annotations')) {
                    final annotations =
                        event['annotations'] as List<Annotation>;
                    if (annotations.isNotEmpty) {
                      final annotation = annotations.first;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Annotation selected: ${annotation.type} on page ${annotation.pageIndex}'),
                      ));
                    }
                  } else if (event is Map && event.containsKey('annotation')) {
                    final annotation = event['annotation'] as Annotation;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Annotation selected: ${annotation.type} on page ${annotation.pageIndex}'),
                    ));
                  }
                });

                controller.addEventListener(NutrientEvent.annotationsDeselected,
                    (event) {
                  if (event is Map && event.containsKey('annotations')) {
                    final annotations =
                        event['annotations'] as List<Annotation>;
                    if (annotations.isNotEmpty) {
                      final annotation = annotations.first;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Annotation deselected: ${annotation.type} on page ${annotation.pageIndex}'),
                      ));
                    }
                  } else if (event is Map && event.containsKey('annotation')) {
                    final annotation = event['annotation'] as Annotation;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Annotation deselected: ${annotation.type} on page ${annotation.pageIndex}'),
                    ));
                  }
                });
                controller.addEventListener(NutrientEvent.formFieldSelected,
                    (event) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Form field selected: $event'),
                  ));
                });
                controller.addEventListener(NutrientEvent.formFieldDeselected,
                    (event) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Form field deselected: $event'),
                  ));
                });
                controller.addEventListener(
                    NutrientEvent.formFieldValuesUpdated, (event) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Form field value changed: $event'),
                  ));
                });
                controller.addEventListener(NutrientEvent.textSelectionChanged,
                    (event) {
                  setState(() {
                    selectedText = event['text'];
                  });
                });
              }),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: Text(selectedText),
            ),
          ),
        ],
      ),
    );
  }
}
