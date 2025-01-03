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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Annotation created: $event'),
                  ));
                });
                controller.addEventListener(NutrientEvent.annotationsUpdated,
                    (event) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Annotation updated: $event'),
                  ));
                });
                controller.addEventListener(NutrientEvent.annotationsDeleted,
                    (event) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Annotation deleted: $event'),
                  ));
                });
                controller.addEventListener(NutrientEvent.annotationsSelected,
                    (event) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Annotation selected: $event'),
                  ));
                });

                controller.addEventListener(NutrientEvent.annotationsDeselected,
                    (event) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Annotation deselected : $event'),
                  ));
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
