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

import 'bindings/nutrient_ios_bindings.dart' hide Factory;
import 'ios_configuration_builder.dart';
import 'ios_platform_adapter.dart';

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

  const NutrientInstantViewIOS({
    super.key,
    required this.serverUrl,
    required this.jwt,
    this.configuration,
    this.onViewCreated,
  });

  @override
  State<NutrientInstantViewIOS> createState() => _NutrientInstantViewIOSState();
}

class _NutrientInstantViewIOSState extends State<NutrientInstantViewIOS> {
  PSPDFViewController? _viewController;
  int? _platformViewId;
  NutrientViewHandle? _viewHandle;

  @override
  void dispose() {
    // Call adapter lifecycle hooks before cleanup
    final adapter = platform.Nutrient.iosAdapter;
    if (adapter != null) {
      unawaited(adapter.dispose());
    }

    // Clear native instance references from the registry BEFORE disposing view handle
    // This prevents dangling references during hot restart
    if (_platformViewId != null) {
      platform.NativeInstanceRegistry.unregister(_platformViewId!);
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

      // Enable real-time sync — PSPDFInstantViewController defaults to false.
      nutrient_instant_set_listen_for_server_changes(vcPointer, true);

      // Wrap the opaque pointer in a PSPDFViewController ObjC object.
      // The C function returns a __bridge_retained pointer (+1 retain count),
      // so we set retain: false and release: true to take ownership.
      _viewController = PSPDFViewController.fromPointer(
        vcPointer.cast(),
        retain: false,
        release: true,
      );
      debugPrint('[NutrientInstantViewIOS] Created PSPDFInstantViewController');

      // Wrap in UINavigationController for toolbar and navigation support
      final navController = _wrapInNavigationController(_viewController!);
      debugPrint('[NutrientInstantViewIOS] Wrapped in UINavigationController');

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

          // Call platform adapter lifecycle hooks so delegates are set up
          // before any document-level events fire
          final adapter = platform.Nutrient.iosAdapter;
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
        }
      }
    } catch (e, stackTrace) {
      debugPrint(
        '[NutrientInstantViewIOS] Error creating Instant view controller: $e\n$stackTrace',
      );
    }
  }

  /// Wrap a [PSPDFViewController] in a [UINavigationController].
  ///
  /// This provides the standard navigation bar and toolbar for PDF features,
  /// matching the pattern used in [NutrientViewIOS].
  UINavigationController _wrapInNavigationController(
    PSPDFViewController pdfViewController,
  ) {
    final allocatedNav = UINavigationController.alloc();
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

  /// Convert a Dart [String] to a null-terminated C string allocated with
  /// [ffi_pkg.calloc]. The caller is responsible for freeing the pointer.
  ffi.Pointer<ffi.Char> _toCString(String s) {
    // Encode as Latin-1 code units then append a null terminator.
    // For URLs and JWTs that are ASCII-safe this is equivalent to UTF-8.
    final units = [...s.codeUnits, 0];
    final ptr = ffi_pkg.calloc<ffi.Char>(units.length);
    for (var i = 0; i < units.length; i++) {
      ptr[i] = units[i];
    }
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
