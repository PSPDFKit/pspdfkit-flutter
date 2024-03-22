import 'processor.dart';

///  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// This class represents a PDF page that can be passes to [generatePdf].
class PdfPage {
  /// Document URI
  final Uri sourceDocumentUri;

  /// Page index ranging from 0 to n-1
  final int pageIndex;

  /// Page position.
  final PagePosition position;

  /// Page zIndex with either FOREGROUND or BACKGROUND
  final PageZOrder zOrder;

  /// Document password for a protected document
  final String? password;

  PdfPage(
      {required this.sourceDocumentUri,
      required this.pageIndex,
      required this.position,
      required this.zOrder,
      this.password});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'documentUri': sourceDocumentUri.toString(),
      'pageIndex': pageIndex,
      'pagePosition': position.position,
      'zOrder': zOrder.order,
      'password': password
    };
  }
}
