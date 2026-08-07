///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Adapter-driven document viewer.
///
/// [NutrientDocumentView] is the modern replacement for [NutrientView]. It
/// delegates to the federated `NutrientViewAndroid` / `NutrientViewIOS` /
/// `NutrientViewWeb` platform views, which are built from Dart via JNI/FFI/JS
/// interop — no Pigeon. All configuration, event listening, and UI
/// customization live on a [NutrientPlatformAdapter] registered with
/// [Nutrient.initialize].
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

// Conditional imports select the platform view factory.
import 'nutrient_document_view_stub.dart'
    if (dart.library.io) 'nutrient_document_view_native.dart'
    if (dart.library.js_interop) 'nutrient_document_view_web.dart';

/// A widget for displaying PDF and image documents with typed controller access.
///
/// This widget pairs with a [NutrientPlatformAdapter] registered via
/// [Nutrient.initialize]. The adapter *is* the controller — it provides
/// document-level APIs (annotations, bookmarks, forms) and receives native
/// lifecycle callbacks so you can customize behavior via JNI/FFI/JS.
///
/// ## Basic Usage
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Nutrient.initialize(
///     androidAdapter: MyAndroidAdapter(),
///     iosAdapter: MyIOSAdapter(),
///     webAdapter: MyWebAdapter(),
///   );
///   runApp(const MyApp());
/// }
///
/// NutrientDocumentView<MyController>(
///   documentPath: 'assets/sample.pdf',
///   onControllerReady: (controller) async {
///     final count = await controller.document.getPageCount();
///     final bookmarks = await controller.document.bookmarks.getBookmarks();
///   },
/// )
/// ```
///
/// ## Extensibility
///
/// Customize any document operation by injecting factory closures on
/// `PdfDocument*` inside your adapter's `createDocument()`:
///
/// ```dart
/// class MyAndroidAdapter extends AndroidAdapter implements MyController {
///   @override
///   NutrientDocumentAndroid createDocument() => NutrientDocumentAndroid(
///     this,
///     bookmarkManagerFactory: (doc) => MyBookmarks(doc),
///   );
/// }
/// ```
///
/// See the Extensibility example in the example app for a full walkthrough.
class NutrientDocumentView<T extends NutrientController>
    extends StatefulWidget {
  /// Path to the document.
  ///
  /// Can be an asset path (`assets/doc.pdf`), a file path, or a remote URL.
  /// If both [documentPath] and [documentBytes] are provided, [documentPath]
  /// takes precedence.
  final String? documentPath;

  /// Document content as in-memory bytes.
  ///
  /// Use when the document isn't available as a file. If both [documentPath]
  /// and [documentBytes] are provided, [documentPath] takes precedence.
  final Uint8List? documentBytes;

  /// Optional typed viewer configuration.
  ///
  /// Applied on each platform before the adapter's configuration hook runs —
  /// so values set on the adapter (e.g. `configureFragment` on Android,
  /// `configureView` on iOS, `configureLoad` on Web) override the values here.
  ///
  /// Use platform sub-configurations ([NutrientViewConfiguration.androidConfig],
  /// [NutrientViewConfiguration.iosConfig], [NutrientViewConfiguration.webConfig])
  /// for options that are only meaningful on a specific platform.
  final NutrientViewConfiguration? configuration;

  /// Called when the typed controller is ready for use.
  ///
  /// The controller is the registered platform adapter — it implements
  /// [T]. Fires after the platform view is created, the document has
  /// loaded, and [NutrientController.markReady] has been called.
  final void Function(T controller)? onControllerReady;

  /// Optional per-view adapter override.
  ///
  /// When supplied, this widget uses [adapter] as its controller. The platform
  /// view's lifecycle callbacks (`onPlatformViewCreated`, `onPdfFragmentReady`,
  /// `onViewControllerReady`, `onInstanceLoaded`, `configureFragment` /
  /// `configureView` / `configureLoad`) target this adapter directly, so two
  /// `NutrientDocumentView`s on the same screen can use independent controllers
  /// without state leaking between them.
  ///
  /// **Ownership.** When [adapter] is supplied, the caller owns its
  /// lifecycle — [NutrientDocumentView] will *not* call [adapter.dispose].
  /// The pattern matches Flutter's controller convention
  /// (`TextEditingController`, `ScrollController`, …): allocate in the
  /// caller's `initState`, dispose in the caller's `dispose`.
  ///
  /// If `null`, the controller is resolved via [Nutrient.buildAdapter] for [T]:
  /// a fresh instance from a factory registered with [Nutrient.addAdapterClass]
  /// (preferred — each view gets its own instance, which this widget disposes),
  /// a matching adapter from [Nutrient.initialize]'s global slots (back-compat,
  /// shared — not disposed by this widget), or the platform default viewer.
  final T? adapter;

  const NutrientDocumentView({
    super.key,
    this.documentPath,
    this.documentBytes,
    this.configuration,
    this.onControllerReady,
    this.adapter,
  }) : assert(
          documentPath != null || documentBytes != null,
          'Either documentPath or documentBytes must be provided',
        );

  @override
  State<NutrientDocumentView<T>> createState() =>
      _NutrientDocumentViewState<T>();
}

class _NutrientDocumentViewState<T extends NutrientController>
    extends State<NutrientDocumentView<T>> {
  T? _controller;
  Timer? _readyTimer;
  bool _readyFired = false;

  /// Whether this view built [_controller] itself — via a factory registered
  /// with [Nutrient.addAdapterClass] or the platform default viewer — and is
  /// therefore responsible for disposing it. False when the controller was
  /// supplied through [NutrientDocumentView.adapter] (the caller owns it) or
  /// resolved from the shared global slot (owned by [Nutrient.initialize]).
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _resolveController();
  }

  @override
  void dispose() {
    _readyTimer?.cancel();
    if (_ownsController) {
      // We built this controller for this view, so we own its lifecycle.
      unawaited(_controller?.dispose());
    }
    super.dispose();
  }

  /// Resolve the controller for this view.
  ///
  /// Resolution order (the adapter *is* the controller in the
  /// adapter-as-controller model):
  /// 1. the per-view [NutrientDocumentView.adapter] when supplied — the caller
  ///    owns its lifecycle, so this view never disposes it;
  /// 2. otherwise [Nutrient.buildAdapter] for [T] — a fresh instance from a
  ///    factory registered with [Nutrient.addAdapterClass], a matching global
  ///    slot from [Nutrient.initialize] (back-compat), or the platform default
  ///    viewer.
  ///
  /// A controller this view *built* (a fresh factory/default instance) is owned
  /// by the view and disposed in [dispose]; one resolved from the shared global
  /// slot is not. The two are distinguished by identity against
  /// `Nutrient.currentAdapter`.
  void _resolveController() {
    final widgetAdapter = widget.adapter;
    if (widgetAdapter != null) {
      _controller = widgetAdapter;
      _ownsController = false;
      return;
    }

    try {
      final built = Nutrient.buildAdapter<T>();
      _controller = built;
      // A build that returns the shared global slot is not ours to dispose;
      // a fresh factory/default instance is.
      _ownsController = !Nutrient.isSharedAdapter(built);
    } on StateError catch (error) {
      // No factory, no matching global slot, no default — surface the
      // actionable message but let the view render (the platform side may
      // still resolve its own default).
      debugPrint('[NutrientDocumentView] $error');
      _controller = null;
      _ownsController = false;
    }
  }

  /// Called by the platform view once it has created the native fragment /
  /// view controller and registered native instances in [handle].
  ///
  /// The platform view also notifies the adapter directly (via
  /// `onPlatformViewCreated` / `onPdfFragmentReady` / etc.) — the handle
  /// is already attached to the controller by that point. We just need to
  /// wait for `markReady()` before surfacing [onControllerReady] to the
  /// widget user.
  void _onPlatformViewReady(NutrientViewHandle handle) {
    debugPrint(
      '[NutrientDocumentView] Platform view ready, handle: ${handle.viewId}',
    );
    final controller = _controller;
    if (controller == null) {
      debugPrint(
        '[NutrientDocumentView] No controller available — '
        'onControllerReady will not fire.',
      );
      return;
    }

    // The platform view already attaches the handle to the adapter via its
    // own lifecycle (onPlatformViewCreated / onPdfFragmentReady / etc.).
    // We just wait for the controller to become ready.
    _awaitControllerReady(controller);
  }

  /// Poll for [NutrientController.isReady] and invoke [onControllerReady]
  /// once. Cancelled on dispose.
  ///
  /// Platform views call [NutrientController.markReady] after the document
  /// loads. We poll rather than expose a notifier to keep the platform
  /// interface surface small.
  void _awaitControllerReady(T controller) {
    if (_readyFired) return;

    if (controller.isReady) {
      _readyFired = true;
      widget.onControllerReady?.call(controller);
      return;
    }

    _readyTimer?.cancel();
    _readyTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || controller.isDisposed || _readyFired) {
        _readyTimer?.cancel();
        return;
      }
      if (controller.isReady) {
        _readyTimer?.cancel();
        _readyFired = true;
        widget.onControllerReady?.call(controller);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Resolution is centralized in _resolveController: _controller is the
    // single adapter this view uses (the per-view adapter, a registered
    // factory's fresh instance, the back-compat global slot, or the platform
    // default). Every platform adapter also implements NutrientPlatformAdapter,
    // so narrow at the boundary and hand the platform-view factory the exact
    // instance the State resolved — the two never disagree. A non-platform
    // adapter T or a failed resolution falls through to null, and the federated
    // side resolves its own default. The intermediate variable is typed loosely
    // so Dart's flow analysis can narrow it (a generic `T?` won't narrow).
    final Object? controller = _controller;
    return createNutrientDocumentView(
      documentPath: widget.documentPath,
      documentBytes: widget.documentBytes,
      configuration: widget.configuration,
      onViewCreated: _onPlatformViewReady,
      adapter: controller is NutrientPlatformAdapter ? controller : null,
    );
  }
}
