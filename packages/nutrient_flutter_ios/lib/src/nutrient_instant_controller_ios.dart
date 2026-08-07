///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:ffi' as ffi;

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

import 'bindings/nutrient_ios_bindings.dart';
import 'ios_platform_adapter.dart';

/// Default iOS [NutrientInstantController] — the adapter-as-controller for
/// [NutrientInstantViewIOS].
///
/// Extends [IOSAdapter] (so it gets the full cross-platform controller
/// surface plus iOS-only escape hatches) and additionally implements the
/// three Instant sync methods declared by [NutrientInstantController]. These
/// used to live on `NutrientDocumentIOS` (thrown for regular documents,
/// implemented for Instant ones); they now live on the controller so the
/// type system only exposes them where they apply, and there is a single
/// Instant controller type shared by every `NutrientInstantView`.
///
/// Reaches the native `PSPDFInstantViewController` the same way every other
/// iOS-only accessor on [IOSAdapter] does: through [nativeViewController],
/// resolved from the view handle registered by [NutrientInstantViewIOS]. The
/// three sync operations aren't exposed by the generated ffigen bindings
/// (the `Instant` module ships as a closed binary framework, not vendored
/// source), so they're implemented via the hand-written native helpers in
/// `NutrientFFI.mm`/`NutrientFFI.h`:
/// `nutrient_instant_sync_annotations`,
/// `nutrient_instant_set_listen_for_server_changes`, and
/// `nutrient_instant_set_delay_for_syncing_local_changes` — the same helpers
/// [NutrientInstantViewIOS] itself already relies on to build the Instant
/// view controller and (for `listen`) to disable the double-set-on-create
/// path.
///
/// Registered automatically by [NutrientInstantViewIOS] when the caller
/// doesn't supply their own `adapter:`. Subclass this (instead of
/// [IOSAdapter]) when you need both a custom controller *and* the Instant
/// sync methods:
///
/// ```dart
/// class MyInstantAdapter extends IOSInstantController implements MyController {
///   @override
///   Future<int> getPageCount() => document.getPageCount();
/// }
/// ```
class IOSInstantController extends IOSAdapter
    implements NutrientInstantController {
  @override
  Future<void> onViewControllerReady(
    PSPDFViewController viewController,
  ) async {}

  @override
  Future<void> onViewControllerDetached() async {}

  /// Returns the raw native pointer for the currently attached
  /// `PSPDFInstantViewController`, throwing a [StateError] with an
  /// actionable message when no view controller has been registered yet.
  ffi.Pointer<ffi.Void> _requireInstantViewControllerPointer(
    String methodName,
  ) {
    final vc = nativeViewController;
    if (vc == null) {
      throw StateError(
        '$methodName called before the PSPDFInstantViewController was '
        'attached. Wait for onControllerReady before invoking Instant sync '
        'methods.',
      );
    }
    return vc.ref.pointer.cast<ffi.Void>();
  }

  @override
  Future<bool> setDelayForSyncingLocalChanges(double delay) async {
    final vcPointer = _requireInstantViewControllerPointer(
      'setDelayForSyncingLocalChanges',
    );
    nutrient_instant_set_delay_for_syncing_local_changes(vcPointer, delay);
    return true;
  }

  @override
  Future<bool> setListenToServerChanges(bool listen) async {
    final vcPointer = _requireInstantViewControllerPointer(
      'setListenToServerChanges',
    );
    nutrient_instant_set_listen_for_server_changes(vcPointer, listen);
    return true;
  }

  @override
  Future<bool> syncAnnotations() async {
    final vcPointer = _requireInstantViewControllerPointer('syncAnnotations');
    nutrient_instant_sync_annotations(vcPointer);
    return true;
  }
}
