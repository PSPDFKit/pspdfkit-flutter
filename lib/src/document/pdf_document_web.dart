///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:typed_data';

import 'package:pspdfkit_flutter/src/document/page_info.dart';
import 'package:pspdfkit_flutter/src/web/pspdfkit_web_instance.dart';

import '../forms/form_field.dart';
import 'document_save_options.dart';
import 'pdf_document.dart';

class PdfDocumentWeb extends PdfDocument {
  final PspdfkitWebInstance _instance;

  PdfDocumentWeb(
      {required super.documentId, required PspdfkitWebInstance instance})
      : _instance = instance;

  @override
  Future<PageInfo> getPageInfo(int pageIndex) {
    return _instance.getPageInfo(pageIndex);
  }

  @override
  Future<Uint8List> exportPdf({DocumentSaveOptions? options}) {
    return _instance.exportPdf(options: options);
  }

  @override
  Future<PdfFormField> getFormField(String fieldName) {
    throw UnimplementedError();
  }

  @override
  Future<List<PdfFormField>> getFormFields() {
    return _instance.getFormFields();
  }

}
