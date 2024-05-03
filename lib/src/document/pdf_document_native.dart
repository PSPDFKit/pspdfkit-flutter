///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter/services.dart';
import 'package:pspdfkit_flutter/src/document/page_info.dart';

import 'document_save_options.dart';
import 'pdf_document.dart';

class PdfDocumentNative extends PdfDocument {
  final MethodChannel _channel;

  PdfDocumentNative({required MethodChannel channel, required super.documentId})
      : _channel = channel;

  @override
  Future<PageInfo> getPageInfo(int pageIndex) =>
      _channel.invokeMethod('getPageInfo', <String, dynamic>{
        'pageIndex': pageIndex,
      }).then((results) {
        if (results == null) {
          throw Exception('Page info is null');
        }
        return PageInfo.fromJson(results);
      }).catchError((error) {
        throw Exception('Error getting page info: $error');
      });

  @override
  Future<Uint8List> exportPdf({DocumentSaveOptions? options}) {
    return _channel.invokeMethod('exportPdf', <String, dynamic>{
      'options': options?.toMap() ?? {},
    }).then((results) {
      if (results == null) {
        throw Exception('Exported PDF is null');
      }
      return Uint8List.fromList(results.cast<int>());
    }).catchError((error) {
      throw Exception('Error exporting PDF: $error');
    });
  }
}
