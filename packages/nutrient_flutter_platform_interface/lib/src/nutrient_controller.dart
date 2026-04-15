///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

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
/// 1. Define your controller interface extending [NutrientController]:
///
/// ```dart
/// abstract class MyController extends NutrientController {
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
class NutrientController {
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
    _viewHandle = viewHandle;
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
  ///   final pageCount = await getPageCount();
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
