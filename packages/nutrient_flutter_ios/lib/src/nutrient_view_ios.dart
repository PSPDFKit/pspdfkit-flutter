///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi_pkg;
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

// Hide `Duration` — the bindings export an ObjC `Duration` that shadows
// dart:core's, breaking `Duration(milliseconds: ...)`.
import 'bindings/nutrient_ios_bindings.dart' hide Factory, Duration;
import 'ios_configuration_builder.dart';
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

  /// Optional viewer configuration applied via [IOSConfigurationBuilder].
  ///
  /// When provided, the typed configuration is translated and applied on the
  /// underlying `PSPDFConfigurationBuilder` before the adapter's
  /// `configureView` hook runs — so adapter customizations win over this
  /// configuration.
  final NutrientViewConfiguration? configuration;

  /// Called when the view has been created and is ready to use.
  final void Function(NutrientViewHandle handle)? onViewCreated;

  /// Optional per-view adapter override.
  ///
  /// When supplied, this view dispatches lifecycle hooks
  /// (`configureView`, `onPlatformViewCreated`, `onViewControllerReady`,
  /// `onDocumentLoaded`) to this adapter instead of the global
  /// `Nutrient.iosAdapter`. Forwarded from [NutrientDocumentView.adapter]
  /// so a single screen can hold multiple `NutrientDocumentView`s with
  /// independent controllers.
  ///
  /// Ownership of the adapter remains with the caller — this view will
  /// call `detachView()` when disposed but never `dispose()` on the
  /// adapter itself. Falls back to `Nutrient.iosAdapter` when null.
  final NutrientPlatformAdapter? adapter;

  const NutrientViewIOS({
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
  State<NutrientViewIOS> createState() => _NutrientViewIOSState();
}

class _NutrientViewIOSState extends State<NutrientViewIOS> {
  PSPDFDocument? _document;

  /// The NSURL passed to [PSPDFDocument.initWithURL]. Held for the lifetime of
  /// [_document] because PSPDFKit's `PSPDFSecurityScopedURL` keeps an unsafe
  /// reference to the original URL — letting Dart GC the NSURL wrapper while
  /// the document is still alive causes a dealloc-time crash in
  /// `-[PSPDFSecurityScopedURL dealloc]` when the document later finalizes.
  // ignore: unused_field
  objc.NSURL? _documentUrl;
  PSPDFViewController? _viewController;
  PSPDFConfiguration? _configuration;
  int? _platformViewId;
  NutrientViewHandle? _viewHandle;
  late final String _resolverKey = 'ios_${identityHashCode(this)}';

  /// Resolves the adapter to drive lifecycle hooks against.
  ///
  /// Prefers the per-view [NutrientViewIOS.adapter] when supplied so two
  /// `NutrientDocumentView`s on the same screen can use independent
  /// controllers. Falls back to the platform-singleton from
  /// `platform.Nutrient.iosAdapter` for callers that don't pass an
  /// explicit adapter (the historical default).
  NutrientPlatformAdapter? get _resolvedAdapter =>
      // Back-compat bridge: NutrientDocumentView now resolves the controller and
      // passes it as `adapter`, so this falls back to the deprecated global slot
      // only for direct NutrientViewIOS use.
      // ignore: deprecated_member_use
      widget.adapter ?? platform.Nutrient.iosAdapter;

  @override
  void dispose() {
    // Call the per-view detach hook on the adapter — NOT dispose() — because
    // the adapter may be registered globally via Nutrient.initialize and
    // must remain usable for subsequent NutrientView mounts. Per-view
    // adapters are owned by the caller, who is responsible for disposal.
    final adapter = _resolvedAdapter;
    if (adapter is IOSAdapter) {
      unawaited(adapter.detachView());
    }

    // Clear native instance references from the registry BEFORE disposing view handle
    // This prevents dangling references during hot restart
    if (_platformViewId != null) {
      platform.NativeInstanceRegistry.unregister(_platformViewId!);
    }

    // Tear down the automatic file-conflict resolution observer (if any)
    // before dropping the view controller reference below — the native side
    // keys the registration off the PDFViewController pointer.
    final viewController = _viewController;
    if (viewController != null) {
      nutrient_unregister_file_conflict_resolution(
        viewController.ref.pointer.cast<ffi.Void>(),
      );
    }

    // Clear Dart-side references to native objects
    // Do NOT release them here - the platform view owns the lifecycle
    _document = null;
    // Drop the URL after the document — Dart finalization order between the
    // two wrappers isn't guaranteed, so we just keep both alive on the state
    // and let GC reclaim them together once the State is gone.
    _documentUrl = null;
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
        // PSPDFDocument loads from a file URL, so persist the bytes to a temp
        // file and load that. Cached + cleaned up under the view's resolver
        // key, like a resolved asset.
        resolvedPath = await DocumentPathResolver.instance.resolveBytes(
          widget.documentBytes!,
          cacheKey: _resolverKey,
        );
      }

      if (resolvedPath == null) {
        debugPrint('[NutrientViewIOS] Failed to resolve document path');
        return;
      }

      // Create URL from the resolved document path. Store on state so the
      // Dart NSURL wrapper outlives the PSPDFDocument — see _documentUrl
      // doc comment.
      final url = _createURL(resolvedPath);
      _documentUrl = url;
      debugPrint('[NutrientViewIOS] Created URL: ${url.absoluteString}');

      // Create the document via FFI bindings. Image documents (JPG/PNG/TIFF/…)
      // use PSPDFImageDocument so the same widget renders them as a single
      // annotatable image page; everything else loads as a PSPDFDocument.
      // Detection is by the original path's extension.
      if (isImageDocumentPath(widget.documentPath)) {
        _document = PSPDFImageDocument.alloc().initWithImageURL(url);
        debugPrint('[NutrientViewIOS] Created PSPDFImageDocument');
      } else {
        _document = PSPDFDocument.alloc().initWithURL(url);
        debugPrint('[NutrientViewIOS] Created PSPDFDocument');

        // Unlock password-protected documents before the view controller is
        // created. A wrong password is non-fatal here — the SDK will render
        // as many pages as it can decrypt (typically zero), and a clear
        // message is logged so the caller can diagnose the issue.
        final pw = widget.configuration?.password;
        if (pw != null && pw.isNotEmpty) {
          final unlocked = _document!.unlockWithPassword(pw.toNSString());
          if (!unlocked) {
            debugPrint(
              '[NutrientViewIOS] Warning: failed to unlock document with '
              'the provided password — the document may render blank.',
            );
          } else {
            debugPrint('[NutrientViewIOS] Document unlocked with password');
          }
        }
      }

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
          final adapter = _resolvedAdapter;
          if (adapter != null) {
            // Attach the handle to the adapter-as-controller before any
            // lifecycle hook runs — NutrientDocumentIOS/managers read
            // adapter.viewHandle to resolve the native viewController.
            if (adapter is IOSAdapter) {
              adapter.attachViewHandle(_viewHandle!);
            }
            await adapter.onPlatformViewCreated(_viewHandle!);
            debugPrint('[NutrientViewIOS] Adapter notified - delegate ready');
          }

          // NOW set the document on the view controller.
          // This triggers pdfViewController_didChangeDocument callback.
          _setDocumentOnViewController(_viewController!, _document!);
          debugPrint('[NutrientViewIOS] Document set on view controller');

          // Apply left/rightBarButtonItems from IOSViewConfiguration. These
          // are runtime navigationItem state, not PSPDFConfigurationBuilder
          // properties, so they can't be applied inside _createConfiguration.
          // Must run BEFORE the AI Assistant button injection below, which
          // appends to the right bar items and would be wiped by a replace.
          _applyBarButtonItems();

          // Add the AI Assistant button to the navigation bar when an AI
          // assistant configuration was provided. The button must be added
          // after the VC exists; the configuration was already applied inside
          // _createConfiguration via nutrient_apply_ai_assistant_configuration.
          if (widget.configuration?.aiAssistantConfiguration != null) {
            final vcPtr = _viewController!.ref.pointer.cast<ffi.Void>();
            nutrient_add_ai_assistant_button(vcPtr);
            debugPrint('[NutrientViewIOS] AI Assistant button injected');
          }

          // Register automatic file-conflict resolution when configured.
          // fileConflictResolution has no PSPDFConfigurationBuilder property
          // (see IOSConfigurationBuilder's doc comment) so it can't be applied
          // inside _createConfiguration's builder block — it must be wired up
          // after the PDFViewController exists.
          _registerFileConflictResolution();

          // Register the document now that it's set
          platform.NativeInstanceRegistry.register(
            _platformViewId!,
            'document',
            _document!,
          );

          // Image documents convert to PDF lazily — `pageCount` stays 0
          // until the conversion completes, so `controller.document.*` calls
          // made from `onControllerReady` would see an empty document. Wait
          // (bounded, ~5 s) for the conversion before marking ready, matching
          // the Android view's document-registration wait.
          if (isImageDocumentPath(widget.documentPath)) {
            // Capture a non-null local: dispose() nulls _document, so the
            // poll must not dereference the field across awaits. Bail out of
            // the loop when the widget unmounts mid-wait.
            final imageDocument = _document!;
            for (
              var attempt = 0;
              mounted && attempt < 25 && imageDocument.pageCount == 0;
              attempt++
            ) {
              await Future<void>.delayed(const Duration(milliseconds: 200));
            }
            debugPrint(
              '[NutrientViewIOS] Image document loaded — pageCount = ${imageDocument.pageCount}',
            );
          }

          // Mark the controller as ready now that the document is loaded
          // The adapter IS the controller in the adapter-as-controller pattern
          if (adapter is IOSAdapter) {
            await adapter.markReady();
            debugPrint('[NutrientViewIOS] Controller marked as ready');
          }

          // Notify user
          widget.onViewCreated?.call(_viewHandle!);

          // Apply the appearance (theme) mode. This is a runtime property on the
          // controller's appearanceModeManager, not a PSPDFConfiguration value,
          // so it is applied here rather than via IOSConfigurationBuilder. It
          // only takes effect once the controller's view is on screen, so wait
          // for the actual readiness signal — the view being loaded and in a
          // window — instead of a fixed delay. Bounded so a never-presented
          // view still falls through.
          final appearance = widget.configuration?.appearanceMode;
          if (appearance != null) {
            await _waitForViewOnScreen();
            if (mounted && _viewController != null) {
              _applyAppearanceMode(appearance);
            }
          }
        }
      }

      // Don't release the URL here — PSPDFKit's PSPDFSecurityScopedURL keeps
      // an unsafe reference to it for the lifetime of the PSPDFDocument.
      // Releasing here was the cause of an EXC_BAD_ACCESS in
      // -[PSPDFSecurityScopedURL dealloc] when the document later finalized.
      // The Dart NSURL wrapper is held in [_documentUrl] until dispose().
      debugPrint('[NutrientViewIOS] View controller setup complete');
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

  /// Waits until the hosted controller's view is loaded and in a window (i.e.
  /// actually on screen), polling a bounded number of frames. The appearance
  /// manager only applies once the view is presented, so this replaces a fixed
  /// delay with the real readiness signal; it returns early as soon as the view
  /// is on screen and gives up after ~1s so a never-presented view still falls
  /// through.
  Future<void> _waitForViewOnScreen() async {
    for (var attempt = 0; attempt < 20; attempt++) {
      if (!mounted) return;
      final vc = _viewController;
      if (vc != null && vc.viewIfLoaded?.window != null) return;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  /// Applies the typed [AppearanceMode] to the hosted view controller.
  ///
  /// On iOS the appearance (theme) is a runtime property of the controller's
  /// `appearanceModeManager`, not a `PSPDFConfiguration` value, so it can't be
  /// set through [IOSConfigurationBuilder] like scroll direction / page mode.
  /// Setting it applies the matching page rendering (Night inverts the page
  /// colors). This matches the legacy `PspdfPlatformView` behavior.
  ///
  /// Note: PSPDFKit applies the Night/Sepia page inversion as a layer-level
  /// effect, which the iOS Simulator screenshot tooling (`simctl` / Maestro)
  /// does not capture — verify the visual change on a device or by eye, not via
  /// captured screenshots.
  void _applyAppearanceMode(AppearanceMode? mode) {
    if (mode == null) return;
    final viewController = _viewController;
    if (viewController == null) return;
    final value = switch (mode) {
      AppearanceMode.defaultMode =>
        PSPDFAppearanceMode.PSPDFAppearanceModeDefault,
      AppearanceMode.sepia => PSPDFAppearanceMode.PSPDFAppearanceModeSepia,
      AppearanceMode.night => PSPDFAppearanceMode.PSPDFAppearanceModeNight,
      AppearanceMode.allCustomColors =>
        PSPDFAppearanceMode.PSPDFAppearanceModeAll,
    };
    viewController.appearanceModeManager.appearanceMode = value;
  }

  /// Registers automatic file-conflict resolution when
  /// `IOSViewConfiguration.fileConflictResolution` is configured to something
  /// other than [IOSFileConflictResolution.defaultBehavior].
  ///
  /// `fileConflictResolution` has no `PSPDFConfigurationBuilder` property
  /// (unlike the rest of [IOSConfigurationBuilder]'s output) — it configures a
  /// runtime notification observer on the `PDFViewController`, not a build-time
  /// configuration value — so it's applied here, after the view controller
  /// exists, via `nutrient_register_file_conflict_resolution` rather than
  /// inside `_createConfiguration`'s builder block. No-op (and leaves the
  /// SDK's default alert UI in place) when the option is unset or set to
  /// [IOSFileConflictResolution.defaultBehavior].
  void _registerFileConflictResolution() {
    final resolution = widget.configuration?.iosConfig?.fileConflictResolution;
    if (resolution == null) return;
    final rawValue = IOSConfigurationBuilder.rawFileConflictResolutionValue(
      resolution,
    );
    if (rawValue == null) return;
    final viewController = _viewController;
    if (viewController == null) return;
    nutrient_register_file_conflict_resolution(
      viewController.ref.pointer.cast<ffi.Void>(),
      rawValue,
    );
    debugPrint(
      '[NutrientViewIOS] Registered automatic file-conflict resolution '
      '(${resolution.name})',
    );
  }

  /// Applies `IOSViewConfiguration.leftBarButtonItems` /
  /// `rightBarButtonItems` to the hosted controller's navigation item.
  ///
  /// Bar button items are runtime `navigationItem` state, not
  /// `PSPDFConfigurationBuilder` properties, so — like
  /// [_registerFileConflictResolution] — they are applied after the view
  /// controller exists rather than inside [_createConfiguration]'s builder
  /// block. Mirrors the legacy `PspdfkitFlutterHelper.setLeft/RightBarButtonItems`
  /// mapping: each string identifier resolves to the controller's built-in
  /// `UIBarButtonItem`, unknown identifiers are skipped, and an item already
  /// present in the opposite bar is skipped too (the same `UIBarButtonItem`
  /// instance must never appear in both bars). Unlike the legacy helper, an
  /// explicit empty list clears the bar, as documented on
  /// `IOSViewConfiguration`; `null` leaves the SDK defaults untouched.
  void _applyBarButtonItems() {
    final iosConfig = widget.configuration?.iosConfig;
    final left = iosConfig?.leftBarButtonItems;
    final right = iosConfig?.rightBarButtonItems;
    if (left == null && right == null) return;
    final viewController = _viewController;
    if (viewController == null) return;
    final navigationItem = viewController.navigationItem;

    // Native pointer addresses of the items currently in a bar — built-in
    // button items are per-controller singletons, so identity comparison
    // matches the legacy `containsObject:` check.
    Set<int> pointerAddresses(objc.NSArray? items) => {
      if (items != null)
        for (final item in items.asDart()) item.ref.pointer.address,
    };

    List<UIBarButtonItem> resolveItems(
      List<String> identifiers,
      Set<int> oppositeBar,
    ) {
      final items = <UIBarButtonItem>[];
      for (final identifier in identifiers) {
        final item = _barButtonItemForIdentifier(identifier, viewController);
        if (item == null) {
          debugPrint(
            '[NutrientViewIOS] Unknown bar button item "$identifier" — '
            'skipped.',
          );
          continue;
        }
        if (oppositeBar.contains(item.ref.pointer.address)) continue;
        items.add(item);
      }
      return items;
    }

    if (left != null) {
      final items = resolveItems(
        left,
        pointerAddresses(navigationItem.rightBarButtonItems),
      );
      navigationItem.setLeftBarButtonItems_animated(
        objc.NSMutableArray.of(items),
        animated: false,
      );
      debugPrint(
        '[NutrientViewIOS] Applied ${items.length} left bar button item(s)',
      );
    }
    if (right != null) {
      final items = resolveItems(
        right,
        pointerAddresses(navigationItem.leftBarButtonItems),
      );
      navigationItem.setRightBarButtonItems_animated(
        objc.NSMutableArray.of(items),
        animated: false,
      );
      debugPrint(
        '[NutrientViewIOS] Applied ${items.length} right bar button item(s)',
      );
    }
  }

  /// Resolves a bar button item identifier to the controller's built-in
  /// `UIBarButtonItem`, or `null` for unknown identifiers. Identifier set
  /// mirrors the legacy `PspdfkitFlutterHelper.barButtonItem(fromString:for:)`.
  UIBarButtonItem? _barButtonItemForIdentifier(
    String identifier,
    PSPDFViewController viewController,
  ) {
    return switch (identifier) {
      'closeButtonItem' => viewController.closeButtonItem,
      'outlineButtonItem' => viewController.outlineButtonItem,
      'searchButtonItem' => viewController.searchButtonItem,
      'thumbnailsButtonItem' => viewController.thumbnailsButtonItem,
      'documentEditorButtonItem' => viewController.documentEditorButtonItem,
      'printButtonItem' => viewController.printButtonItem,
      'openInButtonItem' => viewController.openInButtonItem,
      'emailButtonItem' => viewController.emailButtonItem,
      'messageButtonItem' => viewController.messageButtonItem,
      'annotationButtonItem' => viewController.annotationButtonItem,
      'bookmarkButtonItem' => viewController.bookmarkButtonItem,
      'brightnessButtonItem' => viewController.brightnessButtonItem,
      'activityButtonItem' => viewController.activityButtonItem,
      'settingsButtonItem' => viewController.settingsButtonItem,
      'readerViewButtonItem' => viewController.readerViewButtonItem,
      _ => null,
    };
  }

  /// Wrap PSPDFViewController in a PSPDFNavigationController.
  ///
  /// Uses PSPDFKit's own `PSPDFNavigationController` (a `UINavigationController`
  /// subclass) rather than a plain `UINavigationController`, matching the legacy
  /// `PspdfPlatformView` host so PSPDFKit's navigation/appearance integration
  /// behaves consistently.
  UINavigationController _wrapInNavigationController(
    PSPDFViewController pdfViewController,
  ) {
    // PSPDFNavigationController implements UINavigationController, so it is a
    // drop-in for the attach path below.
    final allocatedNav = PSPDFNavigationController.alloc();
    return allocatedNav.initWithRootViewController(pdfViewController);
  }

  /// Create PSPDFConfiguration with typed-config + adapter customization.
  ///
  /// Ordering inside the builder block:
  /// 1. Apply [widget.configuration] (typed [NutrientViewConfiguration]).
  /// 2. Let the adapter customize the builder — adapter wins conflicts.
  PSPDFConfiguration _createConfiguration() {
    final adapter = _resolvedAdapter;
    final typedConfig = widget.configuration;

    // Fast-path: no typed config and no adapter-level customization.
    if (typedConfig == null &&
        (adapter is! IOSAdapter || _platformViewId == null)) {
      debugPrint('[NutrientViewIOS] Default configuration created');
      return PSPDFConfiguration.defaultConfiguration();
    }

    final tempHandle = _platformViewId != null
        ? NutrientViewHandle.forPlatform(_platformViewId!)
        : null;

    final config = PSPDFConfiguration.configurationWithBuilder(
      ObjCBlock_ffiVoid_BuilderType.fromFunction((
        PSPDFBaseConfigurationBuilder baseBuilder,
      ) {
        final builder = PSPDFConfigurationBuilder.as(baseBuilder);

        // 1. Apply typed configuration first (sets baseline).
        if (typedConfig != null) {
          IOSConfigurationBuilder().applyToBuilder(builder, typedConfig);
        }

        // 2. Apply AI Assistant configuration if provided.
        //    applyToBuilder above applies the typed ObjC setters but does not
        //    reach the Swift-only aiAssistantConfiguration property. We call
        //    the C helper which applies it via KVC on the live builder pointer.
        final aiConfig = typedConfig?.aiAssistantConfiguration;
        if (aiConfig != null && aiConfig.isNotEmpty) {
          // Ensure sessionId has a non-empty value so the native guard passes.
          final aiMap = Map<String, String>.from(aiConfig);
          if ((aiMap['sessionId'] ?? '').isEmpty) {
            aiMap['sessionId'] = 'flutter-session';
          }
          final jsonPtr = _toCString(jsonEncode(aiMap));
          final builderPtr = builder.ref.pointer.cast<ffi.Void>();
          nutrient_apply_ai_assistant_configuration(builderPtr, jsonPtr);
          ffi_pkg.calloc.free(jsonPtr);
        }

        // 3. Adapter customization wins over typed config.
        if (adapter is IOSAdapter && tempHandle != null) {
          adapter.configureView(tempHandle, builder);
        }
      }),
    );

    tempHandle?.dispose();
    debugPrint('[NutrientViewIOS] Configuration created');
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

  /// Convert a Dart [String] to a null-terminated UTF-8 C string allocated
  /// with [ffi_pkg.calloc]. The caller is responsible for freeing the
  /// pointer. UTF-8 (not UTF-16 code units) is required — the native side
  /// reads these with `stringWithUTF8String`, which returns nil on invalid
  /// UTF-8, silently discarding the payload (e.g. a non-ASCII AI Assistant
  /// user ID).
  ffi.Pointer<ffi.Char> _toCString(String s) {
    final bytes = utf8.encode(s);
    final ptr = ffi_pkg.calloc<ffi.Char>(bytes.length + 1);
    for (var i = 0; i < bytes.length; i++) {
      ptr[i] = bytes[i];
    }
    ptr[bytes.length] = 0;
    return ptr;
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
