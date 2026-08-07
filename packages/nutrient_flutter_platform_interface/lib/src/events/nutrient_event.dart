///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';
import 'dart:ui';

import '../api/nutrient_api.g.dart' show AnnotationType;
import '../interfaces/nutrient_document_interface.dart';
import '../models/annotations/annotation_models.dart';
import '../models/forms/form_field.dart';

/// Mixin providing a typed [annotations] view over an event's raw
/// [annotationsJson]. Parsing is defensive ([Annotation.tryFromJson]) so an
/// unknown or malformed entry is skipped rather than throwing.
mixin AnnotationEventData {
  /// The raw Instant JSON string for each annotation in the event.
  List<String> get annotationsJson;

  /// The typed annotations for this event, parsed from [annotationsJson].
  List<Annotation> get annotations => _typedAnnotations(annotationsJson);

  /// The [AnnotationType] of each parsed annotation in this event.
  ///
  /// Convenience over mapping [annotations] to their [Annotation.type] — handy
  /// for filtering, e.g. `if (event.types.contains(AnnotationType.ink)) …`.
  /// Entries that fail to parse are skipped (same policy as [annotations]).
  List<AnnotationType> get types =>
      annotations.map((a) => a.type).toList(growable: false);
}

List<Annotation> _typedAnnotations(List<String> jsons) {
  final result = <Annotation>[];
  for (final j in jsons) {
    if (j.isEmpty) continue;
    try {
      final decoded = jsonDecode(j);
      if (decoded is Map) {
        final a = Annotation.tryFromJson(Map<String, dynamic>.from(decoded));
        if (a != null) result.add(a);
      }
    } catch (_) {
      // Skip an unparseable entry rather than failing the whole event.
    }
  }
  return result;
}

/// Base class for all cross-platform Nutrient SDK events.
///
/// Events are emitted on [NutrientControllerInterface.events] and cover the
/// common event surface shared by Android, iOS, and Web. Platform-specific
/// events are exposed on the respective adapter:
///
/// - Android-only: `AndroidAdapter.androidEvents` → `AndroidNutrientEvent`
/// - iOS-only: `IOSAdapter.iosEvents` → `IOSNutrientEvent`
/// - Web-only: `NutrientWebAdapter.webEvents` → `NutrientWebEventData`
///
/// ## Subscribing
///
/// ```dart
/// // All events
/// controller.events.listen((event) {
///   switch (event) {
///     case DocumentLoadedEvent(:final document):
///       print('Loaded: $document');
///     case PageChangedEvent(:final pageIndex):
///       print('Page changed to $pageIndex');
///     case AnnotationCreatedEvent(:final annotations):
///       print('Created: ${annotations.map((a) => a.type.name)}');
///     default:
///       break;
///   }
/// });
///
/// // Filtered via typed extension getters
/// controller.events.documentLoaded.listen((e) => print(e.document));
/// controller.events.pageChanged.listen((e) => print(e.pageIndex));
/// controller.events.annotationCreated.listen((e) => print(e.annotations));
/// ```
///
/// See the package guide `documentation/events-api-guide.md` for the full
/// event catalogue, buffering semantics, and the platform-support matrix.
sealed class NutrientEvent {
  const NutrientEvent();
}

// ---------------------------------------------------------------------------
// Document events
// ---------------------------------------------------------------------------

/// Emitted when a document is fully loaded and ready for interaction.
///
/// On Android and iOS this fires from the native document listener after the
/// document object is available. On Web it fires at the end of
/// `onInstanceLoaded()` since the document is already loaded at that point.
final class DocumentLoadedEvent extends NutrientEvent {
  /// The document that finished loading.
  ///
  /// This is the same live instance as `controller.document`, carried on the
  /// event so handlers can use it directly — e.g.
  /// `event.document.getPageCount()` — without closing over the controller.
  ///
  /// Note: the instance is a proxy that resolves against the document
  /// *currently* attached to the view at call time, not a snapshot taken when
  /// the event fired. In the rare case where a view loads a second document
  /// before a buffered event is handled, calls resolve against the newer one.
  final NutrientDocumentInterface document;

  const DocumentLoadedEvent(this.document);
}

/// Emitted when a document fails to load.
///
/// [error] contains a human-readable description of the failure.
///
/// Not applicable on Web (load errors are thrown as exceptions instead).
final class DocumentErrorEvent extends NutrientEvent {
  final String error;
  const DocumentErrorEvent(this.error);
}

/// Emitted after a document is successfully saved.
///
/// [path] is the output file path when saving to a new location, or `null`
/// when saving in-place (the common case).
final class DocumentSavedEvent extends NutrientEvent {
  final String? path;
  const DocumentSavedEvent({this.path});
}

// ---------------------------------------------------------------------------
// Navigation events
// ---------------------------------------------------------------------------

/// Emitted when the viewer navigates to a different page.
///
/// [pageIndex] is zero-based.
final class PageChangedEvent extends NutrientEvent {
  final int pageIndex;
  const PageChangedEvent(this.pageIndex);
}

/// Emitted when the user taps on a page.
///
/// [pageIndex] is zero-based. [point] is the tap location in PDF-space
/// coordinates (logical points from the page origin), or `null` if the
/// platform does not provide coordinate information. [annotationJson] is the
/// Instant JSON string of the tapped annotation, or `null` if the tap did not
/// hit an annotation.
final class PageClickedEvent extends NutrientEvent {
  final int pageIndex;
  final Offset? point;
  final String? annotationJson;
  const PageClickedEvent(
    this.pageIndex, {
    this.point,
    this.annotationJson,
  });

  /// The typed annotation that was tapped, or `null` if the tap missed an
  /// annotation (or the payload couldn't be parsed).
  Annotation? get annotation {
    final j = annotationJson;
    if (j == null || j.isEmpty) return null;
    try {
      final decoded = jsonDecode(j);
      return decoded is Map
          ? Annotation.tryFromJson(Map<String, dynamic>.from(decoded))
          : null;
    } catch (_) {
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Annotation events
// ---------------------------------------------------------------------------

/// Emitted when one or more annotations are created.
///
/// [annotationsJson] contains the Instant JSON string for each created
/// annotation, consistent with [AnnotationManagerInterface.getAnnotationsJson].
final class AnnotationCreatedEvent extends NutrientEvent
    with AnnotationEventData {
  @override
  final List<String> annotationsJson;
  const AnnotationCreatedEvent(this.annotationsJson);
}

/// Emitted when one or more annotations are modified.
final class AnnotationUpdatedEvent extends NutrientEvent
    with AnnotationEventData {
  @override
  final List<String> annotationsJson;
  const AnnotationUpdatedEvent(this.annotationsJson);
}

/// Emitted when one or more annotations are deleted.
final class AnnotationDeletedEvent extends NutrientEvent
    with AnnotationEventData {
  @override
  final List<String> annotationsJson;
  const AnnotationDeletedEvent(this.annotationsJson);
}

/// Emitted when the user selects one or more annotations.
final class AnnotationSelectedEvent extends NutrientEvent
    with AnnotationEventData {
  @override
  final List<String> annotationsJson;
  const AnnotationSelectedEvent(this.annotationsJson);
}

/// Emitted when the user deselects one or more annotations.
final class AnnotationDeselectedEvent extends NutrientEvent
    with AnnotationEventData {
  @override
  final List<String> annotationsJson;
  const AnnotationDeselectedEvent(this.annotationsJson);
}

// ---------------------------------------------------------------------------
// Text selection events
// ---------------------------------------------------------------------------

/// Emitted when the user's text selection changes.
///
/// [selectedText] is the currently selected string, or `null` if the
/// selection was cleared.
final class TextSelectionChangedEvent extends NutrientEvent {
  final String? selectedText;
  const TextSelectionChangedEvent(this.selectedText);
}

// ---------------------------------------------------------------------------
// Form events
// ---------------------------------------------------------------------------

/// Emitted when a form field value changes.
///
/// [formFieldJson] is a JSON string describing the updated form field,
/// consistent with [FormManagerInterface.getFormFieldJson].
final class FormFieldUpdatedEvent extends NutrientEvent {
  final String formFieldJson;
  const FormFieldUpdatedEvent(this.formFieldJson);

  /// The typed form field for this event, or `null` if it couldn't be parsed.
  PdfFormField? get formField {
    if (formFieldJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(formFieldJson);
      if (decoded is Map) {
        return PdfFormField.fromMap(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
    return null;
  }
}

// ---------------------------------------------------------------------------
// Instant sync events (Android + iOS only; never fires on Web)
// ---------------------------------------------------------------------------

/// Emitted when an Instant document begins syncing to the server.
final class InstantSyncStartedEvent extends NutrientEvent {
  final String documentId;
  const InstantSyncStartedEvent(this.documentId);
}

/// Emitted when an Instant document sync completes successfully.
final class InstantSyncFinishedEvent extends NutrientEvent {
  final String documentId;
  const InstantSyncFinishedEvent(this.documentId);
}

/// Emitted when an Instant document sync fails.
final class InstantSyncFailedEvent extends NutrientEvent {
  final String documentId;
  final String error;
  const InstantSyncFailedEvent(this.documentId, this.error);
}

/// Emitted when Instant JWT re-authentication completes successfully.
final class InstantAuthFinishedEvent extends NutrientEvent {
  final String documentId;
  final String jwt;
  const InstantAuthFinishedEvent(this.documentId, this.jwt);
}

/// Emitted when Instant JWT authentication or re-authentication fails.
final class InstantAuthFailedEvent extends NutrientEvent {
  final String documentId;
  final String error;
  const InstantAuthFailedEvent(this.documentId, this.error);
}

// ---------------------------------------------------------------------------
// Stream extension
// ---------------------------------------------------------------------------

/// Typed filter getters for [Stream<NutrientEvent>].
///
/// ```dart
/// controller.events.pageChanged.listen((e) => print(e.pageIndex));
/// controller.events.annotationCreated.listen((e) {
///   for (final json in e.annotationsJson) {
///     print(json);
///   }
/// });
/// ```
extension NutrientEventStreamX on Stream<NutrientEvent> {
  // Stream lacks the Iterable.whereType helper, so we filter by type test
  // and cast — runtime behaviour is identical.
  Stream<T> _whereType<T extends NutrientEvent>() =>
      where((e) => e is T).cast<T>();

  /// Filters to [DocumentLoadedEvent] only.
  Stream<DocumentLoadedEvent> get documentLoaded =>
      _whereType<DocumentLoadedEvent>();

  /// Filters to [DocumentErrorEvent] only.
  Stream<DocumentErrorEvent> get documentError =>
      _whereType<DocumentErrorEvent>();

  /// Filters to [DocumentSavedEvent] only.
  Stream<DocumentSavedEvent> get documentSaved =>
      _whereType<DocumentSavedEvent>();

  /// Filters to [PageChangedEvent] only.
  Stream<PageChangedEvent> get pageChanged => _whereType<PageChangedEvent>();

  /// Filters to [PageClickedEvent] only.
  Stream<PageClickedEvent> get pageClicked => _whereType<PageClickedEvent>();

  /// Filters to [AnnotationCreatedEvent] only.
  Stream<AnnotationCreatedEvent> get annotationCreated =>
      _whereType<AnnotationCreatedEvent>();

  /// Filters to [AnnotationUpdatedEvent] only.
  Stream<AnnotationUpdatedEvent> get annotationUpdated =>
      _whereType<AnnotationUpdatedEvent>();

  /// Filters to [AnnotationDeletedEvent] only.
  Stream<AnnotationDeletedEvent> get annotationDeleted =>
      _whereType<AnnotationDeletedEvent>();

  /// Filters to [AnnotationSelectedEvent] only.
  Stream<AnnotationSelectedEvent> get annotationSelected =>
      _whereType<AnnotationSelectedEvent>();

  /// Filters to [AnnotationDeselectedEvent] only.
  Stream<AnnotationDeselectedEvent> get annotationDeselected =>
      _whereType<AnnotationDeselectedEvent>();

  /// Filters to [TextSelectionChangedEvent] only.
  Stream<TextSelectionChangedEvent> get textSelectionChanged =>
      _whereType<TextSelectionChangedEvent>();

  /// Filters to [FormFieldUpdatedEvent] only.
  Stream<FormFieldUpdatedEvent> get formFieldUpdated =>
      _whereType<FormFieldUpdatedEvent>();

  /// Filters to [InstantSyncStartedEvent] only.
  Stream<InstantSyncStartedEvent> get instantSyncStarted =>
      _whereType<InstantSyncStartedEvent>();

  /// Filters to [InstantSyncFinishedEvent] only.
  Stream<InstantSyncFinishedEvent> get instantSyncFinished =>
      _whereType<InstantSyncFinishedEvent>();

  /// Filters to [InstantSyncFailedEvent] only.
  Stream<InstantSyncFailedEvent> get instantSyncFailed =>
      _whereType<InstantSyncFailedEvent>();

  /// Filters to [InstantAuthFinishedEvent] only.
  Stream<InstantAuthFinishedEvent> get instantAuthFinished =>
      _whereType<InstantAuthFinishedEvent>();

  /// Filters to [InstantAuthFailedEvent] only.
  Stream<InstantAuthFailedEvent> get instantAuthFailed =>
      _whereType<InstantAuthFailedEvent>();
}
