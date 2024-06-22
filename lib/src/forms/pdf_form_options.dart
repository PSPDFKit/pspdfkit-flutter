///
///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

class PdfFormOption {
  final String value;
  final String label;

  PdfFormOption({required this.value, required this.label});

  static List<PdfFormOption> listFromMap(List<dynamic> list) {
    return list
        .map((e) => PdfFormOption(
              value: e['value'],
              label: e['label'],
            ))
        .toList();
  }
}
