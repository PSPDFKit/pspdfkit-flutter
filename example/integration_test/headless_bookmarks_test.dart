// Integration test for bookmarks on headless documents (HYB-1111).
//
// Android only set up the BookmarkManagerApi channel for documents shown in a
// viewer, so every bookmark call on a document opened with
// `Nutrient.openDocument` failed with a channel-error PlatformException.
// iOS has the same gap and is skipped until it gets its own fix.
//
// It uses the legacy `Nutrient` API on purpose: the bindings-based
// `Nutrient.openDocument` doesn't go through BookmarkManagerApi.
//
// This test must run on a device/emulator (it exercises the native SDK), so it
// lives under integration_test/. Run with:
//   cd flutter/nutrient_flutter/example
//   flutter test integration_test/headless_bookmarks_test.dart

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
  'nutrient_bookmarks',
);

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

  setUpAll(() => Nutrient.initialize());
  tearDownAll(() => _tempDir.delete(recursive: true));

  group(
    'Headless document bookmarks',
    () {
      testWidgets('adds, lists and removes a bookmark', (tester) async {
        final path = await _extractAsset(
          'PDFs/Form_example.pdf',
          'add_remove.pdf',
        );
        final document = await Nutrient.openDocument(path);
        addTearDown(document.close);

        final before = await document.getBookmarks();
        expect(
          await document.hasBookmarkForPage(0),
          isFalse,
          reason: 'the asset should have no bookmark on page 0 to start with',
        );

        final created = await document.addBookmark(
          BookmarkFactory.forPage(pageIndex: 0, name: 'Headless bookmark'),
        );
        expect(created.name, 'Headless bookmark');
        expect(created.pageIndex, 0);
        expect(created.pdfBookmarkId, isNotNull);

        final afterAdd = await document.getBookmarks();
        expect(afterAdd, hasLength(before.length + 1));
        expect(
          afterAdd.where((b) => b.name == 'Headless bookmark'),
          hasLength(1),
        );
        expect(await document.hasBookmarkForPage(0), isTrue);
        expect((await document.getBookmarksForPage(0)).map((b) => b.name), [
          'Headless bookmark',
        ]);

        expect(await document.removeBookmark(created), isTrue);

        expect(await document.getBookmarks(), hasLength(before.length));
        expect(await document.hasBookmarkForPage(0), isFalse);
      });

      testWidgets('closing the document tears down its bookmark channel',
          (tester) async {
        final path = await _extractAsset('PDFs/Form_example.pdf', 'close.pdf');
        final document = await Nutrient.openDocument(path);
        final documentId = document.documentId;

        // Goes through the channel, so it must be live before the close.
        await document.getBookmarks();
        expect(await document.close(), isTrue);

        // The document refuses calls after close on the Dart side, so talk to
        // the channel directly to check the native handler is gone.
        final api = pigeon.BookmarkManagerApi(
          messageChannelSuffix: '${documentId}_bookmark_manager',
        );
        await expectLater(
          api.getBookmarks(),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              'channel-error',
            ),
          ),
        );
      });
    },
    skip: Platform.isAndroid
        ? false
        : 'Only Android sets up bookmark channels for headless documents',
  );
}
