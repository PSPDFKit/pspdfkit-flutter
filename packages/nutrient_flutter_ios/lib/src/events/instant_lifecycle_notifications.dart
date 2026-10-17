///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Notification-name constants exported by the Instant framework, declared
/// directly via FFI. A full generated `nutrient_instant_ios_bindings.dart`
/// would redeclare the PSPDFKit core types and clash with
/// `nutrient_ios_bindings.dart` in the adapter, so it was never consumed and
/// has since been removed (coverage report Track 4.2) — the Instant path is
/// driven by hand-written FFI (`NutrientFFI.mm`) plus these constants instead.
///
/// Used by `IOSAdapter.observeInstantLifecycle` to bridge the Instant
/// download/sync/auth lifecycle onto the typed cross-platform
/// `InstantSync*` / `InstantAuth*` events.
library;

import 'dart:ffi' as ffi;

import 'package:objective_c/objective_c.dart' as objc;

@ffi.Native<ffi.Pointer<objc.ObjCObjectImpl>>(
  symbol: 'PSPDFInstantDidFinishDownloadNotification',
)
external ffi.Pointer<objc.ObjCObjectImpl> _instantDidFinishDownload;

/// Posted by Instant when the initial document download completes.
objc.NSString get instantDidFinishDownloadNotification =>
    objc.NSString.fromPointer(
      _instantDidFinishDownload,
      retain: true,
      release: true,
    );

@ffi.Native<ffi.Pointer<objc.ObjCObjectImpl>>(
  symbol: 'PSPDFInstantDidFailDownloadNotification',
)
external ffi.Pointer<objc.ObjCObjectImpl> _instantDidFailDownload;

/// Posted by Instant when the initial document download fails.
objc.NSString get instantDidFailDownloadNotification =>
    objc.NSString.fromPointer(
      _instantDidFailDownload,
      retain: true,
      release: true,
    );

@ffi.Native<ffi.Pointer<objc.ObjCObjectImpl>>(
  symbol: 'PSPDFInstantDidBeginSyncingNotification',
)
external ffi.Pointer<objc.ObjCObjectImpl> _instantDidBeginSyncing;

/// Posted by Instant when a sync cycle starts.
objc.NSString get instantDidBeginSyncingNotification =>
    objc.NSString.fromPointer(
      _instantDidBeginSyncing,
      retain: true,
      release: true,
    );

@ffi.Native<ffi.Pointer<objc.ObjCObjectImpl>>(
  symbol: 'PSPDFInstantDidFinishSyncingNotification',
)
external ffi.Pointer<objc.ObjCObjectImpl> _instantDidFinishSyncing;

/// Posted by Instant when a sync cycle completes successfully.
objc.NSString get instantDidFinishSyncingNotification =>
    objc.NSString.fromPointer(
      _instantDidFinishSyncing,
      retain: true,
      release: true,
    );

@ffi.Native<ffi.Pointer<objc.ObjCObjectImpl>>(
  symbol: 'PSPDFInstantDidFailSyncingNotification',
)
external ffi.Pointer<objc.ObjCObjectImpl> _instantDidFailSyncing;

/// Posted by Instant when a sync cycle fails.
objc.NSString get instantDidFailSyncingNotification =>
    objc.NSString.fromPointer(
      _instantDidFailSyncing,
      retain: true,
      release: true,
    );

@ffi.Native<ffi.Pointer<objc.ObjCObjectImpl>>(
  symbol: 'PSPDFInstantDidFinishReauthenticationNotification',
)
external ffi.Pointer<objc.ObjCObjectImpl> _instantDidFinishReauthentication;

/// Posted by Instant when JWT re-authentication completes successfully.
objc.NSString get instantDidFinishReauthenticationNotification =>
    objc.NSString.fromPointer(
      _instantDidFinishReauthentication,
      retain: true,
      release: true,
    );

@ffi.Native<ffi.Pointer<objc.ObjCObjectImpl>>(
  symbol: 'PSPDFInstantDidFailReauthenticationNotification',
)
external ffi.Pointer<objc.ObjCObjectImpl> _instantDidFailReauthentication;

/// Posted by Instant when JWT re-authentication fails.
objc.NSString get instantDidFailReauthenticationNotification =>
    objc.NSString.fromPointer(
      _instantDidFailReauthentication,
      retain: true,
      release: true,
    );

@ffi.Native<ffi.Pointer<objc.ObjCObjectImpl>>(
  symbol: 'PSPDFInstantDidFailAuthenticationNotification',
)
external ffi.Pointer<objc.ObjCObjectImpl> _instantDidFailAuthentication;

/// Posted by Instant when server authentication fails.
objc.NSString get instantDidFailAuthenticationNotification =>
    objc.NSString.fromPointer(
      _instantDidFailAuthentication,
      retain: true,
      release: true,
    );
