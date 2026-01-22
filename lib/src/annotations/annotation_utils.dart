import 'package:nutrient_flutter/nutrient_flutter.dart';

class AnnotationUtils {
  static List<Annotation> annotationsFromInstantJSON(
      Map<String, dynamic> json) {
    List annotationsJSON = <Map<String, dynamic>>[];
    Map<String, Map<String, dynamic>>? attachments;

    if (json['annotations'] != null) {
      annotationsJSON = (json['annotations'] as List);

      if (json['attachments'] != null) {
        final rawAttachments = json['attachments'] as Map;
        attachments = <String, Map<String, dynamic>>{};
        rawAttachments.forEach((key, value) {
          attachments![key.toString()] = Map<String, dynamic>.from(value as Map);
        });
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
