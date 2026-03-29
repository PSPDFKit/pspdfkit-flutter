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
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:jni/jni.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    hide NativeInstanceRegistry;
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    as platform show NativeInstanceRegistry, Nutrient;

import 'android_platform_adapter.dart';
import 'bindings/nutrient_android_sdk_bindings.dart' hide Nutrient;

/// Android-specific implementation of [NutrientView].
///
/// This class provides the minimal document display functionality using JNI bindings.
/// All advanced features and configuration (navigation, annotations, forms, toolbar, etc.)
/// are provided through the Android platform adapter.
class NutrientViewAndroid extends StatefulWidget {
  /// Path to the document file.
  final String? documentPath;

  /// Document content as bytes.
  final Uint8List? documentBytes;

  /// Called when the view has been created and is ready to use.
  final void Function(NutrientViewHandle handle)? onViewCreated;

  const NutrientViewAndroid({
    super.key,
    this.documentPath,
    this.documentBytes,
    this.onViewCreated,
  }) : assert(
          documentPath != null || documentBytes != null,
          'Either documentPath or documentBytes must be provided',
        );

  @override
  State<NutrientViewAndroid> createState() => _NutrientViewAndroidState();
}

class _NutrientViewAndroidState extends State<NutrientViewAndroid> {
  PdfUiFragment? _fragment;
  PdfUiFragmentBuilder? _builder;
  int? _platformViewId;
  NutrientViewHandle? _viewHandle;
  late final String _resolverKey = 'android_${identityHashCode(this)}';
  MethodChannel? _fragmentChannel;

  // JNI listeners for cleanup
  JObject? _documentListener;
  JObject? _annotationListener;

  @override
  void dispose() {
    // Call adapter lifecycle hooks before cleanup
    final adapter = platform.Nutrient.androidAdapter;

    if (adapter != null && _viewHandle != null) {
      unawaited(adapter.dispose());
      // Call Android-specific cleanup
      if (adapter is AndroidAdapter) {
        unawaited(adapter.onFragmentDetached());
      }
    }

    // Release JNI listeners
    _documentListener?.release();
    _annotationListener?.release();
    _viewHandle?.dispose();
    _fragment?.release();
    _builder?.release();
    unawaited(DocumentPathResolver.instance.release(_resolverKey));
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    _platformViewId = id;
    unawaited(_createAndAttachFragment());
  }

  Future<void> _createAndAttachFragment() async {
    try {
      debugPrint('[NutrientViewAndroid] Creating fragment for document');

      // Get the application context
      final context = Jni.getCurrentActivity();
      debugPrint('[NutrientViewAndroid] Got context reference');

      // Resolve the document path
      String? resolvedPath;

      if (widget.documentPath != null) {
        resolvedPath = await DocumentPathResolver.instance.resolve(
          widget.documentPath!,
          cacheKey: _resolverKey,
        );
      } else if (widget.documentBytes != null) {
        // TODO: Handle bytes - need to save to temp file or use content provider

        throw UnimplementedError(
          'Document bytes support not yet implemented for Android',
        );
      }

      if (resolvedPath == null) {
        debugPrint('[NutrientViewAndroid] Failed to resolve document path');
        return;
      }

      // Create URI from the resolved document path

      final uri = _createUri(resolvedPath);
      debugPrint('[NutrientViewAndroid] Created URI');

      // Create array of URIs (must use nullableType when creating JArray with length)
      final uriArray = JArray(Uri.nullableType, 1);
      uriArray[0] = uri;

      // Cast context to Context type
      final contextTyped = Context.fromReference(context);

      // Create PdfUiFragmentBuilder with minimal configuration
      _builder = PdfUiFragmentBuilder.fromUri(contextTyped, uriArray);

      // Apply minimal configuration
      _applyConfiguration(_builder!);

      // Call adapter's configureFragment before building
      final adapter = platform.Nutrient.androidAdapter;
      if (adapter is AndroidAdapter) {
        // Create a temporary view handle for configuration
        // We use a placeholder ID since the platform view isn't fully ready yet
        final tempHandle = NutrientViewHandle.forPlatform(_platformViewId ?? 0);
        await adapter.configureFragment(tempHandle, _builder!, contextTyped);
        tempHandle.dispose();
      }

      // Build the fragment
      _fragment = _builder!.build();
      debugPrint('[NutrientViewAndroid] Built fragment');

      // Attach the fragment to the container
      if (_platformViewId != null) {
        debugPrint(
            '[NutrientViewAndroid] Attaching fragment to view $_platformViewId');

        final companion = FragmentContainerPlatformView.Companion;

        final success = companion.attachFragment(_platformViewId!, _fragment!);

        debugPrint('[NutrientViewAndroid] Attach result = $success');

        if (success) {
          // Register native instances
          _registerNativeInstances();

          // Create view handle using factory constructor
          _viewHandle = NutrientViewHandle.forPlatform(_platformViewId!);

          // Call platform adapter lifecycle hooks
          final adapter = platform.Nutrient.androidAdapter;

          if (adapter != null) {
            // Call base adapter lifecycle
            await adapter.onPlatformViewCreated(_viewHandle!);

            // Call Android-specific adapter methods if it's an AndroidAdapter
            if (adapter is AndroidAdapter && _fragment != null) {
              // Call onFragmentAttached with native instances
              await adapter.onFragmentAttached(_fragment!, contextTyped);
              // Set up document loaded listener
              _setupDocumentLoadedListener(adapter);
            }
          }
          // Notify user
          widget.onViewCreated?.call(_viewHandle!);
        }
        companion.release();
      }

      // Release temporary resources
      uriArray.release();
      uri.release();
      debugPrint('[NutrientViewAndroid] Released resources');
    } catch (e, stackTrace) {
      debugPrint(
          '[NutrientViewAndroid] Error creating fragment: $e\n$stackTrace');
    }
  }

  void _applyConfiguration(PdfUiFragmentBuilder builder) {
    // Configuration is now handled by the Android platform adapter
    // via the adapter lifecycle hooks (onFragmentAttached, onDocumentLoaded, etc.)
    debugPrint(
        '[NutrientViewAndroid] Fragment builder ready for adapter configuration');
  }

  void _registerNativeInstances() {
    if (_platformViewId == null || _fragment == null) return;

    debugPrint('[NutrientViewAndroid] Registering native instances');

    // Register PdfFragment
    platform.NativeInstanceRegistry.register(
      _platformViewId!,
      'pdfFragment',
      _fragment!,
    );

    // Register PdfActivity (if available)
    final activity = Jni.getCurrentActivity();

    if (!activity.isNull) {
      platform.NativeInstanceRegistry.register(
        _platformViewId!,
        'pdfActivity',
        activity,
      );
    }

    // Register PdfDocument (when fragment is ready)
    // Note: Document might not be loaded yet, adapter will receive it in onDocumentLoaded
    debugPrint('[NutrientViewAndroid] Native instances registered');
  }

  void _setupDocumentLoadedListener(AndroidAdapter adapter) {
    debugPrint('[NutrientViewAndroid] Setting up document loaded listener');

    if (_platformViewId == null || _fragment == null) return;

    // Set up MethodChannel to receive callback from native side
    _fragmentChannel =
        MethodChannel('com.nutrient.fragment_container.$_platformViewId');
    _fragmentChannel!.setMethodCallHandler((call) async {
      if (call.method == 'onPdfFragmentReady') {
        debugPrint(
            '[NutrientViewAndroid] Received PdfFragment ready callback from native!');
        _checkAndNotifyDocumentLoaded(adapter);
      }
    });

    debugPrint('[NutrientViewAndroid] MethodChannel callback registered');

    // Fallback: Poll for document if callback doesn't fire
    // This handles cases where the fragment lifecycle events may have already occurred
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        debugPrint(
            '[NutrientViewAndroid] Checking for document availability (fallback)...');
        _checkAndNotifyDocumentLoaded(adapter);
      }
    });
  }

  // Track if we've already notified the adapter about document load
  bool _documentLoadNotified = false;

  /// Check if document is loaded and notify adapter.
  /// Retries up to [maxRetries] times with [retryDelay] between attempts.
  Future<void> _checkAndNotifyDocumentLoaded(
    AndroidAdapter adapter, {
    int retryCount = 0,
    int maxRetries = 10,
    Duration retryDelay = const Duration(milliseconds: 200),
  }) async {
    if (!mounted || _platformViewId == null || _documentLoadNotified) return;

    debugPrint(
        '[NutrientViewAndroid] Checking document availability (attempt ${retryCount + 1}/$maxRetries)...');

    try {
      // Get the PdfFragment from the companion (which tracks it by view ID)
      final companion = FragmentContainerPlatformView.Companion;
      final pdfFragment = companion.getPdfFragment(_platformViewId!);

      if (pdfFragment != null) {
        debugPrint(
            '[NutrientViewAndroid] PdfFragment is ready, notifying adapter');
        _documentLoadNotified = true;

        // Register the PdfFragment so it can be accessed by the adapter
        platform.NativeInstanceRegistry.register(
          _platformViewId!,
          'pdfFragment',
          pdfFragment,
        );

        // Notify adapter - the adapter will set up its own document listener
        // to receive the document when it's loaded
        await adapter.onPdfFragmentReady(pdfFragment);

        // Mark the controller as ready now that the fragment is available
        // The adapter IS the controller in the adapter-as-controller pattern
        await adapter.markReady();
        debugPrint('[NutrientViewAndroid] Controller marked as ready');

        companion.release();
        return;
      } else {
        debugPrint('[NutrientViewAndroid] PdfFragment not yet available');
      }

      companion.release();

      // Retry if we haven't exceeded max retries
      if (retryCount < maxRetries - 1) {
        Future.delayed(retryDelay, () {
          if (mounted && !_documentLoadNotified) {
            _checkAndNotifyDocumentLoaded(
              adapter,
              retryCount: retryCount + 1,
              maxRetries: maxRetries,
              retryDelay: retryDelay,
            );
          }
        });
      } else {
        debugPrint(
            '[NutrientViewAndroid] Max retries reached, document still not loaded');
      }
    } catch (e, stackTrace) {
      debugPrint(
          '[NutrientViewAndroid] Error checking document: $e\n$stackTrace');
    }
  }

  Uri _createUri(String path) {
    if (path.startsWith('file://') ||
        path.startsWith('content://') ||
        path.startsWith('http://') ||
        path.startsWith('https://')) {
      final uri = Uri.parse(path.toJString());
      if (uri == null) {
        throw ArgumentError('Failed to parse URI: $path');
      }
      return uri;
    }

    // Treat anything else as a plain file system path
    final uri = Uri.parse('file://$path'.toJString());
    if (uri == null) {
      throw ArgumentError('Failed to parse URI: file://$path');
    }
    return uri;
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = 'nutrient_fragment_container';

    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        final controller = PlatformViewsService.initAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          onFocus: () {
            params.onFocusChanged(true);
          },
        );

        controller.addOnPlatformViewCreatedListener(_onPlatformViewCreated);
        controller.addOnPlatformViewCreatedListener(
          params.onPlatformViewCreated,
        );

        return controller..create();
      },
    );
  }
}
