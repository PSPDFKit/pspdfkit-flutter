///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:typed_data';

import 'package:pspdfkit_flutter/src/document/document_save_options.dart';
import 'package:pspdfkit_flutter/src/document/page_info.dart';
import 'package:pspdfkit_flutter/src/forms/form_field.dart';

abstract class PdfDocument {
  final String documentId;

  PdfDocument({required this.documentId});

  /// Returns the page info for the given page index.
  /// pageIndex The index of the page. This is a zero-based index.
  Future<PageInfo> getPageInfo(int pageIndex);

  /// Exports the document as a PDF.
  /// options:[DocumentSaveOptions] The options to use when exporting the document.
  /// Returns a [Uint8List] containing the exported PDF data.
  Future<Uint8List> exportPdf({DocumentSaveOptions? options});

  /// Returns the form field with the given name.
  Future<PdfFormField> getFormField(String fieldName);

  /// Returns a list of all form fields in the document.
  Future<List<PdfFormField>> getFormFields();
}
