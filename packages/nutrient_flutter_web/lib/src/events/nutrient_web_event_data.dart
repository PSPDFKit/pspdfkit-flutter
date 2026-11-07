///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// A typed carrier for raw Nutrient Web SDK events.
///
/// The Nutrient Web SDK exposes ~106 named events through
/// `instance.addEventListener(name, callback)`. Each event has a heterogeneous
/// `JSAny` payload whose shape depends on the event name.
///
/// `NutrientWebEventData` wraps each emission so consumers get a Dart-typed
/// stream while keeping payload access via JS interop.
///
/// ## Filtering by type
///
/// ```dart
/// webAdapter.webEvents
///     .where((e) => e.type == 'bookmarks.create')
///     .listen((e) {
///   // Handle the bookmark creation event
/// });
/// ```
///
/// ## Common event names
///
/// See the [Web SDK API reference](https://www.nutrient.io/api/web/enums/NutrientViewer.EventName.html)
/// for the complete list. Useful examples:
///
/// - `annotations.create`, `annotations.update`, `annotations.delete`
/// - `viewState.currentPageIndex.change`, `viewState.zoom.change`
/// - `formFieldValues.update`, `formFields.update`
/// - `bookmarks.create`, `bookmarks.update`, `bookmarks.delete`
/// - `textSelection.change`
/// - `history.undo`, `history.redo`
class NutrientWebEventData {
  /// The Web SDK event name (e.g. `'annotations.create'`).
  final String type;

  /// The raw JS payload delivered to the listener. Cast/inspect using the
  /// `dart:js_interop` APIs based on the event [type].
  final JSAny? payload;

  const NutrientWebEventData(this.type, this.payload);

  /// The [payload] serialized to a JSON string via the browser's
  /// `JSON.stringify`, or `null` if there's no payload or it isn't
  /// JSON-serializable.
  ///
  /// Handy for logging or for forwarding an event's data across the bindings
  /// without hand-writing `dart:js_interop` payload extraction. Note that some
  /// Web SDK payloads are `Immutable` collections that `JSON.stringify` renders
  /// as objects; for those, prefer the typed cross-platform `controller.events`
  /// stream.
  String? get payloadAsJson {
    final p = payload;
    if (p == null) return null;
    try {
      final json = globalContext.getProperty<JSObject?>('JSON'.toJS);
      final stringify = json?.getProperty<JSFunction?>('stringify'.toJS);
      if (stringify == null) return null;
      final result = stringify.callAsFunction(null, p) as JSString?;
      return result?.toDart;
    } catch (_) {
      // `JSON.stringify` throws on circular structures (some Immutable
      // payloads); fall back to null rather than surfacing into the listener.
      return null;
    }
  }

  @override
  String toString() => 'NutrientWebEventData(type: $type)';
}
