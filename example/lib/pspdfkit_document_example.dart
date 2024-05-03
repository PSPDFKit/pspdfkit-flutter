import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'utils/platform_utils.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class PspdfkitDocumentExample extends StatefulWidget {
  final String documentPath;

  const PspdfkitDocumentExample({super.key, required this.documentPath});

  @override
  State<PspdfkitDocumentExample> createState() =>
      _PspdfkitDocumentExampleState();
}

class _PspdfkitDocumentExampleState extends State<PspdfkitDocumentExample> {
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
                                userPassword: '12345',
                                ownerPassword: '12345',
                                excludeAnnotations: true,
                                permissions: [
                                  DocumentPermissions.printHighQuality
                                ],
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
              child: PspdfkitWidget(
                documentPath: widget.documentPath,
                onPdfDocumentLoaded: (PdfDocument document) async {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Document loaded ${document.documentId}')));
                  setState(() {
                    _document = document;
                  });
                },
                onPageChanged: (pageIndex) {
                  _document?.getPageInfo(pageIndex).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Page changed to $value')));
                  });
                },
              ))),
    );
  }
}
