///
///  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// PDF page from page pattern or a pattern tiled document page.
class PagePattern {
  final String? pattern;
  final Uri? documentUri;
  final int pageIndex;

  PagePattern._({this.pattern, this.documentUri, this.pageIndex = 0});

  /// No pattern, empty page.
  static PagePattern get blank {
    return PagePattern._(pattern: 'BLANK');
  }

  /// Dots with 5mm pitch.
  static PagePattern get dots5mm {
    return PagePattern._(pattern: 'DOTS_5MM');
  }

  /// Grid with 5mm squares.
  static PagePattern get grid5mm {
    return PagePattern._(pattern: 'GRID_5MM');
  }

  /// Lines with 5mm of spacing.
  static PagePattern get line5mm {
    return PagePattern._(pattern: 'LINES_5MM');
  }

  /// Lines with 7mm of spacing.
  static PagePattern get line7mm {
    return PagePattern._(pattern: 'LINES_7MM');
  }

  /// Pattern from a pattern tiled PDF document.
  /// [patternDocumentUri] is the path to the document.
  /// [pageIndex] is the page index of the document. used only on iOS.
  ///
  factory PagePattern.fromDocument(Uri patternDocumentUri, int pageIndex) {
    return PagePattern._(documentUri: patternDocumentUri, pageIndex: pageIndex);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pattern': pattern,
      'patternDocument': documentUri?.toString(),
      'pageIndex': pageIndex,
    };
  }
}
