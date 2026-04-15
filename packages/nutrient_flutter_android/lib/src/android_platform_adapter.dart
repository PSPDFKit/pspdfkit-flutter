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

import 'bindings/nutrient_android_sdk_bindings.dart' hide Nutrient;

/// Android platform adapter for Nutrient SDK.
///
/// This is the base adapter class for Android platform. Extend this class to create
/// custom adapters that implement the **adapter-as-controller pattern**.
///
/// ## Adapter-as-Controller Pattern
///
/// The adapter-as-controller pattern allows your adapter to serve as both:
/// 1. A platform adapter (handles Android SDK lifecycle and native access)
/// 2. A controller (provides cross-platform APIs to your app)
///
/// ```
/// AndroidAdapter (this class)
///        ↑ extends
/// YourAndroidAdapter ─────► implements YourController
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
/// class MyAndroidAdapter extends AndroidAdapter implements MyController {
///   PdfDocument? _document;
///   PdfFragment? _fragment;
///   DocumentListener? _documentListener;
///
///   @override
///   Future<void> onPdfFragmentReady(PdfFragment pdfFragment) async {
///     _fragment = pdfFragment;
///     // Set up document listener to receive document when loaded
///     _documentListener = DocumentListener.implement(
///       $DocumentListener(
///         onDocumentLoaded: (doc) => _document = doc,
///         // ... other callbacks
///       ),
///     );
///     pdfFragment.addDocumentListener(_documentListener!);
///   }
///
///   @override
///   Future<int> getPageCount() => Future.value(_document?.getPageCount() ?? 0);
///
///   @override
///   Future<int> getCurrentPageIndex() => Future.value(_fragment?.getPageIndex() ?? 0);
/// }
/// ```
///
/// ## Pre-Build Configuration
///
/// Customize the PdfUiFragmentBuilder before building via [configureFragment]:
///
/// ```dart
/// @override
/// Future<void> configureFragment(
///   NutrientViewHandle handle,
///   PdfUiFragmentBuilder builder,
///   Context context,
/// ) async {
///   await super.configureFragment(handle, builder, context);
///
///   // Create custom configuration
///   final config = PdfActivityConfiguration$Builder(context)
///     .scrollDirection(PageScrollDirection.HORIZONTAL)
///     .layoutMode(PageLayoutMode.SINGLE)
///     .build();
///
///   builder.configuration(config);
/// }
/// ```
///
/// ## Android SDK Access
///
/// Native SDK objects are available in lifecycle callbacks:
///
/// ```dart
/// @override
/// Future<void> onPdfFragmentReady(PdfFragment pdfFragment) async {
///   // Set up document listener to receive native callbacks
///   _documentListener = DocumentListener.implement(
///     $DocumentListener(
///       onDocumentLoaded: (document) {
///         final pageCount = document.getPageCount();
///         debugPrint('Document has $pageCount pages');
///       },
///       onPageChanged: (document, pageIndex) {
///         debugPrint('Page changed to $pageIndex');
///       },
///     ),
///   );
///   pdfFragment.addDocumentListener(_documentListener!);
/// }
/// ```
///
/// ## Available Native Objects
///
/// - [PdfUiFragment] - Main UI component for displaying PDFs
/// - [PdfDocument] - Document model with page management
/// - [PdfFragment] - Lower-level fragment for document display
/// - [Context] - Android context for resource access
///
/// ## Lifecycle Callbacks
///
/// - [configureFragment] - Called before building, for pre-build configuration
/// - [onFragmentAttached] - Called when PdfUiFragment is attached
/// - [onPdfFragmentReady] - Called when PdfFragment is ready for document listeners
/// - [onFragmentDetached] - Called when fragment is detached (cleanup)
///
/// ## JNI Memory Management
///
/// Objects passed to adapter callbacks are managed by the platform.
/// Store references as needed but clean up in [onFragmentDetached].
///
/// ## Registration
///
/// ```dart
/// await Nutrient.initialize(
///   androidLicenseKey: 'YOUR_LICENSE_KEY',
///   androidAdapter: MyAndroidAdapter(),
/// );
/// ```
///
/// ## Documentation
///
/// - Nutrient Android SDK: https://www.nutrient.io/guides/android/
/// - API Reference: https://www.nutrient.io/api/android/kdoc/
abstract class AndroidAdapter extends NutrientController
    implements NutrientPlatformAdapter {
  @override
  TargetPlatform get platform => TargetPlatform.android;

  @override
  Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {
    // Default implementation - can be overridden
  }

  @override
  Future<void> dispose() async {
    await onFragmentDetached();
    await super.dispose();
  }

  /// Configure the PdfUiFragmentBuilder before building the fragment.
  ///
  /// This method is called before the fragment is built, allowing
  /// subclasses to customize the configuration.
  ///
  /// The builder allows you to set:
  /// - Activity configuration (scroll direction, layout mode, fit mode, etc.)
  /// - Document passwords
  /// - Content signatures
  /// - And other PdfUiFragmentBuilder options
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> configureFragment(
  ///   NutrientViewHandle handle,
  ///   PdfUiFragmentBuilder builder,
  ///   Context context,
  /// ) async {
  ///   await super.configureFragment(handle, builder, context);
  ///
  ///   // Create custom configuration
  ///   final config = PdfActivityConfiguration$Builder(context)
  ///     .scrollDirection(PageScrollDirection.HORIZONTAL)
  ///     .layoutMode(PageLayoutMode.SINGLE)
  ///     .fitMode(PageFitMode.FIT_TO_WIDTH)
  ///     .build();
  ///
  ///   builder.configuration(config);
  /// }
  /// ```
  Future<void> configureFragment(
    NutrientViewHandle handle,
    PdfUiFragmentBuilder builder,
    Context context,
  ) async {
    debugPrint('[AndroidAdapter] Configuring fragment for: ${handle.viewId}');
    // Subclasses can override to customize the PdfUiFragmentBuilder
  }

  /// Called when the PdfUiFragment is created and attached.
  ///
  /// This is the primary entry point for accessing native instances.
  /// The fragment reference remains valid until [onFragmentDetached] is called.
  ///
  /// **Parameters:**
  /// - `fragment` - Native PdfUiFragment instance via JNI
  /// - `context` - Android Context for resource access
  ///
  /// **Example:**
  /// ```dart
  /// @override
  /// Future<void> onFragmentAttached(
  ///   PdfUiFragment fragment,
  ///   Context context,
  /// ) async {
  ///   // Access fragment methods through JNI
  ///   final config = fragment.getConfiguration();
  ///   debugPrint('Fragment attached with config');
  /// }
  /// ```
  Future<void> onFragmentAttached(
    PdfUiFragment fragment,
    Context context,
  );

  /// Called when the PdfFragment is ready and attached.
  ///
  /// Use this callback to set up document listeners and access the fragment's APIs.
  /// The document instance can be obtained from the fragment using `pdfFragment.getDocument()`,
  /// or better yet, use a `DocumentListener` to receive the document when it's loaded.
  ///
  /// **Parameters:**
  /// - `pdfFragment` - The PdfFragment for accessing document and fragment APIs
  ///
  /// **Example:**
  /// ```dart
  /// @override
  /// Future<void> onPdfFragmentReady(PdfFragment pdfFragment) async {
  ///   // Set up a document listener to receive callbacks
  ///   _documentListener = DocumentListener.implement(
  ///     $DocumentListener(
  ///       onDocumentLoaded: (document) {
  ///         _document = document;
  ///         final pageCount = document.getPageCount();
  ///         debugPrint('Document loaded: $pageCount pages');
  ///       },
  ///       onPageChanged: (document, pageIndex) {
  ///         debugPrint('Page changed to $pageIndex');
  ///       },
  ///       // ... other callbacks
  ///     ),
  ///   );
  ///   pdfFragment.addDocumentListener(_documentListener!);
  /// }
  /// ```
  Future<void> onPdfFragmentReady(PdfFragment pdfFragment);

  /// Called when the fragment is about to be detached.
  ///
  /// Clean up any native references or listeners here.
  ///
  /// **Example:**
  /// ```dart
  /// @override
  /// Future<void> onFragmentDetached() async {
  ///   // Clean up listeners and resources
  ///   await _eventController.close();
  /// }
  /// ```
  Future<void> onFragmentDetached();
}
