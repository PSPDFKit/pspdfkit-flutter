///
///  Copyright © 2023-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

class OfficeToPdfExample extends StatefulWidget {
  const OfficeToPdfExample({super.key});

  @override
  State<OfficeToPdfExample> createState() => _OfficeToPdfExampleState();
}

class _OfficeToPdfExampleState extends State<OfficeToPdfExample> {
  static const String _excelDocumentPath = 'PDFs/test.docx';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Office to PDF Conversion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Office Document Support',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Nutrient Web SDK can load and display Office documents (Excel, Word, PowerPoint) directly. '
                      'The documents are converted to PDF format in the browser for viewing and annotation.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      'This example loads an Excel spreadsheet (test.xlsx) which will be '
                      'automatically displayed as a PDF in the viewer.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openOfficeDocument(context),
              icon: const Icon(Icons.table_chart),
              label: const Text('Open Excel Document'),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Supports Excel (.xlsx), Word (.docx), and PowerPoint (.pptx)\n'
                      '• Converts documents to PDF in the browser\n'
                      '• No server-side processing required\n'
                      '• Can export the converted document as PDF\n'
                      '• Supports annotations on converted documents',
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Note: Office document support is only available on Web platform for now',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOfficeDocument(BuildContext context) async {
    try {
      // Configure the viewer
      final configuration = PdfConfiguration(
        documentLabelEnabled: false,
        scrollDirection: ScrollDirection.vertical,
      );

      // Open the Office document
      // On Web, Nutrient will load the Office file and display it as PDF
      await Navigator.push<dynamic>(
        context,
        MaterialPageRoute(
          builder: (_) => NutrientView(
            documentPath: _excelDocumentPath,
            configuration: configuration,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open Office document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
