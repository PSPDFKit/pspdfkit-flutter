///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'dart:ffi' as ffi;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    hide NativeInstanceRegistry;
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    as platform
    show NativeInstanceRegistry, Nutrient;
import 'package:objective_c/objective_c.dart' as objc;

import 'bindings/nutrient_ios_bindings.dart' hide Factory;
import 'ios_platform_adapter.dart';

/// iOS-specific implementation of [NutrientView].
///
/// This class provides the minimal document display functionality using FFI bindings.
/// All advanced features and configuration (navigation, annotations, forms, toolbar, etc.)
/// are provided through the iOS platform adapter.
class NutrientViewIOS extends StatefulWidget {
  /// Path to the document file.
  final String? documentPath;

  /// Document content as bytes.
  final Uint8List? documentBytes;

  /// Called when the view has been created and is ready to use.
  final void Function(NutrientViewHandle handle)? onViewCreated;

  const NutrientViewIOS({
    super.key,
    this.documentPath,
    this.documentBytes,
    this.onViewCreated,
  }) : assert(
         documentPath != null || documentBytes != null,
         'Either documentPath or documentBytes must be provided',
       );

  @override
  State<NutrientViewIOS> createState() => _NutrientViewIOSState();
}

class _NutrientViewIOSState extends State<NutrientViewIOS> {
  PSPDFDocument? _document;
  PSPDFViewController? _viewController;
  PSPDFConfiguration? _configuration;
  int? _platformViewId;
  NutrientViewHandle? _viewHandle;
  late final String _resolverKey = 'ios_${identityHashCode(this)}';

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
    _document = null;
    _viewController = null;
    _configuration = null;

    _viewHandle?.dispose();
    unawaited(DocumentPathResolver.instance.release(_resolverKey));
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    _platformViewId = id;
    unawaited(_createAndAttachViewController());
  }

  Future<void> _createAndAttachViewController() async {
    try {
      debugPrint('[NutrientViewIOS] Creating view controller for document');

      // Resolve the document path
      String? resolvedPath;
      if (widget.documentPath != null) {
        resolvedPath = await DocumentPathResolver.instance.resolve(
          widget.documentPath!,
          cacheKey: _resolverKey,
        );
      } else if (widget.documentBytes != null) {
        // TODO: Handle bytes - need to save to temp file or use data provider
        throw UnimplementedError(
          'Document bytes support not yet implemented for iOS',
        );
      }

      if (resolvedPath == null) {
        debugPrint('[NutrientViewIOS] Failed to resolve document path');
        return;
      }

      // Create URL from the resolved document path
      final url = _createURL(resolvedPath);
      debugPrint('[NutrientViewIOS] Created URL: ${url.absoluteString}');

      // Create PSPDFDocument using FFI bindings
      final allocatedDoc = PSPDFDocument.alloc();
      _document = allocatedDoc.initWithURL(url);
      debugPrint('[NutrientViewIOS] Created PSPDFDocument');

      // Create PSPDFConfiguration with minimal configuration
      _configuration = _createConfiguration();
      debugPrint('[NutrientViewIOS] Created PSPDFConfiguration');

      // IMPORTANT: Create PSPDFViewController WITHOUT document first.
      // This allows the delegate to be set up BEFORE the document is loaded,
      // ensuring that pdfViewController_didChangeDocument fires when we set
      // the document. This matches the Android pattern where listeners are
      // added before the document is loaded.
      _viewController = _allocAndInitViewControllerWithoutDocument(
        _configuration!,
      );
      debugPrint('[NutrientViewIOS] Created PSPDFViewController (no document)');

      // Wrap in UINavigationController for proper toolbar and navigation support
      final navController = _wrapInNavigationController(_viewController!);
      debugPrint('[NutrientViewIOS] Wrapped in UINavigationController');

      // Attach the navigation controller to the platform view container
      if (_platformViewId != null) {
        debugPrint(
          '[NutrientViewIOS] Attaching navigation controller to platform view $_platformViewId',
        );

        final success = _attachViewControllerViaCompanion(
          _platformViewId!,
          navController,
        );

        debugPrint('[NutrientViewIOS] Attach result = $success');

        if (success) {
          // Register native instances (document will be registered after it's set)
          _registerNativeInstances();

          // Also register the navigation controller for delegate bridge access
          platform.NativeInstanceRegistry.register(
            _platformViewId!,
            'navigationController',
            navController,
          );

          // Create view handle using factory constructor
          _viewHandle = NutrientViewHandle.forPlatform(_platformViewId!);

          // Call platform adapter lifecycle hooks BEFORE setting the document.
          // This allows the adapter to set up delegates that will receive
          // the didChangeDocument callback when we set the document below.
          final adapter = platform.Nutrient.iosAdapter;
          if (adapter != null) {
            await adapter.onPlatformViewCreated(_viewHandle!);
            debugPrint('[NutrientViewIOS] Adapter notified - delegate ready');
          }

          // NOW set the document on the view controller.
          // This triggers pdfViewController_didChangeDocument callback.
          _setDocumentOnViewController(_viewController!, _document!);
          debugPrint('[NutrientViewIOS] Document set on view controller');

          // Register the document now that it's set
          platform.NativeInstanceRegistry.register(
            _platformViewId!,
            'document',
            _document!,
          );

          // Mark the controller as ready now that the document is loaded
          // The adapter IS the controller in the adapter-as-controller pattern
          if (adapter is IOSAdapter) {
            await adapter.markReady();
            debugPrint('[NutrientViewIOS] Controller marked as ready');
          }

          // Notify user
          widget.onViewCreated?.call(_viewHandle!);
        }
      }

      // Release the URL
      url.release();
      debugPrint('[NutrientViewIOS] Released resources');
    } catch (e, stackTrace) {
      debugPrint(
        '[NutrientViewIOS] Error creating view controller: $e\n$stackTrace',
      );
    }
  }

  /// Allocate and initialize a PSPDFViewController WITHOUT a document.
  /// This allows the delegate to be set up before the document is loaded,
  /// ensuring that didChangeDocument fires when we set the document later.
  PSPDFViewController _allocAndInitViewControllerWithoutDocument(
    PSPDFConfiguration configuration,
  ) {
    // Use the static alloc() method provided by FFIGen
    final allocatedVC = PSPDFViewController.alloc();

    // Call initWithDocument:configuration: with nil document
    // The document will be set later via _setDocumentOnViewController
    return allocatedVC.initWithDocument_configuration(
      null, // No document yet - will be set after delegate is attached
      configuration: configuration,
    );
  }

  /// Set the document on an existing PSPDFViewController.
  /// This triggers the pdfViewController_didChangeDocument delegate callback.
  void _setDocumentOnViewController(
    PSPDFViewController viewController,
    PSPDFDocument document,
  ) {
    // PSPDFViewController conforms to PSPDFControllerStateHandling protocol
    // which has a settable document property. We use .as() to access it.
    final stateHandler = PSPDFControllerStateHandling.as(viewController);
    stateHandler.document = document;
  }

  /// Wrap PSPDFViewController in a UINavigationController
  /// This provides the standard navigation bar and toolbar for PDF features
  UINavigationController _wrapInNavigationController(
    PSPDFViewController pdfViewController,
  ) {
    // Use the static alloc() method provided by FFIGen
    final allocatedNav = UINavigationController.alloc();

    // Call initWithRootViewController: on the allocated instance
    return allocatedNav.initWithRootViewController(pdfViewController);
  }

  /// Create PSPDFConfiguration with adapter customization support
  PSPDFConfiguration _createConfiguration() {
    // Create configuration using the builder pattern
    // This allows the adapter to customize configuration before it's built
    final adapter = platform.Nutrient.iosAdapter;

    if (adapter is IOSAdapter && _platformViewId != null) {
      // Create a temporary view handle for configuration
      final tempHandle = NutrientViewHandle.forPlatform(_platformViewId!);

      // Use configurationWithBuilder to allow adapter customization
      // The block receives PSPDFBaseConfigurationBuilder, but for PSPDFConfiguration
      // it's actually a PSPDFConfigurationBuilder, so we cast it
      final config = PSPDFConfiguration.configurationWithBuilder(
        ObjCBlock_ffiVoid_BuilderType.fromFunction((
          PSPDFBaseConfigurationBuilder baseBuilder,
        ) {
          // Cast to PSPDFConfigurationBuilder for full configuration access
          final builder = PSPDFConfigurationBuilder.as(baseBuilder);
          // Let the adapter customize the builder
          adapter.configureView(tempHandle, builder);
        }),
      );

      tempHandle.dispose();
      debugPrint(
        '[NutrientViewIOS] Configuration created with adapter customization',
      );
      return config;
    }

    // Fallback to default configuration if no adapter
    final config = PSPDFConfiguration.defaultConfiguration();
    debugPrint('[NutrientViewIOS] Default configuration created');
    return config;
  }

  void _registerNativeInstances() {
    if (_platformViewId == null || _viewController == null) return;

    debugPrint('[NutrientViewIOS] Registering native instances');

    // Register PSPDFViewController
    platform.NativeInstanceRegistry.register(
      _platformViewId!,
      'viewController',
      _viewController!,
    );

    // NOTE: Document is registered separately after it's set on the view controller
    // (in _createAndAttachViewController) to ensure proper delegate callback timing.

    // Register PSPDFConfiguration
    if (_configuration != null) {
      platform.NativeInstanceRegistry.register(
        _platformViewId!,
        'configuration',
        _configuration!,
      );
    }

    debugPrint('[NutrientViewIOS] Native instances registered');
  }

  /// Attach the view controller using the native companion method
  bool _attachViewControllerViaCompanion(
    int viewId,
    UINavigationController controller,
  ) {
    try {
      final controllerPointer = controller.ref.pointer.cast<ffi.Void>();

      // Call into the native companion helper exposed via FFI bindings
      return nutrient_attach_view_controller(viewId, controllerPointer);
    } catch (e, stackTrace) {
      debugPrint(
        '[NutrientViewIOS] Error calling companion method: $e\n$stackTrace',
      );
      return false;
    }
  }

  objc.NSURL _createURL(String path) {
    final uri = Uri.tryParse(path);

    if (uri != null && uri.hasScheme && uri.scheme.isNotEmpty) {
      if (uri.scheme == 'file') {
        final nsString = objc.NSString(uri.toFilePath());
        return objc.NSURL.fileURLWithPath(nsString);
      }

      final nsString = objc.NSString(path);
      final url = objc.NSURL.URLWithString(nsString);
      if (url != null) {
        return url;
      }
      return objc.NSURL.fileURLWithPath(nsString);
    }

    final nsString = objc.NSString(path);
    return objc.NSURL.fileURLWithPath(nsString);
  }

  @override
  Widget build(BuildContext context) {
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
