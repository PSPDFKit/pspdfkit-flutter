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
