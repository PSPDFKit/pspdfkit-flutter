///
///  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
///
part of pspdfkit;

/// Represents a new PDF page of any type.
class NewPage {
  /// Page size in PDF points.
  final PageSize pageSize;

  /// Page margin in PDF points.
  final EdgeInsets? margins;

  /// Page rotation ranging from = -270 to 270)
  final int? rotation;

  final Color? backgroundColor;

  // From tiled pattern
  final PagePattern? sourcePattern;

  /// Image added to a page. */
  final PdfImagePage? imagePage;

  /// PDF added to a page. */
  final PdfPage? pdfPage;

  final String type;

  NewPage._(
      {required this.type,
      required this.pageSize,
      this.margins,
      this.rotation,
      this.backgroundColor,
      this.sourcePattern,
      this.imagePage,
      this.pdfPage});

  /// New page from tiled pattern
  /// [pattern] The pattern to use for the page.
  /// [pageSize] The size of the page. Defaults to A4.
  /// [margins] The margins of the page. Defaults to 0.
  /// [rotation] The rotation of the page. Defaults to 0.
  /// [backgroundColor] The background color of the page. Defaults to white.
  factory NewPage.fromPattern(PagePattern pattern,
      {PageSize? pageSize,
      EdgeInsets? margins,
      int? rotation,
      Color? backgroundColor}) {
    return NewPage._(
        type: 'pattern',
        sourcePattern: pattern,
        pageSize: pageSize ?? PageSize.a4,
        margins: margins,
        rotation: rotation,
        backgroundColor: backgroundColor);
  }

  /// New page from image.
  /// [imagePage] The [PdfImagePage] to use for the page.
  /// [pageSize] The size of the page. Defaults to A4.
  /// [margins] The margins of the page. Defaults to 0.
  /// [rotation] The rotation of the page. Defaults to 0.
  /// [backgroundColor] The background color of the page. Defaults to white.
  factory NewPage.fromImage(PdfImagePage imagePage,
      {PageSize? pageSize,
      EdgeInsets? margins,
      int? rotation,
      Color? backgroundColor}) {
    return NewPage._(
        type: 'imagePage',
        imagePage: imagePage,
        pageSize: pageSize ?? PageSize.a4,
        margins: margins,
        rotation: rotation,
        backgroundColor: backgroundColor);
  }

  /// New page from template.
  /// [sourceDocumentge] The the [PdfPage] to use for the template.
  /// [pageSize] The size of the page. Defaults to A4.
  /// [margins] The margins of the page. Defaults to 0.
  /// [rotation] The rotation of the page. Defaults to 0.
  /// [backgroundColor] The background color of the page. Defaults to white.
  factory NewPage.fromPdfPage(PdfPage sourceDocument,
      {PageSize? pageSize,
      EdgeInsets? margins,
      int? rotation,
      Color? backgroundColor}) {
    return NewPage._(
        type: 'pdfPage',
        pdfPage: sourceDocument,
        pageSize: pageSize ?? PageSize.a4,
        margins: margins,
        rotation: rotation,
        backgroundColor: backgroundColor);
  }

  /// Convert page to map.
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'type': type,
      'pageSize': [pageSize.size.width, pageSize.size.height],
    };

    if (sourcePattern != null) {
      map['pattern'] = sourcePattern?.toMap();
    }

    if (imagePage != null) {
      map['imagePage'] = imagePage?.toMap();
    }

    if (pdfPage != null) {
      map['pdfPage'] = pdfPage?.toMap();
    }

    if (margins != null) {
      map['margins'] = [
        margins!.left,
        margins!.top,
        margins!.right,
        margins!.bottom
      ];
    }

    if (rotation != null) {
      map['rotation'] = rotation;
    }

    if (backgroundColor != null) {
      map['backgroundColor'] = backgroundColor?.value;
    }
    return map;
  }
}
