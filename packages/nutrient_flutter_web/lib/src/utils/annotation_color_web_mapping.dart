///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// The Web SDK annotation field that holds the cross-platform
/// `AnnotationProperties.strokeColor`, given the annotation's [type] and which
/// fields it declares ([hasField]).
///
/// Android and iOS read and write `strokeColor` as the annotation's colour.
/// On web:
/// - free text (`pspdfkit/text`) keeps it in `fontColor`;
/// - shapes and ink keep it in `strokeColor`;
/// - notes, text markup, stamps and redactions have no `strokeColor` field
///   and keep it in `color`. A redaction's `color` is its overlay text colour,
///   as on Android and iOS; its outline is `outlineColor`.
String strokeColorWebField(
  String? type,
  bool Function(String field) hasField,
) {
  if (type == 'pspdfkit/text') return 'fontColor';
  return !hasField('strokeColor') && hasField('color')
      ? 'color'
      : 'strokeColor';
}

/// Reports the colour in [field] of a serialized Web SDK annotation ([json])
/// as its `strokeColor`, where [field] is from [strokeColorWebField].
///
/// Leaves [json] unchanged when [field] is `strokeColor` or [json] has no
/// [field], so it never gains a `strokeColor` key it didn't have.
void reportStrokeColorFrom(Map<String, dynamic> json, String field) {
  if (field != 'strokeColor' && json.containsKey(field)) {
    json['strokeColor'] = json[field];
  }
}
