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

  /// Optional viewer configuration applied via [AndroidConfigurationBuilder].
  ///
  /// When provided, the typed configuration is translated to a native
  /// `PdfActivityConfiguration` and applied on the underlying
  /// `PdfUiFragmentBuilder` before the adapter's `configureFragment` hook
  /// runs — so adapter customizations win over this configuration.
  final NutrientViewConfiguration? configuration;

  /// Called when the view has been created and is ready to use.
  final void Function(NutrientViewHandle handle)? onViewCreated;

  /// Optional per-view adapter override.
  ///
  /// When supplied, this view dispatches lifecycle hooks
  /// (`configureFragment`, `onPlatformViewCreated`, `onFragmentAttached`,
  /// `onPdfFragmentReady`, `onDocumentLoaded`) to this adapter instead of
  /// the global `Nutrient.androidAdapter`. Forwarded from
  /// [NutrientDocumentView.adapter] so a single screen can hold multiple
  /// `NutrientDocumentView`s with independent controllers.
  ///
  /// Ownership of the adapter remains with the caller — this view will
  /// call `detachView()` when disposed but never `dispose()` on the
  /// adapter itself. Falls back to `Nutrient.androidAdapter` when null.
  final NutrientPlatformAdapter? adapter;

  const NutrientViewAndroid({
    super.key,
    this.documentPath,
    this.documentBytes,
    this.configuration,
    this.onViewCreated,
    this.adapter,
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

  /// Resolves the adapter to drive lifecycle hooks against.
  ///
  /// Prefers the per-view [NutrientViewAndroid.adapter] when supplied so
  /// two `NutrientDocumentView`s on the same screen can use independent
  /// controllers. Falls back to the platform-singleton from
  /// `platform.Nutrient.androidAdapter` for callers that don't pass an
  /// explicit adapter (the historical default).
  NutrientPlatformAdapter? get _resolvedAdapter =>
      // Back-compat bridge: NutrientDocumentView now resolves the controller and
      // passes it as `adapter`, so this falls back to the deprecated global slot
      // only for direct NutrientViewAndroid use.
      // ignore: deprecated_member_use
      widget.adapter ?? platform.Nutrient.androidAdapter;

  @override
  void dispose() {
    // Call the per-view detach hook on the adapter — NOT dispose() — because
    // the adapter may be registered globally via Nutrient.initialize and
    // must remain usable for subsequent NutrientView mounts. Per-view
    // adapters are owned by the caller, who is responsible for disposal.
    final adapter = _resolvedAdapter;
    if (adapter is AndroidAdapter && _viewHandle != null) {
      unawaited(adapter.detachView());
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

      // Get the application context. As of jni 1.0 the Android context/activity
      // accessors live in package:jni_flutter.
      final context = androidApplicationContext;
      debugPrint('[NutrientViewAndroid] Got context reference');

      // Resolve the document path
      String? resolvedPath;

      if (widget.documentPath != null) {
        resolvedPath = await DocumentPathResolver.instance.resolve(
          widget.documentPath!,
          cacheKey: _resolverKey,
        );
      } else if (widget.documentBytes != null) {
        // The Android loader takes a file URI, so persist the bytes to a temp
        // file and load that. Cached + cleaned up under the view's resolver
        // key, like a resolved asset.
        resolvedPath = await DocumentPathResolver.instance.resolveBytes(
          widget.documentBytes!,
          cacheKey: _resolverKey,
        );
      }

      if (resolvedPath == null) {
        debugPrint('[NutrientViewAndroid] Failed to resolve document path');
        return;
      }

      // Create URI from the resolved document path

      final uri = _createUri(resolvedPath);
      debugPrint('[NutrientViewAndroid] Created URI');

      // Cast context to Context type (jni 1.0 uses `.as`).
      final contextTyped = context.as(Context.type);

      // Native handles created for the builder; released in the cleanup block
      // below, after the fragment has been built and attached (matching the
      // original URI-array lifetime).
      JArray<Uri?>? uriArray;
      DocumentDescriptor? imageDescriptor;
      JArray<DocumentDescriptor?>? imageDescriptors;

      // Create the fragment builder. Image documents (JPG/PNG/TIFF/…) open as a
      // single annotatable image page via a DocumentDescriptor; everything else
      // loads as a PDF. Detection is by the original path's extension so the
      // same widget transparently handles both.
      if (isImageDocumentPath(widget.documentPath)) {
        imageDescriptor = DocumentDescriptor.imageDocumentFromUri(uri);
        imageDescriptors = JArray.withLength(DocumentDescriptor.type, 1);
        imageDescriptors[0] = imageDescriptor;
        _builder = PdfUiFragmentBuilder.fromDocumentDescriptor(
          contextTyped,
          imageDescriptors,
        );
        debugPrint('[NutrientViewAndroid] Built image-document fragment');
      } else {
        // Create array of URIs (must use nullableType when creating JArray with length)
        uriArray = JArray.withLength(Uri.type, 1);
        uriArray[0] = uri;
        _builder = PdfUiFragmentBuilder.fromUri(contextTyped, uriArray);
      }

      // Pass password to the fragment builder when the configuration supplies
      // one. PdfUiFragmentBuilder.passwords() accepts an array of candidate
      // passwords (one per document for multi-document configs); for a single
      // document we pass a one-element array. Image documents are not
      // encrypted, so the password is only applied for PDF paths.
      final password = widget.configuration?.password;
      if (!isImageDocumentPath(widget.documentPath) &&
          password != null &&
          password.isNotEmpty) {
        final pwArray = JArray.withLength(JString.type, 1);
        // Hold the JString in a local so it can be released — assigning the
        // result of toJString() directly into the array leaks its JNI
        // reference (the array stores its own reference to the element).
        final pwJString = password.toJString();
        pwArray[0] = pwJString;
        final builderWithPw = _builder!.passwords$1(pwArray);
        _builder!.release();
        _builder = builderWithPw;
        pwJString.release();
        pwArray.release();
        debugPrint(
            '[NutrientViewAndroid] Password applied to fragment builder');
      }

      // Apply minimal configuration
      _applyConfiguration(_builder!);

      // Apply typed NutrientViewConfiguration if provided. Translated to a
      // native PdfActivityConfiguration and passed through
      // PdfUiFragmentBuilder.configuration(). The adapter's configureFragment
      // hook runs after this, so adapter customizations override these values.
      final typedConfig = widget.configuration;
      if (typedConfig != null) {
        final nativeConfig =
            AndroidConfigurationBuilder().build(typedConfig, contextTyped);
        if (nativeConfig != null) {
          _builder = _builder!.configuration$1(nativeConfig);
          nativeConfig.release();
        }
      }

      // Call adapter's configureFragment before building
      final adapter = _resolvedAdapter;
      if (adapter is AndroidAdapter) {
        // Create a temporary view handle for configuration
        // We use a placeholder ID since the platform view isn't fully ready yet
        final tempHandle = NutrientViewHandle.forPlatform(_platformViewId ?? 0);
        await adapter.configureFragment(tempHandle, _builder!, contextTyped);
        tempHandle.dispose();
      }

      // Register the custom PdfUiFragment subclass so the cross-platform
      // `setMainToolbarItems` can inject custom items into the main toolbar.
      // The subclass behaves exactly like PdfUiFragment when no items are set,
      // so it is safe to register unconditionally. jnigen can't subclass Java,
      // so the class lives in the plugin's Kotlin and is resolved by name.
      // jni 1.0's fragmentClass(...) takes the SDK's java.lang.Class binding,
      // so re-view the looked-up JClass as it (releasing the JClass handle).
      final fragmentClass = JClass.forName(
              'com/nutrient/nutrient_flutter_android/NutrientPdfUiFragment')
          .as(Class.type, releaseOriginal: true);
      final builderWithClass = _builder!.fragmentClass(fragmentClass);
      _builder!.release();
      _builder = builderWithClass;
      fragmentClass.release();

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
          final adapter = _resolvedAdapter;

          if (adapter != null) {
            // Attach the handle to the adapter-as-controller before any
            // lifecycle hook runs — NutrientDocumentAndroid/managers read
            // adapter.viewHandle to resolve the native PdfFragment/Document.
            if (adapter is AndroidAdapter) {
              adapter.attachViewHandle(_viewHandle!);
            }
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
          await _maybeApplyShowStylusButton();

          // Notify user
          widget.onViewCreated?.call(_viewHandle!);
        }
        companion.release();
      }

      // Release temporary resources
      uriArray?.release();
      imageDescriptors?.release();
      imageDescriptor?.release();
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

    // Register PdfActivity (if available). androidActivity is engine-scoped and
    // may be null; it must be used synchronously without an intervening await.
    final engineId = WidgetsBinding.instance.platformDispatcher.engineId;
    final activity = engineId != null ? androidActivity(engineId) : null;

    if (activity != null) {
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
      switch (call.method) {
        case 'onPdfFragmentReady':
          debugPrint(
              '[NutrientViewAndroid] Received PdfFragment ready callback from native!');
          _checkAndNotifyDocumentLoaded(adapter);
          break;
        case 'onInstantAiAssistantReady':
          // Standalone AI assistant shares the same notification method name
          // as the Instant path (both call notifyAiAssistantReady).
          debugPrint(
              '[NutrientViewAndroid] AI Assistant ready for view $_platformViewId');
          break;
        case 'onInstantAiAssistantFailed':
          final args = call.arguments is Map ? (call.arguments as Map) : null;
          final code = args?['errorCode'] ?? 'unknown';
          debugPrint('[NutrientViewAndroid] AI Assistant setup failed: $code');
          break;
        case 'onMainToolbarItemTapped':
          // A custom main-toolbar button was tapped natively; dispatch to the
          // matching ToolbarItem.onPressed held by the adapter-as-controller.
          final args = call.arguments is Map ? (call.arguments as Map) : null;
          final id = args?['id'] as String?;
          if (id != null) {
            adapter.handleMainToolbarItemTapped(id);
          }
          break;
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

  /// Applies the stylus button visibility, if configured.
  ///
  /// Not a `PdfActivityConfiguration` builder property —
  /// `AnnotationToolbar.setShouldShowStylusButton()` is only reachable on the
  /// live fragment, so this goes through the fragment-container channel the same
  /// way the toolbar item customization commands do.
  ///
  /// Guards its own invoke: a throw here (e.g. a `MissingPluginException` when
  /// the container's channel was never registered) must not abort the rest of
  /// view creation, which still has to fire `onViewCreated` and release its JNI
  /// references.
  Future<void> _maybeApplyShowStylusButton() async {
    final viewId = _platformViewId;
    final showStylusButton =
        widget.configuration?.androidConfig?.showStylusButton;
    if (viewId == null || showStylusButton == null) return;

    try {
      final channel = MethodChannel('com.nutrient.fragment_container.$viewId');
      await channel.invokeMethod<bool>(
        'setShowStylusButton',
        {'show': showStylusButton},
      );
    } catch (e) {
      debugPrint(
          '[NutrientViewAndroid] Error applying stylus button visibility: $e');
    }
  }

  /// Invokes the native `setupStandaloneAiAssistant` method channel handler if
  /// [NutrientViewAndroid.configuration.aiAssistantConfiguration] is non-null.
  ///
  /// Called after `markReady()` so the PdfFragment's document is guaranteed to
  /// be registered in the view handle before the Kotlin side accesses it.
  Future<void> _maybeSetupStandaloneAiAssistant() async {
    final viewId = _platformViewId;
    final config = widget.configuration?.aiAssistantConfiguration;
    if (viewId == null || config == null) return;

    final aiServerUrl = config['serverUrl'];
    final aiJwt = config['jwt'];
    // sessionId is optional: default to 'flutter-session-<viewId>'
    final sessionId = config['sessionId'] ?? 'flutter-session-$viewId';

    if (aiServerUrl == null || aiJwt == null) {
      debugPrint(
          '[NutrientViewAndroid] Standalone AI Assistant config missing serverUrl or jwt');
      return;
    }

    try {
      final channel = MethodChannel('com.nutrient.fragment_container.$viewId');
      await channel.invokeMethod<bool>('setupStandaloneAiAssistant', {
        'aiServerUrl': aiServerUrl,
        'aiJwt': aiJwt,
        'sessionId': sessionId,
      });
      debugPrint(
          '[NutrientViewAndroid] setupStandaloneAiAssistant invoked for view $viewId');
    } catch (e) {
      // Log only the runtime type — the args contain JWT material.
      debugPrint(
          '[NutrientViewAndroid] Error setting up standalone AI Assistant: ${e.runtimeType}');
    }
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

        // Register the PdfDocument too — the adapter's NutrientDocumentInterface
        // (and its managers) accesses it via `nativePdfDocument` / the
        // `pdfDocument` key. Without this, calls like
        // `document.annotations.getAnnotationsJson(...)` throw
        // "pdfDocument not registered in handle".
        final pdfDocument = pdfFragment.document;
        if (pdfDocument != null) {
          platform.NativeInstanceRegistry.register(
            _platformViewId!,
            'pdfDocument',
            pdfDocument,
          );
        }

        // Notify adapter - the adapter will set up its own document listener
        // to receive the document when it's loaded
        await adapter.onPdfFragmentReady(pdfFragment);

        // The document may not be loaded yet when onPdfFragmentReady fires —
        // image documents in particular convert to PDF asynchronously, so
        // getDocument() returns null for a few hundred ms. Wait for it before
        // marking the controller ready, otherwise `controller.document.*`
        // calls made from `onControllerReady` race the registration and throw
        // "pdfDocument not registered in handle". The wait is bounded (~5 s);
        // on timeout we mark ready anyway so the controller surface (page
        // navigation etc.) stays usable.
        if (pdfDocument == null) {
          await _waitForDocumentAndRegister(pdfFragment);
        }

        // Mark the controller as ready now that the fragment is available
        // The adapter IS the controller in the adapter-as-controller pattern
        await adapter.markReady();
        debugPrint('[NutrientViewAndroid] Controller marked as ready');

        // Standalone AI Assistant: kick off setup after the document is
        // registered so the native side can access fragment.document.
        await _maybeSetupStandaloneAiAssistant();

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

  /// Polls [fragment.getDocument] and registers the document in the view
  /// handle once it becomes available.
  ///
  /// Called when `onPdfFragmentReady` fires before the document has
  /// finished loading (image documents in particular convert to PDF
  /// asynchronously). Polls for up to ~5 seconds (25 × 200 ms); the returned
  /// future completes once the document is registered or the retries are
  /// exhausted, so callers can defer `markReady()` until the document is
  /// actually usable.
  Future<void> _waitForDocumentAndRegister(
    PdfFragment fragment, {
    int maxRetries = 25,
    Duration retryDelay = const Duration(milliseconds: 200),
  }) async {
    for (var attempt = 0; attempt < maxRetries; attempt++) {
      if (!mounted || _platformViewId == null) return;
      final doc = fragment.document;
      if (doc != null) {
        platform.NativeInstanceRegistry.register(
          _platformViewId!,
          'pdfDocument',
          doc,
        );
        debugPrint(
            '[NutrientViewAndroid] pdfDocument registered after async load');
        return;
      }
      await Future<void>.delayed(retryDelay);
    }
    debugPrint('[NutrientViewAndroid] pdfDocument still not available after '
        '$maxRetries retries; manager calls will fail until the adapter '
        'registers it manually.');
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
