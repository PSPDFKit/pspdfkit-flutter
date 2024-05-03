///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

class PageInfo {
  PageInfo({
    required this.pageIndex,
    required this.height,
    required this.width,
    required this.rotation,
    this.label = '',
  });

  /// The index of the page. This is a zero-based index.
  final int pageIndex;

  /// The height of the page in points.
  final double height;

  /// The width of the page in points.
  final double width;

  /// The rotation of the page in degrees.
  final int rotation;

  /// The label of the page.
  final String label;

  factory PageInfo.fromJson(dynamic pageInfo) {
    return PageInfo(
      pageIndex: pageInfo['index'],
      height: pageInfo['height'],
      width: pageInfo['width'],
      rotation: pageInfo['rotation'],
      label: pageInfo['label'],
    );
  }

  factory PageInfo.fromWebJson(pageInfo) {
    return PageInfo(
      pageIndex: pageInfo['index'],
      height: pageInfo['height'],
      width: pageInfo['width'],
      rotation: pageInfo['rotation'],
      label: pageInfo['label'],
    );
  }

  @override
  String toString() {
    return 'PageInfo{pageIndex: $pageIndex, height: $height, width: $width, rotation: $rotation, label: $label}';
  }
}
