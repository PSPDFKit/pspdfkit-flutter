// Integration test for the document API against the native SDK: forms, Instant JSON, XFDF,
// saving, exporting and processing on a headless document, and the viewer's controller and
// bookmarks. On Android these are the calls that moved from the SDK's RxJava APIs to coroutines
// (HYB-1105), so each one has to answer exactly once, with its result or its error.
//
// This test must run on a device/emulator (it exercises the native SDK), so it lives under
// integration_test/. Run with:
//   cd flutter/nutrient_flutter/example
//   flutter test integration_test/headless_document_api_test.dart

// The legacy API is the one the plugin's Kotlin backs, which is what this tests.
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late PdfDocument document;

  setUpAll(() async {
    await Nutrient.initialize();
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('nutrient_headless');
    final data = await rootBundle.load('PDFs/Form_example.pdf');
    final path = '${directory.path}/Form_example.pdf';
    await File(path).writeAsBytes(data.buffer.asUint8List());
    document = await Nutrient.openDocument(path);
  });

  tearDown(() async {
    await document.close();
    await directory.delete(recursive: true);
  });

  testWidgets('reads and writes form fields', (tester) async {
    final fields = await document.getFormFields();
    final textField =
        fields.firstWhere((field) => field.type == PdfFormFieldTypes.text);
    final name = textField.fullyQualifiedName!;

    expect((await document.getFormField(name)).fullyQualifiedName, name);
    // Short enough for the document's fields with a maximum length.
    expect(await document.setFormFieldValue('Ok', name), isTrue);
    expect(await document.getFormFieldValue(name), 'Ok');
    if (Platform.isAndroid) {
      expect(await document.androidGetFormFieldIsDirty(name), isTrue);
    }
    await expectLater(
        document.getFormFieldValue('No such field'), throwsException);
  });

  testWidgets('exports and applies Instant JSON', (tester) async {
    final instantJson = await document.exportInstantJson();
    expect(instantJson, contains('"format"'));
    expect(await document.applyInstantJson(instantJson!), isTrue);
    expect(await document.getAllUnsavedAnnotations(), isNotNull);
  });

  testWidgets('exports and imports XFDF', (tester) async {
    final path = '${directory.path}/annotations.xfdf';
    expect(await document.exportXfdf(path), isTrue);
    final xfdf = await File(path).readAsString();
    expect(xfdf, contains('<xfdf'));
    expect(await document.importXfdf(xfdf), isTrue);
  });

  testWidgets('saves, exports and processes the document', (tester) async {
    final fields = await document.getFormFields();
    final textField =
        fields.firstWhere((field) => field.type == PdfFormFieldTypes.text);
    await document.setFormFieldValue(
        'Appleseed', textField.fullyQualifiedName!);
    expect(await document.save(), isTrue);

    final copy = '${directory.path}/copy.pdf';
    expect(await document.save(outputPath: copy), isTrue);
    expect(File(copy).lengthSync(), greaterThan(0));

    final bytes = await document.exportPdf();
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');

    final flattened = '${directory.path}/flattened.pdf';
    expect(
        await document.processAnnotations(
            AnnotationType.all, AnnotationProcessingMode.flatten, flattened),
        isTrue);
    expect(File(flattened).lengthSync(), greaterThan(0));
  });

  testWidgets('finishes a call made just before close()', (tester) async {
    final fields = await document.getFormFields();
    final textField =
        fields.firstWhere((field) => field.type == PdfFormFieldTypes.text);
    await document.setFormFieldValue('Ok', textField.fullyQualifiedName!);

    // Not awaited, so close() reaches the plugin before the save has run.
    final saved = document.save();
    expect(await document.close(), isTrue);
    expect(await saved.timeout(const Duration(seconds: 30)), isTrue);
  });

  // Android sets up bookmarks only for a document in a viewer.
  testWidgets('saves, exchanges XFDF, processes and bookmarks in a viewer',
      (tester) async {
    final viewerPath = '${directory.path}/viewer.pdf';
    await File('${directory.path}/Form_example.pdf').copy(viewerPath);
    final controller = Completer<NutrientViewController>();
    final loaded = Completer<PdfDocument>();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NutrientView(
          documentPath: viewerPath,
          onViewCreated: controller.complete,
          onDocumentLoaded: loaded.complete,
          onDocumentError: loaded.completeError,
        ),
      ),
    ));
    final deadline = DateTime.now().add(const Duration(seconds: 60));
    while (!loaded.isCompleted) {
      if (DateTime.now().isAfter(deadline)) {
        fail("The viewer didn't load the document within a minute.");
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    final view = await controller.future;
    final viewerDocument = await loaded.future;

    expect(await view.save(), isTrue);
    final xfdfPath = '${directory.path}/viewer.xfdf';
    expect(await view.exportXfdf(xfdfPath), isTrue);
    expect(await view.importXfdf(await File(xfdfPath).readAsString()), isTrue);
    final flattened = '${directory.path}/viewer_flattened.pdf';
    expect(
        await view.processAnnotations(
            AnnotationType.all, AnnotationProcessingMode.flatten, flattened),
        isTrue);
    expect(File(flattened).lengthSync(), greaterThan(0));

    final added = await viewerDocument
        .addBookmark(BookmarkFactory.forPage(pageIndex: 0, name: 'First page'));
    expect(added.name, 'First page');
    expect(
        (await viewerDocument.getBookmarks()).map((bookmark) => bookmark.name),
        contains('First page'));
    expect(await viewerDocument.hasBookmarkForPage(0), isTrue);
    expect(await viewerDocument.removeBookmark(added), isTrue);
    expect(await viewerDocument.hasBookmarkForPage(0), isFalse);
  });
}
