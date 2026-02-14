///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Platform adapter factory with conditional imports.
///
/// Uses `dart.library.io` (native) and `dart.library.js_interop` (web)
/// to resolve platform-specific adapter implementations at compile time.
library;

export 'example_adapter_controller.dart';
export 'adapters_stub.dart'
    if (dart.library.io) 'adapters_native.dart'
    if (dart.library.js_interop) 'adapters_web.dart';
