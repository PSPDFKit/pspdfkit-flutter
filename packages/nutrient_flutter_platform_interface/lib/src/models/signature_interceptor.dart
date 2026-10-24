///
///  Copyright © 2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:ui';

/// Steps into the built-in electronic signature flow at its two decision
/// points, without replacing the signature UI itself.
///
/// Set it with `controller.setSignatureInterceptor(...)`. Each hook receives a
/// request and returns a response, immediately or after showing UI of your own.
/// Nothing happens until the returned future completes. Both default
/// implementations proceed unchanged, so override only what you need:
///
/// ```dart
/// class BrandedSignatures extends SignatureInterceptor {
///   @override
///   Future<SignatureResponse> onSignatureRequested(SignatureRequest request) async {
///     // Every signature starts with the thickness and opacity stored in the app.
///     return SignatureResponse.proceed(
///       style: SignatureStyle(thickness: prefs.thickness, opacity: prefs.opacity),
///     );
///   }
/// }
///
/// controller.setSignatureInterceptor(BrandedSignatures());
/// ```
///
/// Supported on **Android and iOS**. A request is tied to the flow that
/// issued it: a response that arrives after the view was disposed, or after a
/// newer request replaced it, is ignored and that signing flow is abandoned.
abstract class SignatureInterceptor {
  const SignatureInterceptor();

  /// Called before the signature creation UI is shown, both from the
  /// annotation toolbar and when a signature form field is tapped.
  ///
  /// Return [SignatureResponse.proceed] to show the built-in UI, optionally
  /// with another [SignatureStyle], or [SignatureResponse.cancel] to not show
  /// it at all.
  Future<SignatureResponse> onSignatureRequested(
          SignatureRequest request) async =>
      const SignatureResponse.proceed();

  /// Called once a signature has been created or picked, before it is added to
  /// the document.
  ///
  /// Return [SignaturePlacementResponse.proceed] to add it at the proposed
  /// position or elsewhere, or [SignaturePlacementResponse.cancel] to add
  /// nothing, for example when your app inserts the signature itself.
  Future<SignaturePlacementResponse> onSignaturePlacementRequested(
          SignaturePlacementProposal proposal) async =>
      const SignaturePlacementResponse.proceed();
}

/// Stroke thickness and opacity of signatures created with the built-in UI.
///
/// [thickness] is in PDF points relative to the signing canvas and must be
/// greater than zero. [opacity] runs from `0` (exclusive) to `1` (fully
/// opaque) and applies to drawn, typed and image signatures alike.
class SignatureStyle {
  final double thickness;
  final double opacity;

  const SignatureStyle({required this.thickness, required this.opacity})
      : assert(thickness > 0, 'thickness must be greater than 0'),
        assert(opacity > 0 && opacity <= 1,
            'opacity must be greater than 0 and at most 1');

  SignatureStyle copyWith({double? thickness, double? opacity}) =>
      SignatureStyle(
        thickness: thickness ?? this.thickness,
        opacity: opacity ?? this.opacity,
      );

  @override
  bool operator ==(Object other) =>
      other is SignatureStyle &&
      other.thickness == thickness &&
      other.opacity == opacity;

  @override
  int get hashCode => Object.hash(thickness, opacity);

  @override
  String toString() =>
      'SignatureStyle(thickness: $thickness, opacity: $opacity)';
}

/// A pending request to show the signature creation UI.
class SignatureRequest {
  /// Page the signature is going to be placed on.
  final int pageIndex;

  /// Fully qualified name of the signature form field being signed, or `null`
  /// when the signature was requested from the annotation toolbar.
  final String? formFieldName;

  /// The style the UI will be shown with unless the response carries another.
  final SignatureStyle style;

  const SignatureRequest({
    required this.pageIndex,
    required this.style,
    this.formFieldName,
  });

  /// Whether the signature was requested by tapping a signature form field.
  bool get isFormField => formFieldName != null;
}

/// The answer to a [SignatureRequest].
class SignatureResponse {
  /// Whether the signature creation UI is not shown at all.
  final bool isCancelled;

  /// The style to show the UI with, or `null` to keep [SignatureRequest.style].
  final SignatureStyle? style;

  /// Shows the built-in signature creation UI, with [style] if given.
  const SignatureResponse.proceed({this.style}) : isCancelled = false;

  /// Does not show the signature creation UI.
  const SignatureResponse.cancel()
      : isCancelled = true,
        style = null;
}

/// Where the SDK proposes to add a signature that was just created or picked.
///
/// [boundingBox] and [pageSize] are in PDF page coordinates, the same
/// convention as `getVisibleRect`: the origin is the page's bottom-left
/// corner and [Rect.top] is the smaller y value.
class SignaturePlacementProposal {
  /// Page the signature is proposed to be placed on.
  final int pageIndex;

  /// Proposed bounding box on that page.
  final Rect boundingBox;

  /// Size of that page, for computing a position of your own.
  final Size pageSize;

  /// Fully qualified name of the signature form field being signed, or `null`
  /// for a free-standing signature. A form field has a fixed location, so you
  /// will usually proceed unchanged in that case.
  final String? formFieldName;

  const SignaturePlacementProposal({
    required this.pageIndex,
    required this.boundingBox,
    required this.pageSize,
    this.formFieldName,
  });

  /// Whether the signature fills a signature form field.
  bool get isFormField => formFieldName != null;
}

/// The answer to a [SignaturePlacementProposal].
class SignaturePlacementResponse {
  /// Whether the signature is not added to the document.
  final bool isCancelled;

  /// Page to add the signature on, or `null` to keep the proposed page.
  final int? pageIndex;

  /// Bounding box to add the signature at, in PDF page coordinates with the
  /// same convention as [SignaturePlacementProposal.boundingBox], or `null` to
  /// keep the proposed one. The signature is scaled to fit the box, so keep its
  /// aspect ratio close to the proposal's.
  final Rect? boundingBox;

  /// Adds the signature at the proposed position, or at [pageIndex] and
  /// [boundingBox] where given.
  const SignaturePlacementResponse.proceed({this.pageIndex, this.boundingBox})
      : isCancelled = false;

  /// Does not add the signature to the document, leaving that to you.
  const SignaturePlacementResponse.cancel()
      : isCancelled = true,
        pageIndex = null,
        boundingBox = null;
}
