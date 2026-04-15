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
import 'nutrient_platform_adapter.dart';

/// Main entry point for the Nutrient Flutter Bindings plugin.
///
/// This class provides ONLY:
/// - SDK initialization with license key
/// - Platform adapter registration and management
/// - SDK version information
///
/// All other functionality (navigation, annotations, forms, events, etc.)
/// is provided through platform adapters.
///
/// ## Basic Usage
///
/// Initialize with just a license key:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   await Nutrient.initialize(
///     licenseKey: 'YOUR_LICENSE_KEY',
///   );
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## Advanced Usage with Platform Adapters
///
/// Register custom adapters for advanced functionality:
/// ```dart
/// await Nutrient.initialize(
///   licenseKey: 'YOUR_LICENSE_KEY',
///   androidAdapter: MyAndroidAdapter(),
///   iosAdapter: MyIOSAdapter(),
///   webAdapter: MyWebAdapter(),
/// );
///
/// // Later, access the adapter
/// final adapter = Nutrient.currentAdapter;
/// adapter.events.listen((event) {
///   // Handle events
/// });
/// ```
class Nutrient {
  static NutrientPlatformAdapter? _androidAdapter;
  static NutrientPlatformAdapter? _iosAdapter;
  static NutrientPlatformAdapter? _webAdapter;
  static String? _androidLicenseKey;
  static String? _iosLicenseKey;
  static String? _webLicenseKey;
  static bool _initialized = false;

  /// Initialize the Nutrient SDK.
  ///
  /// Must be called before using [NutrientView] or accessing adapters.
  ///
  /// **License Keys**: License keys are optional. If not provided or set to null,
  /// the SDK will run in trial mode with watermarks.
  ///
  /// **Trial Mode** (no license key):
  /// ```dart
  /// await Nutrient.initialize(
  ///   androidLicenseKey: null,
  ///   iosLicenseKey: null,
  ///   webLicenseKey: null,
  /// );
  /// ```
  ///
  /// **Single Platform Example**:
  /// ```dart
  /// // For Android only
  /// await Nutrient.initialize(
  ///   androidLicenseKey: 'YOUR_ANDROID_KEY',
  /// );
  /// ```
  ///
  /// **Multi-Platform Example**:
  /// ```dart
  /// await Nutrient.initialize(
  ///   androidLicenseKey: 'YOUR_ANDROID_KEY',
  ///   iosLicenseKey: 'YOUR_IOS_KEY',
  ///   webLicenseKey: 'YOUR_WEB_KEY',
  /// );
  /// ```
  ///
  /// **With Platform Adapters**:
  /// ```dart
  /// await Nutrient.initialize(
  ///   androidLicenseKey: 'YOUR_ANDROID_KEY',
  ///   iosLicenseKey: 'YOUR_IOS_KEY',
  ///   webLicenseKey: 'YOUR_WEB_KEY',
  ///   androidAdapter: MyAndroidAdapter(),
  ///   iosAdapter: MyIOSAdapter(),
  ///   webAdapter: MyWebAdapter(),
  /// );
  /// ```
  ///
  /// Throws [StateError] if already initialized.
  static Future<void> initialize({
    String? androidLicenseKey,
    String? iosLicenseKey,
    String? webLicenseKey,
    NutrientPlatformAdapter? androidAdapter,
    NutrientPlatformAdapter? iosAdapter,
    NutrientPlatformAdapter? webAdapter,
  }) async {
    if (_initialized) {
      throw StateError(
        'Nutrient has already been initialized. '
        'Call Nutrient.initialize() only once.',
      );
    }

    // License keys are optional - if null/empty, SDK runs in trial mode
    _androidLicenseKey = androidLicenseKey;
    _iosLicenseKey = iosLicenseKey;
    _webLicenseKey = webLicenseKey;

    _androidAdapter = androidAdapter;
    _iosAdapter = iosAdapter;
    _webAdapter = webAdapter;
    _initialized = true;

    // Platform-specific initialization will be handled by platform implementations
  }

  /// Get the current platform adapter.
  ///
  /// Returns the adapter for the current platform:
  /// - Android: [androidAdapter]
  /// - iOS: [iosAdapter]
  /// - Web: [webAdapter]
  ///
  /// Returns `null` if:
  /// - SDK not initialized
  /// - No adapter registered for current platform
  ///
  /// Example:
  /// ```dart
  /// final adapter = Nutrient.currentAdapter;
  /// if (adapter != null) {
  ///   adapter.events.listen((event) {
  ///     print('Event: $event');
  ///   });
  /// }
  /// ```
  static NutrientPlatformAdapter? get currentAdapter {
    if (!_initialized) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidAdapter;
      case TargetPlatform.iOS:
        return _iosAdapter;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        // Web is handled by kIsWeb check
        return _webAdapter;
    }
  }

  /// Get the Android platform adapter.
  ///
  /// Returns `null` if no Android adapter is registered.
  static NutrientPlatformAdapter? get androidAdapter => _androidAdapter;

  /// Get the iOS platform adapter.
  ///
  /// Returns `null` if no iOS adapter is registered.
  static NutrientPlatformAdapter? get iosAdapter => _iosAdapter;

  /// Get the Web platform adapter.
  ///
  /// Returns `null` if no Web adapter is registered.
  static NutrientPlatformAdapter? get webAdapter => _webAdapter;

  /// Set or replace the Android platform adapter.
  ///
  /// Can be called after initialization to change the adapter.
  ///
  /// Example:
  /// ```dart
  /// await Nutrient.setAndroidAdapter(MyAndroidAdapter());
  /// ```
  static Future<void> setAndroidAdapter(NutrientPlatformAdapter adapter) async {
    if (!_initialized) {
      throw StateError(
        'Nutrient must be initialized before setting adapters. '
        'Call Nutrient.initialize() first.',
      );
    }

    if (adapter.platform != TargetPlatform.android) {
      throw ArgumentError(
        'Adapter platform must be Android, got ${adapter.platform}',
      );
    }

    // Dispose old adapter if exists
    await _androidAdapter?.dispose();
    _androidAdapter = adapter;
  }

  /// Set or replace the iOS platform adapter.
  ///
  /// Can be called after initialization to change the adapter.
  ///
  /// Example:
  /// ```dart
  /// await Nutrient.setIOSAdapter(MyIOSAdapter());
  /// ```
  static Future<void> setIOSAdapter(NutrientPlatformAdapter adapter) async {
    if (!_initialized) {
      throw StateError(
        'Nutrient must be initialized before setting adapters. '
        'Call Nutrient.initialize() first.',
      );
    }

    if (adapter.platform != TargetPlatform.iOS) {
      throw ArgumentError(
        'Adapter platform must be iOS, got ${adapter.platform}',
      );
    }

    // Dispose old adapter if exists
    await _iosAdapter?.dispose();
    _iosAdapter = adapter;
  }

  /// Set or replace the Web platform adapter.
  ///
  /// Can be called after initialization to change the adapter.
  ///
  /// Example:
  /// ```dart
  /// await Nutrient.setWebAdapter(MyWebAdapter());
  /// ```
  static Future<void> setWebAdapter(NutrientPlatformAdapter adapter) async {
    if (!_initialized) {
      throw StateError(
        'Nutrient must be initialized before setting adapters. '
        'Call Nutrient.initialize() first.',
      );
    }

    // Dispose old adapter if exists
    await _webAdapter?.dispose();
    _webAdapter = adapter;
  }

  /// Get the SDK version string.
  ///
  /// Returns the version of the Nutrient Flutter Bindings plugin.
  ///
  /// Example: `"1.0.0"`
  static String get version => '1.0.0-dev';

  /// Get the Android license key.
  ///
  /// Returns `null` if SDK not initialized or no Android key provided.
  static String? get androidLicenseKey => _androidLicenseKey;

  /// Get the iOS license key.
  ///
  /// Returns `null` if SDK not initialized or no iOS key provided.
  static String? get iosLicenseKey => _iosLicenseKey;

  /// Get the Web license key.
  ///
  /// Returns `null` if SDK not initialized or no Web key provided.
  static String? get webLicenseKey => _webLicenseKey;

  /// Get the license key for the current platform.
  ///
  /// Returns the appropriate license key based on the current platform.
  /// Returns `null` if SDK not initialized or no key for current platform.
  static String? get currentLicenseKey {
    if (!_initialized) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidLicenseKey;
      case TargetPlatform.iOS:
        return _iosLicenseKey;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        // Web is handled by kIsWeb check
        return _webLicenseKey;
    }
  }

  /// Whether the SDK has been initialized.
  static bool get isInitialized => _initialized;

  /// Reset the SDK state (for testing only).
  ///
  /// **WARNING**: This should only be used in tests.
  /// Calling this in production code may cause unexpected behavior.
  @visibleForTesting
  static Future<void> reset() async {
    await _androidAdapter?.dispose();
    await _iosAdapter?.dispose();
    await _webAdapter?.dispose();

    _androidAdapter = null;
    _iosAdapter = null;
    _webAdapter = null;
    _androidLicenseKey = null;
    _iosLicenseKey = null;
    _webLicenseKey = null;
    _initialized = false;
  }
}
