///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    hide NativeInstanceRegistry;
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    as platform show NativeInstanceRegistry, Nutrient;
import 'package:web/web.dart' as web;

import 'generated/nutrient_web_bindings.g.dart' as nutrient_web;
import 'web_configuration_builder.dart';
import 'web_platform_adapter.dart';
import 'web_sdk_namespace.dart' as sdk;

/// Web-specific implementation of [NutrientView].
///
/// This class provides the minimal document display functionality using JavaScript interop.
/// All advanced features and configuration (navigation, annotations, forms, toolbar, theme, etc.)
/// are provided through the Web platform adapter.
///
/// **Configuration**: All Web SDK configuration should be done in your adapter's
/// `configureLoad()` method. The view itself only handles document loading.
class NutrientViewWeb extends StatefulWidget {
  /// Path to the document file.
  final String? documentPath;

  /// Document content as bytes.
  final Uint8List? documentBytes;

  /// Called when the view has been created and is ready to use.
  final void Function(NutrientViewHandle handle)? onViewCreated;

  /// Optional adapter override for this widget instance.
  ///
  /// When provided, this adapter is used instead of the global
  /// `Nutrient.webAdapter`. This allows parent widgets (like the
  /// `nutrient_flutter` wrapper) to pass an adapter directly without
  /// modifying global state.
  ///
  /// If `null`, the global `Nutrient.webAdapter` is used as a fallback.
  final NutrientWebAdapter? adapter;

  /// Optional viewer configuration applied via [WebConfigurationBuilder].
  ///
  /// When provided, the typed configuration is translated to a web load
  /// config map and merged into the base configuration before the adapter's
  /// `configureLoad` hook runs — so adapter customizations win over this
  /// configuration.
  final NutrientViewConfiguration? configuration;

  const NutrientViewWeb({
    super.key,
    this.documentPath,
    this.documentBytes,
    this.onViewCreated,
    this.adapter,
    this.configuration,
  }) : assert(
          documentPath != null || documentBytes != null,
          'Either documentPath or documentBytes must be provided',
        );

  @override
  State<NutrientViewWeb> createState() => _NutrientViewWebState();
}

class _NutrientViewWebState extends State<NutrientViewWeb> {
  nutrient_web.Instance? _instance;
  web.HTMLDivElement? _containerElement;
  late final String _viewType;
  int? _viewId;
  NutrientViewHandle? _viewHandle;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _viewId = identityHashCode(this);
    _viewType = 'pspdfkit-container-$_viewId';

    // Register the platform view factory
    _registerViewFactory();
  }

  void _registerViewFactory() {
    // Register factory to create the HTML element
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        // Create and return the container element
        _containerElement =
            (web.document.createElement('div') as web.HTMLDivElement)
              ..id = _viewType
              ..style.width = '100%'
              ..style.height = '100%';

        // Initialize PSPDFKit after a short delay to ensure element is attached
        Future.delayed(const Duration(milliseconds: 100), _initializePSPDFKit);

        return _containerElement!;
      },
    );
  }

  @override
  void dispose() {
    _viewHandle?.dispose();
    _unloadInstance();
    super.dispose();
  }

  void _unloadInstance() {
    if (_instance != null) {
      try {
        sdk.unloadInstance(_instance!);
      } catch (e) {
        debugPrint('[NutrientViewWeb] Error unloading instance: $e');
      }
      _instance = null;
    }
  }

  Future<void> _initializePSPDFKit() async {
    if (_isInitialized || _containerElement == null) return;

    try {
      debugPrint('[NutrientViewWeb] Initializing PSPDFKit for Web');

      // Resolve document source
      final documentSource = await _resolveDocumentSource();
      if (documentSource == null) {
        debugPrint('[NutrientViewWeb] Failed to resolve document source');
        return;
      }

      // Create configuration object
      final configMap = _createConfigurationMap(documentSource);

      // Merge typed NutrientViewConfiguration if provided. The
      // WebConfigurationBuilder output is a partial map whose top-level
      // keys merge directly into the load config; its `initialViewState`
      // (if any) is merged into the existing nested view state.
      final typedConfig = widget.configuration;
      if (typedConfig != null) {
        final typed = WebConfigurationBuilder().buildConfig(typedConfig);
        final typedViewState = typed.remove('initialViewState');
        if (typedViewState is Map<String, dynamic>) {
          final existing = configMap['initialViewState'];
          configMap['initialViewState'] = <String, dynamic>{
            if (existing is Map<String, dynamic>) ...existing,
            ...typedViewState,
          };
        }
        configMap.addAll(typed);
      }

      // Create temporary view handle for configuration
      final tempViewHandle = NutrientViewHandle.forPlatform(_viewId!);

      // Allow adapter to modify configuration before load.
      // Prefer widget-level adapter over the deprecated global slot (a
      // back-compat bridge for direct NutrientViewWeb use — NutrientDocumentView
      // now resolves and passes the controller as `adapter`).
      // ignore: deprecated_member_use
      final globalWebAdapter = platform.Nutrient.webAdapter;
      final adapter = widget.adapter ??
          (globalWebAdapter is NutrientWebAdapter ? globalWebAdapter : null);
      if (adapter != null) {
        await adapter.configureLoad(tempViewHandle, configMap);
      }

      // Convert initialViewState map to a proper ViewState instance.
      // The Web SDK requires initialViewState to be a NutrientViewer.ViewState
      // (or PSPDFKit.ViewState) object, not a plain JS object.
      final viewStateMap = configMap.remove('initialViewState');
      final config = configMap.jsify() as JSObject;
      if (viewStateMap is Map<String, dynamic> && viewStateMap.isNotEmpty) {
        final jsViewStateProps = viewStateMap.jsify()!;
        try {
          config['initialViewState'] = sdk.createViewState(jsViewStateProps);
        } catch (e) {
          debugPrint(
              '[NutrientViewWeb] Error creating ViewState, using plain object: $e');
          config['initialViewState'] = jsViewStateProps;
        }
      }

      // Load instance via the namespace shim (picks NutrientViewer or
      // PSPDFKit at runtime).
      debugPrint('[NutrientViewWeb] Loading Nutrient instance');

      if (!sdk.isLoaded) {
        throw Exception(
          'Nutrient Web SDK not found. Please ensure you have loaded the SDK script in your index.html:\n'
          '<script src="https://cdn.cloud.nutrient.io/pspdfkit-web@1.13.0/nutrient-nutrient_web.js"></script>',
        );
      }

      _instance = await sdk.loadInstance(config).toDart;
      debugPrint('[NutrientViewWeb] PSPDFKit instance loaded successfully');

      _isInitialized = true;

      // Register native instance
      _registerNativeInstance();

      // Create view handle
      _viewHandle = NutrientViewHandle.forPlatform(_viewId!);

      // Call adapter lifecycle hooks
      if (adapter != null) {
        // Attach the handle to the adapter-as-controller before any
        // lifecycle hook runs — NutrientDocumentWeb/managers read
        // adapter.viewHandle to resolve the native nutrient_web.Instance.
        adapter.attachViewHandle(_viewHandle!);
        await adapter.onPlatformViewCreated(_viewHandle!);
        await adapter.onInstanceLoaded(_instance!);

        // Mark the controller as ready now that the instance is loaded.
        // The adapter IS the controller in the adapter-as-controller pattern.
        await adapter.markReady();
        debugPrint('[NutrientViewWeb] Controller marked as ready');
      }

      // Notify user
      widget.onViewCreated?.call(_viewHandle!);
    } catch (e, stackTrace) {
      debugPrint(
          '[NutrientViewWeb] Error initializing PSPDFKit: $e\n$stackTrace');
      _isInitialized = false;
    }
  }

  Future<String?> _resolveDocumentSource() async {
    if (widget.documentPath != null) {
      // For web, document paths are typically URLs or asset paths
      final path = widget.documentPath!;

      // Check if it's already a URL
      if (path.startsWith('http://') ||
          path.startsWith('https://') ||
          path.startsWith('blob:')) {
        return path;
      }

      // Handle asset paths
      if (path.startsWith('assets/')) {
        // Flutter assets are served from the root
        return path;
      }

      // Return as-is and let PSPDFKit handle it
      return path;
    } else if (widget.documentBytes != null) {
      // Convert bytes to Blob URL
      return _createBlobUrl(widget.documentBytes!);
    }

    return null;
  }

  String _createBlobUrl(Uint8List bytes) {
    // Create a Blob from the bytes
    final jsArray = bytes.toJS;
    final blob =
        web.Blob([jsArray].toJS, web.BlobPropertyBag(type: 'application/pdf'));

    // Create and return a blob URL
    return web.URL.createObjectURL(blob);
  }

  Map<String, dynamic> _createConfigurationMap(String documentSource) {
    // Create minimal configuration object for PSPDFKit.load()
    //
    // IMPORTANT: Do NOT set baseUrl or baseCoreUrl here. These are set by the
    // adapter's configureLoad() method from the user's PdfWebConfiguration.
    // The Web SDK enforces that these values stay consistent across load()
    // calls (constantStandaloneBackendOptions), so they must come from a
    // single source of truth — the configuration.
    //
    // useCDN defaults to true to silence the Web SDK deprecation warning
    // (since 1.9.0). When the user provides baseUrl via configuration,
    // useCDN has no effect. useCDN is NOT in constantStandaloneBackendOptions
    // so it won't cause assertion errors.
    final config = <String, dynamic>{
      'container': _containerElement,
      'document': documentSource,
      // Always include productId to ensure consistent configuration across loads.
      // The Web SDK remembers configuration and rejects different configs on reload.
      'productId': 'FlutterForWeb',
      // Default to CDN for asset loading. Has no effect when baseUrl is set.
      'useCDN': true,
    };

    // Only include license key if it's provided and not empty
    final licenseKey = platform.Nutrient.webLicenseKey;
    if (licenseKey != null && licenseKey.isNotEmpty) {
      config['licenseKey'] = licenseKey;
    }

    debugPrint('[NutrientViewWeb] Basic configuration created');

    return config;
  }

  void _registerNativeInstance() {
    if (_viewId == null || _instance == null) return;

    debugPrint('[NutrientViewWeb] Registering native instance');

    // Register PSPDFKit.Instance
    platform.NativeInstanceRegistry.register(
      _viewId!,
      'instance',
      _instance!,
    );

    debugPrint('[NutrientViewWeb] Native instance registered');
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: _viewType,
    );
  }
}
