///
///  Copyright © 2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Bindings for the signature interceptor in `ios/Classes/NutrientFFI.h`.
///
/// These belong in the generated `bindings/nutrient_ios_bindings.dart`, which
/// ffigen builds from the same header, but regenerating it against an iOS SDK
/// that has the signature placement API currently exhausts ffigen's heap, so
/// these few declarations stand in by hand. Remove this file once the
/// generated bindings include them.
// ignore_for_file: non_constant_identifier_names
@ffi.DefaultAsset('package:nutrient_flutter_ios/nutrient_flutter_ios.dylib')
library;

import 'dart:ffi' as ffi;

/// `nutrient_signature_request_callback`
typedef NutrientSignatureRequestCallback =
    ffi.Void Function(
      ffi.Int64 requestId,
      ffi.Int64 pageIndex,
      ffi.Pointer<ffi.Char> formFieldName,
      ffi.Double lineWidth,
      ffi.Double alpha,
    );

/// `nutrient_signature_placement_callback`
typedef NutrientSignaturePlacementCallback =
    ffi.Void Function(
      ffi.Int64 requestId,
      ffi.Int64 pageIndex,
      ffi.Double x,
      ffi.Double y,
      ffi.Double width,
      ffi.Double height,
      ffi.Double pageWidth,
      ffi.Double pageHeight,
      ffi.Pointer<ffi.Char> formFieldName,
    );

@ffi.Native<
  ffi.Void Function(
    ffi.Pointer<ffi.Void>,
    ffi.Pointer<ffi.NativeFunction<NutrientSignatureRequestCallback>>,
    ffi.Pointer<ffi.NativeFunction<NutrientSignaturePlacementCallback>>,
  )
>()
external void nutrient_set_signature_interceptor(
  ffi.Pointer<ffi.Void> viewController,
  ffi.Pointer<ffi.NativeFunction<NutrientSignatureRequestCallback>> onRequest,
  ffi.Pointer<ffi.NativeFunction<NutrientSignaturePlacementCallback>>
  onPlacement,
);

@ffi.Native<
  ffi.Void Function(ffi.Int64, ffi.Bool, ffi.Bool, ffi.Double, ffi.Double)
>()
external void nutrient_resolve_signature_request(
  int requestId,
  bool proceed,
  bool applyStyle,
  double lineWidth,
  double alpha,
);

@ffi.Native<
  ffi.Void Function(
    ffi.Int64,
    ffi.Int32,
    ffi.Int64,
    ffi.Double,
    ffi.Double,
    ffi.Double,
    ffi.Double,
  )
>()
external void nutrient_resolve_signature_placement(
  int requestId,
  int action,
  int pageIndex,
  double x,
  double y,
  double width,
  double height,
);

/// The `action` values of [nutrient_resolve_signature_placement].
abstract final class NutrientSignaturePlacementAction {
  /// Where the SDK proposed.
  static const proposed = 0;

  /// On the given page, in the given rect.
  static const custom = 1;

  /// Not at all: the signature is dropped.
  static const drop = 2;
}
