///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Handle for accessing platform-specific native SDK instances.
///
/// This class provides access to native SDK objects when extending platform
/// adapters. Use it in adapter callbacks like [NutrientPlatformAdapter.onPlatformViewCreated]
/// to access native instances.
///
/// Platform packages use this handle to:
/// - Register native instances during view creation
/// - Access native SDK objects (PdfFragment, PSPDFViewController, etc.)
/// - Clean up resources when the view is disposed
///
/// Example:
/// ```dart
/// @override
/// Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {
///   await super.onPlatformViewCreated(handle);
///   final viewController = handle.getNativeInstance('viewController');
/// }
/// ```
class NutrientViewHandle {
  /// Internal constructor.
  NutrientViewHandle._(this.viewId);

  /// Factory constructor for platform implementations.
  ///
  /// Platform implementations should use this to create handle instances.
  factory NutrientViewHandle.forPlatform(int viewId) {
    return NutrientViewHandle._(viewId);
  }

  /// Unique identifier for this view instance.
  final int viewId;

  /// Get native SDK instance by identifier.
  ///
  /// Available instances by platform:
  ///
  /// **Android (via JNI bindings)**:
  /// - `'pdfFragment'` → `PdfFragment` (primary view)
  /// - `'pdfUiFragment'` → `PdfUiFragment` (UI wrapper)
  /// - `'pdfDocument'` → `PdfDocument` (document instance)
  ///
  /// **iOS (via FFI bindings)**:
  /// - `'viewController'` → `PSPDFViewController` (primary controller)
  /// - `'document'` → `PSPDFDocument` (document instance)
  /// - `'configuration'` → `PSPDFConfiguration` (config object)
  ///
  /// **Web (via JS interop)**:
  /// - `'instance'` → `NutrientWebInstance` (SDK instance)
  ///
  /// Returns `null` if identifier not found or platform doesn't support it.
  Object? getNativeInstance(String identifier) {
    return NativeInstanceRegistry.get(viewId, identifier);
  }

  /// Dispose of this handle and clean up resources.
  ///
  /// Called automatically when [NutrientView] is disposed.
  Future<void> dispose() async {
    NativeInstanceRegistry.unregister(viewId);
  }
}

/// Registry for native instances.
///
/// Platform-specific implementations register their native instances
/// here during view creation.
class NativeInstanceRegistry {
  static final Map<int, Map<String, Object>> _instances = {};

  /// Register a native instance for a view.
  ///
  /// Called by platform implementations during view creation.
  static void register(int viewId, String identifier, Object instance) {
    _instances.putIfAbsent(viewId, () => {})[identifier] = instance;
  }

  /// Get a registered native instance.
  static Object? get(int viewId, String identifier) {
    return _instances[viewId]?[identifier];
  }

  /// Unregister all instances for a view.
  static void unregister(int viewId) {
    _instances.remove(viewId);
  }
}
