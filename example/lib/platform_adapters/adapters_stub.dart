///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Stub implementation for unsupported platforms.
///
/// This file is used when neither native (dart.library.io) nor web
/// (dart.library.js_interop) platforms are detected.

import 'example_adapter_controller.dart';

/// Creates an example adapter for unsupported platforms (returns null).
ExampleAdapterController? createExampleAdapter({
  StatusChangedCallback? onStatusChanged,
  DocumentInfoCallback? onDocumentInfo,
}) {
  return null;
}
