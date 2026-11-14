///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

/// An annotation in a selection the Web SDK reported: its `id`, and its
/// Instant JSON, or `null` when it couldn't be converted.
typedef SelectedAnnotation = ({String id, String? json});

/// Turns the Web SDK's `annotationSelection.change` reports, each the whole
/// new selection, into the cross-platform events as Android reports them:
/// [AnnotationDeselectedEvent] for the annotations that left the selection,
/// then [AnnotationSelectedEvent] for the ones that joined it.
///
/// Annotations are followed by `id`, so one that couldn't be converted to
/// JSON still counts as selected. It's only left out of the events.
class AnnotationSelectionTracker {
  // The selected annotations' latest JSON by id, in selection order.
  Map<String, String?> _selected = {};

  /// Whether any annotation is selected.
  bool get hasSelection => _selected.isNotEmpty;

  /// The events for a change to [selection].
  List<NutrientEvent> update(List<SelectedAnnotation> selection) {
    final next = <String, String?>{
      for (final (:id, :json) in selection) id: json ?? _selected[id],
    };
    final deselected = [
      for (final MapEntry(:key, :value) in _selected.entries)
        if (!next.containsKey(key) && value != null) value,
    ];
    final selected = [
      for (final MapEntry(:key, :value) in next.entries)
        if (!_selected.containsKey(key) && value != null) value,
    ];
    _selected = next;
    return [
      if (deselected.isNotEmpty) AnnotationDeselectedEvent(deselected),
      if (selected.isNotEmpty) AnnotationSelectedEvent(selected),
    ];
  }

  /// Keeps the JSON of selected annotations current when they change while
  /// selected, so a later deselection reports them as they are, as Android
  /// does. Annotations that aren't selected are ignored.
  void refresh(List<SelectedAnnotation> updated) {
    for (final (:id, :json) in updated) {
      if (json != null && _selected.containsKey(id)) _selected[id] = json;
    }
  }

  /// The events for a selection that's gone with its document, as when the
  /// view unloads it or another one loads.
  List<NutrientEvent> clear() => update(const []);
}
