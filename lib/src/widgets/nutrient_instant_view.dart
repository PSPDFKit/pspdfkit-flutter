///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:nutrient_flutter_android/nutrient_flutter_android.dart'
    show NutrientInstantViewAndroid;
import 'package:nutrient_flutter_ios/nutrient_flutter_ios.dart'
    show NutrientInstantViewIOS;

import '../configuration/web_config_resolution.dart';

/// A cross-platform widget that opens a Nutrient Instant document.
///
/// [NutrientInstantView] connects to a Document Engine server using the
/// provided [serverUrl] and [jwt] credentials and renders the resulting
/// document with real-time collaboration support.
///
/// The controller surfaced by [onControllerReady] is a
/// [NutrientInstantController] — the regular controller surface plus the
/// Instant sync controls (`syncAnnotations`,
/// `setDelayForSyncingLocalChanges`, `setListenToServerChanges`).
///
/// Controller resolution mirrors [NutrientDocumentView]:
///
/// - **Bare** `NutrientInstantView(...)` — the platform's default Instant
///   controller is built fresh for this view (and disposed with it).
/// - **Typed** `NutrientInstantView<MyInstantController>(...)` — a fresh
///   instance from the factory registered with
///   `Nutrient.addAdapterClass<MyInstantController>(...)`; the view owns its
///   lifecycle.
/// - **Per-view instance** via [adapter] — you allocate and dispose it; the
///   view only attaches/detaches.
///
/// Example:
/// ```dart
/// NutrientInstantView(
///   serverUrl: 'https://your-server.example.com/api/1/documents/abc123',
///   jwt: 'eyJhbGci...',
///   configuration: NutrientViewConfiguration(
///     pageLayoutMode: PageLayoutMode.single,
///   ),
///   onControllerReady: (controller) async {
///     await controller.setDelayForSyncingLocalChanges(2);
///     await controller.syncAnnotations();
///   },
/// )
/// ```
class NutrientInstantView<T extends NutrientInstantController>
    extends StatefulWidget {
  /// The Document Engine server URL for the Instant document to open.
  final String serverUrl;

  /// The JWT used to authenticate with the Document Engine server.
  final String jwt;

  /// Optional viewer configuration.
  final NutrientViewConfiguration? configuration;

  /// Called when the platform view has been created and is ready to use.
  final void Function(NutrientViewHandle handle)? onViewCreated;

  /// Optional per-view controller instance you own.
  ///
  /// When supplied, this widget uses [adapter] as its controller — the
  /// Instant view dispatches its lifecycle hooks and the typed Instant events
  /// to it, and [onControllerReady] surfaces it. Ownership stays with the
  /// caller: dispose it yourself (the view calls `detachView()` on teardown,
  /// never `dispose()`).
  ///
  /// If `null`, the controller is resolved via [Nutrient.buildAdapter] for
  /// [T]: a fresh instance from a factory registered with
  /// [Nutrient.addAdapterClass], or — for a bare view — the platform's
  /// default Instant controller. Controllers this view builds are owned and
  /// disposed by the view.
  ///
  /// On web the Instant view manages its own adapter, so this is ignored.
  final T? adapter;

  /// Called when the Instant controller is ready.
  ///
  /// ```dart
  /// NutrientInstantView(
  ///   serverUrl: url,
  ///   jwt: jwt,
  ///   onControllerReady: (controller) async {
  ///     await controller.setListenToServerChanges(true);
  ///     await controller.syncAnnotations();
  ///   },
  /// )
  /// ```
  ///
  /// Not called on Web, where Instant sync is configured at load time.
  final void Function(T controller)? onControllerReady;

  /// Creates a [NutrientInstantView].
  const NutrientInstantView({
    super.key,
    required this.serverUrl,
    required this.jwt,
    this.configuration,
    this.onViewCreated,
    this.adapter,
    this.onControllerReady,
  });

  @override
  State<NutrientInstantView<T>> createState() => _NutrientInstantViewState<T>();
}

class _NutrientInstantViewState<T extends NutrientInstantController>
    extends State<NutrientInstantView<T>> {
  T? _controller;
  bool _readyFired = false;

  /// Whether this view built [_controller] itself — via a factory registered
  /// with [Nutrient.addAdapterClass] or the platform default Instant
  /// controller — and is therefore responsible for disposing it. False when
  /// the controller was supplied through [NutrientInstantView.adapter] (the
  /// caller owns it) or resolved from the shared global slot.
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _resolveController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      // We built this controller for this view, so we own its lifecycle. The
      // platform view has already detached it in its own dispose (children
      // dispose before their ancestors).
      unawaited(_controller?.dispose());
    }
    super.dispose();
  }

  /// Resolve the controller for this view — same order as
  /// [NutrientDocumentView]: the per-view [NutrientInstantView.adapter] when
  /// supplied (caller-owned), otherwise [Nutrient.buildAdapter] for [T] (a
  /// registered factory's fresh instance, or the platform default Instant
  /// controller for a bare view — both view-owned).
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
      _ownsController = !Nutrient.isSharedAdapter(built);
    } on StateError catch (error) {
      // No factory and no platform Instant default — surface the actionable
      // message but let the view render (the platform side may still resolve
      // its own default).
      debugPrint('[NutrientInstantView] $error');
      _controller = null;
      _ownsController = false;
    }
  }

  /// Forwards the platform view's ready callback to the widget's typed
  /// [NutrientInstantView.onControllerReady] exactly once.
  ///
  /// The platform views surface the same instance this State resolved and
  /// passed down as `adapter:` — the `is T` check only filters the fallback
  /// case where resolution failed here and the platform built its own
  /// (platform-typed) default.
  void _onPlatformControllerReady(NutrientInstantController controller) {
    if (_readyFired) return;
    if (controller is T) {
      _readyFired = true;
      widget.onControllerReady?.call(controller);
    } else {
      debugPrint(
        '[NutrientInstantView] Platform controller ${controller.runtimeType} '
        'is not a $T — onControllerReady will not fire. Register a factory '
        'with Nutrient.addAdapterClass<$T>(() => ...) or pass `adapter:`.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resolve webConfig: if it is a WebViewConfiguration, pre-serialize it
    // into the builder-map format so nutrient_flutter_web can consume it
    // without importing nutrient_flutter.
    final resolvedConfig = resolveWebConfig(widget.configuration);

    // Hand the platform view the exact instance this State resolved (every
    // bundled controller also implements NutrientPlatformAdapter). A failed
    // resolution falls through to null and the platform view builds its own
    // default. Typed loosely so flow analysis can narrow (`T?` won't).
    final Object? controller = _controller;
    final NutrientPlatformAdapter? platformAdapter =
        controller is NutrientPlatformAdapter ? controller : null;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return NutrientInstantViewAndroid(
        serverUrl: widget.serverUrl,
        jwt: widget.jwt,
        configuration: resolvedConfig,
        onViewCreated: widget.onViewCreated,
        adapter: platformAdapter,
        onControllerReady: _onPlatformControllerReady,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return NutrientInstantViewIOS(
        serverUrl: widget.serverUrl,
        jwt: widget.jwt,
        configuration: resolvedConfig,
        onViewCreated: widget.onViewCreated,
        adapter: platformAdapter,
        onControllerReady: _onPlatformControllerReady,
      );
    }
    return Text(
      '$defaultTargetPlatform is not yet supported by Nutrient Instant for Flutter.',
    );
  }
}
