import 'package:pspdfkit_flutter/pspdfkit.dart';

class AnnotationUtils {
  static List<Annotation> annotationsFromInstantJSON(
      Map<String, dynamic> json) {
    List annotationsJSON = <Map<String, dynamic>>[];
    Map<String, Map<String, dynamic>>? attachments;

    if (json['annotations'] != null) {
      annotationsJSON = (json['annotations'] as List);

      if (json['attachments'] != null) {
        attachments = (json['attachments'] as Map<String, dynamic>)
            .cast<String, Map<String, dynamic>>();
      }

      var annotations = (annotationsJSON)
          .map((e) =>
              Annotation.fromJson(e as Map<String, dynamic>, attachments))
          .toList();
      return annotations;
    }
    return [];
  }
}
