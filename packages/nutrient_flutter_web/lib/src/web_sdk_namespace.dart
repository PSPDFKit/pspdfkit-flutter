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

import 'generated/nutrient_web_bindings.g.dart' as nutrient_web;

// The Nutrient Web SDK ships its API under one of two browser globals
// depending on the loaded version:
//   - `window.NutrientViewer` (≥ 1.0)
//   - `window.PSPDFKit`       (legacy)
//
// The generated bindings hoist these namespace methods to top-level
// `external` Dart functions tied to whichever global the analyzer
// resolved. That doesn't fit our runtime model where we need to:
//
//   1. detect at runtime which global is present, and
//   2. invoke the namespaced ViewState/Geometry.Rect constructors by
//      literal name (the bindings don't expose a
//      `@JS('NutrientViewer.ViewState')` factory).
//
// So this file owns the small surface where we cross the JS namespace
// boundary by hand. Everything else (Instance methods, Rect/Point/etc.
// types, annotation/form types) flows through the generated bindings.

/// Resolved Nutrient Web SDK namespace handle (`NutrientViewer` or
/// `PSPDFKit` JS object), or `null` if no SDK script is loaded.
JSObject? get _namespaceObject {
  if (globalContext.has('NutrientViewer')) {
    return globalContext['NutrientViewer'] as JSObject?;
  }
  if (globalContext.has('PSPDFKit')) {
    return globalContext['PSPDFKit'] as JSObject?;
  }
  return null;
}

/// Whether the Nutrient Web SDK script is loaded on the page under
/// either the `NutrientViewer` or `PSPDFKit` global.
bool get isLoaded => _namespaceObject != null;

/// The loaded Nutrient Web SDK version (e.g. `"1.5.0"`), read from the
/// namespace's `version` property, or `null` if the SDK script isn't present.
String? get sdkVersion {
  final value = _namespaceObject?['version'].dartify();
  return value is String ? value : null;
}

/// Loads a Nutrient Web SDK instance with the given configuration.
///
/// `config` must be a JS object (typically built with `jsify()`) that
/// matches the Web SDK's `Configuration` shape. See
/// https://www.nutrient.io/api/web/NutrientViewer.html#.load.
///
/// Throws `StateError` if the SDK script isn't loaded.
JSPromise<nutrient_web.Instance> loadInstance(JSAny config) {
  final ns = _namespaceObject;
  if (ns == null) {
    throw StateError(
      'Nutrient Web SDK not found. Load the viewer script before '
      'calling loadInstance().',
    );
  }
  return ns.callMethod<JSPromise<nutrient_web.Instance>>('load'.toJS, config);
}

/// Unloads a previously-loaded Web SDK instance via the namespace's
/// `unload` static.
void unloadInstance(nutrient_web.Instance instance) {
  final ns = _namespaceObject;
  if (ns == null) return;
  ns.callMethod<JSAny?>('unload'.toJS, instance as JSAny);
}

/// Constructs a Web SDK `ViewState` JS object from a property bag.
///
/// The Web SDK requires `initialViewState` to be an instance of its
/// `ViewState` class (an Immutable.Record), not a plain JS object.
JSObject createViewState(JSAny props) {
  final ns = _namespaceObject;
  if (ns == null) {
    throw StateError(
      'Nutrient Web SDK not found. Load the viewer script before '
      'calling createViewState().',
    );
  }
  final ctor = ns['ViewState'] as JSFunction?;
  if (ctor == null) {
    throw StateError(
      'ViewState constructor not found on the Nutrient Web SDK '
      'namespace. The SDK script may be too old.',
    );
  }
  return ctor.callAsConstructor<JSObject>(props);
}

/// Constructs an SDK-native `Geometry.Rect` from `{left, top, width,
/// height}` numbers.
///
/// APIs like [nutrient_web.Instance.jumpAndZoomToRect] won't accept a plain
/// JS object — they need an instance produced by the namespaced
/// `NutrientViewer.Geometry.Rect` constructor. This helper handles the
/// runtime lookup and `callAsConstructor` so callers don't need to
/// reach into the JS object themselves.
nutrient_web.Rect createGeometryRect({
  required num left,
  required num top,
  required num width,
  required num height,
}) {
  final ns = _namespaceObject;
  if (ns == null) {
    throw StateError(
      'Nutrient Web SDK not found. Load the viewer script before '
      'calling createGeometryRect().',
    );
  }
  final geometry = ns['Geometry'] as JSObject?;
  if (geometry == null) {
    throw StateError(
      'Geometry namespace not found on the Nutrient Web SDK. The '
      'SDK script may be too old.',
    );
  }
  final ctor = geometry['Rect'] as JSFunction?;
  if (ctor == null) {
    throw StateError(
      'Geometry.Rect constructor not found on the Nutrient Web SDK '
      'namespace. The SDK script may be too old.',
    );
  }
  final props = <String, num>{
    'left': left,
    'top': top,
    'width': width,
    'height': height,
  }.jsify();
  return ctor.callAsConstructor<JSObject>(props) as nutrient_web.Rect;
}

/// Constructs an SDK-native `Geometry.Point` from `{x, y}` numbers.
///
/// Like [createGeometryRect], point-transform APIs such as
/// [nutrient_web.Instance.transformContentClientToPageSpace] require an
/// instance produced by the namespaced `NutrientViewer.Geometry.Point`
/// constructor rather than a plain JS object.
nutrient_web.Point createGeometryPoint({required num x, required num y}) {
  final ns = _namespaceObject;
  if (ns == null) {
    throw StateError(
      'Nutrient Web SDK not found. Load the viewer script before '
      'calling createGeometryPoint().',
    );
  }
  final geometry = ns['Geometry'] as JSObject?;
  if (geometry == null) {
    throw StateError(
      'Geometry namespace not found on the Nutrient Web SDK. The '
      'SDK script may be too old.',
    );
  }
  final ctor = geometry['Point'] as JSFunction?;
  if (ctor == null) {
    throw StateError(
      'Geometry.Point constructor not found on the Nutrient Web SDK '
      'namespace. The SDK script may be too old.',
    );
  }
  final props = <String, num>{'x': x, 'y': y}.jsify();
  return ctor.callAsConstructor<JSObject>(props) as nutrient_web.Point;
}
