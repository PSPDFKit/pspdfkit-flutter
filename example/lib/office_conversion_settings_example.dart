///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Example demonstrating how to configure Office document conversion settings
/// for Excel spreadsheets when opening them in Nutrient Web.
class OfficeConversionSettingsExample extends StatefulWidget {
  final String documentPath;

  const OfficeConversionSettingsExample({
    super.key,
    required this.documentPath,
  });

  @override
  State<OfficeConversionSettingsExample> createState() =>
      _OfficeConversionSettingsExampleState();
}

class _OfficeConversionSettingsExampleState
    extends State<OfficeConversionSettingsExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Office Conversion Settings'),
      ),
      body: Column(
        children: [
          if (kIsWeb)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: const Text(
                'This example demonstrates Office document conversion settings for spreadsheets. '
                'The settings control the maximum dimensions of content rendered per sheet.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          Expanded(
            child: kIsWeb
                ? NutrientView(
                    documentPath: widget.documentPath,
                    configuration: PdfConfiguration(
                      webConfiguration: PdfWebConfiguration(
                        // Configure Office conversion settings for spreadsheets
                        officeConversionSettings:
                            const OfficeConversionSettings(
                          // Maximum height in millimeters per sheet (A4 height is 297mm)
                          spreadsheetMaximumContentHeightPerSheet: 500,
                          // Maximum width in millimeters per sheet (A4 width is 210mm)
                          spreadsheetMaximumContentWidthPerSheet: 300,
                        ),
                        // Other web configuration options
                        allowPrinting: true,
                        showAnnotations: true,
                        interactionMode: NutrientWebInteractionMode.pan,
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'Office conversion settings are only available on the web platform.',
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Example usage in a simple app
class OfficeConversionApp extends StatelessWidget {
  const OfficeConversionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Office Conversion Settings',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OfficeConversionSettingsExample(
        // This would be an Excel file (.xlsx) or other Office document
        documentPath: 'assets/sample_spreadsheet.xlsx',
      ),
    );
  }
}
