///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:ui';

/// Base class for iOS-only Nutrient SDK events.
///
/// These events are emitted on [IOSAdapter.iosEvents] and cover native iOS
/// SDK callbacks (delegate methods and NotificationCenter observers) that
/// have no cross-platform equivalent.
///
/// Cross-platform events (page changes, annotation CRUD, document save, etc.)
/// are available on `controller.events` ([NutrientEvent]).
///
/// ## Subscribing
///
/// ```dart
/// final adapter = controller as IOSAdapter;
/// adapter.iosEvents.listen((event) {
///   switch (event) {
///     case IOSViewModeChangedEvent(:final viewMode):
///       print('View mode changed to $viewMode');
///     case IOSAnnotationTappedEvent(:final pageIndex, :final point):
///       print('Annotation tapped on page $pageIndex at $point');
///     default:
///       break;
///   }
/// });
/// ```
sealed class IOSNutrientEvent {
  const IOSNutrientEvent();
}

/// Emitted just before the PSPDFViewController is dismissed.
final class IOSViewControllerWillDismissEvent extends IOSNutrientEvent {
  const IOSViewControllerWillDismissEvent();
}

/// Emitted after the PSPDFViewController has been dismissed.
final class IOSViewControllerDidDismissEvent extends IOSNutrientEvent {
  const IOSViewControllerDidDismissEvent();
}

/// Emitted when the view mode changes (e.g. between document and thumbnails).
///
/// [viewMode] is the raw `PSPDFViewMode` integer value.
final class IOSViewModeChangedEvent extends IOSNutrientEvent {
  final int viewMode;

  const IOSViewModeChangedEvent(this.viewMode);
}

/// Emitted when the user interface (HUD/chrome) becomes visible.
final class IOSUserInterfaceShownEvent extends IOSNutrientEvent {
  const IOSUserInterfaceShownEvent();
}

/// Emitted when the user interface (HUD/chrome) is hidden.
final class IOSUserInterfaceHiddenEvent extends IOSNutrientEvent {
  const IOSUserInterfaceHiddenEvent();
}

/// Emitted when the user taps on an annotation.
///
/// [annotationJson] is the Instant JSON representation of the tapped
/// annotation. [pageIndex] is the zero-based page index. [point] is the
/// tap location in PDF page coordinates.
final class IOSAnnotationTappedEvent extends IOSNutrientEvent {
  final String annotationJson;
  final int pageIndex;
  final Offset point;

  const IOSAnnotationTappedEvent(
    this.annotationJson,
    this.pageIndex,
    this.point,
  );
}

/// Emitted when an Instant document download finishes.
///
/// [documentId] is the Instant document identifier.
final class IOSInstantDownloadFinishedEvent extends IOSNutrientEvent {
  final String documentId;

  const IOSInstantDownloadFinishedEvent(this.documentId);
}

/// Emitted when an Instant document download fails.
///
/// [documentId] is the Instant document identifier and [error] describes
/// the failure.
final class IOSInstantDownloadFailedEvent extends IOSNutrientEvent {
  final String documentId;
  final String error;

  const IOSInstantDownloadFailedEvent(this.documentId, this.error);
}
