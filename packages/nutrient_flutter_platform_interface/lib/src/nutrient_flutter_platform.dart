///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nutrient_platform_adapter.dart';

/// The interface that implementations of nutrient_flutter must implement.
///
/// Platform implementations should extend this class rather than implement it as `nutrient_flutter`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [NutrientFlutterPlatform] methods.
abstract class NutrientFlutterPlatform extends PlatformInterface {
  /// Constructs a NutrientFlutterPlatform.
  NutrientFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static NutrientFlutterPlatform? _instance;

  /// The registered platform implementation, or `null` if none has registered
  /// yet — e.g. on an unsupported platform, or before the Flutter plugin
  /// registrant has run. Each platform package sets this from its
  /// `registerWith()`, which Flutter invokes before `main()`.
  static NutrientFlutterPlatform? get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NutrientFlutterPlatform] when
  /// they register themselves.
  static set instance(NutrientFlutterPlatform? instance) {
    if (instance != null) {
      PlatformInterface.verifyToken(instance, _token);
    }
    _instance = instance;
  }

  /// The version string of the underlying native Nutrient SDK on this platform
  /// (e.g. `"11.5.1"` on Android/iOS, the Web SDK version on web), or `null`
  /// when the platform doesn't report one. Surfaced to apps via
  /// [Nutrient.frameworkVersion].
  Future<String?> getPlatformVersion();

  /// Activates the native SDK license for this platform.
  ///
  /// Called once by [Nutrient.initialize] with the current platform's license
  /// key (`null`/empty ⇒ trial mode, watermarked). This is a **stateless**,
  /// SDK-global step — independent of any per-view adapter — so it lives here
  /// rather than on [NutrientPlatformAdapter]:
  ///
  /// - **Android** — `Nutrient.initialize(context, …)` with the key.
  /// - **iOS** — `PSPDFKitGlobal.setLicenseKey(…)`, which must run before any
  ///   other SDK API.
  /// - **Web** — no-op (the key is injected into each `NutrientViewer.load()`).
  ///
  /// Implementations must be idempotent (activate at most once). The default is
  /// a no-op so platforms that license per-load (web) need not override it.
  Future<void> activateLicense(String? licenseKey) async {}

  /// Creates the SDK's built-in default adapter for this platform.
  ///
  /// This is the no-customization adapter — it gives you the full default
  /// viewer (document loading, the built-in toolbar, annotations, the typed
  /// event stream, …). [Nutrient.initialize] calls it to supply an adapter
  /// when the caller didn't pass one, so registering an adapter is only
  /// necessary when you want to customize the viewer.
  ///
  /// Platform packages override this. The base implementation throws so that
  /// any platform without a default surfaces the gap instead of failing
  /// silently — callers are expected to handle [UnimplementedError].
  NutrientPlatformAdapter createDefaultAdapter() => throw UnimplementedError(
        'createDefaultAdapter() has not been implemented for this platform.',
      );

  /// Creates a fresh default adapter for an Instant view — the Instant
  /// counterpart of [createDefaultAdapter], returning a controller that also
  /// implements `NutrientInstantController` so a bare `NutrientInstantView`
  /// surfaces the Instant sync methods in `onControllerReady`.
  ///
  /// Android and iOS override this. The base implementation throws so
  /// platforms without runtime Instant controls (Web configures Instant at
  /// load time) surface the gap — callers handle [UnimplementedError].
  NutrientPlatformAdapter createDefaultInstantAdapter() =>
      throw UnimplementedError(
        'createDefaultInstantAdapter() has not been implemented for this '
        'platform.',
      );
}
