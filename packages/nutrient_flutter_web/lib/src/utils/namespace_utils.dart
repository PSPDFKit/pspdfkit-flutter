///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../nutrient_web_bindings.dart';

/// Utilities for resolving the Web SDK global namespace.
///
/// The Nutrient Web SDK uses either `NutrientViewer` (v1.0+) or `PSPDFKit`
/// (legacy) as its global namespace. This class provides methods to resolve
/// the correct namespace at runtime.
class NutrientNamespace {
  NutrientNamespace._();

  /// Returns the Web SDK static object (`NutrientViewer` or `PSPDFKit`).
  ///
  /// Tries `NutrientViewer` first (new SDK), falls back to `PSPDFKit` (legacy).
  /// Throws if neither namespace is available.
  static NutrientWebStatic get() {
    if (globalContext.has('NutrientViewer')) {
      return nutrient;
    }
    if (globalContext.has('PSPDFKit')) {
      return pspdfkit;
    }
    throw StateError(
      'Nutrient Web SDK not found. Ensure the SDK script is loaded in index.html.',
    );
  }

  /// Returns the Web SDK namespace as a raw [JSObject] for property access.
  ///
  /// Use this when you need to access nested properties like
  /// `namespace['Annotations']` or `namespace['Color']`.
  static JSObject getAsJSObject() {
    if (globalContext.has('NutrientViewer')) {
      return globalContext['NutrientViewer'] as JSObject;
    }
    if (globalContext.has('PSPDFKit')) {
      return globalContext['PSPDFKit'] as JSObject;
    }
    throw StateError(
      'Nutrient Web SDK not found. Ensure the SDK script is loaded in index.html.',
    );
  }

  /// Whether the `NutrientViewer` namespace is available (new SDK v1.0+).
  static bool get isNutrientViewer => globalContext.has('NutrientViewer');

  /// Whether the `PSPDFKit` namespace is available (legacy SDK).
  static bool get isPSPDFKit => globalContext.has('PSPDFKit');
}
