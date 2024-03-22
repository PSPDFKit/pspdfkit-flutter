import 'processor.dart';

///  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// PDF page from an Image path
class PdfImagePage {
  /// Image from URI */
  final Uri imageUri;

  /// Image position, either gravity or actual rect */
  //  final PagePosition position;
  final PagePosition position;

  /// Image compression quality
  final int quality;

  /// Page rotation in degrees, ranges form -270 to 270*/
  final int rotation;

  final PageZOrder zOrder;

  PdfImagePage(
      {required this.imageUri,
      required this.position,
      required this.zOrder,
      this.quality = 98,
      this.rotation = 0});

  factory PdfImagePage.fromUri(Uri fileUri, PagePosition positionRect) {
    return PdfImagePage(
        imageUri: fileUri,
        position: positionRect,
        zOrder: PageZOrder.foreground);
  }

  factory PdfImagePage.fromPath(String filePath, PagePosition positionRect) {
    return PdfImagePage(
        imageUri: Uri.file(filePath),
        position: positionRect,
        zOrder: PageZOrder.foreground);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'imageUri': imageUri.toString(),
      'position': position.position,
      'quality': quality,
      'rotation': rotation,
      'zOrder': zOrder.order
    };
    return map;
  }
}
