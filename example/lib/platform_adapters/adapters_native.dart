///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Native platform implementation for example adapters.
///
/// This file is used on Android and iOS platforms where dart.library.io is
/// available, providing access to JNI (Android) and FFI (iOS) bindings.

import 'dart:io';

// ignore: depend_on_referenced_packages

import 'android_adapter.dart';
import 'example_adapter_controller.dart';
import 'ios_adapter.dart';

/// Creates an example adapter for the current native platform.
///
/// On Android, creates an [ExampleAndroidAdapter] with JNI access.
/// On iOS, creates an [ExampleIOSAdapter] with FFI access.
///
/// The callbacks receive events and document info from the adapter.
ExampleAdapterController? createExampleAdapter({
  StatusChangedCallback? onStatusChanged,
  DocumentInfoCallback? onDocumentInfo,
}) {
  if (Platform.isAndroid) {
    return ExampleAndroidAdapter(
      onStatusChanged: onStatusChanged,
      onDocumentInfo: onDocumentInfo,
    );
  } else if (Platform.isIOS) {
    return ExampleIOSAdapter(
      onStatusChanged: onStatusChanged,
      onDocumentInfo: onDocumentInfo,
    );
  }
  return null;
}
