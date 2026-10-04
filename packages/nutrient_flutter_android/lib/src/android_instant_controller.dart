///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import 'android_platform_adapter.dart';
import 'bindings/nutrient_android_sdk_bindings.dart' hide Nutrient;

/// Default Android [NutrientInstantController] — the adapter-as-controller
/// for [NutrientInstantViewAndroid].
///
/// Extends [AndroidAdapter] (so it gets the full cross-platform controller
/// surface plus Android-only escape hatches) and additionally implements the
/// three Instant sync methods declared by [NutrientInstantController]. These
/// used to live on `NutrientDocumentAndroid`/`InstantPdfDocumentAndroid`
/// (thrown for regular documents, implemented for Instant ones); they now
/// live on the controller so the type system only exposes them where they
/// apply, and there is a single Instant controller type shared by every
/// `NutrientInstantView`.
///
/// Reaches the native `InstantPdfDocument` the same way
/// `InstantPdfDocumentAndroid` used to: through the view handle's registered
/// `pdfDocument` native instance, reinterpret-cast via JNI.
///
/// Registered automatically by [NutrientInstantViewAndroid] when the caller
/// doesn't supply their own `adapter:`. Subclass this (instead of
/// [AndroidAdapter]) when you need both a custom controller *and* the Instant
/// sync methods:
///
/// ```dart
/// class MyInstantAdapter extends AndroidInstantController implements MyController {
///   @override
///   Future<int> getPageCount() => document.getPageCount();
/// }
/// ```
class AndroidInstantController extends AndroidAdapter
    implements NutrientInstantController {
  InstantPdfDocument _requireInstantDocument() {
    final handle = internalViewHandle;
    if (handle == null) {
      throw StateError(
          'AndroidInstantController: no view handle — is the controller ready?');
    }
    // Prefer the pre-registered document; fall back to the fragment's current
    // document. An Instant document downloads asynchronously *after* the
    // fragment is ready, so `pdfFragment.document` is often null when the view
    // first registers native instances — leaving `pdfDocument` unregistered.
    // By the time a sync method is called the document has loaded, so read it
    // live from the (always-registered) fragment.
    var doc = handle.getNativeInstance('pdfDocument') as PdfDocument?;
    if (doc == null) {
      final fragment = handle.getNativeInstance('pdfFragment') as PdfFragment?;
      doc = fragment?.document;
    }
    if (doc == null) {
      throw StateError(
        'AndroidInstantController: no Instant document available yet — the '
        'document is still loading. Wait for the DocumentLoadedEvent on '
        'controller.events before calling sync methods.',
      );
    }
    // Cast the PdfDocument JNI object to InstantPdfDocument.
    // This is a JNI reinterpret-cast — it will throw at runtime if the
    // underlying Java object is not an InstantPdfDocument.
    try {
      return doc.as(InstantPdfDocument.type);
    } catch (_) {
      throw StateError(
        'AndroidInstantController: pdfDocument is not an InstantPdfDocument. '
        'Ensure the document was loaded via NutrientInstantView.',
      );
    }
  }

  @override
  Future<bool> setDelayForSyncingLocalChanges(double delay) async {
    // InstantPdfDocument.setDelayForSyncingLocalChanges takes milliseconds as long.
    _requireInstantDocument()
        .setDelayForSyncingLocalChanges((delay * 1000).round());
    return true;
  }

  @override
  Future<bool> setListenToServerChanges(bool listen) async {
    // The 11.5 Android SDK renamed setListenToServerChanges(boolean) to
    // setListeningToServerChanges(boolean).
    _requireInstantDocument().setListeningToServerChanges(listen);
    return true;
  }

  @override
  Future<bool> syncAnnotations() async {
    _requireInstantDocument().syncAnnotations();
    return true;
  }
}
