///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Web platform implementation for example adapters.
///
/// This file is used on the web platform where dart.library.js_interop is
/// available, providing access to JavaScript interop bindings.

import 'example_adapter_controller.dart';
import 'web_adapter.dart';

/// Creates an example adapter for the web platform.
///
/// Creates an [ExampleWebAdapter] with JS interop access.
///
/// The callbacks receive events and document info from the adapter.
ExampleAdapterController? createExampleAdapter({
  StatusChangedCallback? onStatusChanged,
  DocumentInfoCallback? onDocumentInfo,
}) {
  return ExampleWebAdapter(
    onStatusChanged: onStatusChanged,
    onDocumentInfo: onDocumentInfo,
  );
}
