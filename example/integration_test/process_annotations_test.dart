// Integration test for the `Nutrient.processAnnotations` contract from
// headless-document-api-guide.md:
//   "Passing the same path for sourcePath and destinationPath processes in
//    place."
//
// Regression coverage for the in-place bug found in review of
// https://github.com/PSPDFKit/PSPDFKit/pull/55349 (test contributed there):
// both adapters now write to a sibling temp file and move it over the
// destination only after a successful write — the native processors can't
// write directly over their own source (Android's PdfProcessor throws
// IllegalStateException; iOS's PSPDFProcessor reads the source lazily while
// writing), and a pre-existing destination must never be deleted before the
// replacement output is complete.
//
// This test must run on a device/emulator (it exercises the native SDK), so it
// lives under integration_test/. Run with:
//   cd flutter/nutrient_flutter/example
//   flutter test integration_test/process_annotations_test.dart

import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutrient_flutter/bindings.dart';

final Directory _tempDir = Directory.systemTemp.createTempSync('nutrient_proc');

Future<String> _extractAsset(String assetPath, String outName) async {
  final data = await rootBundle.load(assetPath);
  final path = '${_tempDir.path}/$outName';
  final file = File(path);
  await file.create(recursive: true);
  file.writeAsBytesSync(data.buffer.asUint8List());
  return path;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Nutrient.processAnnotations', () {
    test('flattens to a DISTINCT destination (control case)', () async {
      final source =
          await _extractAsset('PDFs/PSPDFKit.pdf', 'src_distinct.pdf');
      final destination = '${_tempDir.path}/out_distinct.pdf';
      final outFile = File(destination);
      if (outFile.existsSync()) outFile.deleteSync();

      final ok = await Nutrient.processAnnotations(
        sourcePath: source,
        type: AnnotationType.all,
        mode: AnnotationProcessingMode.flatten,
        destinationPath: destination,
      );

      expect(ok, isTrue);
      expect(outFile.existsSync(), isTrue,
          reason: 'processed output should be written to the destination');
      expect(outFile.lengthSync(), greaterThan(0));
    });

    // Regression test for the review's Finding 1: in-place processing must
    // succeed on both platforms and must never destroy the source.
    test('processes IN PLACE (source == destination) per the guide', () async {
      final path = await _extractAsset('PDFs/PSPDFKit.pdf', 'src_inplace.pdf');
      final before = File(path).lengthSync();

      final ok = await Nutrient.processAnnotations(
        sourcePath: path,
        type: AnnotationType.all,
        mode: AnnotationProcessingMode.flatten,
        destinationPath: path, // same path == in-place
      );

      expect(ok, isTrue,
          reason: 'the guide documents in-place processing as supported');
      expect(File(path).existsSync(), isTrue,
          reason: 'in-place must never destroy the source');
      expect(File(path).lengthSync(), greaterThan(0),
          reason:
              'processed file must be non-empty (before was $before bytes)');
    });
  });
}
