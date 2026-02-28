///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

// Import adapters directly from their source files to avoid conditional export issues
// ignore: implementation_imports
import 'package:nutrient_flutter_android/src/android_platform_adapter.dart';
// ignore: implementation_imports
import 'package:nutrient_flutter_ios/src/ios_platform_adapter.dart';

// Platform-specific bindings for direct native SDK access
// ignore: implementation_imports
import 'package:nutrient_flutter_ios/src/bindings/nutrient_ios_bindings.dart'
    as ios_bindings;
// ignore: implementation_imports
import 'package:nutrient_flutter_android/src/bindings/nutrient_android_sdk_bindings.dart'
    as android_bindings;

// Type aliases for cleaner usage
typedef PdfFragment = android_bindings.PdfFragment;
typedef PSPDFViewController = ios_bindings.PSPDFViewController;

/// Bridge for connecting native platform instances to adapters.
///
/// This class listens for native instance ready callbacks from the platform
/// and forwards them to the appropriate adapter methods.
///
/// ## Architecture
///
/// The AdapterBridge connects the Pigeon-based NutrientView to the adapter
/// infrastructure. When native instances (PdfFragment on Android,
/// PSPDFViewController on iOS) become ready, the native side sends a
/// notification via method channel, and this bridge:
///
/// 1. Creates a [NutrientViewHandle] for the view
/// 2. Notifies the adapter via its lifecycle callbacks
/// 3. Marks the adapter as ready
///
/// ## Native Instance Access
///
/// The native instances are registered in static registries on the native side:
/// - Android: `PSPDFKitView.pdfFragmentRegistry`
/// - iOS: `PspdfPlatformView.viewControllerRegistry`
///
/// For full JNI/FFI access to these instances, users should use the bindings-based
/// packages (`NutrientViewAndroid`, `NutrientViewIOS`) instead of the Pigeon-based
/// `NutrientView`. The Pigeon-based view provides adapter lifecycle notifications
/// but does not expose direct native object access.
///
/// ## Usage Note
///
/// This bridge enables adapter lifecycle hooks for the Pigeon-based NutrientView.
/// For advanced use cases requiring direct native SDK access via JNI/FFI bindings,
/// use `NutrientViewAndroid` or `NutrientViewIOS` from the platform-specific packages.
class AdapterBridge {
  static final Map<int, AdapterBridge> _instances = {};

  final int _viewId;
  final MethodChannel _channel;
  final NutrientPlatformAdapter _adapter;
  NutrientViewHandle? _handle;

  AdapterBridge._({
    required int viewId,
    required MethodChannel channel,
    required NutrientPlatformAdapter adapter,
  })  : _viewId = viewId,
        _channel = channel,
        _adapter = adapter {
    _setupMethodCallHandler();
  }

  /// Sets up the adapter bridge for the given view ID.
  static void setup({
    required int viewId,
    required MethodChannel channel,
    required NutrientPlatformAdapter adapter,
  }) {
    _instances[viewId] = AdapterBridge._(
      viewId: viewId,
      channel: channel,
      adapter: adapter,
    );
  }

  /// Disposes the adapter bridge for the given view ID.
  static void dispose(int viewId) {
    final bridge = _instances.remove(viewId);
    bridge?._dispose();
  }

  void _setupMethodCallHandler() {
    // Create view handle and attach to adapter
    _handle = NutrientViewHandle.forPlatform(_viewId);

    // Attach handle to adapter if it extends NutrientController
    if (_adapter is NutrientController) {
      (_adapter as NutrientController).attachViewHandle(_handle!);
    }

    // Set up method call handler for native instance callbacks
    _channel.setMethodCallHandler(_handleMethodCall);

    debugPrint('[AdapterBridge] Setup complete for view $_viewId');
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    debugPrint('[AdapterBridge] Received method call: ${call.method}');

    switch (call.method) {
      case 'onPdfFragmentReady':
        await _handleAndroidFragmentReady(call.arguments);
        break;
      case 'onViewControllerReady':
        await _handleIOSViewControllerReady(call.arguments);
        break;
      default:
        // Let other handlers process unknown methods
        break;
    }
  }

  Future<void> _handleAndroidFragmentReady(dynamic arguments) async {
    if (!Platform.isAndroid) return;
    if (_adapter is! AndroidAdapter) {
      debugPrint('[AdapterBridge] Adapter is not an AndroidAdapter, skipping');
      return;
    }

    final androidAdapter = _adapter as AndroidAdapter;

    // The native side has registered the PdfFragment in PSPDFKitView's static registry.
    // We notify the adapter that the fragment is ready.
    //
    // Note: For direct JNI access to PdfFragment, users should use NutrientViewAndroid
    // from nutrient_flutter_android package instead of the Pigeon-based NutrientView.
    try {
      // Try to get the PdfFragment via JNI if bindings are available
      final pdfFragment = _getPdfFragmentFromNative();

      if (pdfFragment != null) {
        // Register in the native instance registry
        NativeInstanceRegistry.register(_viewId, 'pdfFragment', pdfFragment);

        // Notify the adapter with the actual fragment
        await androidAdapter.onPdfFragmentReady(pdfFragment);

        debugPrint(
            '[AdapterBridge] Android PdfFragment ready and adapter notified');
      } else {
        // JNI bindings not available for PSPDFKitView - notify adapter without fragment
        debugPrint('[AdapterBridge] PdfFragment JNI access not available. '
            'For direct native access, use NutrientViewAndroid instead.');

        // Still notify the adapter that the view is ready
        await _adapter.onPlatformViewCreated(_handle!);
      }

      // Mark adapter as ready
      await androidAdapter.markReady();
    } catch (e, stackTrace) {
      debugPrint(
          '[AdapterBridge] Error handling PdfFragment ready: $e\n$stackTrace');

      // Fallback: notify adapter via platform view created
      await _adapter.onPlatformViewCreated(_handle!);
      await androidAdapter.markReady();
    }
  }

  Future<void> _handleIOSViewControllerReady(dynamic arguments) async {
    if (!Platform.isIOS) return;
    if (_adapter is! IOSAdapter) {
      debugPrint('[AdapterBridge] Adapter is not an IOSAdapter, skipping');
      return;
    }

    final iosAdapter = _adapter as IOSAdapter;

    // The native side has registered the PSPDFViewController in PspdfPlatformView's
    // static registry. We notify the adapter that the view controller is ready.
    //
    // Note: For direct FFI access to PSPDFViewController, users should use
    // NutrientViewIOS from nutrient_flutter_ios package instead.
    try {
      // Try to get the PSPDFViewController via FFI if bindings are available
      final viewController = _getPSPDFViewControllerFromNative();

      if (viewController != null) {
        // Register in the native instance registry
        NativeInstanceRegistry.register(
            _viewId, 'viewController', viewController);

        // Notify the adapter with the actual view controller
        await iosAdapter.onViewControllerReady(viewController);

        debugPrint(
            '[AdapterBridge] iOS PSPDFViewController ready and adapter notified');
      } else {
        // FFI bindings not available for PspdfPlatformView - notify adapter without VC
        debugPrint(
            '[AdapterBridge] PSPDFViewController FFI access not available. '
            'For direct native access, use NutrientViewIOS instead.');

        // Still notify the adapter that the view is ready
        await _adapter.onPlatformViewCreated(_handle!);
      }

      // Mark adapter as ready
      await iosAdapter.markReady();
    } catch (e, stackTrace) {
      debugPrint(
          '[AdapterBridge] Error handling PSPDFViewController ready: $e\n$stackTrace');

      // Fallback: notify adapter via platform view created
      await _adapter.onPlatformViewCreated(_handle!);
      await iosAdapter.markReady();
    }
  }

  /// Attempts to get the PdfFragment from native via JNI.
  ///
  /// This calls `PSPDFKitView.getPdfFragment(viewId)` via JNI bindings.
  /// The bindings are generated from nutrient_flutter's PSPDFKitView class
  /// which maintains a static registry of PdfFragment instances.
  ///
  /// Returns null if the fragment is not registered or JNI fails.
  PdfFragment? _getPdfFragmentFromNative() {
    try {
      // Access the Companion object on PSPDFKitView, then call getPdfFragment
      final companion = android_bindings.PSPDFKitView.Companion;
      final pdfFragment = companion.getPdfFragment(_viewId);

      if (pdfFragment == null) {
        debugPrint('[AdapterBridge] No PdfFragment found for view $_viewId');
        return null;
      }

      debugPrint(
          '[AdapterBridge] Successfully retrieved PdfFragment for view $_viewId');
      return pdfFragment;
    } catch (e, stackTrace) {
      debugPrint(
          '[AdapterBridge] Error getting PdfFragment via JNI: $e\n$stackTrace');
      return null;
    }
  }

  /// Attempts to get the PSPDFViewController from native via FFI.
  ///
  /// This calls the `nutrient_get_view_controller` C function which is
  /// implemented in `nutrient_flutter`'s native code and exposed via
  /// `nutrient_flutter_ios`'s FFI bindings.
  ///
  /// Returns null if the view controller is not registered or FFI fails.
  PSPDFViewController? _getPSPDFViewControllerFromNative() {
    try {
      // Call the FFI function to get the view controller pointer.
      // Implemented in nutrient_flutter_ios's NutrientFFI.mm, compiled into
      // nutrient_flutter_ios.dylib by the native-assets hook (hook/build.dart).
      final viewControllerPointer =
          ios_bindings.nutrient_get_view_controller(_viewId);

      if (viewControllerPointer == ffi.nullptr) {
        debugPrint(
            '[AdapterBridge] No PSPDFViewController found for view $_viewId');
        return null;
      }

      // Wrap the pointer in a PSPDFViewController object.
      // The C function returns a __bridge cast (no ownership transfer), so we
      // must retain (+1) to prevent deallocation if the native registry removes
      // its reference first, and release (-1) on Dart GC finalization.
      final viewController = PSPDFViewController.fromPointer(
        viewControllerPointer.cast(),
        retain: true,
        release: true,
      );

      debugPrint(
          '[AdapterBridge] Successfully retrieved PSPDFViewController for view $_viewId');
      return viewController;
    } catch (e, stackTrace) {
      // This will fail if bindings haven't been regenerated yet.
      // In that case, fall back to notifying the adapter without the native instance.
      debugPrint(
          '[AdapterBridge] Error getting PSPDFViewController via FFI: $e\n$stackTrace');
      return null;
    }
  }

  void _dispose() {
    // Eagerly clear the registry to release the retained native object
    // (PSPDFViewController/PdfFragment) as soon as possible, rather than
    // waiting for Dart GC to finalize the FFI wrapper.
    NativeInstanceRegistry.unregister(_viewId);
    _handle?.dispose();
    _adapter.dispose();
    debugPrint('[AdapterBridge] Disposed for view $_viewId');
  }
}
