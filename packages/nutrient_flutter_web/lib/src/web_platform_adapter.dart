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
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:web/web.dart' as web;

import 'document/nutrient_document_web.dart';
import 'events/nutrient_web_event_data.dart';
import 'generated/nutrient_web_bindings.g.dart' as nutrient_web;
import 'operations/annotation_operations.dart';
import 'operations/bookmark_operations.dart';
import 'operations/document_operations.dart';
import 'operations/form_operations.dart';
import 'utils/annotation_tool_web_mapping.dart';
import 'web_sdk_namespace.dart' as sdk;

/// Callback type for when the web instance is loaded.
typedef OnInstanceLoadedCallback = Future<void> Function(
  nutrient_web.Instance instance,
);

/// Web platform adapter for Nutrient SDK.
///
/// This is the base adapter class for Web platform. Extend this class to create
/// custom adapters that implement the **adapter-as-controller pattern**.
///
/// ## Adapter-as-Controller Pattern
///
/// The adapter-as-controller pattern allows your adapter to serve as both:
/// 1. A platform adapter (handles Web SDK lifecycle and configuration)
/// 2. A controller (provides cross-platform APIs to your app)
///
/// ```
/// NutrientWebAdapter (this class)
///        ↑ extends
/// YourWebAdapter ─────► implements YourController
///        │
///        └── The adapter IS the controller
/// ```
///
/// ## Creating a Custom Adapter
///
/// ```dart
/// // 1. Define your controller interface
/// abstract class MyController extends NutrientController {
///   Future<int> getPageCount();
///   Future<int> getCurrentPageIndex();
/// }
///
/// // 2. Create adapter that implements your controller
/// class MyWebAdapter extends NutrientWebAdapter implements MyController {
///   @override
///   Future<void> onInstanceLoaded(nutrient_web.Instance instance) async {
///     await super.onInstanceLoaded(instance);
///     // Instance is now available via this.instance
///   }
///
///   @override
///   Future<int> getPageCount() async => instance?.totalPageCount ?? 0;
///
///   @override
///   Future<int> getCurrentPageIndex() async => instance?.currentPageIndex ?? 0;
/// }
/// ```
///
/// ## Web SDK Instance Access
///
/// After [onInstanceLoaded] is called, access the Web SDK via [instance]:
///
/// ```dart
/// @override
/// Future<void> onInstanceLoaded(nutrient_web.Instance instance) async {
///   await super.onInstanceLoaded(instance);
///
///   // Access document properties
///   final pageCount = instance.totalPageCount;
///   final currentPage = instance.currentPageIndex;
///
///   // Add event listeners
///   instance.addEventListener('viewState.currentPageIndex.change', ...);
/// }
/// ```
///
/// ## Pre-load Configuration
///
/// Customize PSPDFKit.load() options in [configureLoad]:
///
/// ```dart
/// @override
/// Future<void> configureLoad(
///   NutrientViewHandle handle,
///   Map<String, dynamic> config,
/// ) async {
///   await super.configureLoad(handle, config);
///
///   config['layoutMode'] = 'SINGLE';
///   config['theme'] = 'DARK';
///   config['toolbarItems'] = [
///     {'type': 'sidebar-thumbnails'},
///     {'type': 'pager'},
///   ];
/// }
/// ```
///
/// ## Available Web SDK APIs
///
/// The [instance] property provides access to:
/// - `totalPageCount` - Total pages in document
/// - `currentPageIndex` - Current visible page (0-based)
/// - `addEventListener()` - Listen to SDK events
/// - And all other Web SDK APIs
///
/// ## Available Events
///
/// - annotations.create, annotations.update, annotations.delete
/// - viewState.currentPageIndex.change, viewState.zoom.change
/// - formFieldValues.update, formFields.change
/// - document.saveStateChange, document.saved
/// - text.selectionChange
/// - search.stateChange
///
/// See: https://www.nutrient.io/guides/web/events/
///
/// ## Registration
///
/// ```dart
/// await Nutrient.initialize(
///   webLicenseKey: 'YOUR_LICENSE_KEY',
///   webAdapter: MyWebAdapter(),
/// );
/// ```
class NutrientWebAdapter extends NutrientController
    implements NutrientPlatformAdapter {
  /// The current web instance (available after [onInstanceLoaded] is called).
  nutrient_web.Instance? _instance;

  // Operations (initialized when instance is loaded)
  NutrientAnnotationOperations? _annotationOps;
  NutrientDocumentOperations? _documentOps;
  NutrientFormOperations? _formOps;
  NutrientBookmarkOperations? _bookmarkOps;

  // ---------------------------------------------------------------------------
  // Web-specific event stream
  // ---------------------------------------------------------------------------

  final StreamController<NutrientWebEventData> _webEventController =
      StreamController<NutrientWebEventData>.broadcast();

  // Listeners registered on the Web SDK instance, kept so we can remove them
  // on dispose. Map: event name → JSFunction reference.
  final Map<String, JSFunction> _webListeners = {};

  /// A broadcast stream of all Nutrient Web SDK events.
  ///
  /// Each emission carries the raw Web SDK event name and JS payload.
  /// Cross-platform events are also surfaced on `controller.events`.
  ///
  /// ```dart
  /// final adapter = controller as NutrientWebAdapter;
  /// adapter.webEvents
  ///     .where((e) => e.type == 'bookmarks.create')
  ///     .listen((e) => print('Bookmark created'));
  /// ```
  Stream<NutrientWebEventData> get webEvents => _webEventController.stream;

  /// Emits a Web event to all [webEvents] subscribers.
  ///
  /// Subclasses can call this to push additional events into the stream.
  /// Silently no-ops if the controller has been disposed.
  @protected
  void emitWebEvent(NutrientWebEventData event) {
    if (!_webEventController.isClosed) _webEventController.add(event);
  }

  /// The raw Nutrient Web SDK [nutrient_web.Instance], or `null` if the
  /// instance hasn't been loaded yet.
  ///
  /// Use this as the escape hatch for advanced Web-only capabilities that
  /// aren't surfaced on the cross-platform [NutrientController] / managers
  /// or on the curated [formOperations] / [annotationOperations] /
  /// [documentOperations] / [bookmarkOperations] wrappers.
  ///
  /// Equivalent to [IOSAdapter.nativeDocument] / [AndroidAdapter.nativePdfDocument]
  /// on native platforms — the underlying SDK object, no wrapping, no opinion.
  ///
  /// ```dart
  /// final adapter = controller as NutrientWebAdapter;
  /// adapter.instance?.exportXFDF();
  /// adapter.instance?.create([widget, formField].jsify());
  /// ```
  nutrient_web.Instance? get instance => _instance;

  /// The raw native Web SDK [nutrient_web.Instance], named to follow the
  /// cross-platform `native*` accessor convention ([AndroidAdapter.nativePdfDocument],
  /// [IOSAdapter.nativeDocument]). Alias for [instance]; `null` until the viewer
  /// has loaded.
  nutrient_web.Instance? get nativeInstance => _instance;

  // ---------------------------------------------------------------------------
  // Toolbar customization
  // ---------------------------------------------------------------------------

  // Custom-item `onPress` callbacks are bridged to JS via `.toJS`. The SDK
  // holds the resulting JSFunctions, so we retain them here for the lifetime
  // of the adapter to keep them from being collected while still referenced.
  final List<JSFunction> _retainedToolbarCallbacks = <JSFunction>[];

  /// Replaces the viewer's **main toolbar** with [items] on the loaded
  /// instance (the cross-platform [NutrientControllerInterface.setMainToolbarItems]).
  ///
  /// List the [ToolbarItemType] values you want (in order) to add / remove /
  /// reorder the built-ins, and drop in [CustomToolbarItem] buttons whose Dart
  /// [CustomToolbarItem.onPressed] callbacks are bridged to the Web SDK's
  /// JavaScript `onPress` for you. Built-in reordering is a web-only feature;
  /// custom buttons are cross-platform.
  ///
  /// Reachable from `NutrientDocumentView.onControllerReady`; re-callable any
  /// time. No-op (returns) until the instance is loaded.
  @override
  Future<void> setMainToolbarItems(List<ToolbarItem> items) async {
    final inst = _instance;
    if (inst == null) return;
    // Build the new items (and collect their callbacks) *before* dropping the
    // old retained callbacks, so an old onPress can't be GC'd mid-swap while
    // the SDK still holds it.
    final newCallbacks = <JSFunction>[];
    final jsItems = <JSAny>[
      for (final item in items) _toolbarItemToJs(item, newCallbacks),
    ];
    _retainedToolbarCallbacks
      ..clear()
      ..addAll(newCallbacks);
    // The generated `setToolbarItems` parameter is an awkward union type; go
    // through `callMethod` to pass the plain JS array, as the adapter does for
    // `setViewState`.
    (inst as JSObject).callMethod<JSAny?>('setToolbarItems'.toJS, jsItems.toJS);
  }

  JSObject _toolbarItemToJs(ToolbarItem item, List<JSFunction> retainOut) {
    final obj = JSObject();
    switch (item) {
      case ToolbarItemType type:
        obj.setProperty('type'.toJS, type.id.toJS);
      case CustomToolbarItem(
          :final id,
          :final title,
          :final icon,
          :final className,
          :final onPressed,
          :final selected,
          :final disabled,
        ):
        obj.setProperty('type'.toJS, 'custom'.toJS);
        obj.setProperty('id'.toJS, id.toJS);
        if (title != null) obj.setProperty('title'.toJS, title.toJS);
        if (icon != null) obj.setProperty('icon'.toJS, icon.toJS);
        if (className != null) {
          obj.setProperty('className'.toJS, className.toJS);
        }
        if (selected != null) obj.setProperty('selected'.toJS, selected.toJS);
        if (disabled != null) obj.setProperty('disabled'.toJS, disabled.toJS);
        if (onPressed != null) {
          // The Web SDK calls `onPress(event)`; a 0-arg `.toJS` callback
          // safely ignores the extra JS argument (see _addWebOnlyListener).
          final fn = (() => onPressed()).toJS;
          retainOut.add(fn);
          obj.setProperty('onPress'.toJS, fn);
        }
    }
    return obj;
  }

  // The annotation-toolbar callback is a JS function the SDK holds for the
  // instance's lifetime; retain it against GC like the main-toolbar callbacks.
  final List<JSFunction> _retainedAnnotationToolbarCallbacks = <JSFunction>[];

  /// Replaces the **annotation editing / property toolbar** (the bar shown when
  /// an annotation is selected) with [items] — the cross-platform
  /// [NutrientControllerInterface.setAnnotationEditingToolbarItems].
  ///
  /// The Web SDK takes a callback that returns the items for the selected
  /// annotation; we ignore the selection and always return the configured list,
  /// matching the static native behavior. No-op until the instance is loaded.
  @override
  Future<void> setAnnotationEditingToolbarItems(
      List<AnnotationEditingItem> items) async {
    final inst = _instance;
    if (inst == null) return;

    final typeIds = <String>[
      for (final item in items)
        if (_annotationEditingTypeId(item) case final id?) id,
    ];

    JSArray<JSAny> callback(JSAny? annotation, JSObject options) {
      return <JSAny>[
        for (final type in typeIds)
          JSObject()..setProperty('type'.toJS, type.toJS),
      ].toJS;
    }

    final jsCallback = callback.toJS;
    // Build then swap so an in-flight call can't see a half-cleared list.
    _retainedAnnotationToolbarCallbacks
      ..clear()
      ..add(jsCallback);
    (inst as JSObject)
        .callMethod<JSAny?>('setAnnotationToolbarItems'.toJS, jsCallback);
  }

  /// Maps an [AnnotationEditingItem] to the Web SDK's annotation-toolbar item
  /// type id, or `null` if there is no web equivalent.
  String? _annotationEditingTypeId(AnnotationEditingItem item) {
    switch (item) {
      case AnnotationEditingItem.color:
        return 'stroke-color';
      case AnnotationEditingItem.fillColor:
        return 'fill-color';
      case AnnotationEditingItem.outlineColor:
        return 'outline-color';
      case AnnotationEditingItem.opacity:
        return 'opacity';
      case AnnotationEditingItem.thickness:
        return 'line-width';
      case AnnotationEditingItem.blendMode:
        return 'blend-mode';
      case AnnotationEditingItem.font:
        return 'font';
      case AnnotationEditingItem.borderStyle:
        return 'border-style';
      case AnnotationEditingItem.lineEnds:
        return 'linecaps-dasharray';
      case AnnotationEditingItem.note:
        return 'annotation-note';
      case AnnotationEditingItem.delete:
        return 'delete';
    }
  }

  // ---------------------------------------------------------------------------
  // View state + raw-instance escape hatches
  //
  // The Web SDK's `viewState` is an Immutable.Record the generated bindings
  // can only surface as an opaque object, and a few instance APIs have awkward
  // union types. These typed helpers (and the `callInstanceMethod` /
  // `getInstanceProperty` escape hatches) keep the `dart:js_interop_unsafe`
  // calls inside the package, so consumers and catalog adapters don't have to
  // reach for it themselves.
  // ---------------------------------------------------------------------------

  /// The viewer's current page index (0-based), or `null` if no instance is
  /// loaded.
  int? get currentPageIndex {
    final inst = _instance;
    if (inst == null) return null;
    // `viewState` can be transiently null while the instance is tearing down;
    // return null rather than throwing on the cast.
    final viewState = inst.viewState as JSObject?;
    if (viewState == null) return null;
    return viewState.getProperty<JSNumber?>('currentPageIndex'.toJS)?.toDartInt;
  }

  /// Navigates the viewer to [pageIndex] by merging the view state.
  ///
  /// No-op if no instance is loaded. This is the typed counterpart to building
  /// a `viewState.merge({...})` + `setViewState(...)` call by hand.
  void setCurrentPageIndex(int pageIndex) {
    final inst = _instance;
    if (inst == null) return;
    final viewState = inst.viewState as JSObject?;
    if (viewState == null) return;
    final updated = viewState.callMethod<JSAny>(
      'merge'.toJS,
      {'currentPageIndex': pageIndex}.jsify()!,
    );
    // `setViewState`'s generated parameter is an awkward union; go through
    // `callMethod` to pass the merged record.
    (inst as JSObject).callMethod<JSAny?>('setViewState'.toJS, updated);
  }

  /// Reads property [name] off the raw Web SDK `Instance`, or `null` if no
  /// instance is loaded.
  ///
  /// Escape hatch for instance APIs the typed adapter doesn't surface — use it
  /// instead of importing `dart:js_interop_unsafe` and casting [instance]
  /// yourself.
  T? getInstanceProperty<T extends JSAny?>(String name) {
    final inst = _instance;
    if (inst == null) return null;
    return (inst as JSObject).getProperty<T>(name.toJS);
  }

  /// Calls method [method] on the raw Web SDK `Instance` with [args], or
  /// returns `null` if no instance is loaded.
  ///
  /// Companion escape hatch to [getInstanceProperty]. Pass Dart values as
  /// `JSAny?` (e.g. `42.toJS`, `someMap.jsify()`).
  T? callInstanceMethod<T extends JSAny?>(
    String method, [
    List<JSAny?> args = const [],
  ]) {
    final inst = _instance;
    if (inst == null) return null;
    return (inst as JSObject).callMethodVarArgs<T>(method.toJS, args);
  }

  // ---------------------------------------------------------------------------
  // High-level operations (escape hatch for advanced Web SDK usage)
  //
  // These are the documented public escape hatch for features that aren't
  // surfaced on the cross-platform [NutrientController] / managers — e.g.
  // checkbox `List<String>` writes via [NutrientFormOperations.setFormFieldValues],
  // Instant JSON / XFDF import/export, etc.
  //
  // Equivalent to [IOSAdapter.nativeDocument] / [AndroidAdapter.nativePdfDocument]
  // on native platforms, but pre-curated as Dart-friendly wrappers around the
  // raw Web SDK [nutrient_web.Instance].
  // ---------------------------------------------------------------------------

  /// High-level annotation operations (available after [onInstanceLoaded]).
  ///
  /// Provides Dart-friendly methods for annotation CRUD, including
  /// type-safe conversion between Dart JSON and Web SDK annotation objects.
  NutrientAnnotationOperations? get annotationOperations => _annotationOps;

  /// High-level document operations (available after [onInstanceLoaded]).
  ///
  /// Provides save, export (PDF, Instant JSON, XFDF), and import methods.
  NutrientDocumentOperations? get documentOperations => _documentOps;

  /// High-level form field operations (available after [onInstanceLoaded]).
  ///
  /// Provides form field get/set with `instanceof`-based type detection,
  /// plus advanced bulk writes via [NutrientFormOperations.setFormFieldValues]
  /// for non-text fields (checkbox `List<String>` values, choice index sets).
  ///
  /// ```dart
  /// final adapter = controller as NutrientWebAdapter;
  /// await adapter.formOperations?.setFormFieldValues({
  ///   'Agreement': ['Yes'], // checkbox — requires List<String>
  /// });
  /// ```
  NutrientFormOperations? get formOperations => _formOps;

  /// High-level bookmark operations (available after [onInstanceLoaded]).
  ///
  /// Provides bookmark CRUD with action conversion.
  NutrientBookmarkOperations? get bookmarkOperations => _bookmarkOps;

  @override
  TargetPlatform get platform =>
      TargetPlatform.linux; // Web uses linux platform

  // ---------------------------------------------------------------------------
  // Document
  // ---------------------------------------------------------------------------

  NutrientDocumentInterface? _document;

  @override
  NutrientDocumentInterface get document => _document ??= createDocument();

  /// Creates the [NutrientDocumentInterface] for this adapter.
  ///
  /// Override to provide a custom document implementation:
  /// ```dart
  /// class MyWebAdapter extends NutrientWebAdapter {
  ///   @override
  ///   NutrientDocumentInterface createDocument() => MyPdfDocument(this);
  /// }
  /// ```
  @protected
  NutrientDocumentInterface createDocument() => NutrientDocumentWeb(this);

  /// Opens a document without a view (headless access).
  ///
  /// Loads the Nutrient Web SDK with `headless: true` so no DOM container is
  /// required. The returned [NutrientDocumentInterface] is isolated from any
  /// view-attached instance — its operations call only this headless instance.
  ///
  /// Call [NutrientDocumentInterface.close] when done to unload the instance.
  ///
  /// ```dart
  /// final doc = await adapter.openDocument('path/to/doc.pdf');
  /// final count = await doc.getPageCount();
  /// await doc.close();
  /// ```
  @override
  Future<NutrientDocumentInterface> openDocument(
    String path, {
    String? password,
  }) async {
    if (!sdk.isLoaded) {
      throw StateError(
        'Nutrient Web SDK global not found. Ensure the SDK script is loaded '
        'before calling openDocument().',
      );
    }

    final config = <String, dynamic>{
      'document': path,
      'headless': true,
      // Mirror the productId used by the view path (NutrientViewWeb). The
      // Nutrient Web SDK enforces that all load() calls in a session use a
      // consistent configuration — passing a different productId (or omitting
      // it after the view set it) triggers an assertion error.
      'productId': 'FlutterForWeb',
      'useCDN': true,
      // Mirror native: only forward a real password. An empty string
      // succeeds on Android/iOS but may fail or behave inconsistently on web.
      if (password != null && password.isNotEmpty) 'password': password,
    };

    final licenseKey = Nutrient.webLicenseKey;
    if (licenseKey != null && licenseKey.isNotEmpty) {
      config['licenseKey'] = licenseKey;
    }

    final jsConfig = config.jsify() as JSObject;
    final instance = await sdk.loadInstance(jsConfig).toDart;
    return NutrientDocumentWeb.headless(this, instance);
  }

  @override
  Future<NutrientDocumentInterface> openDocumentFromBytes(
    Uint8List bytes, {
    String? password,
  }) async {
    // The Web SDK loads from a URL; wrap the bytes in a blob URL and open that
    // (mirrors how NutrientViewWeb opens `documentBytes`).
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'application/pdf'),
    );
    final blobUrl = web.URL.createObjectURL(blob);
    return openDocument(blobUrl, password: password);
  }

  @override
  Future<bool> processAnnotations(
    String sourcePath,
    AnnotationType type,
    AnnotationProcessingMode mode,
    String destinationPath,
  ) {
    // The Web SDK has no file-based annotation processor. Consumers can export
    // a flattened document via `document.exportPdf(options: ...)` instead.
    throw UnsupportedError(
      'Nutrient.processAnnotations is not supported on Web. Use '
      'document.exportPdf() with DocumentSaveOptions(flatten: true) instead.',
    );
  }

  /// Package-internal access to annotation operations for document manager classes.
  @internal
  NutrientAnnotationOperations? get internalAnnotationOperations =>
      annotationOperations;

  /// Package-internal access to document operations for document manager classes.
  @internal
  NutrientDocumentOperations? get internalDocumentOperations =>
      documentOperations;

  /// Package-internal access to form operations for document manager classes.
  @internal
  NutrientFormOperations? get internalFormOperations => formOperations;

  /// Package-internal access to bookmark operations for document manager classes.
  @internal
  NutrientBookmarkOperations? get internalBookmarkOperations =>
      bookmarkOperations;

  /// Configure the PSPDFKit.load() configuration before loading.
  ///
  /// This method is called before PSPDFKit.load() is invoked, allowing
  /// subclasses to modify the configuration object.
  ///
  /// The configuration is a mutable Map that will be converted to a JSObject
  /// before being passed to PSPDFKit.load().
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> configureLoad(
  ///   NutrientViewHandle handle,
  ///   Map<String, dynamic> config,
  /// ) async {
  ///   await super.configureLoad(handle, config);
  ///
  ///   // Customize the load configuration
  ///   config['layoutMode'] = 'SINGLE';
  ///   config['scrollMode'] = 'CONTINUOUS';
  ///   config['theme'] = 'DARK';
  ///   config['toolbarItems'] = [
  ///     {'type': 'sidebar-thumbnails'},
  ///     {'type': 'pager'},
  ///     {'type': 'zoom-out'},
  ///     {'type': 'zoom-in'},
  ///   ];
  /// }
  /// ```
  Future<void> configureLoad(
    NutrientViewHandle handle,
    Map<String, dynamic> config,
  ) async {
    // Subclasses can override to customize the PSPDFKit.load() configuration
  }

  /// Called when the Nutrient Web SDK instance has been loaded.
  ///
  /// Override this method to perform actions after the instance is ready,
  /// such as adding event listeners or accessing document properties.
  ///
  /// This is the Web equivalent of [IOSAdapter.onDocumentLoaded] and
  /// [AndroidAdapter.onDocumentLoaded].
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> onInstanceLoaded(nutrient_web.Instance instance) async {
  ///   await super.onInstanceLoaded(instance);
  ///
  ///   // Access document properties
  ///   final pageCount = instance.totalPageCount;
  ///   debugPrint('Document has $pageCount pages');
  ///
  ///   // Add event listeners
  ///   instance.addEventListener('viewState.currentPageIndex.change', ((JSAny event) {
  ///     debugPrint('Page changed to: ${instance.currentPageIndex}');
  ///   }).toJS);
  /// }
  /// ```
  Future<void> onInstanceLoaded(nutrient_web.Instance instance) async {
    _instance = instance;
    _annotationOps = NutrientAnnotationOperations(instance);
    _documentOps = NutrientDocumentOperations(instance);
    _formOps = NutrientFormOperations(instance);
    _bookmarkOps = NutrientBookmarkOperations(instance);

    _wireSdkEventListeners(instance);

    // Web's instance is already fully loaded by the time we get here, while
    // Android/iOS receive [DocumentLoadedEvent] from a native callback. Emit
    // it synchronously so consumers see consistent semantics on all platforms.
    emitEvent(DocumentLoadedEvent(document));
  }

  /// Registers the SDK-managed event listeners that drive [events] and
  /// [webEvents]. Cross-platform events are translated and emitted on
  /// [events]; everything is mirrored to [webEvents] as raw payloads.
  void _wireSdkEventListeners(nutrient_web.Instance instance) {
    // Cross-platform events.
    _addCrossPlatformListener(instance, 'annotations.create', (payload) {
      emitEvent(AnnotationCreatedEvent(_extractAnnotationsJson(payload)));
    });
    _addCrossPlatformListener(instance, 'annotations.update', (payload) {
      emitEvent(AnnotationUpdatedEvent(_extractAnnotationsJson(payload)));
    });
    _addCrossPlatformListener(instance, 'annotations.delete', (payload) {
      emitEvent(AnnotationDeletedEvent(_extractAnnotationsJson(payload)));
    });
    _addCrossPlatformListener(instance, 'annotations.focus', (payload) {
      emitEvent(AnnotationSelectedEvent(_extractAnnotationsJson(payload)));
    });
    _addCrossPlatformListener(instance, 'annotations.blur', (payload) {
      emitEvent(AnnotationDeselectedEvent(_extractAnnotationsJson(payload)));
    });
    _addCrossPlatformListener(instance, 'viewState.currentPageIndex.change',
        (_) {
      emitEvent(PageChangedEvent(_documentOps?.currentPageIndex ?? 0));
    });
    _addCrossPlatformListener(instance, 'page.press', (_) {
      emitEvent(PageClickedEvent(_documentOps?.currentPageIndex ?? 0));
    });
    _addCrossPlatformListener(
        instance, 'textSelection.change', _onTextSelectionChange);
    _addCrossPlatformListener(instance, 'formFieldValues.update', (payload) {
      emitEvent(FormFieldUpdatedEvent(_jsToJsonString(payload)));
    });
    _addCrossPlatformListener(instance, 'document.saveStateChange', (payload) {
      // Web fires `saveStateChange` for *both* directions — when the document
      // becomes dirty and when it's persisted — so we can't treat every
      // change as a save. Only emit `DocumentSavedEvent` for the clean
      // transition (`hasUnsavedChanges == false`), which matches the
      // Android/iOS "did save" semantics. Without this guard, an edit's
      // dirtying `saveStateChange` would masquerade as a save and clear a
      // consumer's dirty flag prematurely.
      final event = payload as nutrient_web.Events_SaveStateChangeEvent?;
      if (event != null && event.hasUnsavedChanges) return;
      emitEvent(const DocumentSavedEvent());
    });

    // Mirror everything else to webEvents only. The full list mirrors what
    // the Web SDK exposes in NutrientViewer.EventName; consumers can filter
    // by name with `webEvents.where((e) => e.type == '...')`.
    for (final name in _webOnlyEventNames) {
      _addWebOnlyListener(instance, name);
    }
  }

  void _addCrossPlatformListener(
    nutrient_web.Instance instance,
    String name,
    void Function(JSAny? payload) handler,
  ) {
    final fn = ((JSAny? payload) {
      // Mirror to webEvents first so subscribers always see every event.
      emitWebEvent(NutrientWebEventData(name, payload));
      handler(payload);
    }).toJS;
    try {
      instance.addEventListener(name.toJS, fn);
      _webListeners[name] = fn;
    } catch (e) {
      // The SDK build may not support this event name (different SDK
      // versions ship different events). Skip silently.
      debugPrint('[WebPlatformAdapter] Skipping unsupported event "$name": $e');
    }
  }

  /// Monotonic guard for the async text fetch in [_onTextSelectionChange]:
  /// results belonging to a superseded selection are dropped.
  int _textSelectionGeneration = 0;

  void _onTextSelectionChange(JSAny? payload) {
    final generation = ++_textSelectionGeneration;
    // The Web SDK delivers the TextSelection object, or null on deselect.
    if (payload.isUndefinedOrNull) {
      emitEvent(const TextSelectionChangedEvent(null));
      return;
    }
    // Unlike Android/iOS, the Web SDK's `getText()` is asynchronous (a JS
    // promise), so the populated event is emitted a microtask+ later than
    // the selection change itself. `getText` is a per-payload closure over
    // the selection snapshot (no `this` dependence), but go through
    // `callMethod` anyway — the adapter's established pattern for invoking
    // SDK methods.
    final selection = payload as nutrient_web.TextSelection;
    unawaited(selection
        .callMethod<JSPromise<JSString>>('getText'.toJS)
        .toDart
        .then((text) {
      // A newer textSelection.change arrived while getText was in flight —
      // drop this result so events can't go backwards.
      if (generation != _textSelectionGeneration) return;
      emitEvent(TextSelectionChangedEvent(text.toDart));
    }, onError: (Object error) {
      // Selection invalidated mid-fetch — skip the emit rather than surface
      // a bogus value or an async error.
      debugPrint('[WebPlatformAdapter] textSelection getText failed: $error');
    }));
  }

  void _addWebOnlyListener(nutrient_web.Instance instance, String name) {
    // Web SDK events fire with varying arity (0, 1, or 2 arguments).
    // Dart's `.toJS` enforces exact arity, so we register a 0-arg
    // callback — JS happily ignores extra args. Consumers that need the
    // payload can listen via the more specific cross-platform streams or
    // call the Web SDK API directly.
    final fn = (() {
      emitWebEvent(NutrientWebEventData(name, null));
    }).toJS;
    try {
      instance.addEventListener(name.toJS, fn);
      _webListeners[name] = fn;
    } catch (e) {
      // The SDK build may not support this event name (different SDK
      // versions ship different events). Skip silently.
      debugPrint('[WebPlatformAdapter] Skipping unsupported event "$name": $e');
    }
  }

  // JSON extraction from an annotations event payload. Web's event payload is
  // an Immutable.List of annotation objects. Each is normalized through
  // `webAnnotationToJson` (the same `toSerializableObject` + color→hex + inject
  // `type` path used by getAnnotations) so consumers get spec Instant JSON
  // consistent with Android/iOS. A raw JSON.stringify of the Immutable Record
  // would instead emit `{r,g,b}` colors, no `type`, and `boundingBox` rather
  // than `bbox` — which the typed `Annotation` models can't parse. See
  // documentation/typed-annotations-cross-platform.md.
  List<String> _extractAnnotationsJson(JSAny? payload) {
    if (payload == null) return const [];
    final ops = _annotationOps;
    if (ops == null) return const [];
    final result = <String>[];
    void add(JSAny? annotation) {
      if (annotation == null) return;
      try {
        final map = ops.webAnnotationToJson(annotation as JSObject);
        if (map != null) result.add(jsonEncode(map));
      } catch (_) {
        // Skip an annotation that can't be serialized (e.g. already detached
        // on a delete) rather than failing the whole event.
      }
    }

    try {
      final list = payload as JSObject;
      final forEach = list['forEach'] as JSFunction?;
      if (forEach != null) {
        forEach.callAsFunction(list, ((JSAny? a) => add(a)).toJS);
        return result;
      }
      // Single-annotation payload.
      add(payload);
      return result;
    } catch (_) {
      return const [];
    }
  }

  String _jsToJsonString(JSAny? payload) {
    if (payload == null) return 'null';
    try {
      final jsonGlobal = globalContext['JSON'] as JSObject?;
      final stringify = jsonGlobal?['stringify'] as JSFunction?;
      final result = stringify?.callAsFunction(null, payload) as JSString?;
      return result?.toDart ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<void> dispose() async {
    debugPrint('[WebPlatformAdapter] Disposing adapter');
    await _document?.close();
    _document = null;
    final instance = _instance;
    if (instance != null) {
      _webListeners.forEach((name, fn) {
        try {
          instance.removeEventListener(name.toJS, fn);
        } catch (_) {
          // Removing a listener may throw if the instance is already torn
          // down; safe to ignore.
        }
      });
    }
    _webListeners.clear();
    await _webEventController.close();
    _instance = null;
    _annotationOps = null;
    _documentOps = null;
    _formOps = null;
    _bookmarkOps = null;
    await super.dispose();
  }

  // Web SDK event names mirrored to [webEvents]. Sourced from the canonical
  // NutrientViewer.EventName enum in web/web/src/enums/EventName.ts of the
  // monorepo. Cross-platform events are wired separately in
  // [_wireSdkEventListeners] and are intentionally omitted here to avoid
  // double registration.
  static const List<String> _webOnlyEventNames = [
    // Annotation
    'annotationNote.hover',
    'annotationNote.press',
    'annotationPresets.update',
    'annotationSelection.change',
    'annotations.change',
    'annotations.copy',
    'annotations.cut',
    'annotations.didSave',
    'annotations.duplicate',
    'annotations.load',
    'annotations.paste',
    'annotations.press',
    'annotations.transform',
    'annotations.willChange',
    'annotations.willSave',
    // Bookmark
    'bookmarks.change',
    'bookmarks.create',
    'bookmarks.delete',
    'bookmarks.didSave',
    'bookmarks.load',
    'bookmarks.update',
    'bookmarks.willSave',
    // Comment
    'comments.change',
    'comments.create',
    'comments.delete',
    'comments.didSave',
    'comments.load',
    'comments.mention',
    'comments.update',
    'comments.willSave',
    // Crop area
    'cropArea.changeStart',
    'cropArea.changeStop',
    // Document
    'document.change',
    'documentComparisonUI.end',
    'documentComparisonUI.start',
    // Forms
    'formFieldValues.didSave',
    'formFieldValues.willSave',
    'formFields.change',
    'formFields.create',
    'formFields.delete',
    'formFields.didSave',
    'formFields.load',
    'formFields.update',
    'formFields.willSave',
    'forms.didSubmit',
    'forms.willSubmit',
    // History
    'history.change',
    'history.clear',
    'history.redo',
    'history.undo',
    'history.willChange',
    // Signatures
    'inkSignatures.change',
    'inkSignatures.create',
    'inkSignatures.delete',
    'inkSignatures.update',
    'storedSignatures.change',
    'storedSignatures.create',
    'storedSignatures.delete',
    'storedSignatures.update',
    // Instant
    'instant.connectedClients.change',
    // Search
    'search.stateChange',
    'search.termChange',
    // Text
    'textLine.press',
    // Viewport
    'viewState.change',
    'viewState.zoom.change',
  ];

  /// Get the nutrient_web.Instance for the given handle.
  ///
  /// This provides type-safe access to the Nutrient Web SDK instance,
  /// allowing you to call any Web SDK API method with proper typing.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {
  ///   await super.onPlatformViewCreated(handle);
  ///
  ///   final instance = getInstance(handle);
  ///
  ///   // Type-safe Web SDK API calls
  ///   final pageInfo = await instance.pageInfoForIndex(0)?.toDart;
  ///   final totalPages = instance.totalPageCount;
  ///
  ///   // Listen to events directly
  ///   instance.addEventListener('annotations.create', ((JSAny event) {
  ///     print('Annotation created');
  ///   }).toJS);
  /// }
  /// ```
  @protected
  nutrient_web.Instance getInstance(NutrientViewHandle handle) {
    return handle.getNativeInstance('instance') as nutrient_web.Instance;
  }

  @override
  Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {
    // Subclasses can override to customize behavior after view creation
  }

  // ---------------------------------------------------------------------------
  // Viewport and zoom
  // ---------------------------------------------------------------------------

  /// Returns the visible rect of [pageIndex] in PDF page coordinates.
  ///
  /// The Web SDK has no single "visible rect" API, but it can be composed: the
  /// viewer content lives in a content frame exposed via
  /// `instance.contentDocument`. We measure the visible portion of the page
  /// there (intersection of the `.PSPDFKit-Page` and `.PSPDFKit-Viewport`
  /// elements) and convert it to page coordinates with
  /// `instance.transformContentClientToPageSpace(...)` — the approach from
  /// Nutrient's "Render the visible area of the current page" web guide.
  ///
  /// Returns [Rect.zero] when the page isn't currently mounted/visible. The
  /// legacy web controller threw `UnimplementedError` here; this implements it.
  @override
  Future<Rect> getVisibleRect(int pageIndex) async {
    final instance = _requireInstance('getVisibleRect');
    final jsInstance = instance as JSObject;

    // `contentDocument` is a Document (server mode) or a ShadowRoot
    // (standalone) — both expose querySelector, so go through callMethod.
    final contentDoc =
        jsInstance.getProperty<JSObject?>('contentDocument'.toJS);
    if (contentDoc == null) return Rect.zero;

    JSObject? query(String selector) =>
        contentDoc.callMethod<JSObject?>('querySelector'.toJS, selector.toJS);

    final viewport = query('.PSPDFKit-Viewport');
    final pageEl = query('.PSPDFKit-Page[data-page-index="$pageIndex"]');
    if (viewport == null || pageEl == null) return Rect.zero;

    double field(JSObject domRect, String name) =>
        domRect.getProperty<JSNumber>(name.toJS).toDartDouble;

    final pageRect = pageEl.callMethod<JSObject>('getBoundingClientRect'.toJS);
    final viewRect =
        viewport.callMethod<JSObject>('getBoundingClientRect'.toJS);

    // Visible region = intersection of the page and the viewport, in
    // content-client coordinates.
    final left = math.max(field(pageRect, 'left'), field(viewRect, 'left'));
    final top = math.max(field(pageRect, 'top'), field(viewRect, 'top'));
    final right = math.min(field(pageRect, 'right'), field(viewRect, 'right'));
    final bottom =
        math.min(field(pageRect, 'bottom'), field(viewRect, 'bottom'));
    if (right <= left || bottom <= top) return Rect.zero;

    final clientRect = sdk.createGeometryRect(
      left: left,
      top: top,
      width: right - left,
      height: bottom - top,
    );
    // The generated `transformContentClientToPageSpace` binding has an awkward
    // union signature; call it directly to keep the cast simple.
    final pageSpace = jsInstance.callMethod<nutrient_web.Rect>(
      'transformContentClientToPageSpace'.toJS,
      clientRect,
      pageIndex.toJS,
    );
    return Rect.fromLTWH(
      pageSpace.left,
      pageSpace.top,
      pageSpace.width,
      pageSpace.height,
    );
  }

  @override
  Future<void> zoomToRect(int pageIndex, Rect rect) async {
    final webInstance = _requireInstance('zoomToRect');
    final webRect = sdk.createGeometryRect(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
    );
    webInstance.jumpAndZoomToRect(pageIndex, webRect);
  }

  @override
  Future<double> getZoomScale(int pageIndex) async {
    final webInstance = _requireInstance('getZoomScale');
    return webInstance.currentZoomLevel.toDouble();
  }

  // ---------------------------------------------------------------------------
  // Annotation creation mode
  // ---------------------------------------------------------------------------

  @override
  Future<bool?> enterAnnotationCreationMode(
      [AnnotationTool? annotationTool]) async {
    final webInstance = _requireInstance('enterAnnotationCreationMode');
    final tool = annotationTool ?? AnnotationTool.inkPen;

    final pspdfkitNamespace = globalContext['PSPDFKit'] as JSObject?;
    if (pspdfkitNamespace == null) {
      throw StateError('PSPDFKit namespace not found.');
    }
    final interactionModeNamespace =
        pspdfkitNamespace['InteractionMode'] as JSObject?;
    if (interactionModeNamespace == null) {
      throw StateError('PSPDFKit.InteractionMode namespace not found.');
    }

    final modeName = webInteractionModeFor(tool);
    final interactionMode = interactionModeNamespace[modeName];
    if (interactionMode == null) {
      // The Web SDK build doesn't ship this interaction mode.
      return false;
    }

    // Text-markup tools all share TEXT_HIGHLIGHTER; the preset selects
    // which markup style the user gets.
    final presetId = annotationPresetForTextMarkupTool(tool);
    if (presetId != null) {
      // setCurrentAnnotationPreset is generated as `void` (TS source has
      // no return type), so it can't be awaited. The Web SDK applies
      // the preset synchronously.
      webInstance.setCurrentAnnotationPreset(presetId);
    }

    final updateFn = ((JSObject viewState) {
      return viewState.callMethod(
          'set'.toJS, 'interactionMode'.toJS, interactionMode);
    }).toJS;
    // The generated `setViewState` takes an anonymous union type;
    // route through `callMethod` to bypass the static union check.
    (webInstance as JSObject).callMethod<JSAny?>('setViewState'.toJS, updateFn);
    return true;
  }

  @override
  Future<bool?> exitAnnotationCreationMode() async {
    final webInstance = _requireInstance('exitAnnotationCreationMode');
    final updateFn = ((JSObject viewState) {
      return viewState.callMethod('set'.toJS, 'interactionMode'.toJS, null);
    }).toJS;
    (webInstance as JSObject).callMethod<JSAny?>('setViewState'.toJS, updateFn);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Coordinate conversion
  // ---------------------------------------------------------------------------

  /// Converts a view-space point to PDF page coordinates.
  ///
  /// The Web SDK has no single view↔PDF point call (the legacy web controller
  /// threw `UnimplementedError`), but it's composable from the content-frame
  /// transforms — see [_transformPoint].
  @override
  Future<Offset> convertViewPointToPdfPoint(int pageIndex, Offset point) async {
    // The Web SDK has no dedicated view↔PDF point API, but the content-frame
    // transforms cover it: client (view) space → page (PDF) space.
    return _transformPoint(
      'convertViewPointToPdfPoint',
      'transformContentClientToPageSpace',
      point,
      pageIndex,
    );
  }

  @override
  Future<Offset> convertPdfPointToViewPoint(int pageIndex, Offset point) async {
    // Inverse of the above: page (PDF) space → client (view) space.
    return _transformPoint(
      'convertPdfPointToViewPoint',
      'transformContentPageToClientSpace',
      point,
      pageIndex,
    );
  }

  /// Runs one of the Web SDK's content-frame point transforms
  /// (`transformContentClientToPageSpace` / `transformContentPageToClientSpace`)
  /// on [point]. The generated bindings type these with an awkward union, so
  /// call through `callMethod` with a `Geometry.Point` instance.
  Offset _transformPoint(
    String methodName,
    String jsMethod,
    Offset point,
    int pageIndex,
  ) {
    final instance = _requireInstance(methodName);
    final jsInstance = instance as JSObject;
    final geomPoint = sdk.createGeometryPoint(x: point.dx, y: point.dy);
    final result = jsInstance.callMethod<JSObject>(
        jsMethod.toJS, geomPoint, pageIndex.toJS);
    final x = result.getProperty<JSNumber>('x'.toJS).toDartDouble;
    final y = result.getProperty<JSNumber>('y'.toJS).toDartDouble;
    return Offset(x, y);
  }

  nutrient_web.Instance _requireInstance(String methodName) {
    final current = _instance;
    if (current == null) {
      throw StateError(
          '$methodName called before the Web SDK instance was loaded. '
          'Wait for onInstanceLoaded before invoking view-controller methods.');
    }
    return current;
  }
}
