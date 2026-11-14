///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Base class for Android-only Nutrient SDK events.
///
/// These events are emitted on [AndroidAdapter.androidEvents] and cover
/// native Android SDK callbacks that have no cross-platform equivalent.
///
/// Cross-platform events (page changes, annotation CRUD, document save, etc.)
/// are available on `controller.events` ([NutrientEvent]).
///
/// ## Subscribing
///
/// ```dart
/// // Cast the controller to AndroidAdapter to access android-specific events
/// final adapter = controller as AndroidAdapter;
/// adapter.androidEvents.listen((event) {
///   switch (event) {
///     case AndroidAnnotationZOrderChangedEvent(:final pageIndex):
///       print('Z-order changed on page $pageIndex');
///     case AndroidDocumentZoomedEvent(:final pageIndex, :final zoomScale):
///       print('Zoomed page $pageIndex to ${zoomScale}x');
///     default:
///       break;
///   }
/// });
/// ```
sealed class AndroidNutrientEvent {
  const AndroidNutrientEvent();
}

/// Emitted when the Z-order of annotations on a page changes.
///
/// [pageIndex] is the zero-based page index where the reordering occurred.
/// [annotationsAboveJson] and [annotationsBelowJson] are Instant JSON strings
/// of the annotations now above and below the changed annotation, respectively.
final class AndroidAnnotationZOrderChangedEvent extends AndroidNutrientEvent {
  final int pageIndex;
  final List<String> annotationsAboveJson;
  final List<String> annotationsBelowJson;

  const AndroidAnnotationZOrderChangedEvent(
    this.pageIndex,
    this.annotationsAboveJson,
    this.annotationsBelowJson,
  );
}

/// Emitted when the user zooms in or out on a page.
///
/// [pageIndex] is the zero-based page index. [zoomScale] is the new zoom
/// factor (1.0 = fit-to-page).
final class AndroidDocumentZoomedEvent extends AndroidNutrientEvent {
  final int pageIndex;
  final double zoomScale;

  const AndroidDocumentZoomedEvent(this.pageIndex, this.zoomScale);
}

/// Emitted when the document fails to save.
///
/// [error] contains a description of the failure. For the success case see
/// [DocumentSavedEvent] on `controller.events`.
final class AndroidDocumentSaveFailedEvent extends AndroidNutrientEvent {
  final String error;

  const AndroidDocumentSaveFailedEvent(this.error);
}

/// Emitted when a document save operation is cancelled.
final class AndroidDocumentSaveCancelledEvent extends AndroidNutrientEvent {
  const AndroidDocumentSaveCancelledEvent();
}

/// Emitted when the PDF activity is paused (Android lifecycle event).
final class AndroidActivityPausedEvent extends AndroidNutrientEvent {
  const AndroidActivityPausedEvent();
}

/// Emitted when the PDF fragment is added to the activity.
final class AndroidFragmentAddedEvent extends AndroidNutrientEvent {
  const AndroidFragmentAddedEvent();
}

/// Emitted when the form field editing mode changes.
///
/// [mode] is one of `'enter'`, `'change'`, or `'exit'`.
final class AndroidFormEditingModeChangedEvent extends AndroidNutrientEvent {
  final String mode;

  const AndroidFormEditingModeChangedEvent(this.mode);
}

/// Emitted when the annotation creation mode changes.
///
/// [tool] is the annotation tool name (e.g. `'inkPen'`, `'highlight'`), or
/// `null` if the user exited annotation creation mode.
final class AndroidAnnotationCreationModeChangedEvent
    extends AndroidNutrientEvent {
  final String? tool;

  const AndroidAnnotationCreationModeChangedEvent(this.tool);
}
