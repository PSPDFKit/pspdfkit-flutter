// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'utils/platform_utils.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

class DocumentExample extends StatefulWidget {
  final String documentPath;

  const DocumentExample({super.key, required this.documentPath});

  @override
  State<DocumentExample> createState() => _DocumentExampleState();
}

class _DocumentExampleState extends State<DocumentExample> {
  PdfDocument? _document;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: PlatformUtils.isAndroid(),
      // Do not resize the the document view on Android or
      // it won't be rendered correctly when filling forms.
      resizeToAvoidBottomInset: PlatformUtils.isIOS(),
      appBar: AppBar(
        actions: [
          // Export button
          IconButton(
            onPressed: _document == null
                ? null
                : () {
                    _document
                        ?.exportPdf(
                            options: DocumentSaveOptions(
                                flatten: true,
                                excludeAnnotations: true,
                                optimize: true))
                        .then((Uint8List value) async {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Document exported to Uint8: ${value.length}')));
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $error')));
                    });
                  },
            icon: const Icon(Icons.file_download),
          ),
        ],
      ),

      body: SafeArea(
          top: false,
          bottom: false,
          child: Container(
              padding: PlatformUtils.isAndroid()
                  ? const EdgeInsets.only(top: kToolbarHeight)
                  : null,
              child: NutrientView(
                documentPath: widget.documentPath,
                onDocumentLoaded: (PdfDocument document) async {
                  var pageCount = await document.getPageCount();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Document loaded ${document.documentId} with $pageCount pages')));
                  setState(() {
                    _document = document;
                  });
                },
                onPageChanged: (pageIndex) {
                  _document?.getPageInfo(pageIndex).then((PageInfo value) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Page changed to ${value.pageIndex}, Rotation: ${value.rotation}')));
                  }).catchError((error) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error: $error')));
                  });
                },
              ))),
    );
  }
}
