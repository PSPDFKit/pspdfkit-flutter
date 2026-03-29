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
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'nutrient_web_bindings.dart';
import 'operations/annotation_operations.dart';
import 'operations/bookmark_operations.dart';
import 'operations/document_operations.dart';
import 'operations/form_operations.dart';

/// Callback type for when the web instance is loaded.
typedef OnInstanceLoadedCallback = Future<void> Function(
  NutrientWebInstance instance,
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
///   Future<void> onInstanceLoaded(NutrientWebInstance instance) async {
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
/// Future<void> onInstanceLoaded(NutrientWebInstance instance) async {
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
  NutrientWebInstance? _instance;

  // Operations (initialized when instance is loaded)
  NutrientAnnotationOperations? _annotationOps;
  NutrientDocumentOperations? _documentOps;
  NutrientFormOperations? _formOps;
  NutrientBookmarkOperations? _bookmarkOps;

  /// Get the current web instance.
  ///
  /// This is available after [onInstanceLoaded] has been called.
  /// Returns `null` if the instance hasn't been loaded yet.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> onInstanceLoaded(NutrientWebInstance instance) async {
  ///   await super.onInstanceLoaded(instance);
  ///
  ///   // Now you can access instance via the property
  ///   final pageCount = this.instance?.totalPageCount;
  /// }
  /// ```
  @protected
  NutrientWebInstance? get instance => _instance;

  /// High-level annotation operations (available after [onInstanceLoaded]).
  ///
  /// Provides Dart-friendly methods for annotation CRUD, including
  /// type-safe conversion between Dart JSON and Web SDK annotation objects.
  @protected
  NutrientAnnotationOperations? get annotationOperations => _annotationOps;

  /// High-level document operations (available after [onInstanceLoaded]).
  ///
  /// Provides save, export (PDF, Instant JSON, XFDF), and import methods.
  @protected
  NutrientDocumentOperations? get documentOperations => _documentOps;

  /// High-level form field operations (available after [onInstanceLoaded]).
  ///
  /// Provides form field get/set with `instanceof`-based type detection.
  @protected
  NutrientFormOperations? get formOperations => _formOps;

  /// High-level bookmark operations (available after [onInstanceLoaded]).
  ///
  /// Provides bookmark CRUD with action conversion.
  @protected
  NutrientBookmarkOperations? get bookmarkOperations => _bookmarkOps;

  @override
  TargetPlatform get platform =>
      TargetPlatform.linux; // Web uses linux platform

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
  /// Future<void> onInstanceLoaded(NutrientWebInstance instance) async {
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
  Future<void> onInstanceLoaded(NutrientWebInstance instance) async {
    _instance = instance;
    _annotationOps = NutrientAnnotationOperations(instance);
    _documentOps = NutrientDocumentOperations(instance);
    _formOps = NutrientFormOperations(instance);
    _bookmarkOps = NutrientBookmarkOperations(instance);
  }

  @override
  Future<void> dispose() async {
    debugPrint('[WebPlatformAdapter] Disposing adapter');
    _instance = null;
    _annotationOps = null;
    _documentOps = null;
    _formOps = null;
    _bookmarkOps = null;
    await super.dispose();
  }

  /// Get the NutrientWebInstance for the given handle.
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
  NutrientWebInstance getInstance(NutrientViewHandle handle) {
    return handle.getNativeInstance('instance') as NutrientWebInstance;
  }

  @override
  Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {
    // Subclasses can override to customize behavior after view creation
  }
}
