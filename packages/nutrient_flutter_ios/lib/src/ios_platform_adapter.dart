///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as pkg_ffi;
import 'package:flutter/foundation.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    as iface;
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:objective_c/objective_c.dart' as objc;

// Hide the iOS bindings' ffi.Struct `Rect` so it doesn't shadow dart:ui's
// Rect — we use the latter in the public API of the seven view methods.
// `Deprecated` is hidden: the bindings declare an `extension Deprecated on
// NSFileProviderExtension`, which otherwise shadows dart:core's `@Deprecated`.
import 'bindings/nutrient_ios_bindings.dart' hide Rect, Deprecated;
import 'dart:convert' show jsonEncode, utf8;
import 'document/nutrient_document_ios.dart';
import 'events/instant_lifecycle_notifications.dart';
import 'events/ios_nutrient_event.dart';
import 'utils/annotation_tool_ios_mapping.dart';

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

  /// Package-internal access to the view handle for document classes.
  ///
  /// [NutrientDocumentIOS] lives in the same package and needs access to the native
  /// instances registered in the view handle.
  @internal
  NutrientViewHandle? get internalViewHandle => viewHandle;

  // ---------------------------------------------------------------------------
  // iOS-specific event stream
  // ---------------------------------------------------------------------------

  final StreamController<IOSNutrientEvent> _iosEventController =
      StreamController<IOSNutrientEvent>.broadcast();

  /// A broadcast stream of iOS-only Nutrient SDK events.
  ///
  /// Covers native iOS callbacks that have no cross-platform equivalent.
  /// Cross-platform events are available on `controller.events`.
  ///
  /// ```dart
  /// final adapter = controller as IOSAdapter;
  /// adapter.iosEvents.listen((event) {
  ///   switch (event) {
  ///     case IOSViewModeChangedEvent(:final viewMode):
  ///       print('View mode changed to $viewMode');
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  Stream<IOSNutrientEvent> get iosEvents => _iosEventController.stream;

  /// Emits an iOS-only event to all [iosEvents] subscribers.
  ///
  /// Call this from subclasses to push platform-specific events. Silently
  /// no-ops if the controller has been disposed.
  @protected
  void emitIOSEvent(IOSNutrientEvent event) {
    if (!_iosEventController.isClosed) _iosEventController.add(event);
  }

  // The SDK-managed delegate that drives [events] and [iosEvents]. Held to
  // prevent GC and allow detachment in [dispose].
  PSPDFViewControllerDelegate? _sdkDelegate;

  // NSNotificationCenter observer tokens for annotation CRUD events.
  // Held so we can remove them on dispose.
  final List<objc.NSObjectProtocol> _annotationObservers = [];

  // Native callable that the empty-page tap recognizer invokes from the
  // UIKit main thread. NativeCallable.listener marshals the call back onto
  // the Dart isolate's main port (asynchronous) — necessary because the C
  // callback fires from UIKit gesture-recognizer dispatch, not from a
  // Dart-managed thread. Created lazily on first attach, closed in dispose.
  ffi.NativeCallable<
    ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Double, ffi.Double, ffi.Int64)
  >?
  _emptyPageTapCallable;

  ffi.NativeCallable<
    ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Double, ffi.Double, ffi.Int64)
  >
  get _emptyPageTapCallback {
    return _emptyPageTapCallable ??=
        ffi.NativeCallable<
          ffi.Void Function(
            ffi.Pointer<ffi.Void>,
            ffi.Double,
            ffi.Double,
            ffi.Int64,
          )
        >.listener(_handleEmptyPageTap);
  }

  void _handleEmptyPageTap(
    ffi.Pointer<ffi.Void> pageView,
    double x,
    double y,
    int pageIndex,
  ) {
    // Empty-page tap: no annotation context. Coordinates are in the
    // PSPDFPageView's coordinate space (UIKit logical points). Consumers
    // can map them to PDF-space via convertViewPointToPdfPoint if needed.
    emitEvent(PageClickedEvent(pageIndex, point: Offset(x, y)));
  }

  // ---------------------------------------------------------------------------
  // Document
  // ---------------------------------------------------------------------------

  NutrientDocumentInterface? _document;

  /// Most recently opened headless document, tracked so [nativeDocument]
  /// can resolve to it without depending on [_document] (which is only
  /// populated lazily by the cross-platform managers via [document]).
  NutrientDocumentIOS? _lastHeadlessDocument;

  @override
  NutrientDocumentInterface get document => _document ??= createDocument();

  /// Creates the [NutrientDocumentInterface] for this adapter.
  ///
  /// Override to provide a custom document implementation:
  /// ```dart
  /// class MyIOSAdapter extends IOSAdapter {
  ///   @override
  ///   NutrientDocumentInterface createDocument() => MyPdfDocument(this);
  /// }
  /// ```
  @protected
  NutrientDocumentInterface createDocument() => NutrientDocumentIOS(this);

  /// Opens a document without a view (headless access).
  ///
  /// Loads a [PSPDFDocument] directly via FFI and wraps it in a
  /// [NutrientDocumentIOS] in headless mode — no view controller is created.
  /// All managers and document operations resolve to this isolated instance.
  ///
  /// Call [NutrientDocumentInterface.close] when done to release the
  /// [PSPDFDocument] reference.
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
    final url = _createURL(path);
    final PSPDFDocument document;
    if (isImageDocumentPath(path)) {
      // Image documents (JPG/PNG/TIFF/…) open as a single annotatable image
      // page via PSPDFImageDocument. Images aren't encrypted, so the
      // password path doesn't apply.
      document = PSPDFImageDocument.alloc().initWithImageURL(url);
    } else {
      document = PSPDFDocument.alloc().initWithURL(url);
      if (password != null && password.isNotEmpty) {
        // Mirror Android's PdfDocumentLoader behaviour: a wrong password is
        // a hard failure, not a silently-locked document. Without this check
        // callers see getPageCount() == 0 instead of a clear error.
        final unlocked = document.unlockWithPassword(password.toNSString());
        if (!unlocked) {
          throw ArgumentError.value(
            password,
            'password',
            'Failed to unlock PDF — incorrect password.',
          );
        }
      }
    }
    // Pass the URL into the headless document so it stays alive alongside —
    // PSPDFKit's PSPDFSecurityScopedURL keeps an unsafe reference to it.
    final headless = NutrientDocumentIOS.headless(this, document, url);
    // Track on the adapter so [nativeDocument] can resolve to this headless
    // doc without depending on the lazy [_document] field. Consumers may
    // open and discard multiple headless docs; the accessor reflects the
    // most recently opened one.
    _lastHeadlessDocument = headless;
    return headless;
  }

  static int _headlessBytesCounter = 0;

  @override
  Future<NutrientDocumentInterface> openDocumentFromBytes(
    Uint8List bytes, {
    String? password,
  }) async {
    // PSPDFDocument loads from a file URL; persist the bytes to a temp file
    // and open that. A monotonic counter guarantees a unique cache key (and
    // temp file) per call — `identityHashCode` is not collision-free across
    // different byte arrays. The temp file lives in the OS temp dir until
    // `DocumentPathResolver.clearAll()` or the OS reclaims it.
    final path = await DocumentPathResolver.instance.resolveBytes(
      bytes,
      cacheKey: 'ios-headless-bytes-${_headlessBytesCounter++}',
    );
    return openDocument(path, password: password);
  }

  /// Builds an [objc.NSURL] from [path], handling `file://` URIs, plain file
  /// paths, and other URL schemes — mirrors `NutrientViewIOS._createURL`.
  static objc.NSURL _createURL(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme && uri.scheme.isNotEmpty) {
      if (uri.scheme == 'file') {
        return objc.NSURL.fileURLWithPath(uri.toFilePath().toNSString());
      }
      final url = objc.NSURL.URLWithString(path.toNSString());
      if (url != null) return url;
    }
    return objc.NSURL.fileURLWithPath(path.toNSString());
  }

  // ---------------------------------------------------------------------------
  // Annotation processing
  // ---------------------------------------------------------------------------

  /// Processes the annotations of the document at [sourcePath] and writes the
  /// result to [destinationPath], via `PSPDFProcessor`.
  ///
  /// Mirrors the legacy plugin's `PspdfkitFlutterHelper.processAnnotations`:
  /// opens [sourcePath] headlessly into a [PSPDFDocument], builds a
  /// [PSPDFProcessorConfiguration] that changes annotations of [type] (or
  /// every annotation, for [iface.AnnotationType.all]) per [mode], then runs
  /// [PSPDFProcessor] and writes the result to [destinationPath].
  ///
  /// The result is always written to a sibling temp file first and moved over
  /// [destinationPath] only after the write succeeds. This serves three
  /// constraints at once: `writeToFileURL:` throws if a file already exists at
  /// the target; `PSPDFProcessor` reads the source lazily while writing, so it
  /// can never write directly over its own source (the in-place case); and a
  /// pre-existing destination must only be replaced by a complete output —
  /// never deleted up front, so a failed write can't destroy it. The rename is
  /// atomic (same directory ⇒ same filesystem) and matches the legacy helper's
  /// `writableFileURL(withPath:override: true, ...)` semantics.
  ///
  /// On a failed write the generated binding surfaces the `NSError` out-param
  /// as an [objc.NSErrorException] (it is not swallowed); a bare `false`
  /// return without an error is passed through as-is.
  ///
  /// The processing runs in a short-lived worker isolate: `PSPDFProcessor`
  /// rewrites the whole document synchronously on the calling thread, so
  /// running it on the root isolate froze the UI for the whole write. The
  /// closure captures only sendable values (paths and enum constants); all
  /// FFI objects are created inside the worker.
  @override
  Future<bool> processAnnotations(
    String sourcePath,
    iface.AnnotationType type,
    iface.AnnotationProcessingMode mode,
    String destinationPath,
  ) {
    return Isolate.run(
      () => _processAnnotationsSync(sourcePath, type, mode, destinationPath),
    );
  }

  /// Synchronous body of [processAnnotations]. Runs inside a worker isolate —
  /// must stay `static` so the [Isolate.run] closure doesn't capture the
  /// adapter (FFI wrappers and stream controllers aren't sendable).
  static bool _processAnnotationsSync(
    String sourcePath,
    iface.AnnotationType type,
    iface.AnnotationProcessingMode mode,
    String destinationPath,
  ) {
    final sourceUrl = _createURL(sourcePath);
    final document = PSPDFDocument.alloc().initWithURL(sourceUrl);
    if (!document.isValid) {
      throw StateError(
        'IOSAdapter.processAnnotations: PDF document not found or is '
        'invalid at "$sourcePath".',
      );
    }

    final configuration = PSPDFProcessorConfiguration.alloc().initWithDocument(
      document,
    );
    if (configuration == null) {
      throw StateError(
        'IOSAdapter.processAnnotations: could not build a '
        'PSPDFProcessorConfiguration for "$sourcePath".',
      );
    }

    final annotationChange = _annotationChangeFromMode(mode);
    final annotationTypes = _annotationBitmaskFromType(type);
    configuration.modifyAnnotationsOfTypes_change(
      annotationTypes,
      annotationChange: annotationChange,
    );

    final destinationFile = File(destinationPath);
    if (!destinationFile.existsSync()) {
      destinationFile.parent.createSync(recursive: true);
    }
    // Always write to a sibling temp file and move it over the destination
    // after a successful write — see the doc comment for why this covers the
    // in-place, existing-destination, and failed-write cases alike.
    final writeTarget = File('$destinationPath.nutrient-processing.tmp');
    if (writeTarget.existsSync()) {
      writeTarget.deleteSync();
    }

    final processor = PSPDFProcessor.alloc()
        .initWithConfiguration_securityOptions(
          configuration,
          securityOptions: null,
        );
    final bool wrote;
    try {
      wrote = processor.writeToFileURL_error(_createURL(writeTarget.path));
      if (wrote) {
        // Atomically replace the destination with the complete output.
        writeTarget.renameSync(destinationPath);
      }
    } catch (_) {
      // Don't leave a temp file behind on a failed write or rename; the
      // original destination (if any) is untouched.
      if (writeTarget.existsSync()) {
        writeTarget.deleteSync();
      }
      rethrow;
    }
    if (!wrote && writeTarget.existsSync()) {
      writeTarget.deleteSync();
    }
    return wrote;
  }

  /// Maps the cross-platform [iface.AnnotationProcessingMode] to the native
  /// `PSPDFAnnotationChange`, matching the legacy plugin's
  /// `PspdfkitFlutterConverter.annotationChangeFromString` 1:1 by meaning.
  static PSPDFAnnotationChange _annotationChangeFromMode(
    iface.AnnotationProcessingMode mode,
  ) {
    switch (mode) {
      case iface.AnnotationProcessingMode.flatten:
        return PSPDFAnnotationChange.PSPDFAnnotationChangeFlatten;
      case iface.AnnotationProcessingMode.remove:
        return PSPDFAnnotationChange.PSPDFAnnotationChangeRemove;
      case iface.AnnotationProcessingMode.embed:
        return PSPDFAnnotationChange.PSPDFAnnotationChangeEmbed;
      case iface.AnnotationProcessingMode.print:
        return PSPDFAnnotationChange.PSPDFAnnotationChangePrint;
    }
  }

  /// Maps the cross-platform [iface.AnnotationType] to the native
  /// `PSPDFAnnotationType` bitmask (an `NSUInteger`-sized options mask on the
  /// ObjC side; `PSPDFAnnotationTypeAll` is `-1`, i.e. all bits set).
  ///
  /// Matches the legacy plugin's `PspdfkitFlutterConverter.annotationTypeFromString`
  /// (including `image` → `PSPDFAnnotationTypeStamp`, matching Android's same
  /// `image` → `STAMP` fallback, and `none`/`undefined` → no bits set).
  static int _annotationBitmaskFromType(iface.AnnotationType type) {
    switch (type) {
      case iface.AnnotationType.all:
        return PSPDFAnnotationType.PSPDFAnnotationTypeAll;
      case iface.AnnotationType.none:
      case iface.AnnotationType.undefined:
        return PSPDFAnnotationType.PSPDFAnnotationTypeNone;
      case iface.AnnotationType.link:
        return PSPDFAnnotationType.PSPDFAnnotationTypeLink;
      case iface.AnnotationType.highlight:
        return PSPDFAnnotationType.PSPDFAnnotationTypeHighlight;
      case iface.AnnotationType.strikeout:
        return PSPDFAnnotationType.PSPDFAnnotationTypeStrikeOut;
      case iface.AnnotationType.underline:
        return PSPDFAnnotationType.PSPDFAnnotationTypeUnderline;
      case iface.AnnotationType.squiggly:
        return PSPDFAnnotationType.PSPDFAnnotationTypeSquiggly;
      case iface.AnnotationType.freeText:
        return PSPDFAnnotationType.PSPDFAnnotationTypeFreeText;
      case iface.AnnotationType.ink:
        return PSPDFAnnotationType.PSPDFAnnotationTypeInk;
      case iface.AnnotationType.square:
        return PSPDFAnnotationType.PSPDFAnnotationTypeSquare;
      case iface.AnnotationType.circle:
        return PSPDFAnnotationType.PSPDFAnnotationTypeCircle;
      case iface.AnnotationType.line:
        return PSPDFAnnotationType.PSPDFAnnotationTypeLine;
      case iface.AnnotationType.note:
        return PSPDFAnnotationType.PSPDFAnnotationTypeNote;
      case iface.AnnotationType.stamp:
        return PSPDFAnnotationType.PSPDFAnnotationTypeStamp;
      case iface.AnnotationType.caret:
        return PSPDFAnnotationType.PSPDFAnnotationTypeCaret;
      case iface.AnnotationType.media:
        return PSPDFAnnotationType.PSPDFAnnotationTypeRichMedia;
      case iface.AnnotationType.screen:
        return PSPDFAnnotationType.PSPDFAnnotationTypeScreen;
      case iface.AnnotationType.widget:
        return PSPDFAnnotationType.PSPDFAnnotationTypeWidget;
      case iface.AnnotationType.file:
        return PSPDFAnnotationType.PSPDFAnnotationTypeFile;
      case iface.AnnotationType.sound:
        return PSPDFAnnotationType.PSPDFAnnotationTypeSound;
      case iface.AnnotationType.polygon:
        return PSPDFAnnotationType.PSPDFAnnotationTypePolygon;
      case iface.AnnotationType.polyline:
        return PSPDFAnnotationType.PSPDFAnnotationTypePolyLine;
      case iface.AnnotationType.popup:
        return PSPDFAnnotationType.PSPDFAnnotationTypePopup;
      case iface.AnnotationType.watermark:
        return PSPDFAnnotationType.PSPDFAnnotationTypeWatermark;
      case iface.AnnotationType.trapNet:
        return PSPDFAnnotationType.PSPDFAnnotationTypeTrapNet;
      case iface.AnnotationType.type3d:
        return PSPDFAnnotationType.PSPDFAnnotationTypeThreeDimensional;
      case iface.AnnotationType.redact:
        // iOS has no distinct "redaction markup" processor type separate from
        // the Redaction annotation itself — PSPDFAnnotationTypeRedaction
        // covers it (Android's native enum has a dedicated REDACT constant;
        // this is the corresponding iOS bit).
        return PSPDFAnnotationType.PSPDFAnnotationTypeRedaction;
      case iface.AnnotationType.image:
        return PSPDFAnnotationType.PSPDFAnnotationTypeStamp;
    }
  }

  @override
  Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {
    // Get native view controller from the registry
    final viewController =
        handle.getNativeInstance('viewController') as PSPDFViewController?;

    if (viewController != null) {
      // Wire the SDK's events delegate first so that [events] and [iosEvents]
      // start firing as soon as the view controller is ready. If a subclass
      // sets its own delegate inside [onViewControllerReady], the SDK's
      // delegate is replaced and the event streams stop firing — prefer the
      // [events] / [iosEvents] streams over manual delegates.
      _attachSdkDelegate(viewController);
      _attachAnnotationObservers();
      await onViewControllerReady(viewController);
    }
  }

  /// Subscribes to PSPDFKit's annotation NSNotifications so that
  /// AnnotationCreatedEvent / AnnotationUpdatedEvent / AnnotationDeletedEvent
  /// fire on the cross-platform [events] stream. PSPDFKit posts these
  /// notifications on the default NSNotificationCenter whenever the default
  /// PSPDFContainerAnnotationProvider mutates.
  ///
  /// We use `ObjCBlock.listener()` (rather than `.fromFunction()`) for the
  /// observer callbacks. The notifications can fire from any thread (PSPDFKit
  /// often posts them from a background save/sync queue), and listener-style
  /// blocks marshal the call back onto the Dart isolate's main port via
  /// FFI's NativeCallable.listener — without it, Dart crashes with a SIGABRT
  /// inside DLRT_GetFfiCallbackMetadata when the block runs on a non-isolate
  /// thread.
  void _attachAnnotationObservers() {
    // PSPDFAnnotationsAdded: notification.object is an NSArray of new annotations.
    observeNotification(PSPDFAnnotationsAddedNotification, (notification) {
      final json = _annotationsFromNotificationObject(notification);
      if (json.isNotEmpty) emitEvent(AnnotationCreatedEvent(json));
    });

    // PSPDFAnnotationsRemoved: notification.object is an NSArray of removed annotations.
    observeNotification(PSPDFAnnotationsRemovedNotification, (notification) {
      final json = _annotationsFromNotificationObject(notification);
      if (json.isNotEmpty) emitEvent(AnnotationDeletedEvent(json));
    });

    // PSPDFAnnotationChanged: notification.object IS the changed annotation
    // (single annotation, not an array). When the changed annotation is a
    // form widget, also emit FormFieldUpdatedEvent for parity with Android.
    observeNotification(PSPDFAnnotationChangedNotification, (notification) {
      final obj = notification.object;
      if (obj == null) return;
      final annotation = PSPDFAnnotation.as(obj);
      final json = _annotationToJson(annotation);
      if (json != null) emitEvent(AnnotationUpdatedEvent([json]));

      // Form widgets ARE annotations on iOS; detect and re-emit as a
      // form-change event so cross-platform listeners see the same signal
      // they get on Android via OnFormElementUpdatedListener.
      if (json != null && _isFormWidgetAnnotation(annotation)) {
        emitEvent(FormFieldUpdatedEvent(json));
      }
    });
  }

  /// Registers an NSNotificationCenter observer that is automatically
  /// removed on [dispose]. The [handler] runs on the Dart isolate's main
  /// port (the block uses `.listener()` so cross-thread notifications —
  /// PSPDFKit often posts from a background save/sync queue — are marshalled
  /// safely; without that, Dart crashes with SIGABRT inside
  /// DLRT_GetFfiCallbackMetadata).
  ///
  /// Use this from subclasses or extensions to bridge additional native
  /// notifications (form-submission lifecycle, library indexing, document
  /// checkpoint saves, etc.) without manually managing observer tokens.
  ///
  /// ```dart
  /// observeNotification(
  ///   PSPDFFormSubmissionControllerDidFinishLoadingNotification,
  ///   (note) => emitIOSEvent(MyFormSubmitDoneEvent()),
  /// );
  /// ```
  @protected
  void observeNotification(
    DartNSNotificationName name,
    void Function(objc.NSNotification notification) handler,
  ) {
    final center = NSNotificationCenter.getDefaultCenter();
    _annotationObservers.add(
      center.addObserverForName_object_queue_usingBlock(
        name,
        block: ObjCBlock_ffiVoid_NSNotification.listener(handler),
      ),
    );
  }

  /// Bridges the Instant framework's download/sync/auth lifecycle
  /// notifications onto the typed cross-platform events
  /// ([DocumentLoadedEvent], [InstantSyncStartedEvent],
  /// [InstantSyncFinishedEvent], [InstantSyncFailedEvent],
  /// [InstantAuthFinishedEvent], [InstantAuthFailedEvent]).
  ///
  /// Called by `NutrientInstantViewIOS` once the Instant view controller is
  /// attached. Instant posts no notification when the document is already
  /// downloaded locally — that path re-authenticates instead, surfacing
  /// [InstantAuthFinishedEvent]. The failure events carry a fixed message
  /// because `package:objective_c`'s `NSNotification` doesn't expose
  /// `userInfo` (where Instant stores the `NSError`); details land in the
  /// native console log.
  ///
  /// Observers registered here are removed in [detachView] along with the
  /// rest of the notification observers.
  void observeInstantLifecycle({required String documentId}) {
    observeNotification(instantDidFinishDownloadNotification, (_) {
      emitEvent(DocumentLoadedEvent(document));
    });
    observeNotification(instantDidFailDownloadNotification, (_) {
      emitEvent(
        InstantSyncFailedEvent(
          documentId,
          'Document download failed — see native logs',
        ),
      );
    });
    observeNotification(instantDidBeginSyncingNotification, (_) {
      emitEvent(InstantSyncStartedEvent(documentId));
    });
    observeNotification(instantDidFinishSyncingNotification, (_) {
      emitEvent(InstantSyncFinishedEvent(documentId));
    });
    observeNotification(instantDidFailSyncingNotification, (_) {
      emitEvent(
        InstantSyncFailedEvent(documentId, 'Sync failed — see native logs'),
      );
    });
    observeNotification(instantDidFinishReauthenticationNotification, (_) {
      emitEvent(InstantAuthFinishedEvent(documentId, ''));
    });
    observeNotification(instantDidFailReauthenticationNotification, (_) {
      emitEvent(
        InstantAuthFailedEvent(
          documentId,
          'Re-authentication failed — see native logs',
        ),
      );
    });
    observeNotification(instantDidFailAuthenticationNotification, (_) {
      emitEvent(
        InstantAuthFailedEvent(
          documentId,
          'Authentication failed — see native logs',
        ),
      );
    });
  }

  /// True when [annotation] is a form widget. Form widgets ARE annotations
  /// on iOS — `PSPDFFormElement` extends `PSPDFWidgetAnnotation` — so a
  /// `PSPDFAnnotationChanged` notification on a widget also indicates a
  /// form-value change.
  bool _isFormWidgetAnnotation(PSPDFAnnotation annotation) {
    return PSPDFFormElement.isA(annotation) ||
        PSPDFWidgetAnnotation.isA(annotation);
  }

  // PSPDFAnnotationsAdded/Removed notifications carry an NSArray of annotations
  // as the notification's `object` (per binding doc-comment).
  List<String> _annotationsFromNotificationObject(
    objc.NSNotification notification,
  ) {
    final obj = notification.object;
    if (obj == null) return const [];
    return _annotationsArrayToJson(
      objc.NSArray.fromPointer(obj.ref.pointer, retain: true, release: true),
    );
  }

  // Track the most recently displayed page so we only fire PageChangedEvent
  // on actual page index transitions, not on every page-view configuration.
  int? _lastEmittedPageIndex;

  // Implement SDK delegates with `implementAsListener`, never the synchronous
  // `.implement(...)`. A non-void Objective-C delegate method invoked from a
  // non-isolate thread SIGABRTs; `implementAsListener` side-steps that by only
  // accepting **void** callbacks (it dispatches asynchronously and has no
  // return value to marshal back). That makes the safe choice the *only*
  // choice the API allows here — a non-void callback is a compile error, not a
  // runtime crash. See docs/extending-the-platform-adapter.md §2.
  void _attachSdkDelegate(PSPDFViewController viewController) {
    _sdkDelegate = PSPDFViewControllerDelegate$Builder.implementAsListener(
      pdfViewController_didChangeDocument: (vc, doc) {
        emitEvent(DocumentLoadedEvent(document));
      },
      pdfViewController_willBeginDisplayingPageView_forPageAtIndex:
          (vc, pageView, pageIndex) {
            if (_lastEmittedPageIndex != pageIndex) {
              _lastEmittedPageIndex = pageIndex;
              emitEvent(PageChangedEvent(pageIndex));
            }
          },
      pdfViewController_didSaveDocument_error: (vc, doc, err) {
        if (err == null) {
          emitEvent(const DocumentSavedEvent());
        } else {
          emitEvent(DocumentErrorEvent(err.localizedDescription.toString()));
        }
      },
      pdfViewController_didSelectAnnotations_onPageView: (vc, anns, pv) {
        final json = _annotationsArrayToJson(anns);
        emitEvent(AnnotationSelectedEvent(json));
        // Also surface a PageClickedEvent for the cross-platform stream:
        // selecting an annotation IS a page click in our event model.
        if (json.isNotEmpty) {
          emitEvent(PageClickedEvent(0, annotationJson: json.first));
          emitIOSEvent(IOSAnnotationTappedEvent(json.first, 0, Offset.zero));
        }
      },
      pdfViewController_didConfigurePageView_forPageAtIndex:
          (vc, pageView, pageIndex) {
            // Install our empty-page tap recognizer on this page view. The
            // recognizer defers to all of PSPDFKit's existing recognizers via
            // requireGestureRecognizerToFail:, so it only fires when nothing
            // else captures the tap (i.e. taps on empty page area). The
            // helper is idempotent — re-configuring the same page view is a
            // no-op except for refreshing the page index.
            nutrient_install_page_tap(
              pageView.ref.pointer.cast(),
              pageIndex,
              _emptyPageTapCallback.nativeFunction,
            );
          },
      pdfViewController_didDeselectAnnotations_onPageView: (vc, anns, pv) {
        emitEvent(AnnotationDeselectedEvent(_annotationsArrayToJson(anns)));
      },
      pdfViewController_didSelectText_withGlyphs_atRect_onPageView:
          (vc, text, glyphs, rect, pv) {
            emitEvent(TextSelectionChangedEvent(text.toDartString()));
          },
      pdfViewControllerWillDismiss_: (vc) {
        emitIOSEvent(const IOSViewControllerWillDismissEvent());
      },
      pdfViewControllerDidDismiss_: (vc) {
        emitIOSEvent(const IOSViewControllerDidDismissEvent());
      },
      pdfViewController_didChangeViewMode: (vc, mode) {
        emitIOSEvent(IOSViewModeChangedEvent(mode.value));
      },
      pdfViewController_didShowUserInterface: (vc, animated) {
        emitIOSEvent(const IOSUserInterfaceShownEvent());
      },
      pdfViewController_didHideUserInterface: (vc, animated) {
        emitIOSEvent(const IOSUserInterfaceHiddenEvent());
      },
      // didTapOnAnnotation:... returns bool. PSPDFViewControllerDelegate$Builder
      // .implementAsListener can only make VOID methods cross-thread-safe
      // listeners; non-void methods stay as synchronous same-thread dispatch
      // and crash with SIGABRT when invoked from the gesture-recognizer
      // dispatch path off the Dart isolate. We use `didSelectAnnotations`
      // (void, listener-safe) below for cross-platform AnnotationSelectedEvent
      // and IOSAnnotationTappedEvent — those cover the same user interaction
      // (a tap on an annotation) without the threading hazard.
    );
    viewController.delegate = _sdkDelegate;
  }

  /// Serialises a [PSPDFAnnotation] to InstantJSON, never throwing.
  ///
  /// These conversions run inside NSNotification observer blocks marshalled
  /// onto the Dart isolate. `generateInstantJSONWithError()` requires the
  /// annotation to still be attached to a document — for a detached one (most
  /// notably during deletion, where PSPDFKit first *deselects* and then
  /// *removes* the annotation, firing both observers on the now-detached
  /// object) the binding's `NSErrorException.checkErrorPointer` throws an
  /// `NSErrorException`. Left uncaught in the observer block that becomes an
  /// unhandled isolate error and crashes the app (mirroring the JNI
  /// `UndeclaredThrowableException` crash on Android).
  ///
  /// On failure we fall back to a minimal `{ "uuid": … }` payload so listeners
  /// still get a stable identifier instead of a crash. (Delete/deselect
  /// consumers only need to know *which* annotation it was.) Returns `null`
  /// only when even the uuid is unavailable.
  String? _annotationToJson(PSPDFAnnotation annotation) {
    try {
      final data = annotation.generateInstantJSONWithError();
      if (data != null) return utf8.decode(data.toList());
    } catch (e) {
      debugPrint(
        '[IOSAdapter] generateInstantJSON failed: $e — '
        'emitting minimal payload',
      );
    }
    try {
      final uuid = annotation.uuid.toDartString();
      return jsonEncode({'uuid': uuid, 'type': 'pspdfkit/unknown'});
    } catch (_) {
      return null;
    }
  }

  List<String> _annotationsArrayToJson(objc.NSArray annotations) {
    final result = <String>[];
    for (final item in annotations.asDart()) {
      final annotation = PSPDFAnnotation.as(item);
      final json = _annotationToJson(annotation);
      if (json != null) result.add(json);
    }
    return result;
  }

  @override
  Future<void> dispose() async {
    await detachView();
    await _iosEventController.close();
    await super.dispose();
  }

  /// Called by [NutrientViewIOS] when its platform view is being torn down.
  ///
  /// Performs per-view cleanup — closes the view-attached document and
  /// invokes [onViewControllerDetached] — without permanently disposing
  /// the underlying [NutrientController]. Use this instead of [dispose] when
  /// the adapter is registered globally (via `Nutrient.initialize`) and
  /// must remain usable for subsequent views.
  Future<void> detachView() async {
    // Run per-view cleanup at most once per attach. Capture-and-null the
    // document synchronously (before the first await) so a concurrent second
    // call can't double-close it. See [consumeViewAttached].
    if (!consumeViewAttached()) return;
    final document = _document;
    _document = null;
    await document?.close();
    await onViewControllerDetached();
    _sdkDelegate = null;
    _detachAnnotationObservers();
    _emptyPageTapCallable?.close();
    _emptyPageTapCallable = null;
    _toolbarTapCallable?.close();
    _toolbarTapCallable = null;
    _toolbarItemCallbacks.clear();
  }

  void _detachAnnotationObservers() {
    if (_annotationObservers.isEmpty) return;
    final center = NSNotificationCenter.getDefaultCenter();
    for (final token in _annotationObservers) {
      center.removeObserver(token);
    }
    _annotationObservers.clear();
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

  // ---------------------------------------------------------------------------
  // Typed native accessors (raw escape hatch)
  //
  // These return the underlying iOS SDK FFI objects directly — no wrapping,
  // no opinion. Use them to reach any iOS-only capability that isn't
  // exposed on the cross-platform [NutrientController] / managers (forms,
  // signatures, advanced annotation providers, etc.).
  //
  // The accessors return `null` until the platform view has registered the
  // corresponding native instance; safe to call eagerly with `?.` chains.
  // ---------------------------------------------------------------------------

  /// The native [PSPDFViewController] FFI instance, or `null` if the
  /// platform view hasn't yet registered one.
  PSPDFViewController? get nativeViewController =>
      viewHandle?.getNativeInstance('viewController') as PSPDFViewController?;

  /// The native [PSPDFDocument] FFI instance, or `null` if no document is
  /// loaded yet.
  ///
  /// Resolution order:
  /// 1. The view-attached document registered by `NutrientViewIOS` (when a
  ///    platform view is mounted) — this is the user-visible document.
  /// 2. The most recently opened headless document from [openDocument]
  ///    (when no view is attached, or when the consumer is operating
  ///    purely on a headless document).
  ///
  /// ```dart
  /// final adapter = controller as IOSAdapter;
  /// final field = adapter.nativeDocument?.formParser?
  ///     .findFieldWithFullFieldName('First Name'.toNSString());
  /// ```
  PSPDFDocument? get nativeDocument {
    final registered =
        viewHandle?.getNativeInstance('document') as PSPDFDocument?;
    if (registered != null) return registered;
    return _lastHeadlessDocument?.maybeDocument;
  }

  /// Convenience accessor for the [PSPDFFormParser] on the active document
  /// (the `native*` raw escape hatch, consistent with [nativeViewController] /
  /// [nativeDocument]).
  ///
  /// Returns `null` until a document is loaded. Once available, exposes the
  /// full iOS form API — `formFields`, `findFieldWithFullFieldName`,
  /// `resetForm_withFlags_error`, `removeFormFields_error`, etc.
  ///
  /// ```dart
  /// adapter.nativeFormParser?.resetForm_withFlags_error(null, 0, errorPtr);
  /// ```
  PSPDFFormParser? get nativeFormParser => nativeDocument?.formParser;

  /// The `UINavigationController` that hosts the [PSPDFViewController], or `null`
  /// if the platform view hasn't registered one.
  ///
  /// PSPDFKit owns the navigation bar, so reach for this only for low-level
  /// navigation-bar customization — [nativeViewController] is the root for
  /// everything else. (PSPDFKit may rebuild the bar on mode transitions; see
  /// `setMainToolbarItems` for the re-appliable custom-button path.)
  UINavigationController? get nativeNavigationController =>
      viewHandle?.getNativeInstance('navigationController')
          as UINavigationController?;

  /// Deprecated alias for [nativeFormParser].
  ///
  /// Renamed for consistency with the `native*` accessor convention used by
  /// every other raw-native getter ([nativeViewController], [nativeDocument]).
  @Deprecated('Use nativeFormParser instead.')
  PSPDFFormParser? get formParser => nativeFormParser;

  PSPDFViewController _requireViewController(String methodName) {
    final vc = nativeViewController;
    if (vc == null) {
      throw StateError(
        '$methodName called before the PSPDFViewController was attached. '
        'Wait for onViewControllerReady before invoking view-controller '
        'methods.',
      );
    }
    return vc;
  }

  // ---------------------------------------------------------------------------
  // Viewport and zoom
  // ---------------------------------------------------------------------------

  @override
  Future<Rect> getVisibleRect(int pageIndex) async {
    final vc = _requireViewController('getVisibleRect');
    final viewState = vc.viewState;
    if (viewState == null) {
      // No view state yet — viewer is still settling. Return an empty rect
      // rather than fabricating coordinates.
      return Rect.zero;
    }
    final cgRect = viewState.viewPort;
    return Rect.fromLTWH(
      cgRect.origin.x.toDouble(),
      cgRect.origin.y.toDouble(),
      cgRect.size.width.toDouble(),
      cgRect.size.height.toDouble(),
    );
  }

  @override
  Future<void> zoomToRect(int pageIndex, Rect rect) async {
    final vc = _requireViewController('zoomToRect');
    final docVC = vc.documentViewController;
    final cgRect = _cgRectFromFlutterRect(rect);
    docVC.zoomToPDFRect_forPageAtIndex_animated(
      cgRect,
      pageIndex: pageIndex,
      animated: false,
    );
  }

  @override
  Future<double> getZoomScale(int pageIndex) async {
    final vc = _requireViewController('getZoomScale');
    final pageView = vc.pageViewForPageAtIndex(pageIndex);
    if (pageView == null) {
      // Page isn't currently loaded — common when the index is outside
      // the viewport. Returning a zero scale is misleading; fall back to
      // 1.0 (the PSPDFKit DEFAULT_ZOOM constant).
      return 1.0;
    }
    return pageView.PDFScale.toDouble();
  }

  // ---------------------------------------------------------------------------
  // Annotation creation mode
  // ---------------------------------------------------------------------------

  @override
  Future<bool?> enterAnnotationCreationMode([
    iface.AnnotationTool? annotationTool,
  ]) async {
    final vc = _requireViewController('enterAnnotationCreationMode');
    final tool = annotationTool ?? iface.AnnotationTool.inkPen;
    final stateString = iosAnnotationStringFor(tool);
    if (stateString == null) {
      // No iOS equivalent for this tool.
      return false;
    }
    // Set the state *and* variant together. Setting `state` on its own
    // resets the variant to nil, which leaves variant-backed tools (the
    // pen / highlighter / magic Ink tools, arrow) un-highlighted in the
    // annotation toolbar — the toolbar matches buttons by (state, variant).
    // `setState(_:variant:)` (vs `toggleState`) keeps enter-only semantics:
    // no "exit if already in this mode" toggle.
    vc.annotationStateManager.setState_variant(
      stateString,
      variant: iosAnnotationVariantFor(tool),
    );
    return true;
  }

  @override
  Future<bool?> exitAnnotationCreationMode() async {
    final vc = _requireViewController('exitAnnotationCreationMode');
    // Setting state to nil exits annotation creation mode.
    vc.annotationStateManager.state = null;
    return true;
  }

  // ---------------------------------------------------------------------------
  // Toolbar customization
  // ---------------------------------------------------------------------------

  /// Tapped item index → Dart `onPressed`. Rebuilt on every
  /// [setMainToolbarItems] call; the native side reports the tapped item by its
  /// position (index) rather than its id so the value stays valid across the
  /// asynchronous `NativeCallable.listener` hop.
  final Map<int, VoidCallback> _toolbarItemCallbacks = {};

  // Native callable invoked from the UIKit main thread when a custom bar button
  // is tapped. `.listener` marshals the call back onto the Dart isolate.
  // Created lazily; closed in [detachView].
  ffi.NativeCallable<ffi.Void Function(ffi.Int64)>? _toolbarTapCallable;

  ffi.NativeCallable<ffi.Void Function(ffi.Int64)> get _toolbarTapCallback {
    return _toolbarTapCallable ??=
        ffi.NativeCallable<ffi.Void Function(ffi.Int64)>.listener(
          _handleToolbarTap,
        );
  }

  void _handleToolbarTap(int index) {
    _toolbarItemCallbacks[index]?.call();
  }

  /// Replaces the navigation bar's custom buttons with the [CustomToolbarItem]s
  /// in [items]. Built-in items are ignored on iOS (reordering the native
  /// built-ins is a web-only capability — see the parity matrix on
  /// [ToolbarItem]). Re-callable any time to add, remove, enable, or disable
  /// custom buttons.
  ///
  /// Each custom item becomes a `UIBarButtonItem` on the view controller's
  /// navigation item; taps are routed back to the matching
  /// [CustomToolbarItem.onPressed].
  ///
  /// Note: PSPDFKit owns the navigation bar and may rebuild
  /// `rightBarButtonItems` when it swaps the toolbar for a different mode
  /// (e.g. entering/leaving the thumbnail or document-editor view), which can
  /// drop the custom buttons. Since this call is re-appliable, re-invoke it
  /// after such a transition to restore them.
  @override
  Future<void> setMainToolbarItems(List<ToolbarItem> items) async {
    final vc = nativeViewController;
    if (vc == null) return;

    final custom = items.whereType<CustomToolbarItem>().toList();
    _toolbarItemCallbacks.clear();

    final payload = <Map<String, dynamic>>[];
    for (var i = 0; i < custom.length; i++) {
      final item = custom[i];
      if (item.onPressed != null) _toolbarItemCallbacks[i] = item.onPressed!;
      payload.add({
        'id': item.id,
        if (item.title != null) 'title': item.title,
        if (item.disabled != null) 'disabled': item.disabled,
      });
    }

    final jsonPtr = _toCString(jsonEncode(payload));
    try {
      nutrient_set_main_toolbar_items(
        vc.ref.pointer.cast<ffi.Void>(),
        jsonPtr,
        _toolbarTapCallback.nativeFunction,
      );
    } finally {
      pkg_ffi.calloc.free(jsonPtr);
    }
  }

  ffi.Pointer<ffi.Char> _toCString(String s) {
    final bytes = utf8.encode(s);
    final ptr = pkg_ffi.calloc<ffi.Char>(bytes.length + 1);
    for (var i = 0; i < bytes.length; i++) {
      ptr[i] = bytes[i];
    }
    ptr[bytes.length] = 0;
    return ptr;
  }

  // ---------------------------------------------------------------------------
  // Annotation creation toolbar customization
  // ---------------------------------------------------------------------------

  /// Replaces the annotation **creation** toolbar (the tool picker) with the
  /// tools/groups in [items], by building a `PSPDFAnnotationToolbarConfiguration`
  /// and setting it on `annotationToolbarController.annotationToolbar`. Pure Dart
  /// FFI — the group/item/configuration initializers are usable from the
  /// bindings (no C glue, unlike the main toolbar). The configuration survives
  /// view-mode changes, so no re-application hook is needed.
  ///
  /// Tools with no iOS equivalent (e.g. `freeTextCallOut`, `widget`) are skipped.
  @override
  Future<void> setAnnotationToolbarItems(
    List<AnnotationToolbarItem> items,
  ) async {
    final vc = nativeViewController;
    if (vc == null) return;

    final groups = <PSPDFAnnotationGroup>[];
    for (final item in items) {
      final group = _annotationGroupFor(item);
      if (group != null) groups.add(group);
    }
    if (groups.isEmpty) return;

    final groupsArray = objc.NSMutableArray.array();
    for (final group in groups) {
      groupsArray.addObject(group);
    }

    final config = PSPDFAnnotationToolbarConfiguration.alloc()
        .initWithAnnotationGroups(groupsArray);
    final configs = objc.NSMutableArray.array();
    configs.addObject(config);

    vc.annotationToolbarController.annotationToolbar.configurations = configs;
  }

  /// Builds a `PSPDFAnnotationGroup` for a creation-toolbar [item] — a single
  /// tool becomes a one-item group; an [AnnotationToolGroup] becomes a
  /// multi-item group whose default-shown item is its `representative`. Returns
  /// `null` when none of the tools map to an iOS annotation type.
  PSPDFAnnotationGroup? _annotationGroupFor(AnnotationToolbarItem item) {
    switch (item) {
      case AnnotationToolGroup(:final representative, :final items):
        final groupItems = <PSPDFAnnotationGroupItem>[];
        for (final tool in items) {
          final groupItem = _annotationGroupItemFor(tool);
          if (groupItem != null) groupItems.add(groupItem);
        }
        if (groupItems.isEmpty) return null;
        final itemsArray = objc.NSMutableArray.array();
        for (final groupItem in groupItems) {
          itemsArray.addObject(groupItem);
        }
        // The collapsed group shows `representative`; map it to the choice index.
        final choice = items.indexOf(representative);
        if (choice > 0 && choice < groupItems.length) {
          return PSPDFAnnotationGroup.groupWithItems_choice(
            itemsArray,
            choice: choice,
          );
        }
        return PSPDFAnnotationGroup.groupWithItems(itemsArray);
      case AnnotationTool tool:
        final groupItem = _annotationGroupItemFor(tool);
        if (groupItem == null) return null;
        final itemsArray = objc.NSMutableArray.array();
        itemsArray.addObject(groupItem);
        return PSPDFAnnotationGroup.groupWithItems(itemsArray);
    }
  }

  /// Builds a `PSPDFAnnotationGroupItem` for [tool] (type + optional variant),
  /// or `null` when the tool has no iOS `PSPDFAnnotationString` equivalent.
  PSPDFAnnotationGroupItem? _annotationGroupItemFor(AnnotationTool tool) {
    final type = iosAnnotationStringFor(tool);
    if (type == null) return null;
    final variant = iosAnnotationVariantFor(tool);
    if (variant != null) {
      return PSPDFAnnotationGroupItem.itemWithType_variant(
        type,
        variant: variant,
      );
    }
    return PSPDFAnnotationGroupItem.itemWithType(type);
  }

  // ---------------------------------------------------------------------------
  // Annotation editing (style inspector) customization
  // ---------------------------------------------------------------------------

  /// Sets which **style** controls (color, opacity, line width, blend mode,
  /// font, …) appear when an annotation is selected, by configuring
  /// `propertiesForAnnotations` and applying it at runtime via
  /// `updateConfigurationWithoutReloadingWithBuilder` (pure Dart FFI).
  ///
  /// The `note` / `delete` *menu actions* are not style properties — those live
  /// on the selected-annotation contextual menu (a non-void delegate that needs
  /// native glue) and are not customizable from Dart yet, so they're skipped on
  /// iOS. Re-callable; no-op until the view controller is ready.
  @override
  Future<void> setAnnotationEditingToolbarItems(
    List<AnnotationEditingItem> items,
  ) async {
    final vc = nativeViewController;
    if (vc == null) return;

    final styleKeys = <objc.NSString>[];
    for (final item in items) {
      final key = _iosStyleKeyFor(item);
      if (key != null) styleKeys.add(key);
    }
    if (styleKeys.isEmpty) return;

    // propertiesForAnnotations maps an annotation type → an array-of-arrays of
    // style keys (each inner array is one inspector section). We use a single
    // section with the configured keys, applied to the common editable types.
    final keysArray = objc.NSMutableArray.array();
    for (final key in styleKeys) {
      keysArray.addObject(key);
    }
    final sections = objc.NSMutableArray.array();
    sections.addObject(keysArray);

    final dict = objc.NSMutableDictionary.dictionary();
    for (final type in _iosEditableAnnotationTypes()) {
      dict.setObject(sections, forKey: type);
    }

    final block = ObjCBlock_ffiVoid_PSPDFConfigurationBuilder.fromFunction((
      PSPDFConfigurationBuilder builder,
    ) {
      builder.propertiesForAnnotations = dict;
    });
    vc.updateConfigurationWithoutReloadingWithBuilder(block);
  }

  /// Maps an [AnnotationEditingItem] to its iOS `PSPDFAnnotationStyleKey`, or
  /// `null` when it's a menu action (note/delete) rather than a style property.
  objc.NSString? _iosStyleKeyFor(AnnotationEditingItem item) {
    switch (item) {
      case AnnotationEditingItem.color:
        return PSPDFAnnotationStyleKeyColor;
      case AnnotationEditingItem.fillColor:
        return PSPDFAnnotationStyleKeyFillColor;
      case AnnotationEditingItem.outlineColor:
        return PSPDFAnnotationStyleKeyOutlineColor;
      case AnnotationEditingItem.opacity:
        return PSPDFAnnotationStyleKeyAlpha;
      case AnnotationEditingItem.thickness:
        return PSPDFAnnotationStyleKeyLineWidth;
      case AnnotationEditingItem.blendMode:
        return PSPDFAnnotationStyleKeyBlendMode;
      case AnnotationEditingItem.font:
        return PSPDFAnnotationStyleKeyFontName;
      case AnnotationEditingItem.borderStyle:
        return PSPDFAnnotationStyleKeyDashArray;
      case AnnotationEditingItem.lineEnds:
        return PSPDFAnnotationStyleKeyLineEnd;
      case AnnotationEditingItem.note:
      case AnnotationEditingItem.delete:
        return null;
    }
  }

  /// The common annotation types the editing-style configuration is applied to.
  List<objc.NSString> _iosEditableAnnotationTypes() => [
    PSPDFAnnotationStringInk,
    PSPDFAnnotationStringFreeText,
    PSPDFAnnotationStringLine,
    PSPDFAnnotationStringSquare,
    PSPDFAnnotationStringCircle,
    PSPDFAnnotationStringPolygon,
    PSPDFAnnotationStringPolyLine,
    PSPDFAnnotationStringHighlight,
    PSPDFAnnotationStringUnderline,
    PSPDFAnnotationStringStrikeOut,
    PSPDFAnnotationStringSquiggly,
    PSPDFAnnotationStringStamp,
    PSPDFAnnotationStringNote,
    PSPDFAnnotationStringSignature,
  ];

  // ---------------------------------------------------------------------------
  // Coordinate conversion
  // ---------------------------------------------------------------------------

  @override
  Future<Offset> convertViewPointToPdfPoint(int pageIndex, Offset point) async {
    final vc = _requireViewController('convertViewPointToPdfPoint');
    final pageView = vc.pageViewForPageAtIndex(pageIndex);
    if (pageView == null) {
      throw StateError(
        'convertViewPointToPdfPoint: page $pageIndex is not currently '
        'loaded in the viewer.',
      );
    }
    // Use UIKit's UICoordinateSpace conversion via the page view's
    // pdfCoordinateSpace, matching the legacy iOS plugin's behaviour.
    final viewPoint = _cgPoint(point);
    final pdfPoint = pageView.convertPoint_toCoordinateSpace(
      viewPoint,
      coordinateSpace: pageView.pdfCoordinateSpace,
    );
    return Offset(pdfPoint.x.toDouble(), pdfPoint.y.toDouble());
  }

  @override
  Future<Offset> convertPdfPointToViewPoint(int pageIndex, Offset point) async {
    final vc = _requireViewController('convertPdfPointToViewPoint');
    final pageView = vc.pageViewForPageAtIndex(pageIndex);
    if (pageView == null) {
      throw StateError(
        'convertPdfPointToViewPoint: page $pageIndex is not currently '
        'loaded in the viewer.',
      );
    }
    final pdfPoint = _cgPoint(point);
    final viewPoint = pageView.convertPoint_fromCoordinateSpace(
      pdfPoint,
      coordinateSpace: pageView.pdfCoordinateSpace,
    );
    return Offset(viewPoint.x.toDouble(), viewPoint.y.toDouble());
  }
}

/// The SDK's built-in default iOS adapter — the no-customization viewer.
///
/// [IOSAdapter] is abstract (it declares the [onViewControllerReady] /
/// [onViewControllerDetached] lifecycle hooks), so this default supplies empty
/// implementations to give you the full default iOS viewer. This is what
/// [Nutrient.initialize] registers when the caller doesn't pass an `iosAdapter`.
/// Subclass [IOSAdapter] yourself if you need to handle those hooks.
class DefaultIOSAdapter extends IOSAdapter {
  @override
  Future<void> onViewControllerReady(
    PSPDFViewController viewController,
  ) async {}

  @override
  Future<void> onViewControllerDetached() async {}
}

objc.CGPoint _cgPoint(Offset offset) {
  // CGPoint is an ffi.Struct, which has no public generative constructor;
  // allocate via calloc and write the fields, mirroring the pattern
  // jnigen/ffigen uses for return-by-value structs in nutrient_ios_bindings.
  final $ptr = pkg_ffi.calloc<objc.CGPoint>();
  final $finalizable = $ptr.cast<ffi.Uint8>().asTypedList(
    ffi.sizeOf<objc.CGPoint>(),
    finalizer: pkg_ffi.calloc.nativeFree,
  );
  final cgPoint = ffi.Struct.create<objc.CGPoint>($finalizable);
  cgPoint.x = offset.dx;
  cgPoint.y = offset.dy;
  return cgPoint;
}

objc.CGRect _cgRectFromFlutterRect(Rect rect) {
  final $ptr = pkg_ffi.calloc<objc.CGRect>();
  final $finalizable = $ptr.cast<ffi.Uint8>().asTypedList(
    ffi.sizeOf<objc.CGRect>(),
    finalizer: pkg_ffi.calloc.nativeFree,
  );
  final cgRect = ffi.Struct.create<objc.CGRect>($finalizable);
  cgRect.origin.x = rect.left;
  cgRect.origin.y = rect.top;
  cgRect.size.width = rect.width;
  cgRect.size.height = rect.height;
  return cgRect;
}
