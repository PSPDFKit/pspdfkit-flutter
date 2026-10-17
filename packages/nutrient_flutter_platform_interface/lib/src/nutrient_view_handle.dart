///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Handle identifying a platform view instance.
///
/// Passed to adapter lifecycle callbacks (e.g.
/// [NutrientPlatformAdapter.onPlatformViewCreated]). To reach native SDK
/// objects, prefer the **typed** accessors on your platform adapter — they
/// return the real native type with no casting:
///
/// - **Android** ([AndroidAdapter]): `nativePdfDocument`, `nativePdfFragment`,
///   `nativePdfUiFragment`, `nativeFormProvider`.
/// - **iOS** ([IOSAdapter]): `nativeViewController`, `nativeDocument`,
///   `nativeFormParser`.
/// - **Web** ([NutrientWebAdapter]): `nativeInstance`.
///
/// Example:
/// ```dart
/// @override
/// Future<void> onViewControllerReady(PSPDFViewController vc) async {
///   final doc = nativeDocument; // typed, no cast
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

  /// Low-level, stringly-typed lookup of a registered native instance.
  ///
  /// Internal plumbing behind the typed `native*` accessors on the platform
  /// adapters — those are the supported, type-safe way to reach native objects.
  /// This returns `Object?` keyed by a magic string and requires a manual cast,
  /// so prefer `nativeDocument` / `nativePdfFragment` / `nativeInstance` / etc.
  ///
  /// Returns `null` if the identifier isn't registered or the platform doesn't
  /// support it.
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

  /// Whether any native instance is still registered for [viewId].
  ///
  /// Used to tell whether a view is still live: a view registers its native
  /// instances on creation and unregisters them (via [NutrientViewHandle.dispose])
  /// when it is torn down, so a `true` result means the view is still around.
  static bool hasView(int viewId) => _instances.containsKey(viewId);

  /// Unregister all instances for a view.
  static void unregister(int viewId) {
    _instances.remove(viewId);
  }
}
