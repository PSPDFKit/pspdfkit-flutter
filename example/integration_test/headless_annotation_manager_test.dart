// Integration test for the annotation manager on headless documents
// (HYB-1111, "Related gaps").
//
// Android and iOS only set up the AnnotationManagerApi channel for documents
// shown in a viewer, so getAnnotationProperties, saveAnnotationProperties and
// searchAnnotations on a document opened with `Nutrient.openDocument` failed
// with a channel-error PlatformException.
//
// It uses the legacy `Nutrient` API on purpose: the bindings-based
// `Nutrient.openDocument` doesn't go through AnnotationManagerApi.
//
// This test must run on a device/emulator (it exercises the native SDK), so it
// lives under integration_test/. Run with:
//   cd flutter/nutrient_flutter/example
//   flutter test integration_test/headless_annotation_manager_test.dart

// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
// ignore: implementation_imports
import 'package:nutrient_flutter_platform_interface/src/api/nutrient_api.g.dart'
    as pigeon;

final Directory _tempDir = Directory.systemTemp.createTempSync(
  'nutrient_annotation_manager',
);

Future<String> _extractAsset(String assetPath, String outName) async {
  final data = await rootBundle.load(assetPath);
  final path = '${_tempDir.path}/$outName';
  final file = File(path);
  await file.create(recursive: true);
  file.writeAsBytesSync(data.buffer.asUint8List());
  return path;
}

const _annotationName = 'headless-square';

/// Opens a copy of the asset with one square annotation on page 0.
Future<PdfDocument> _openWithSquare(String outName, {String? subject}) async {
  final path = await _extractAsset('PDFs/PSPDFKit.pdf', outName);
  final document = await Nutrient.openDocument(path);
  addTearDown(document.close);

  // Goes through PdfDocumentApi, which headless documents always had.
  final square = SquareAnnotation(
    bbox: [100, 100, 120, 80],
    pageIndex: 0,
    strokeColor: const Color(0xFF2492FB),
    strokeWidth: 2,
    name: _annotationName,
    subject: subject,
  );
  expect(await document.addAnnotation(square), isTrue);
  return document;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => Nutrient.initialize());
  tearDownAll(() => _tempDir.delete(recursive: true));

  group('Headless document annotation manager', () {
    testWidgets('reads and saves annotation properties', (tester) async {
      final document = await _openWithSquare('properties.pdf');

      final properties = await document.getAnnotationProperties(
        0,
        _annotationName,
      );
      expect(properties, isNotNull);
      expect(properties!.annotationId, isNotNull);
      expect(properties.pageIndex, 0);
      expect(properties.contents, isNull);

      expect(
        await document.saveAnnotationProperties(
          properties.withContents('Saved contents'),
        ),
        isTrue,
      );
      expect(
        (await document.getAnnotationProperties(0, _annotationName))?.contents,
        'Saved contents',
      );
    });

    testWidgets('saving properties keeps a single copy of the annotation', (
      tester,
    ) async {
      final document = await _openWithSquare('single_copy.pdf');

      final properties = await document.getAnnotationProperties(
        0,
        _annotationName,
      );
      await document.saveAnnotationProperties(
        properties!.withContents('Saved contents'),
      );

      expect(
        await document.getAnnotations(0, AnnotationType.square),
        hasLength(1),
      );
    });

    testWidgets('saving properties leaves unsaved changes', (tester) async {
      final document = await _openWithSquare('unsaved_changes.pdf');
      expect(await document.save(), isTrue);
      expect(await document.hasUnsavedChanges(), isFalse);

      final properties = await document.getAnnotationProperties(
        0,
        _annotationName,
      );
      await document.saveAnnotationProperties(
        properties!.withContents('Saved contents'),
      );

      // Maps to iOSHasDirtyAnnotations on iOS.
      expect(await document.hasUnsavedChanges(), isTrue);
    });

    testWidgets('searches annotations', (tester) async {
      final document = await _openWithSquare(
        'search.pdf',
        subject: 'Headless needle',
      );

      final found = await document.searchAnnotations('headless NEEDLE');
      expect(found, hasLength(1));
      expect(found.single.type, AnnotationType.square);
      expect(
        await document.searchAnnotations('Headless needle', 0),
        hasLength(1),
      );
      expect(await document.searchAnnotations('Headless needle', 1), isEmpty);
      expect(await document.searchAnnotations('no such annotation'), isEmpty);
    });

    testWidgets(
      'closing the document tears down its annotation manager channel',
      (tester) async {
        final path = await _extractAsset('PDFs/PSPDFKit.pdf', 'close.pdf');
        final document = await Nutrient.openDocument(path);
        final documentId = document.documentId;

        // Goes through the channel, so it must be live before the close.
        await document.searchAnnotations('anything');
        expect(await document.close(), isTrue);

        // The document refuses calls after close on the Dart side, so talk to
        // the channel directly to check the native handler is gone.
        final api = pigeon.AnnotationManagerApi(
          messageChannelSuffix: '${documentId}_annotation_manager',
        );
        await expectLater(
          api.searchAnnotationsJson('anything', null),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              'channel-error',
            ),
          ),
        );
      },
    );
  });
}
