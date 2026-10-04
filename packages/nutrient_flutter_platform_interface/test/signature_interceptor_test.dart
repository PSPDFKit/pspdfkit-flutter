///
///  Copyright © 2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

/// Overrides nothing, so both hooks fall back to the defaults.
class _PassThrough extends SignatureInterceptor {
  const _PassThrough();
}

/// Overrides only the appearance hook, the common case.
class _Branded extends SignatureInterceptor {
  const _Branded();

  @override
  Future<SignatureResponse> onSignatureRequested(
          SignatureRequest request) async =>
      const SignatureResponse.proceed(
          style: SignatureStyle(thickness: 9, opacity: 0.5));
}

void main() {
  const request = SignatureRequest(
      pageIndex: 0, style: SignatureStyle(thickness: 4, opacity: 1));
  const proposal = SignaturePlacementProposal(
    pageIndex: 2,
    boundingBox: Rect.fromLTWH(10, 20, 100, 50),
    pageSize: Size(612, 792),
  );

  group('SignatureInterceptor defaults', () {
    test('proceed unchanged at both points', () async {
      const interceptor = _PassThrough();

      final response = await interceptor.onSignatureRequested(request);
      final placement =
          await interceptor.onSignaturePlacementRequested(proposal);

      expect(response.isCancelled, isFalse);
      expect(response.style, isNull);
      expect(placement.isCancelled, isFalse);
      expect(placement.pageIndex, isNull);
      expect(placement.boundingBox, isNull);
    });

    test('a subclass overrides one hook without touching the other', () async {
      const interceptor = _Branded();

      final response = await interceptor.onSignatureRequested(request);
      final placement =
          await interceptor.onSignaturePlacementRequested(proposal);

      expect(response.style, const SignatureStyle(thickness: 9, opacity: 0.5));
      expect(placement.isCancelled, isFalse);
    });
  });

  group('requests', () {
    test('form field origin is derived from the field name', () {
      expect(request.isFormField, isFalse);
      expect(
        const SignatureRequest(
          pageIndex: 0,
          style: SignatureStyle(thickness: 4, opacity: 1),
          formFieldName: 'Signature1',
        ).isFormField,
        isTrue,
      );
      expect(proposal.isFormField, isFalse);
    });
  });

  group('responses', () {
    test('cancel carries no overrides', () {
      const response = SignatureResponse.cancel();
      const placement = SignaturePlacementResponse.cancel();

      expect(response.isCancelled, isTrue);
      expect(response.style, isNull);
      expect(placement.isCancelled, isTrue);
      expect(placement.pageIndex, isNull);
      expect(placement.boundingBox, isNull);
    });

    test('proceed carries the overrides given', () {
      const placement = SignaturePlacementResponse.proceed(
          pageIndex: 3, boundingBox: Rect.fromLTWH(0, 0, 50, 25));

      expect(placement.isCancelled, isFalse);
      expect(placement.pageIndex, 3);
      expect(placement.boundingBox, const Rect.fromLTWH(0, 0, 50, 25));
    });
  });

  group('SignatureStyle', () {
    test('rejects values the signing UI cannot draw with', () {
      expect(() => SignatureStyle(thickness: 0, opacity: 1),
          throwsA(isA<AssertionError>()));
      expect(() => SignatureStyle(thickness: 4, opacity: 0),
          throwsA(isA<AssertionError>()));
      expect(() => SignatureStyle(thickness: 4, opacity: 1.5),
          throwsA(isA<AssertionError>()));
    });

    test('copyWith and equality', () {
      const base = SignatureStyle(thickness: 4, opacity: 1);

      expect(base.copyWith(opacity: 0.3),
          const SignatureStyle(thickness: 4, opacity: 0.3));
      expect(base, const SignatureStyle(thickness: 4, opacity: 1));
      expect(base.hashCode,
          const SignatureStyle(thickness: 4, opacity: 1).hashCode);
    });
  });

  group('NutrientController', () {
    test('setSignatureInterceptor is a no-op by default', () {
      final controller = _Controller();
      expect(() => controller.setSignatureInterceptor(const _PassThrough()),
          returnsNormally);
      expect(() => controller.setSignatureInterceptor(null), returnsNormally);
    });
  });
}

class _Controller extends NutrientController {
  @override
  NutrientDocumentInterface get document => throw UnimplementedError();
}
