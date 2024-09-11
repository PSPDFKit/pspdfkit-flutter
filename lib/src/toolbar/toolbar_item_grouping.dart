///
///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:pspdfkit_flutter/src/toolbar/annotation_toolbar_items.dart';

class AnnotationToolsGroup {
  final List<AnnotationToolbarItem> items;
  final String? id;
  final AnnotationToolbarItem? type;

  AnnotationToolsGroup({required this.items, required this.type, this.id});

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((e) => e.name).toList(),
      'key': type?.name ?? ''
    };
  }

  Map<String, dynamic> toWebMap() {
    return {
      'items': items.map((e) => e.name).toList(),
      'id': id,
    };
  }
}
