import 'dart:async';
import 'package:flutter/foundation.dart';
import 'nutrient_view_handle.dart';

/// Platform adapter interface for extending Nutrient functionality.
///
/// Platform adapters provide lifecycle hooks and access to native SDK instances,
/// enabling deep customization without forking the plugin.
///
/// ## Overview
///
/// The core plugin provides:
/// - Document display via [NutrientView]
/// - Native instance access via platform-specific adapters
///
/// Platform adapters provide:
/// - Lifecycle hooks (view creation, document loading, cleanup)
/// - Direct access to native SDK instances
/// - Custom event handling and business logic
///
/// ## Implementation
///
/// Extend the platform-specific base adapter:
///
/// ### Android (JNI Bindings)
/// ```dart
/// class MyAndroidAdapter extends AndroidAdapter {
///   @override
///   Future<void> onFragmentAttached(
///     PdfUiFragment fragment,
///     Context context,
///   ) async {
///     // Access fragment methods through JNI
///     final config = fragment.getConfiguration();
///   }
///
///   @override
///   Future<void> onDocumentLoaded(
///     PdfDocument document,
///     PdfFragment pdfFragment,
///   ) async {
///     // Access document properties
///     final pageCount = document.getPageCount();
///   }
///
///   @override
///   Future<void> onFragmentDetached() async {
///     // Clean up resources
///   }
/// }
/// ```
///
/// ### iOS (FFI Bindings)
/// ```dart
/// class MyIOSAdapter extends IOSAdapter {
///   @override
///   Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {
///     await super.onPlatformViewCreated(handle);
///     // Access iOS-specific APIs through handle
///     // Implementation depends on iOS adapter structure
///   }
/// }
/// ```
///
/// ### Web (JavaScript Interop)
/// ```dart
/// class MyWebAdapter extends NutrientWebAdapter {
///   @override
///   Future<void> configureLoad(
///     NutrientViewHandle handle,
///     Map<String, dynamic> config,
///   ) async {
///     await super.configureLoad(handle, config);
///     config['layoutMode'] = 'SINGLE';
///     config['theme'] = 'DARK';
///   }
///
///   @override
///   Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {
///     await super.onPlatformViewCreated(handle);
///     final instance = getInstance(handle);
///     // Use instance to access Web SDK APIs
///   }
/// }
/// ```
///
/// ## Registration
///
/// Register adapters during initialization:
/// ```dart
/// await Nutrient.initialize(
///   licenseKey: 'YOUR_LICENSE_KEY',
///   androidAdapter: MyAndroidAdapter(),
///   iosAdapter: MyIOSAdapter(),
///   webAdapter: MyWebAdapter(),
/// );
/// ```
abstract class NutrientPlatformAdapter {
  /// Platform this adapter supports.
  TargetPlatform get platform;

  /// Called when the platform view is created.
  ///
  /// Use this for early initialization that doesn't require the native SDK instances.
  /// For Android, prefer using [onFragmentAttached] to access native instances.
  ///
  Future<void> onPlatformViewCreated(NutrientViewHandle handle);

  /// Dispose of this adapter and clean up resources.
  ///
  /// Called when the adapter is being removed.
  /// Clean up listeners, streams, and native resources.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> dispose() async {
  ///   await _eventController.close();
  ///   // Clean up native listeners
  /// }
  /// ```
  Future<void> dispose();
}
