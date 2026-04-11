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

import 'android_configuration_builder.dart';
import 'android_platform_adapter.dart';
import 'bindings/nutrient_android_sdk_bindings.dart' hide Nutrient;

/// Android-specific implementation of a Nutrient Instant document view.
///
/// This widget creates an [InstantPdfUiFragment] (which includes the full
/// PSPDFKit toolbar UI) via [InstantPdfUiFragmentBuilder], enabling real-time
/// collaboration and server-backed document viewing.
class NutrientInstantViewAndroid extends StatefulWidget {
  /// The Instant document server URL.
  final String serverUrl;

  /// The JWT token used to authenticate with the Instant document server.
  final String jwt;

  /// Optional viewer configuration applied via [AndroidConfigurationBuilder].
  final NutrientViewConfiguration? configuration;

  /// Called when the view has been created and is ready to use.
  final void Function(NutrientViewHandle handle)? onViewCreated;

  const NutrientInstantViewAndroid({
    super.key,
    required this.serverUrl,
    required this.jwt,
    this.configuration,
    this.onViewCreated,
  });

  @override
  State<NutrientInstantViewAndroid> createState() =>
      _NutrientInstantViewAndroidState();
}

class _NutrientInstantViewAndroidState
    extends State<NutrientInstantViewAndroid> {
  InstantPdfUiFragment? _fragment;
  int? _platformViewId;
  NutrientViewHandle? _viewHandle;
  MethodChannel? _fragmentChannel;

  // JNI listeners for cleanup
  JObject? _documentListener;
  JObject? _annotationListener;

  @override
  void dispose() {
    final adapter = platform.Nutrient.androidAdapter;
    if (adapter != null && _viewHandle != null) {
      unawaited(adapter.dispose());
      if (adapter is AndroidAdapter) {
        unawaited(adapter.onFragmentDetached());
      }
    }

    _documentListener?.release();
    _annotationListener?.release();
    _viewHandle?.dispose();
    _fragment?.release();
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    _platformViewId = id;
    unawaited(_createAndAttachFragment());
  }

  Future<void> _createAndAttachFragment() async {
    try {
      debugPrint('[NutrientInstantViewAndroid] Creating InstantPdfUiFragment');

      final activityRef = Jni.getCurrentActivity();
      final context = Context.fromReference(activityRef);

      // Build InstantPdfUiFragment using the builder companion
      var builder = InstantPdfUiFragmentBuilder.Companion.fromInstantDocument(
        context,
        widget.serverUrl.toJString(),
        widget.jwt.toJString(),
      );

      // Apply NutrientViewConfiguration if provided
      final config = widget.configuration;
      if (config != null) {
        final nativeConfig =
            AndroidConfigurationBuilder().build(config, context);
        if (nativeConfig != null) {
          builder = builder.configuration(nativeConfig);
          nativeConfig.release();
        }
      }

      _fragment = builder.build();
      builder.release();
      debugPrint('[NutrientInstantViewAndroid] Created InstantPdfUiFragment');

      if (_platformViewId != null) {
        debugPrint(
            '[NutrientInstantViewAndroid] Attaching fragment to view $_platformViewId');

        final companion = FragmentContainerPlatformView.Companion;
        final success = companion.attachFragment(_platformViewId!, _fragment!);
        debugPrint('[NutrientInstantViewAndroid] Attach result = $success');

        if (success) {
          _registerNativeInstances();

          _viewHandle = NutrientViewHandle.forPlatform(_platformViewId!);

          final adapter = platform.Nutrient.androidAdapter;
          if (adapter != null) {
            await adapter.onPlatformViewCreated(_viewHandle!);

            if (adapter is AndroidAdapter) {
              _setupDocumentLoadedListener(adapter);
            }
          }

          widget.onViewCreated?.call(_viewHandle!);
        }

        companion.release();
      }
    } catch (e, stackTrace) {
      debugPrint(
          '[NutrientInstantViewAndroid] Error creating fragment: $e\n$stackTrace');
    }
  }

  void _registerNativeInstances() {
    if (_platformViewId == null || _fragment == null) return;

    debugPrint('[NutrientInstantViewAndroid] Registering native instances');

    platform.NativeInstanceRegistry.register(
      _platformViewId!,
      'pdfUiFragment',
      _fragment!,
    );

    final activity = Jni.getCurrentActivity();
    if (!activity.isNull) {
      platform.NativeInstanceRegistry.register(
        _platformViewId!,
        'pdfActivity',
        activity,
      );
    }

    debugPrint('[NutrientInstantViewAndroid] Native instances registered');
  }

  void _setupDocumentLoadedListener(AndroidAdapter adapter) {
    if (_platformViewId == null || _fragment == null) return;

    _fragmentChannel =
        MethodChannel('com.nutrient.fragment_container.$_platformViewId');
    _fragmentChannel!.setMethodCallHandler((call) async {
      if (call.method == 'onPdfFragmentReady') {
        _checkAndNotifyDocumentLoaded(adapter);
      }
    });

    // Fallback poll
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _checkAndNotifyDocumentLoaded(adapter);
    });
  }

  bool _documentLoadNotified = false;

  Future<void> _checkAndNotifyDocumentLoaded(
    AndroidAdapter adapter, {
    int retryCount = 0,
    int maxRetries = 10,
    Duration retryDelay = const Duration(milliseconds: 200),
  }) async {
    if (!mounted || _platformViewId == null || _documentLoadNotified) return;

    debugPrint(
        '[NutrientInstantViewAndroid] Checking document (attempt ${retryCount + 1}/$maxRetries)...');

    try {
      final companion = FragmentContainerPlatformView.Companion;
      final pdfFragment = companion.getPdfFragment(_platformViewId!);

      if (pdfFragment != null) {
        debugPrint('[NutrientInstantViewAndroid] PdfFragment ready');
        _documentLoadNotified = true;

        platform.NativeInstanceRegistry.register(
          _platformViewId!,
          'pdfFragment',
          pdfFragment,
        );

        await adapter.onPdfFragmentReady(pdfFragment);
        await adapter.markReady();

        companion.release();
        return;
      }

      companion.release();

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
            '[NutrientInstantViewAndroid] Max retries reached, document not loaded');
      }
    } catch (e, stackTrace) {
      debugPrint(
          '[NutrientInstantViewAndroid] Error checking document: $e\n$stackTrace');
    }
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
