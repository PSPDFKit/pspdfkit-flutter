///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi_pkg;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    hide NativeInstanceRegistry;
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    as platform
    show NativeInstanceRegistry, Nutrient;

// Hide `Duration` — the bindings export an ObjC `Duration` that shadows
// dart:core's, breaking `Duration(milliseconds: ...)`.
import 'bindings/nutrient_ios_bindings.dart' hide Factory, Duration;
import 'ios_configuration_builder.dart';
import 'ios_platform_adapter.dart';
import 'nutrient_instant_controller_ios.dart';

/// iOS-specific implementation of a Nutrient Instant view.
///
/// This widget creates a [PSPDFInstantViewController] by connecting to a
/// Document Engine server using the provided [serverUrl] and [jwt] credentials.
/// The returned view controller is typed as [PSPDFViewController] and attached
/// to the same native platform view container used by [NutrientViewIOS].
///
/// All advanced features (annotations, forms, toolbar, etc.) are provided
/// through the iOS platform adapter after the view is created.
class NutrientInstantViewIOS extends StatefulWidget {
  /// The Document Engine server URL to connect to.
  final String serverUrl;

  /// The JWT used to authenticate with the Document Engine server.
  final String jwt;

  /// Optional viewer configuration applied via [IOSConfigurationBuilder].
  final NutrientViewConfiguration? configuration;

  /// Called when the view has been created and is ready to use.
  final void Function(NutrientViewHandle handle)? onViewCreated;

  /// Called once the Instant controller is ready for use — after the native
  /// Instant view controller is attached and [NutrientController.markReady]
  /// has been called (the same readiness point as [onViewCreated], fired
  /// immediately after it).
  ///
  /// The controller is [adapter] when it already implements
  /// [NutrientInstantController]; otherwise a default [IOSInstantController]
  /// is created and attached to this view so `setDelayForSyncingLocalChanges`
  /// / `setListenToServerChanges` / `syncAnnotations` resolve against the
  /// live Instant view controller.
  final void Function(NutrientInstantController controller)? onControllerReady;

  /// Optional per-view adapter. When supplied, this view dispatches its
  /// lifecycle hooks and typed Instant events to this adapter instead of the
  /// (deprecated) global `Nutrient.iosAdapter`. Ownership stays with the
  /// caller — the view calls `detachView()` on teardown, never `dispose()`.
  final NutrientPlatformAdapter? adapter;

  const NutrientInstantViewIOS({
    super.key,
    required this.serverUrl,
    required this.jwt,
    this.configuration,
    this.onViewCreated,
    this.onControllerReady,
    this.adapter,
  });

  @override
  State<NutrientInstantViewIOS> createState() => _NutrientInstantViewIOSState();
}

class _NutrientInstantViewIOSState extends State<NutrientInstantViewIOS> {
  PSPDFViewController? _viewController;
  int? _platformViewId;
  NutrientViewHandle? _viewHandle;

  /// A default [IOSInstantController] built by this view for
  /// [NutrientInstantViewIOS.onControllerReady] when [_resolvedAdapter]
  /// doesn't already implement [NutrientInstantController].
  ///
  /// Owned by this view — attached in [_createAndAttachViewController] and
  /// detached in [dispose] alongside the resolved adapter. `null` when the
  /// resolved adapter already implements [NutrientInstantController] (that
  /// adapter is used directly instead — see [_resolveInstantController]).
  IOSInstantController? _defaultInstantController;

  /// Resolves the adapter that drives this Instant view's lifecycle + typed
  /// events: the per-view [NutrientInstantViewIOS.adapter] when supplied,
  /// otherwise the (deprecated) global slot as a back-compat fallback.
  NutrientPlatformAdapter? get _resolvedAdapter =>
      // ignore: deprecated_member_use
      widget.adapter ?? platform.Nutrient.iosAdapter;

  @override
  void dispose() {
    // Use detachView() — not dispose() — so a caller-owned adapter or the
    // shared global slot stays usable for subsequent mounts of the view.
    final adapter = _resolvedAdapter;
    if (adapter is IOSAdapter) {
      unawaited(adapter.detachView());
    }

    // The default instant controller (built only when `adapter` doesn't
    // already implement NutrientInstantController) is owned by this view,
    // not the caller — dispose() it directly rather than detachView(), since
    // nothing else can reach it to reuse it across mounts.
    final defaultController = _defaultInstantController;
    if (defaultController != null) {
      _defaultInstantController = null;
      unawaited(defaultController.dispose());
    }

    // Clear native instance references from the registry BEFORE disposing view handle
    // This prevents dangling references during hot restart
    if (_platformViewId != null) {
      platform.NativeInstanceRegistry.unregister(_platformViewId!);
    }

    // Tear down the automatic file-conflict resolution observer (if any)
    // before dropping the view controller reference below — the native side
    // keys the registration off the PDFViewController pointer.
    final viewController = _viewController;
    if (viewController != null) {
      nutrient_unregister_file_conflict_resolution(
        viewController.ref.pointer.cast<ffi.Void>(),
      );
    }

    // Clear Dart-side references to native objects
    // Do NOT release them here - the platform view owns the lifecycle
    _viewController = null;

    _viewHandle?.dispose();
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    _platformViewId = id;
    unawaited(_createAndAttachViewController());
  }

  Future<void> _createAndAttachViewController() async {
    try {
      debugPrint(
        '[NutrientInstantViewIOS] Creating Instant view controller for ${widget.serverUrl}',
      );

      // Convert Dart strings to null-terminated C strings
      final serverUrlPtr = _toCString(widget.serverUrl);
      final jwtPtr = _toCString(widget.jwt);

      // Call the FFI factory that creates a PSPDFInstantViewController.
      // Use the config-aware variant when a NutrientViewConfiguration is provided.
      ffi.Pointer<ffi.Void> vcPointer;
      final config = widget.configuration;
      if (config != null) {
        final iosMap = IOSConfigurationBuilder().buildConfig(config);
        final configJsonPtr = _toCString(jsonEncode(iosMap));
        vcPointer = nutrient_create_instant_view_controller_with_config(
          serverUrlPtr,
          jwtPtr,
          configJsonPtr,
        );
        ffi_pkg.calloc.free(configJsonPtr);
      } else {
        vcPointer = nutrient_create_instant_view_controller(
          serverUrlPtr,
          jwtPtr,
        );
      }

      // Free the C strings immediately after the call
      ffi_pkg.calloc.free(serverUrlPtr);
      ffi_pkg.calloc.free(jwtPtr);

      if (vcPointer == ffi.nullptr) {
        debugPrint(
          '[NutrientInstantViewIOS] nutrient_create_instant_view_controller returned null',
        );
        return;
      }

      // Wrap the opaque pointer in a PSPDFViewController ObjC object.
      // The C function returns a __bridge_retained pointer (+1 retain count),
      // so we set retain: false and release: true to take ownership.
      // Do NOT call nutrient_instant_set_listen_for_server_changes here —
      // nutrient_create_instant_view_controller already sets
      // shouldListenForServerChangesWhenVisible = YES internally.
      _viewController = PSPDFViewController.fromPointer(
        vcPointer.cast(),
        retain: false,
        release: true,
      );
      debugPrint('[NutrientInstantViewIOS] Created PSPDFInstantViewController');

      // Wrap in PSPDFNavigationController — PSPDFKit's navigation controller
      // subclass that forwards rotation methods and bar appearance to the
      // embedded PDF view controller. Using a plain UINavigationController
      // omits the PSPDFKit-specific integration hooks that PSPDFInstantViewController
      // relies on for its Instant document connection after download completes.
      final navController = _wrapInNavigationController(_viewController!);
      debugPrint(
        '[NutrientInstantViewIOS] Wrapped in PSPDFNavigationController',
      );

      // Attach the navigation controller to the platform view container
      if (_platformViewId != null) {
        debugPrint(
          '[NutrientInstantViewIOS] Attaching navigation controller to platform view $_platformViewId',
        );

        final success = _attachViewControllerViaCompanion(
          _platformViewId!,
          navController,
        );

        debugPrint('[NutrientInstantViewIOS] Attach result = $success');

        if (success) {
          // Register view controller in the native instance registry
          platform.NativeInstanceRegistry.register(
            _platformViewId!,
            'viewController',
            _viewController!,
          );

          // Also register the navigation controller for delegate bridge access
          platform.NativeInstanceRegistry.register(
            _platformViewId!,
            'navigationController',
            navController,
          );

          // Create the view handle
          _viewHandle = NutrientViewHandle.forPlatform(_platformViewId!);

          // Register automatic file-conflict resolution when configured.
          // fileConflictResolution has no PSPDFConfigurationBuilder property
          // (see IOSConfigurationBuilder's doc comment), so it isn't applied by
          // nutrient_apply_config_dict inside
          // nutrient_create_instant_view_controller_with_config — it must be
          // wired up separately, after the view controller exists.
          _registerFileConflictResolution();

          // Call platform adapter lifecycle hooks so delegates are set up
          // before any document-level events fire.
          // attachViewHandle must be called BEFORE onPlatformViewCreated so
          // that adapter.viewHandle / nativeViewController / nativeDocument
          // are non-nil inside onViewControllerReady and all downstream
          // managers. Missing this call (unlike NutrientViewIOS which always
          // calls it) left adapter.viewHandle == null, breaking every
          // native-instance accessor on the adapter.
          final adapter = _resolvedAdapter;
          if (adapter is IOSAdapter) {
            adapter.attachViewHandle(_viewHandle!);
            // Bridge the Instant download/sync/auth notifications onto the
            // typed InstantSync*/InstantAuth* + DocumentLoadedEvent stream.
            // Must be registered before the download completes so the
            // initial lifecycle events aren't missed.
            adapter.observeInstantLifecycle(
              documentId: _documentIdFromJwt(widget.jwt),
            );
          }
          if (adapter != null) {
            await adapter.onPlatformViewCreated(_viewHandle!);
            debugPrint(
              '[NutrientInstantViewIOS] Adapter notified - delegate ready',
            );
          }

          // Mark the controller as ready now that the Instant VC is attached
          if (adapter is IOSAdapter) {
            await adapter.markReady();
            debugPrint('[NutrientInstantViewIOS] Controller marked as ready');
          }

          // Notify user
          widget.onViewCreated?.call(_viewHandle!);

          // Resolve and notify the typed Instant controller — after
          // onViewCreated, mirroring NutrientViewIOS's onControllerReady
          // timing at the composition layer (fires once markReady()
          // succeeds).
          final instantController = await _resolveInstantController(adapter);
          if (instantController != null) {
            widget.onControllerReady?.call(instantController);
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint(
        '[NutrientInstantViewIOS] Error creating Instant view controller: $e\n$stackTrace',
      );
    }
  }

  /// Resolves the [NutrientInstantController] to hand to
  /// [NutrientInstantViewIOS.onControllerReady], or `null` when
  /// [onControllerReady] has no registered listener need (i.e. there's no
  /// resolved [adapter] at all — nothing to attach a default controller to).
  ///
  /// - If [adapter] already implements [NutrientInstantController] (either
  ///   the caller passed an instant-aware adapter, or a custom subclass),
  ///   it's used directly — it already went through the full lifecycle
  ///   ([IOSAdapter.attachViewHandle], `onPlatformViewCreated`, `markReady`)
  ///   above, so no extra wiring is needed.
  /// - Otherwise, a fresh [IOSInstantController] is built and attached to
  ///   the same [_viewHandle] so its native calls resolve to the live
  ///   Instant view controller. It intentionally skips
  ///   `observeInstantLifecycle` / `onPlatformViewCreated` — those install
  ///   NSNotification observers and the SDK delegate, which must be set up
  ///   exactly once per view controller; [adapter] (or the default iOS
  ///   viewer, when [adapter] is null) already owns that. The default
  ///   controller only needs [IOSAdapter.attachViewHandle] +
  ///   [NutrientController.markReady] for [nativeViewController] (and
  ///   hence the three Instant sync methods) to resolve.
  ///
  /// Limitation of the fallback: because the fresh default controller
  /// deliberately skips `observeInstantLifecycle`, its `events` stream never
  /// emits `InstantSync*`/`InstantAuth*`/`DocumentLoadedEvent` — it surfaces
  /// the three sync methods only. This path is reached only when
  /// [NutrientInstantViewIOS] is used directly with a non-Instant adapter (or
  /// the deprecated global slot); the public [NutrientInstantView] composition
  /// always supplies a [NutrientInstantController] adapter, which took the
  /// branch above and has a fully wired event stream. Callers on the direct
  /// path who need Instant events should pass an adapter that implements
  /// [NutrientInstantController].
  Future<NutrientInstantController?> _resolveInstantController(
    NutrientPlatformAdapter? adapter,
  ) async {
    if (adapter is NutrientInstantController) {
      return adapter as NutrientInstantController;
    }

    final viewHandle = _viewHandle;
    if (viewHandle == null) return null;

    final controller = _defaultInstantController ??= IOSInstantController();
    controller.attachViewHandle(viewHandle);
    await controller.markReady();
    return controller;
  }

  /// Registers automatic file-conflict resolution when
  /// `IOSViewConfiguration.fileConflictResolution` is configured to something
  /// other than [IOSFileConflictResolution.defaultBehavior].
  ///
  /// See [IOSConfigurationBuilder]'s doc comment: `fileConflictResolution` has
  /// no `PSPDFConfigurationBuilder` property, so it rides along in the same
  /// config JSON map but is applied separately here, after the view controller
  /// exists, via `nutrient_register_file_conflict_resolution`. No-op (leaves
  /// the SDK's default alert UI in place) when unset or set to
  /// [IOSFileConflictResolution.defaultBehavior].
  void _registerFileConflictResolution() {
    final resolution = widget.configuration?.iosConfig?.fileConflictResolution;
    if (resolution == null) return;
    final rawValue = IOSConfigurationBuilder.rawFileConflictResolutionValue(
      resolution,
    );
    if (rawValue == null) return;
    final viewController = _viewController;
    if (viewController == null) return;
    nutrient_register_file_conflict_resolution(
      viewController.ref.pointer.cast<ffi.Void>(),
      rawValue,
    );
    debugPrint(
      '[NutrientInstantViewIOS] Registered automatic file-conflict resolution '
      '(${resolution.name})',
    );
  }

  /// Wrap a [PSPDFViewController] in a [PSPDFNavigationController].
  ///
  /// Uses PSPDFKit's own `PSPDFNavigationController` (a `UINavigationController`
  /// subclass) rather than a plain `UINavigationController`, matching the
  /// pattern used in [NutrientViewIOS] and the legacy `PspdfkitApiImpl` path.
  /// PSPDFNavigationController forwards rotation and bar-appearance hooks to
  /// the embedded PDF view controller; without it PSPDFInstantViewController's
  /// internal Instant connection hooks do not wire up correctly after the
  /// document download completes, causing `document.isValid` to return NO and
  /// every page render to fail with PSPDFErrorCodeDocumentNotValid (code 102).
  UINavigationController _wrapInNavigationController(
    PSPDFViewController pdfViewController,
  ) {
    final allocatedNav = PSPDFNavigationController.alloc();
    return allocatedNav.initWithRootViewController(pdfViewController);
  }

  /// Attach the navigation controller to the platform view container using
  /// the native companion helper exposed via FFI bindings.
  bool _attachViewControllerViaCompanion(
    int viewId,
    UINavigationController controller,
  ) {
    try {
      final controllerPointer = controller.ref.pointer.cast<ffi.Void>();
      return nutrient_attach_view_controller(viewId, controllerPointer);
    } catch (e, stackTrace) {
      debugPrint(
        '[NutrientInstantViewIOS] Error calling companion method: $e\n$stackTrace',
      );
      return false;
    }
  }

  /// Extracts the `document_id` claim from the Instant JWT (shared
  /// [instantDocumentIdFromJwt] helper, also used by the web Instant view)
  /// so the typed Instant events can carry it. Falls back to an empty
  /// string when the JWT is malformed — the server would reject such a
  /// token anyway, and the auth-failure event will say so.
  static String _documentIdFromJwt(String jwt) {
    try {
      return instantDocumentIdFromJwt(jwt);
    } on FormatException {
      return '';
    }
  }

  /// Convert a Dart [String] to a null-terminated UTF-8 C string allocated
  /// with [ffi_pkg.calloc]. The caller is responsible for freeing the
  /// pointer. UTF-8 (not UTF-16 code units) is required — the native side
  /// reads these with `stringWithUTF8String`, which returns nil on invalid
  /// UTF-8 (a non-ASCII server URL or config value would otherwise be
  /// silently discarded).
  ffi.Pointer<ffi.Char> _toCString(String s) {
    final bytes = utf8.encode(s);
    final ptr = ffi_pkg.calloc<ffi.Char>(bytes.length + 1);
    for (var i = 0; i < bytes.length; i++) {
      ptr[i] = bytes[i];
    }
    ptr[bytes.length] = 0;
    return ptr;
  }

  @override
  Widget build(BuildContext context) {
    // Reuse the same native container view type as NutrientViewIOS so that
    // the same PspdfPlatformView factory and companion helper are used.
    const String viewType = 'io.nutrient.flutter/pdf_view_controller_container';

    return UiKitView(
      viewType: viewType,
      creationParams: const <String, dynamic>{},
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onPlatformViewCreated,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );
  }
}
