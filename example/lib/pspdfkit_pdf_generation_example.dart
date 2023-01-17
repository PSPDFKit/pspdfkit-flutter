///
///  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pspdfkit_example/utils/file_utils.dart';
import 'package:pspdfkit_example/utils/platform_utils.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

import 'dart:io';

class PspdfkitPDFGenerationExampleWidget extends StatelessWidget {
  final PspdfkitProcessor pdfProcessor = PspdfkitProcessor.instance;

  PspdfkitPDFGenerationExampleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: PlatformUtils.isAndroid(),
      appBar: AppBar(
        title: const Text('PDF generation'),
      ),
      body: ListView(
        children: [
          ListTile(
              title: const Text('Generate PDF from Template'),
              subtitle: const Text(
                  'Generate a PDF from an existing PDF Document pages.'),
              onTap: () => _generateFromTemplate(context)
                  .then((value) => Pspdfkit.present(value))),
          const Divider(),
          ListTile(
            title: const Text('Generate PDF from Image'),
            subtitle: const Text('Generate a PDF from an image file.'),
            onTap: () => _generateFromImage(context)
                .then((value) => Pspdfkit.present(value)),
          ),
          const Divider(),
          ListTile(
            title: const Text('Generate PDF from Pattern'),
            subtitle: const Text(
                'generate PDF from a Pattern of tiled PDF document page.'),
            onTap: () => _generateFromPattern(context)
                .then((value) => Pspdfkit.present(value)),
          ),
          const Divider(),
          ListTile(
            title: const Text('Generate PDF from HTML String'),
            subtitle: const Text('Generate a PDF from a plain HTML string.'),
            onTap: () => _generateFromHtmlString(context)
                .then((value) => Pspdfkit.present(value)),
          ),
          const Divider(),
          ListTile(
            title: const Text('Generate PDF from HTML URI'),
            subtitle:
                const Text('Generate a PDF from an HTML file URI or URL.'),
            onTap: () {
              _progressDialogue(context);
              _generateFromHtmlUri(context).then((value) {
                _dismissProgressDialogue(context);
                Pspdfkit.present(value);
              });
            },
          ),
        ],
      ),
    );
  }

  /// Generates a PDF from an image.
  Future<String> _generateFromImage(BuildContext context) async {
    File img = await extractAsset(context, 'PDFs/PSPDFKit_Image_Example.jpg');

    String outputPath = await getOutputPath('pspdfkit_generated_image.pdf');

    var pages = [
      NewPage.fromImage(PdfImagePage.fromUri(img.uri, PagePosition.center),
          pageSize: PageSize.a4),
      NewPage.fromImage(PdfImagePage.fromUri(img.uri, PagePosition.bottom),
          pageSize: PageSize.a4),
      NewPage.fromImage(PdfImagePage.fromUri(img.uri, PagePosition.top),
          pageSize: PageSize.a4)
    ];

    var filePath = await pdfProcessor.generatePdf(
        pages, outputPath); // or generatePDFFromImage

    if (filePath != null) {
      return filePath;
    } else {
      throw Exception('Error generating PDF');
    }
  }

  /// Generates a PDF from an existig PDF document page.
  Future<String> _generateFromTemplate(BuildContext context) async {
    File sourceDocument = await extractAsset(context, 'PDFs/PSPDFKit.pdf');

    String outputPath = await getOutputPath('pspdfkit_generated_template.pdf');

    var pages = [
      NewPage.fromPdfPage(PdfPage(
        sourceDocumentUri: sourceDocument.uri,
        pageIndex: 4,
        position: PagePosition.center,
        zOrder: PageZOrder.foreground,
      ))
    ];

    var filePath = await pdfProcessor.generatePdf(pages, outputPath);

    if (filePath != null) {
      return filePath;
    } else {
      throw Exception('Error generating PDF from template');
    }
  }

  /// Generate a PDF from a pattern or tiled PDF document page.
  Future<String> _generateFromPattern(BuildContext context) async {
    File patternDocument =
        await extractAsset(context, 'PDFs/template_sample.pdf');

    String outputPath = await getOutputPath('pspdfkit_generated_blank.pdf');

    List<NewPage> pages = [
      NewPage.fromPattern(PagePattern.blank, pageSize: PageSize.a4),
      NewPage.fromPattern(PagePattern.grid5mm, pageSize: PageSize.a5),
      NewPage.fromPattern(PagePattern.line5mm, pageSize: PageSize.usLetter),
      NewPage.fromPattern(PagePattern.dots5mm, pageSize: PageSize.a0),
      // Page from tiled PDF document
      NewPage.fromPattern(PagePattern.fromDocument(patternDocument.uri, 0),
          pageSize: PageSize.a4),
    ];
    var filePath = await pdfProcessor.generatePdf(pages, outputPath);

    if (filePath != null) {
      return filePath;
    } else {
      throw Exception('Error generating PDF');
    }
  }

  /// Generate a PDF from a plain HTML string.
  Future<String> _generateFromHtmlString(BuildContext context) async {
    final html = await rootBundle.loadString('PDFs/PSPDFKit.html');
    final outputFilePath = await getOutputPath('PDFs/html_String.pdf');

    var filePath =
        await pdfProcessor.generatePdfFromHtmlString(html, outputFilePath);

    if (filePath != null) {
      return filePath;
    } else {
      throw Exception('Error generating PDF from HTML');
    }
  }

  /// Generate a PDF from a HTML file URI or URL.
  Future<String> _generateFromHtmlUri(BuildContext context) async {
    final htmlUri = PlatformUtils.isAndroid()
        ? 'file:///android_asset/html-conversion/invoice.html'
        : 'https://pspdfkit.com';

    String outputPath = await getOutputPath('pspdfkit_generated_html.pdf');

    var filePath = await pdfProcessor.generatePdfFromHtmlUri(
        Uri.parse(htmlUri), outputPath);

    if (filePath != null) {
      return filePath;
    } else {
      throw Exception('Error generating PDF from HTML');
    }
  }

  // Show progress loader while generating PDF
  void _progressDialogue(BuildContext context) {
    //set up the AlertDialog
    AlertDialog alert = const AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: CircularProgressIndicator(),
      ),
    );

    showDialog<void>(
      //prevent outside touch
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        //prevent Back button press
        return WillPopScope(onWillPop: () async => false, child: alert);
      },
    );
  }

  void _dismissProgressDialogue(BuildContext context) {
    Navigator.of(context).pop();
  }
}
