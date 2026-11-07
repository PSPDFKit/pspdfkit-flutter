///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import '../nutrient_controller.dart';

/// Controller for an Instant (real-time collaboration) document, surfaced by
/// [NutrientInstantView.onControllerReady].
///
/// Extends the cross-platform [NutrientController] surface with the sync
/// controls that are only meaningful for Instant documents. These used to live
/// on `NutrientDocumentInterface` where they threw for non-Instant documents;
/// they now live here so the type system only exposes them where they apply.
///
/// Declared as `implements NutrientController` (the same shape as custom
/// controller interfaces in the adapter architecture) so it satisfies
/// `Nutrient.buildAdapter<T extends NutrientController>` — the platform
/// implementations (`AndroidInstantController`, `IOSInstantController`) extend
/// their platform adapters, which already provide the controller surface.
///
/// ```dart
/// NutrientInstantView(
///   serverUrl: url,
///   jwt: jwt,
///   onControllerReady: (controller) async {
///     await controller.setDelayForSyncingLocalChanges(2);
///     await controller.setListenToServerChanges(true);
///     await controller.syncAnnotations();
///   },
/// )
/// ```
///
/// Supported on Android and iOS. On Web, Instant sync is configured at load
/// time, so these methods throw [UnsupportedError].
abstract class NutrientInstantController implements NutrientController {
  /// Sets the delay (in seconds) before local changes are synced to the
  /// server.
  Future<bool> setDelayForSyncingLocalChanges(double delay);

  /// Enables or disables listening for changes made on the server.
  Future<bool> setListenToServerChanges(bool listen);

  /// Triggers an immediate annotation sync with the Instant server.
  Future<bool> syncAnnotations();
}
