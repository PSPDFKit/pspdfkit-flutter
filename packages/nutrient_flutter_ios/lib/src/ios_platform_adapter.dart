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

import 'bindings/nutrient_ios_bindings.dart';

/// iOS platform adapter for Nutrient SDK.
///
/// This is the base adapter class for iOS platform. Extend this class to create
/// custom adapters that implement the **adapter-as-controller pattern**.
///
/// ## Adapter-as-Controller Pattern
///
/// The adapter-as-controller pattern allows your adapter to serve as both:
/// 1. A platform adapter (handles iOS SDK lifecycle and native access)
/// 2. A controller (provides cross-platform APIs to your app)
///
/// ```
/// IOSAdapter (this class)
///        ↑ extends
/// YourIOSAdapter ─────► implements YourController
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
/// class MyIOSAdapter extends IOSAdapter implements MyController {
///   PSPDFDocument? _document;
///   PSPDFViewController? _viewController;
///   PSPDFViewControllerDelegate? _delegate;
///
///   @override
///   Future<void> onViewControllerReady(PSPDFViewController viewController) async {
///     _viewController = viewController;
///     _setupDelegate(viewController);
///   }
///
///   void _setupDelegate(PSPDFViewController viewController) {
///     // IMPORTANT: Use implementAsListener for thread-safe callbacks.
///     // iOS callbacks can come from layout, animation, or gesture threads.
///     _delegate = PSPDFViewControllerDelegate$Builder.implementAsListener(
///       pdfViewController_didChangeDocument: (controller, document) {
///         _document = document;
///         _onDocumentLoaded(document);
///       },
///     );
///     viewController.delegate = _delegate;
///
///     // Check for already-loaded document (delegate only fires on changes)
///     final existingDocument = viewController.document;
///     if (existingDocument != null) {
///       _document = existingDocument;
///       _onDocumentLoaded(existingDocument);
///     }
///   }
///
///   void _onDocumentLoaded(PSPDFDocument? document) {
///     if (document != null) {
///       debugPrint('Document loaded: ${document.pageCount} pages');
///     }
///   }
///
///   @override
///   Future<int> getPageCount() => Future.value(_document?.pageCount ?? 0);
///
///   @override
///   Future<int> getCurrentPageIndex() => Future.value(_viewController?.pageIndex ?? 0);
/// }
/// ```
///
/// ## Pre-Build Configuration
///
/// Customize the PSPDFConfiguration before view controller creation via [configureView]:
///
/// ```dart
/// @override
/// void configureView(
///   NutrientViewHandle handle,
///   PSPDFConfigurationBuilder builder,
/// ) {
///   super.configureView(handle, builder);
///
///   // Customize configuration
///   builder.pageMode = PSPDFPageMode.single;
///   builder.scrollDirection = PSPDFScrollDirection.horizontal;
///   builder.pageTransition = PSPDFPageTransition.scrollContinuous;
///   builder.thumbnailBarMode = PSPDFThumbnailBarMode.none;
/// }
/// ```
///
/// ## Thread Safety
///
/// iOS delegate callbacks can be invoked from various threads (layout, animation,
/// gesture recognizers), not just the main Dart isolate thread. Always use
/// `implementAsListener` for void-returning delegate methods to ensure thread safety.
///
/// ## Available Native Objects
///
/// - [PSPDFViewController] - Main UI component for displaying PDFs
/// - [PSPDFDocument] - Document model (access via `viewController.document`)
/// - [PSPDFViewControllerDelegate] - Protocol for receiving native events
///
/// ## Lifecycle Callbacks
///
/// - [configureView] - Called before building, for pre-build configuration
/// - [onViewControllerReady] - Called when PSPDFViewController is ready
/// - [onViewControllerDetached] - Called when view controller is detached (cleanup)
///
/// ## FFI Memory Management
///
/// The iOS SDK uses Automatic Reference Counting (ARC).
/// Objects passed to adapter callbacks are managed automatically -
/// no manual memory management needed.
///
/// ## Registration
///
/// ```dart
/// await Nutrient.initialize(
///   iosLicenseKey: 'YOUR_LICENSE_KEY',
///   iosAdapter: MyIOSAdapter(),
/// );
/// ```
///
/// ## Documentation
///
/// - Nutrient iOS SDK: https://www.nutrient.io/guides/ios/
/// - API Reference: https://www.nutrient.io/api/ios/
abstract class IOSAdapter extends NutrientController
    implements NutrientPlatformAdapter {
  @override
  TargetPlatform get platform => TargetPlatform.iOS;

  @override
  Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {
    // Get native view controller from the registry
    final viewController =
        handle.getNativeInstance('viewController') as PSPDFViewController?;

    if (viewController != null) {
      await onViewControllerReady(viewController);
    }
  }

  @override
  Future<void> dispose() async {
    await onViewControllerDetached();
    await super.dispose();
  }

  /// Configure the PSPDFConfigurationBuilder before the view controller is created.
  ///
  /// This method is called before the PSPDFViewController is created, allowing
  /// subclasses to customize the configuration.
  ///
  /// The builder allows you to set:
  /// - Page mode (single, double, automatic)
  /// - Scroll direction (horizontal, vertical)
  /// - Page transition (scroll per spread, scroll continuous, curl)
  /// - Thumbnail bar mode
  /// - And many other PSPDFKit configuration options
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void configureView(
  ///   NutrientViewHandle handle,
  ///   PSPDFConfigurationBuilder builder,
  /// ) {
  ///   super.configureView(handle, builder);
  ///
  ///   // Customize configuration
  ///   builder.pageMode = PSPDFPageMode.single;
  ///   builder.scrollDirection = PSPDFScrollDirection.horizontal;
  ///   builder.pageTransition = PSPDFPageTransition.scrollContinuous;
  ///   builder.thumbnailBarMode = PSPDFThumbnailBarMode.none;
  ///   builder.isSearchEnabled = false;
  ///   builder.outlineViewEnabled = false;
  /// }
  /// ```
  void configureView(
    NutrientViewHandle handle,
    PSPDFConfigurationBuilder builder,
  ) {
    debugPrint('[IOSAdapter] Configuring view for: ${handle.viewId}');
    // Subclasses can override to customize the PSPDFConfigurationBuilder
  }

  /// Called when the PSPDFViewController is ready to receive a delegate.
  ///
  /// This is the primary entry point for accessing native iOS SDK functionality.
  /// Set up your delegate implementation here using `implementAsListener`.
  ///
  /// See the class documentation for a complete example.
  Future<void> onViewControllerReady(PSPDFViewController viewController);

  /// Called when the view controller is about to be detached.
  ///
  /// Clean up any native references or listeners here.
  ///
  /// **Example:**
  /// ```dart
  /// @override
  /// Future<void> onViewControllerDetached() async {
  ///   // Clean up references
  ///   _delegate = null;
  ///   _document = null;
  ///   _viewController = null;
  /// }
  /// ```
  Future<void> onViewControllerDetached();
}
