///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'configuration/annotation_editing_item.dart';
import 'configuration/toolbar_item.dart';
import 'events/nutrient_event.dart';
import 'interfaces/nutrient_controller_interface.dart';
import 'interfaces/nutrient_document_interface.dart';
import 'models/annotation_tool.dart';
import 'nutrient_view_handle.dart';

/// Base class for Nutrient controllers.
///
/// This is the foundation for the **adapter-as-controller pattern**.
/// Platform adapters extend this class, allowing them to serve as both
/// platform adapters and controllers.
///
/// ## Adapter-as-Controller Pattern
///
/// Instead of having separate adapter and controller objects, the adapter
/// itself serves as the controller:
///
/// ```
/// NutrientController (this class)
///        ↑ extends
/// PlatformAdapter (e.g., AndroidAdapter, IOSAdapter, NutrientWebAdapter)
///        ↑ extends
/// YourAdapter ─────► implements YourController
///        │
///        └── The adapter IS the controller
/// ```
///
/// ## Creating a Custom Controller
///
/// 1. Define your controller interface implementing [NutrientControllerInterface]:
///
/// ```dart
/// abstract class MyController implements NutrientControllerInterface {
///   Future<int> getPageCount();
///   Future<int> getCurrentPageIndex();
/// }
/// ```
///
/// 2. Have your platform adapters implement your controller:
///
/// ```dart
/// class MyAndroidAdapter extends AndroidAdapter implements MyController {
///   PdfDocument? _document;
///
///   @override
///   Future<int> getPageCount() => Future.value(_document?.getPageCount() ?? 0);
/// }
/// ```
///
/// 3. Use typed controller access in your view:
///
/// ```dart
/// NutrientView<MyController>(
///   documentPath: 'document.pdf',
///   onControllerReady: (controller) async {
///     // Type-safe access to your APIs
///     final pageCount = await controller.getPageCount();
///   },
/// )
/// ```
///
/// ## Lifecycle
///
/// The controller goes through these lifecycle states:
/// 1. Created - Controller instance exists but view not ready
/// 2. Ready - View is created and [isReady] is true
/// 3. Disposed - Controller is disposed ([isDisposed] is true)
///
/// ## Lifecycle Methods
///
/// - [markReady] - Called by platform view when ready (internal)
/// - [onReady] - Override to perform initialization when ready
/// - [dispose] - Override to clean up resources
abstract class NutrientController implements NutrientControllerInterface {
  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------

  late final StreamController<NutrientEvent> _eventController =
      StreamController<NutrientEvent>.broadcast(onListen: _flushBufferedEvents);

  /// Events emitted before the first [events] listener attaches.
  ///
  /// A broadcast [StreamController] drops anything added while it has no
  /// listeners. Document-lifecycle events (notably [DocumentLoadedEvent], which
  /// the native document listener emits as soon as the document loads) can fire
  /// before the consumer subscribes in `onControllerReady`, which would race the
  /// subscription and silently lose the event. Buffering early events until the
  /// first listener attaches makes delivery timing-independent without changing
  /// broadcast semantics for any later listeners.
  final List<NutrientEvent> _bufferedEvents = <NutrientEvent>[];

  /// Cap on buffered events as a defensive bound in case a controller is never
  /// listened to; the real window (until `onControllerReady` subscribes) only
  /// ever holds a handful of events.
  static const int _maxBufferedEvents = 256;

  bool _hasHadListener = false;

  @override
  Stream<NutrientEvent> get events => _eventController.stream;

  void _flushBufferedEvents() {
    _hasHadListener = true;
    if (_bufferedEvents.isEmpty) return;
    final pending = List<NutrientEvent>.of(_bufferedEvents);
    _bufferedEvents.clear();
    // Deliver on a microtask so the listener is fully wired before the buffered
    // events arrive.
    scheduleMicrotask(() {
      for (final event in pending) {
        if (!_eventController.isClosed) _eventController.add(event);
      }
    });
  }

  /// Emits a cross-platform event to all [events] subscribers.
  ///
  /// Call this from platform adapter subclasses to push events into the shared
  /// stream. Events emitted before the first listener attaches are buffered and
  /// flushed once a listener subscribes (see [_bufferedEvents]). Silently no-ops
  /// if the controller has been disposed.
  @protected
  void emitEvent(NutrientEvent event) {
    if (_eventController.isClosed) return;
    if (_hasHadListener) {
      _eventController.add(event);
    } else {
      _bufferedEvents.add(event);
      if (_bufferedEvents.length > _maxBufferedEvents) {
        _bufferedEvents.removeAt(0);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Document
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // View / UI configuration
  // ---------------------------------------------------------------------------

  @override
  Future<bool> setAnnotationConfigurations(
      Map<String, dynamic> configurations) async {
    throw UnimplementedError(
        'setAnnotationConfigurations is not implemented on this platform.');
  }

  @override
  Future<bool> setAnnotationMenuConfiguration(
      Map<String, dynamic> configuration) async {
    throw UnimplementedError(
        'setAnnotationMenuConfiguration is not implemented on this platform.');
  }

  // ---------------------------------------------------------------------------
  // Viewport and zoom
  // ---------------------------------------------------------------------------

  @override
  Future<Rect> getVisibleRect(int pageIndex) async {
    throw UnimplementedError(
        'getVisibleRect is not implemented on this platform.');
  }

  @override
  Future<void> zoomToRect(int pageIndex, Rect rect) async {
    throw UnimplementedError('zoomToRect is not implemented on this platform.');
  }

  @override
  Future<double> getZoomScale(int pageIndex) async {
    throw UnimplementedError(
        'getZoomScale is not implemented on this platform.');
  }

  // ---------------------------------------------------------------------------
  // Annotation creation mode
  // ---------------------------------------------------------------------------

  @override
  Future<bool?> enterAnnotationCreationMode(
      [AnnotationTool? annotationTool]) async {
    throw UnimplementedError(
        'enterAnnotationCreationMode is not implemented on this platform.');
  }

  @override
  Future<bool?> exitAnnotationCreationMode() async {
    throw UnimplementedError(
        'exitAnnotationCreationMode is not implemented on this platform.');
  }

  // ---------------------------------------------------------------------------
  // Toolbar customization
  // ---------------------------------------------------------------------------

  /// No-op default — toolbar customization is opt-in per platform. The
  /// Android/iOS/Web adapters override this; controllers that don't support it
  /// simply ignore the request.
  @override
  Future<void> setMainToolbarItems(List<ToolbarItem> items) async {}

  /// No-op default — annotation creation toolbar customization is opt-in per
  /// platform (Android/iOS adapters override this; Web routes annotation tools
  /// through the main toolbar).
  @override
  Future<void> setAnnotationToolbarItems(
      List<AnnotationToolbarItem> items) async {}

  /// No-op default — annotation editing toolbar customization is opt-in per
  /// platform (Web/Android/iOS adapters override this).
  @override
  Future<void> setAnnotationEditingToolbarItems(
      List<AnnotationEditingItem> items) async {}

  // ---------------------------------------------------------------------------
  // Coordinate conversion
  // ---------------------------------------------------------------------------

  @override
  Future<Offset> convertViewPointToPdfPoint(int pageIndex, Offset point) async {
    throw UnimplementedError(
        'convertViewPointToPdfPoint is not implemented on this platform.');
  }

  @override
  Future<Offset> convertPdfPointToViewPoint(int pageIndex, Offset point) async {
    throw UnimplementedError(
        'convertPdfPointToViewPoint is not implemented on this platform.');
  }

  /// The open PDF document and its document-level operations.
  ///
  /// Available after [onReady] is called. Populated by the platform adapter
  /// via its `createDocument()` factory, which can be overridden to provide
  /// a custom [NutrientDocumentInterface] implementation.
  ///
  /// ```dart
  /// onControllerReady: (controller) async {
  ///   final count = await controller.document.getPageCount();
  ///   final json = await controller.document.annotations.getAnnotationsJson(0, 'all');
  ///   final bookmarks = await controller.document.bookmarks.getBookmarks();
  /// }
  /// ```
  NutrientDocumentInterface get document;

  /// Whether the controller is ready for use.
  ///
  /// Returns `true` after [onReady] has been called, indicating that
  /// the underlying platform view is created and the controller can
  /// interact with the PDF viewer.
  bool get isReady => _ready;
  bool _ready = false;

  /// Whether the controller has been disposed.
  ///
  /// Returns `true` after [dispose] has been called. A disposed controller
  /// cannot be used and will throw if methods are called on it.
  bool get isDisposed => _disposed;
  bool _disposed = false;

  /// The internal view handle for accessing native instances.
  ///
  /// This is only available after the controller is attached to a view.
  /// Use this in subclasses to access platform-specific native instances.
  @protected
  NutrientViewHandle? get viewHandle => _viewHandle;
  NutrientViewHandle? _viewHandle;

  /// Whether a live platform view is currently attached (set by
  /// [attachViewHandle], consumed by [consumeViewAttached]).
  bool _viewAttached = false;

  // ---------------------------------------------------------------------------
  // Lifecycle Methods
  // ---------------------------------------------------------------------------

  /// Attach the view handle to this controller.
  ///
  /// Called by the platform view when it's created. This connects the
  /// controller to the underlying native view.
  ///
  /// This method is intended for internal SDK use. Users should not call
  /// this method directly.
  void attachViewHandle(NutrientViewHandle viewHandle) {
    _throwIfDisposed();

    // Guard against one controller/adapter instance backing two *live* views at
    // once. The global adapter registered via `Nutrient.initialize` is shared by
    // every `NutrientDocumentView` that doesn't pass its own `adapter:`; because
    // the adapter *is* the controller, two simultaneous views would clobber each
    // other's view handle, document, and event stream.
    //
    // A previously-attached view is still live only if its native instances are
    // still registered — a view unregisters them (via `NutrientViewHandle.dispose`)
    // when torn down. So *sequential* reuse (one view gone before the next
    // attaches) stays allowed; only genuine concurrent reuse trips the guard.
    final previous = _viewHandle;
    if (previous != null &&
        previous.viewId != viewHandle.viewId &&
        NativeInstanceRegistry.hasView(previous.viewId)) {
      final message =
          'This $runtimeType is already driving NutrientDocumentView '
          '#${previous.viewId} and cannot back #${viewHandle.viewId} at the '
          'same time: one adapter/controller instance maps to one live view, '
          'so their native handle, document, and event stream would collide. '
          'Give each NutrientDocumentView its own `adapter:` (allocate it in '
          'the caller and dispose it there, like two_widgets_example) instead '
          'of reusing the global adapter from Nutrient.initialize() for '
          'multiple simultaneous views.';
      // Debug: fail loudly so the collision is caught in development/CI.
      assert(false, message);
      // Release (assert stripped): still surface it so it's diagnosable from
      // logs rather than silently corrupting per-view state.
      debugPrint('[NutrientController] WARNING: $message');
    }

    _viewHandle = viewHandle;
    _viewAttached = true;
  }

  /// For platform adapters: atomically check-and-clear the view-attached flag.
  ///
  /// Returns `true` exactly once per attach — the first `detachView()` after a
  /// view attaches gets `true` and should run its per-view cleanup; a redundant
  /// second call returns `false` and must skip it. This keeps detach cleanup
  /// idempotent when `detachView()` is invoked twice during one teardown — the
  /// federated platform view detaches the adapter, and an owning
  /// [NutrientDocumentView] then disposes it (and [dispose] also detaches).
  /// Returns `false` when no view ever attached, so disposing a never-shown
  /// adapter does no per-view work.
  @protected
  bool consumeViewAttached() {
    if (!_viewAttached) return false;
    _viewAttached = false;
    return true;
  }

  /// Mark the controller as ready for use.
  ///
  /// Called by the platform view after the native view is fully initialized.
  /// This triggers [onReady] and allows the controller to be used.
  ///
  /// This method is intended for internal SDK use. Users should not call
  /// this method directly.
  Future<void> markReady() async {
    _throwIfDisposed();
    _ready = true;
    await onReady();
  }

  /// Called when the controller becomes ready.
  ///
  /// Override this in subclasses to perform initialization that requires
  /// the view to be ready. The [viewHandle] is guaranteed to be available.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> onReady() async {
  ///   await super.onReady();
  ///   // Perform custom initialization
  ///   final pageCount = await document.getPageCount();
  ///   debugPrint('Controller ready with $pageCount pages');
  /// }
  /// ```
  @protected
  Future<void> onReady() async {
    // Subclasses can override for custom initialization
  }

  /// Dispose of this controller and release resources.
  ///
  /// After disposal, the controller cannot be used. Calling methods on a
  /// disposed controller will throw.
  ///
  /// This is called automatically when the [NutrientView] is disposed if
  /// the controller was created by the view. If you provided your own
  /// controller, you are responsible for disposing it.
  @mustCallSuper
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _ready = false;
    _bufferedEvents.clear();
    await _eventController.close();
    await _viewHandle?.dispose();
    _viewHandle = null;
  }

  /// Throws if the controller has been disposed.
  void _throwIfDisposed() {
    if (_disposed) {
      throw StateError(
        'NutrientController has been disposed and cannot be used.',
      );
    }
  }
}
