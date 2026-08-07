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
import 'package:jni_flutter/jni_flutter.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    hide NativeInstanceRegistry;
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    as platform show NativeInstanceRegistry, Nutrient;

import 'android_configuration_builder.dart';
import 'android_instant_controller.dart';
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

  /// Called once the Instant controller is ready for use — after the
  /// document has loaded and [NutrientController.markReady] has been called
  /// (the same readiness point as [onViewCreated], fired once the fragment's
  /// document is available).
  ///
  /// The controller is [adapter] when it already implements
  /// [NutrientInstantController]; otherwise a default [AndroidInstantController]
  /// is created and attached to this view so `setDelayForSyncingLocalChanges`
  /// / `setListenToServerChanges` / `syncAnnotations` resolve against the
  /// live Instant document.
  final void Function(NutrientInstantController controller)? onControllerReady;

  /// Optional per-view adapter. When supplied, this view dispatches its
  /// lifecycle hooks and typed Instant events to this adapter instead of the
  /// (deprecated) global `Nutrient.androidAdapter`. Ownership stays with the
  /// caller — the view calls `detachView()` on teardown, never `dispose()`.
  final NutrientPlatformAdapter? adapter;

  const NutrientInstantViewAndroid({
    super.key,
    required this.serverUrl,
    required this.jwt,
    this.configuration,
    this.onViewCreated,
    this.onControllerReady,
    this.adapter,
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

  /// A default [AndroidInstantController] built by this view for
  /// [NutrientInstantViewAndroid.onControllerReady] when [_resolvedAdapter]
  /// doesn't already implement [NutrientInstantController].
  ///
  /// Owned by this view — attached in [_createAndAttachFragment]'s markReady
  /// path ([_resolveInstantController]) and disposed in [dispose] alongside
  /// the resolved adapter. `null` when the resolved adapter already
  /// implements [NutrientInstantController] (that adapter is used directly
  /// instead).
  AndroidInstantController? _defaultInstantController;

  /// Resolves the adapter that drives this Instant view's lifecycle + typed
  /// events: the per-view [NutrientInstantViewAndroid.adapter] when supplied,
  /// otherwise the (deprecated) global slot as a back-compat fallback.
  NutrientPlatformAdapter? get _resolvedAdapter =>
      // ignore: deprecated_member_use
      widget.adapter ?? platform.Nutrient.androidAdapter;

  @override
  void dispose() {
    unawaited(_teardownAiAssistant());

    // Per-view cleanup — detachView (NOT dispose), so a caller-owned adapter or
    // the shared global slot stays usable for the next mount (matches iOS).
    final adapter = _resolvedAdapter;
    if (adapter is AndroidAdapter && _viewHandle != null) {
      unawaited(adapter.detachView());
    }

    // The default instant controller (built only when `adapter` doesn't
    // already implement NutrientInstantController) is owned by this view,
    // not the caller — dispose() it directly rather than detachView(), since
    // nothing else can reach it to reuse it across mounts.
    final defaultController = _defaultInstantController;
    if (defaultController != null) {
      _defaultInstantController = null;
      unawaited(defaultController.dispose());
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

      // As of jni 1.0 the Android context accessor lives in package:jni_flutter.
      final context = androidApplicationContext.as(Context.type);

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

          await _maybeSetupAiAssistant();

          final adapter = _resolvedAdapter;
          // attachViewHandle must be called BEFORE onPlatformViewCreated so
          // adapter.internalViewHandle (and everything built on it — the
          // document, the Instant sync methods) is non-null inside
          // onFragmentReady/onControllerReady and all downstream managers.
          if (adapter is AndroidAdapter) {
            adapter.attachViewHandle(_viewHandle!);
          }
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

    final engineId = WidgetsBinding.instance.platformDispatcher.engineId;
    final activity = engineId != null ? androidActivity(engineId) : null;
    if (activity != null) {
      platform.NativeInstanceRegistry.register(
        _platformViewId!,
        'pdfActivity',
        activity,
      );
    }

    debugPrint('[NutrientInstantViewAndroid] Native instances registered');
  }

  /// Asks the native side to build an AI Assistant for the Instant document
  /// hosted in this view. The Kotlin handler hooks into the fragment's
  /// document-load lifecycle and writes the assistant into the static slot
  /// that [FlutterAppCompatActivity.getAiAssistant] resolves.
  Future<void> _maybeSetupAiAssistant() async {
    final viewId = _platformViewId;
    final config = widget.configuration?.aiAssistantConfiguration;
    if (viewId == null || config == null) return;
    final aiServerUrl = config['serverUrl'];
    final aiJwt = config['jwt'];
    final sessionId = config['sessionId'];
    if (aiServerUrl == null || aiJwt == null || sessionId == null) {
      debugPrint(
          '[NutrientInstantViewAndroid] AI Assistant config missing serverUrl/jwt/sessionId');
      return;
    }
    try {
      final channel = MethodChannel('com.nutrient.fragment_container.$viewId');
      await channel.invokeMethod<bool>('setupInstantAiAssistant', {
        'instantServerUrl': widget.serverUrl,
        'instantJwt': widget.jwt,
        'aiServerUrl': aiServerUrl,
        'aiJwt': aiJwt,
        'sessionId': sessionId,
      });
    } catch (e) {
      // Log only the runtime type, never the args. The args contain JWT
      // material that could grant read/write on the Instant document.
      debugPrint(
          '[NutrientInstantViewAndroid] Error setting up AI Assistant: ${e.runtimeType}');
    }
  }

  Future<void> _teardownAiAssistant() async {
    final viewId = _platformViewId;
    if (viewId == null) return;
    if (widget.configuration?.aiAssistantConfiguration == null) return;
    try {
      final channel = MethodChannel('com.nutrient.fragment_container.$viewId');
      await channel.invokeMethod<bool>('teardownInstantAiAssistant');
    } catch (e) {
      // See _maybeSetupAiAssistant: don't echo the exception body.
      debugPrint(
          '[NutrientInstantViewAndroid] Error tearing down AI Assistant: ${e.runtimeType}');
    }
  }

  void _setupDocumentLoadedListener(AndroidAdapter adapter) {
    if (_platformViewId == null || _fragment == null) return;

    _fragmentChannel =
        MethodChannel('com.nutrient.fragment_container.$_platformViewId');
    _fragmentChannel!.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPdfFragmentReady':
          _checkAndNotifyDocumentLoaded(adapter);
          break;
        case 'onInstantAiAssistantReady':
          debugPrint(
              '[NutrientInstantViewAndroid] AI Assistant ready for view $_platformViewId');
          break;
        case 'onInstantAiAssistantFailed':
          // Native side surfaces a `errorCode` string (exception class
          // name). The Dart-side handler stays minimal — apps can listen on
          // this channel for richer UI behaviour.
          final args = call.arguments is Map ? (call.arguments as Map) : null;
          final code = args?['errorCode'] ?? 'unknown';
          debugPrint(
              '[NutrientInstantViewAndroid] AI Assistant setup failed: $code');
          break;
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

        // Register the PdfDocument too — NutrientDocumentAndroid.requireDocument
        // and AndroidInstantController._requireInstantDocument both resolve it
        // via the 'pdfDocument' key on the view handle. Without this, document
        // and Instant-sync calls made from onControllerReady throw
        // "pdfDocument not registered in handle".
        final pdfDocument = pdfFragment.document;
        if (pdfDocument != null) {
          platform.NativeInstanceRegistry.register(
            _platformViewId!,
            'pdfDocument',
            pdfDocument,
          );
        }

        await adapter.onPdfFragmentReady(pdfFragment);
        await adapter.markReady();

        // Resolve and notify the typed Instant controller — after markReady,
        // mirroring NutrientInstantViewIOS's timing (fires once markReady()
        // succeeds so the view handle and document are already registered).
        final instantController = await _resolveInstantController(adapter);
        if (instantController != null) {
          widget.onControllerReady?.call(instantController);
        }

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

  /// Resolves the [NutrientInstantController] to hand to
  /// [NutrientInstantViewAndroid.onControllerReady], or `null` when this view
  /// has already been unmounted.
  ///
  /// - If [adapter] already implements [NutrientInstantController] (either the
  ///   caller passed an instant-aware adapter, or a custom subclass), it's
  ///   used directly — it already went through the full lifecycle
  ///   ([AndroidAdapter.attachViewHandle], `onPlatformViewCreated`,
  ///   `onPdfFragmentReady`, `markReady`) in [_createAndAttachFragment] /
  ///   [_checkAndNotifyDocumentLoaded], so no extra wiring is needed.
  /// - Otherwise, a fresh [AndroidInstantController] is built and attached to
  ///   the same [_viewHandle] so its native calls resolve to the live Instant
  ///   document. It intentionally skips `onPlatformViewCreated` /
  ///   `onFragmentAttached` — those set up native listeners exactly once per
  ///   view; [adapter] (or the default Android viewer, when [adapter] is
  ///   null) already owns that. The default controller only needs
  ///   [AndroidAdapter.attachViewHandle] + [NutrientController.markReady] for
  ///   the registered `pdfDocument` (and hence the three Instant sync
  ///   methods) to resolve.
  ///
  /// Limitation of the fallback: because the fresh default controller skips the
  /// per-view listener setup, its `events` stream never emits document or
  /// annotation events — it surfaces the three sync methods only. This path is
  /// reached only when [NutrientInstantViewAndroid] is used directly with a
  /// non-Instant adapter (or the deprecated global slot); the public
  /// [NutrientInstantView] composition always supplies a
  /// [NutrientInstantController] adapter, which took the branch above and has a
  /// fully wired event stream. Callers on the direct path who need Instant
  /// events should pass an adapter that implements [NutrientInstantController].
  Future<NutrientInstantController?> _resolveInstantController(
    NutrientPlatformAdapter? adapter,
  ) async {
    if (adapter is NutrientInstantController) {
      return adapter as NutrientInstantController;
    }

    final viewHandle = _viewHandle;
    if (!mounted || viewHandle == null) return null;

    final controller = _defaultInstantController ??= AndroidInstantController();
    controller.attachViewHandle(viewHandle);
    await controller.markReady();
    return controller;
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
