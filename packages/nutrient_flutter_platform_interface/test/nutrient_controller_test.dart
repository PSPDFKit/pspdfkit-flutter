///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

// ---------------------------------------------------------------------------
// Test doubles — managers
// ---------------------------------------------------------------------------

class FakeAnnotationManager implements AnnotationManagerInterface {
  @override
  Future<String> getAnnotationsJson(int pageIndex, String type) async => '[]';
  @override
  Future<String> getUnsavedAnnotationsJson() async => '[]';
  @override
  Future<String> addAnnotationJson(String jsonAnnotation,
          {String? attachment}) async =>
      jsonAnnotation;
  @override
  Future<bool> removeAnnotation(int pageIndex, String annotationId) async =>
      true;
  @override
  Future<AnnotationProperties?> getAnnotationProperties(
          int pageIndex, String annotationId) async =>
      null;
  @override
  Future<bool> saveAnnotationProperties(
          AnnotationProperties properties) async =>
      true;
  @override
  Future<String> searchAnnotationsJson(String query, {int? pageIndex}) async =>
      '[]';
  @override
  Future<String> exportXfdf({int? pageIndex}) async => '';
  @override
  Future<bool> importXfdf(String xfdfString) async => true;
}

class FakeBookmarkManager implements BookmarkManagerInterface {
  @override
  Future<List<Bookmark>> getBookmarks() async => [];
  @override
  Future<Bookmark> addBookmark(Bookmark bookmark) async => bookmark;
  @override
  Future<bool> removeBookmark(Bookmark bookmark) async => true;
  @override
  Future<bool> updateBookmark(Bookmark bookmark) async => true;
  @override
  Future<List<Bookmark>> getBookmarksForPage(int pageIndex) async => [];
  @override
  Future<bool> hasBookmarkForPage(int pageIndex) async => false;
}

class FakeFormManager implements FormManagerInterface {
  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) async => null;
  @override
  Future<bool> setFormFieldValue(
          String value, String fullyQualifiedName) async =>
      true;
  @override
  Future<String> getFormFieldsJson() async => '[]';
  @override
  Future<String> getFormFieldJson(String fieldName) async => '{}';
}

// ---------------------------------------------------------------------------
// Test doubles — custom managers (for factory closure tests)
// ---------------------------------------------------------------------------

class CustomAnnotationManager extends FakeAnnotationManager {
  @override
  Future<String> getAnnotationsJson(int pageIndex, String type) async =>
      '["custom"]';
}

class CustomBookmarkManager extends FakeBookmarkManager {
  @override
  Future<List<Bookmark>> getBookmarks() async => [Bookmark(name: 'custom')];
}

class CustomFormManager extends FakeFormManager {
  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) async =>
      'custom_value';
}

// ---------------------------------------------------------------------------
// Test doubles — document
// ---------------------------------------------------------------------------

/// Minimal [NutrientDocumentInterface] implementation for testing.
///
/// Supports factory closures for manager injection, mirroring the
/// pattern used by NutrientDocumentAndroid/iOS/Web.
class FakePdfDocument implements NutrientDocumentInterface {
  int pageCount = 3;
  bool closed = false;

  final AnnotationManagerInterface Function(FakePdfDocument)?
      _annotationFactory;
  final BookmarkManagerInterface Function(FakePdfDocument)? _bookmarkFactory;
  final FormManagerInterface Function(FakePdfDocument)? _formFactory;

  FakePdfDocument({
    AnnotationManagerInterface Function(FakePdfDocument)?
        annotationManagerFactory,
    BookmarkManagerInterface Function(FakePdfDocument)? bookmarkManagerFactory,
    FormManagerInterface Function(FakePdfDocument)? formManagerFactory,
  })  : _annotationFactory = annotationManagerFactory,
        _bookmarkFactory = bookmarkManagerFactory,
        _formFactory = formManagerFactory;

  late final AnnotationManagerInterface _annotations =
      _annotationFactory?.call(this) ?? FakeAnnotationManager();
  late final BookmarkManagerInterface _bookmarks =
      _bookmarkFactory?.call(this) ?? FakeBookmarkManager();
  late final FormManagerInterface _forms =
      _formFactory?.call(this) ?? FakeFormManager();

  @override
  AnnotationManagerInterface get annotations => _annotations;
  @override
  BookmarkManagerInterface get bookmarks => _bookmarks;
  @override
  FormManagerInterface get forms => _forms;

  @override
  Future<int> getPageCount() async => pageCount;

  @override
  Future<PageInfo> getPageInfo(int pageIndex) async => PageInfo(
        pageIndex: pageIndex,
        width: 612,
        height: 792,
        rotation: 0,
      );

  @override
  Future<bool> save({String? outputPath, DocumentSaveOptions? options}) async =>
      true;

  @override
  Future<Uint8List> exportPdf({DocumentSaveOptions? options}) async =>
      Uint8List(0);

  @override
  Future<bool> hasUnsavedChanges() async => false;

  @override
  Future<bool> applyInstantJson(String annotationsJson) async => true;

  @override
  Future<String?> exportInstantJson() async => '{}';

  @override
  Future<void> setAuthorName(String name) async {}

  @override
  Future<String> getAuthorName() async => 'Test Author';

  @override
  Future<bool> close() async {
    closed = true;
    return true;
  }
}

// ---------------------------------------------------------------------------
// Test doubles — controllers
// ---------------------------------------------------------------------------

/// Concrete [NutrientController] for testing.
class TestController extends NutrientController {
  final FakePdfDocument _document = FakePdfDocument();

  @override
  NutrientDocumentInterface get document => _document;

  /// Exposes the protected [emitEvent] for tests.
  void emit(NutrientEvent event) => emitEvent(event);
}

/// A user-defined controller interface using [NutrientControllerInterface].
abstract class MyCustomController implements NutrientControllerInterface {
  Future<int> getCurrentPageIndex();
  Future<void> goToPage(int pageIndex);
}

/// A concrete adapter that implements the custom controller interface
/// by extending [NutrientController] (simulating what a real adapter does).
class TestCustomAdapter extends NutrientController
    implements MyCustomController {
  final FakePdfDocument _document = FakePdfDocument();
  int _currentPage = 0;

  @override
  NutrientDocumentInterface get document => _document;

  @override
  Future<int> getCurrentPageIndex() async => _currentPage;

  @override
  Future<void> goToPage(int pageIndex) async {
    _currentPage = pageIndex;
  }
}

/// A minimal [NutrientPlatformAdapter] double used to exercise adapter slot
/// resolution and the default-adapter fallback. License activation no longer
/// lives on the adapter (see [FakeNutrientFlutterPlatform.activateLicense]).
class RecordingAdapter implements NutrientPlatformAdapter {
  RecordingAdapter(this.platform);

  @override
  final TargetPlatform platform;

  @override
  Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {}

  @override
  Future<NutrientDocumentInterface> openDocument(
    String path, {
    String? password,
  }) async =>
      FakePdfDocument();

  @override
  Future<NutrientDocumentInterface> openDocumentFromBytes(
    Uint8List bytes, {
    String? password,
  }) async =>
      FakePdfDocument();

  @override
  Future<bool> processAnnotations(String sourcePath, AnnotationType type,
          AnnotationProcessingMode mode, String destinationPath) async =>
      throw UnimplementedError();

  @override
  Future<void> dispose() async {}
}

/// A controller that is ALSO a [NutrientPlatformAdapter] (like the real
/// bundled adapters), for exercising the default / back-compat resolution
/// paths of `Nutrient.buildAdapter`.
class TestPlatformAdapter extends NutrientController
    implements NutrientPlatformAdapter {
  final FakePdfDocument _document = FakePdfDocument();
  @override
  NutrientDocumentInterface get document => _document;
  @override
  TargetPlatform get platform => TargetPlatform.android;
  @override
  Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {}
  @override
  Future<NutrientDocumentInterface> openDocument(String path,
          {String? password}) async =>
      _document;
  @override
  Future<bool> processAnnotations(String sourcePath, AnnotationType type,
          AnnotationProcessingMode mode, String destinationPath) async =>
      throw UnimplementedError();
  @override
  Future<NutrientDocumentInterface> openDocumentFromBytes(Uint8List bytes,
          {String? password}) async =>
      _document;
}

/// A user-defined controller *interface* + a concrete impl, mirroring the
/// `ReaderController` + `ReaderAndroidAdapter` pattern from the A2 proposal:
/// the registry key is the abstract interface, the value is the impl.
abstract class FakeReaderController implements NutrientController {
  int get marker;
}

class FakeReaderAdapter extends NutrientController
    implements FakeReaderController, NutrientPlatformAdapter {
  FakeReaderAdapter(this.marker);
  @override
  final int marker;
  final FakePdfDocument _document = FakePdfDocument();
  @override
  NutrientDocumentInterface get document => _document;
  @override
  TargetPlatform get platform => TargetPlatform.android;
  @override
  Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {}
  @override
  Future<NutrientDocumentInterface> openDocument(String path,
          {String? password}) async =>
      _document;
  @override
  Future<NutrientDocumentInterface> openDocumentFromBytes(Uint8List bytes,
          {String? password}) async =>
      _document;
  @override
  Future<bool> processAnnotations(String sourcePath, AnnotationType type,
          AnnotationProcessingMode mode, String destinationPath) async =>
      throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NutrientControllerInterface', () {
    test('can be implemented by a custom controller type', () {
      final adapter = TestCustomAdapter();
      expect(adapter, isA<NutrientControllerInterface>());
      expect(adapter, isA<MyCustomController>());
    });

    test('provides document access through the interface', () async {
      final NutrientControllerInterface controller = TestCustomAdapter();
      final count = await controller.document.getPageCount();
      expect(count, 3);
    });

    test('exposes isReady and isDisposed', () {
      final NutrientControllerInterface controller = TestCustomAdapter();
      expect(controller.isReady, isFalse);
      expect(controller.isDisposed, isFalse);
    });

    test('custom methods are accessible through custom interface', () async {
      final MyCustomController controller = TestCustomAdapter();
      expect(await controller.getCurrentPageIndex(), 0);
      await controller.goToPage(5);
      expect(await controller.getCurrentPageIndex(), 5);
    });
  });

  group('NutrientController', () {
    late TestController controller;

    setUp(() {
      controller = TestController();
    });

    test('implements NutrientControllerInterface', () {
      expect(controller, isA<NutrientControllerInterface>());
    });

    test('starts not ready and not disposed', () {
      expect(controller.isReady, isFalse);
      expect(controller.isDisposed, isFalse);
    });

    test('markReady transitions isReady to true', () async {
      await controller.markReady();
      expect(controller.isReady, isTrue);
      expect(controller.isDisposed, isFalse);
    });

    test(
        'buffers events emitted before the first listener and delivers '
        'them once a listener subscribes', () async {
      // A consumer typically subscribes in onControllerReady, which can run
      // after the native document listener has already emitted
      // DocumentLoadedEvent. A plain broadcast stream would drop it; the
      // controller buffers it instead.
      controller.emit(DocumentLoadedEvent(controller.document));

      final received = <NutrientEvent>[];
      controller.events.listen(received.add);

      // Buffered events flush on a microtask after the listener is wired.
      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(1));
      expect(received.single, isA<DocumentLoadedEvent>());
    });

    test('a buffered DocumentLoadedEvent exposes the controller document',
        () async {
      controller.emit(DocumentLoadedEvent(controller.document));

      final received = <NutrientEvent>[];
      controller.events.listen(received.add);
      await Future<void>.delayed(Duration.zero);

      final event = received.single as DocumentLoadedEvent;
      expect(event.document, same(controller.document));
    });

    test('preserves order of buffered events', () async {
      controller.emit(DocumentLoadedEvent(controller.document));
      controller.emit(const PageChangedEvent(3));

      final received = <NutrientEvent>[];
      controller.events.listen(received.add);
      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(2));
      expect(received[0], isA<DocumentLoadedEvent>());
      expect(received[1], isA<PageChangedEvent>());
    });

    test('delivers events emitted after subscription directly', () async {
      final received = <NutrientEvent>[];
      controller.events.listen(received.add);

      controller.emit(const PageChangedEvent(1));
      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(1));
      expect(received.single, isA<PageChangedEvent>());
    });

    test('does not replay buffered events to later subscribers', () async {
      controller.emit(DocumentLoadedEvent(controller.document));

      final first = <NutrientEvent>[];
      controller.events.listen(first.add);
      await Future<void>.delayed(Duration.zero);
      expect(first, hasLength(1));

      // A second listener joining afterwards follows normal broadcast
      // semantics — it only sees events emitted from now on.
      final second = <NutrientEvent>[];
      controller.events.listen(second.add);
      controller.emit(const PageChangedEvent(2));
      await Future<void>.delayed(Duration.zero);

      expect(second, hasLength(1));
      expect(second.single, isA<PageChangedEvent>());
    });

    test('dispose transitions state correctly', () async {
      await controller.markReady();
      expect(controller.isReady, isTrue);

      await controller.dispose();
      expect(controller.isReady, isFalse);
      expect(controller.isDisposed, isTrue);
    });

    test('dispose is idempotent', () async {
      await controller.dispose();
      await controller.dispose();
      expect(controller.isDisposed, isTrue);
    });

    test('markReady throws after dispose', () async {
      await controller.dispose();
      expect(() => controller.markReady(), throwsStateError);
    });

    test('attachViewHandle throws after dispose', () async {
      await controller.dispose();
      final handle = NutrientViewHandle.forPlatform(1);
      expect(() => controller.attachViewHandle(handle), throwsStateError);
    });

    test('attachViewHandle stores the handle', () {
      final handle = NutrientViewHandle.forPlatform(42);
      controller.attachViewHandle(handle);
      // ignore: invalid_use_of_protected_member
      expect(controller.viewHandle, same(handle));
      // ignore: invalid_use_of_protected_member
      expect(controller.viewHandle?.viewId, 42);
    });

    test('consumeViewAttached fires once per attach, then no-ops', () {
      // Nothing attached yet → no per-view cleanup to run.
      // ignore: invalid_use_of_protected_member
      expect(controller.consumeViewAttached(), isFalse);

      controller.attachViewHandle(NutrientViewHandle.forPlatform(1));
      // The first detach after an attach consumes the flag…
      // ignore: invalid_use_of_protected_member
      expect(controller.consumeViewAttached(), isTrue);
      // …a redundant second detach in the same teardown is a no-op, so
      // per-view cleanup (document close, detach hooks) can't run twice.
      // ignore: invalid_use_of_protected_member
      expect(controller.consumeViewAttached(), isFalse);

      // Re-attaching (a global adapter reused by the next view) re-arms it.
      controller.attachViewHandle(NutrientViewHandle.forPlatform(2));
      // ignore: invalid_use_of_protected_member
      expect(controller.consumeViewAttached(), isTrue);
    });

    test('document is accessible', () async {
      final count = await controller.document.getPageCount();
      expect(count, 3);
    });

    test('setAnnotationConfigurations throws UnimplementedError by default',
        () {
      expect(
        () => controller.setAnnotationConfigurations({'ink': {}}),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('setAnnotationMenuConfiguration throws UnimplementedError by default',
        () {
      expect(
        () => controller.setAnnotationMenuConfiguration({}),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Platform-adapter API review — A1: shared-adapter multi-view collision.
  //
  // A registered adapter (Nutrient.androidAdapter / iosAdapter / webAdapter) is
  // a process-global singleton that ALSO extends NutrientController, so it
  // carries per-view state (viewHandle, document, event stream). Every
  // NutrientDocumentView that doesn't pass its own `adapter` resolves to that
  // single instance, so two simultaneous views would clobber each other.
  //
  // `attachViewHandle` now guards against this: a previously-attached view is
  // "live" only while its native instances are registered (a view unregisters
  // them via NutrientViewHandle.dispose when torn down), so concurrent reuse
  // trips a debug assert while sequential reuse stays allowed.
  // ---------------------------------------------------------------------------
  group('Shared-adapter multi-view collision guard (review A1)', () {
    // A view is "live" while its native instances are registered; simulate
    // creation/teardown by registering/unregistering a marker for the view id.
    void registerView(int viewId) =>
        NativeInstanceRegistry.register(viewId, 'marker', Object());
    void tearDownView(int viewId) => NativeInstanceRegistry.unregister(viewId);

    tearDown(() {
      for (final id in [1, 2, 5]) {
        NativeInstanceRegistry.unregister(id);
      }
    });

    test('attaching a second LIVE view to the same controller asserts', () {
      final shared = TestController(); // the one global registered adapter
      registerView(1);
      shared
          .attachViewHandle(NutrientViewHandle.forPlatform(1)); // view A (live)

      registerView(2);
      expect(
        () => shared.attachViewHandle(NutrientViewHandle.forPlatform(2)),
        throwsA(isA<AssertionError>()),
        reason: 'one adapter instance cannot back two concurrent live views',
      );
    });

    test('the controller is reusable once the first view is torn down', () {
      final shared = TestController();
      registerView(1);
      shared.attachViewHandle(NutrientViewHandle.forPlatform(1));

      tearDownView(1); // view A disposed → its instances unregistered

      // Sequential reuse of the global adapter is allowed.
      shared.attachViewHandle(NutrientViewHandle.forPlatform(2));
      // ignore: invalid_use_of_protected_member
      expect(shared.viewHandle?.viewId, 2);
    });

    test('re-attaching the same view id is allowed (idempotent)', () {
      final shared = TestController();
      registerView(5);
      shared.attachViewHandle(NutrientViewHandle.forPlatform(5));
      // Same id (e.g. a re-attach for the same view) must not trip the guard.
      shared.attachViewHandle(NutrientViewHandle.forPlatform(5));
      // ignore: invalid_use_of_protected_member
      expect(shared.viewHandle?.viewId, 5);
    });
  });

  group('NutrientDocumentInterface', () {
    late FakePdfDocument doc;

    setUp(() {
      doc = FakePdfDocument();
    });

    test('getPageCount returns expected value', () async {
      expect(await doc.getPageCount(), 3);
      doc.pageCount = 10;
      expect(await doc.getPageCount(), 10);
    });

    test('getPageInfo returns correct structure', () async {
      final info = await doc.getPageInfo(0);
      expect(info.pageIndex, 0);
      expect(info.width, 612);
      expect(info.height, 792);
      expect(info.rotation, 0);
    });

    test('close sets closed flag', () async {
      expect(doc.closed, isFalse);
      await doc.close();
      expect(doc.closed, isTrue);
    });

    test('exposes annotations manager', () async {
      expect(doc.annotations, isA<AnnotationManagerInterface>());
      final json = await doc.annotations.getAnnotationsJson(0, 'all');
      expect(json, '[]');
    });

    test('exposes bookmarks manager', () async {
      expect(doc.bookmarks, isA<BookmarkManagerInterface>());
      final bookmarks = await doc.bookmarks.getBookmarks();
      expect(bookmarks, isEmpty);
    });

    test('exposes forms manager', () async {
      expect(doc.forms, isA<FormManagerInterface>());
      final value = await doc.forms.getFormFieldValue('name');
      expect(value, isNull);
    });

    test('does not contain setAnnotationConfigurations', () {
      expect(doc, isA<NutrientDocumentInterface>());
      expect(doc, isNot(isA<NutrientControllerInterface>()));
    });
  });

  group('Factory closure manager injection', () {
    test('uses default managers when no factories provided', () {
      final doc = FakePdfDocument();
      expect(doc.annotations, isA<FakeAnnotationManager>());
      expect(doc.bookmarks, isA<FakeBookmarkManager>());
      expect(doc.forms, isA<FakeFormManager>());
    });

    test('uses custom annotation manager from factory', () async {
      final doc = FakePdfDocument(
        annotationManagerFactory: (_) => CustomAnnotationManager(),
      );
      expect(doc.annotations, isA<CustomAnnotationManager>());
      final json = await doc.annotations.getAnnotationsJson(0, 'all');
      expect(json, '["custom"]');
      // Other managers are still defaults
      expect(doc.bookmarks, isA<FakeBookmarkManager>());
      expect(doc.forms, isA<FakeFormManager>());
    });

    test('uses custom bookmark manager from factory', () async {
      final doc = FakePdfDocument(
        bookmarkManagerFactory: (_) => CustomBookmarkManager(),
      );
      expect(doc.bookmarks, isA<CustomBookmarkManager>());
      final bookmarks = await doc.bookmarks.getBookmarks();
      expect(bookmarks, hasLength(1));
      expect(bookmarks.first.name, 'custom');
    });

    test('uses custom form manager from factory', () async {
      final doc = FakePdfDocument(
        formManagerFactory: (_) => CustomFormManager(),
      );
      expect(doc.forms, isA<CustomFormManager>());
      final value = await doc.forms.getFormFieldValue('any');
      expect(value, 'custom_value');
    });

    test('can replace all managers at once', () {
      final doc = FakePdfDocument(
        annotationManagerFactory: (_) => CustomAnnotationManager(),
        bookmarkManagerFactory: (_) => CustomBookmarkManager(),
        formManagerFactory: (_) => CustomFormManager(),
      );
      expect(doc.annotations, isA<CustomAnnotationManager>());
      expect(doc.bookmarks, isA<CustomBookmarkManager>());
      expect(doc.forms, isA<CustomFormManager>());
    });

    test('factory receives the document instance', () {
      FakePdfDocument? receivedDoc;
      final doc = FakePdfDocument(
        annotationManagerFactory: (d) {
          receivedDoc = d;
          return CustomAnnotationManager();
        },
      );
      // Access annotations to trigger lazy init
      doc.annotations;
      expect(receivedDoc, same(doc));
    });

    test('managers are lazily initialized', () {
      var factoryCalled = false;
      final doc = FakePdfDocument(
        annotationManagerFactory: (_) {
          factoryCalled = true;
          return CustomAnnotationManager();
        },
      );
      expect(factoryCalled, isFalse);
      doc.annotations; // triggers lazy init
      expect(factoryCalled, isTrue);
    });

    test('manager instance is cached after first access', () {
      var callCount = 0;
      final doc = FakePdfDocument(
        annotationManagerFactory: (_) {
          callCount++;
          return CustomAnnotationManager();
        },
      );
      final first = doc.annotations;
      final second = doc.annotations;
      expect(callCount, 1);
      expect(first, same(second));
    });
  });

  group('Bookmark', () {
    test('fromJson and toJson roundtrip', () {
      final original = Bookmark(
        pdfBookmarkId: 'abc-123',
        name: 'Chapter 1',
        actionJson: '{"pageIndex": 5}',
      );
      final json = original.toJson();
      final restored = Bookmark.fromJson(json);
      expect(restored.pdfBookmarkId, 'abc-123');
      expect(restored.name, 'Chapter 1');
      expect(restored.actionJson, '{"pageIndex": 5}');
    });

    test('toJson omits null fields', () {
      final bookmark = Bookmark(name: 'Test');
      final json = bookmark.toJson();
      expect(json.containsKey('pdfBookmarkId'), isFalse);
      expect(json.containsKey('actionJson'), isFalse);
      expect(json['name'], 'Test');
    });

    test('fromJson handles missing fields', () {
      final bookmark = Bookmark.fromJson({});
      expect(bookmark.pdfBookmarkId, isNull);
      expect(bookmark.name, isNull);
      expect(bookmark.actionJson, isNull);
    });
  });

  group('AnnotationProperties', () {
    test('fromJson and toJson roundtrip with all fields', () {
      final original = AnnotationProperties(
        annotationId: 'ann-001',
        pageIndex: 2,
        strokeColor: 0xFFFF0000,
        fillColor: 0xFF00FF00,
        opacity: 0.75,
        lineWidth: 2.5,
        flagsJson: '["print"]',
        customDataJson: '{"key": "value"}',
        contents: 'Hello',
        subject: 'Note',
        creator: 'Alice',
        bboxJson: '{"x":10,"y":20,"width":100,"height":50}',
        note: 'A review note',
        inkLinesJson: '[[{"x":0,"y":0}]]',
        fontName: 'Helvetica',
        fontSize: 14.0,
        iconName: 'Comment',
      );
      final json = original.toJson();
      final restored = AnnotationProperties.fromJson(json);
      expect(restored.annotationId, 'ann-001');
      expect(restored.pageIndex, 2);
      expect(restored.strokeColor, 0xFFFF0000);
      expect(restored.fillColor, 0xFF00FF00);
      expect(restored.opacity, 0.75);
      expect(restored.lineWidth, 2.5);
      expect(restored.flagsJson, '["print"]');
      expect(restored.customDataJson, '{"key": "value"}');
      expect(restored.contents, 'Hello');
      expect(restored.subject, 'Note');
      expect(restored.creator, 'Alice');
      expect(restored.bboxJson, '{"x":10,"y":20,"width":100,"height":50}');
      expect(restored.note, 'A review note');
      expect(restored.inkLinesJson, '[[{"x":0,"y":0}]]');
      expect(restored.fontName, 'Helvetica');
      expect(restored.fontSize, 14.0);
      expect(restored.iconName, 'Comment');
    });

    test('toJson omits null fields', () {
      final props = AnnotationProperties(annotationId: 'ann-002', pageIndex: 0);
      final json = props.toJson();
      expect(json['annotationId'], 'ann-002');
      expect(json['pageIndex'], 0);
      expect(json.containsKey('strokeColor'), isFalse);
      expect(json.containsKey('fillColor'), isFalse);
      expect(json.containsKey('opacity'), isFalse);
      expect(json.containsKey('lineWidth'), isFalse);
      expect(json.containsKey('contents'), isFalse);
      expect(json.containsKey('creator'), isFalse);
    });

    test('fromJson handles missing/null fields gracefully', () {
      final props = AnnotationProperties.fromJson({});
      expect(props.annotationId, isNull);
      expect(props.pageIndex, isNull);
      expect(props.strokeColor, isNull);
      expect(props.opacity, isNull);
      expect(props.fontSize, isNull);
    });

    test('fromJson parses CSS hex string colors from Web SDK', () {
      final props = AnnotationProperties.fromJson({
        'strokeColor': '#607d8b',
        'fillColor': '#FF00FF00',
      });
      expect(props.strokeColor, 0xFF607D8B);
      expect(props.fillColor, 0xFF00FF00);
    });

    test('fromJson coerces num to double for opacity', () {
      final props = AnnotationProperties.fromJson(
          {'opacity': 1, 'lineWidth': 3, 'fontSize': 12});
      expect(props.opacity, isA<double>());
      expect(props.opacity, 1.0);
      expect(props.lineWidth, isA<double>());
      expect(props.lineWidth, 3.0);
      expect(props.fontSize, isA<double>());
      expect(props.fontSize, 12.0);
    });
  });

  group('PageInfo', () {
    test('constructor stores all fields', () {
      final info = PageInfo(
        pageIndex: 2,
        width: 595.0,
        height: 842.0,
        rotation: 90,
        label: 'iii',
      );
      expect(info.pageIndex, 2);
      expect(info.width, 595.0);
      expect(info.height, 842.0);
      expect(info.rotation, 90);
      expect(info.label, 'iii');
    });

    test('label defaults to null', () {
      final info = PageInfo(
        pageIndex: 0,
        width: 612,
        height: 792,
        rotation: 0,
      );
      expect(info.label, isNull);
    });

    test('toString includes all fields', () {
      final info = PageInfo(
        pageIndex: 1,
        width: 100,
        height: 200,
        rotation: 180,
        label: 'A',
      );
      final str = info.toString();
      expect(str, contains('pageIndex: 1'));
      expect(str, contains('width: 100'));
      expect(str, contains('rotation: 180'));
      expect(str, contains('label: A'));
    });
  });

  group('Nutrient static API', () {
    tearDown(() async {
      await Nutrient.reset();
      debugDefaultTargetPlatformOverride = null;
    });

    test('initialize licenses the platform with the current platform key',
        () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final platform =
          FakeNutrientFlutterPlatform(RecordingAdapter(TargetPlatform.android));
      NutrientFlutterPlatform.instance = platform;
      addTearDown(() => NutrientFlutterPlatform.instance = null);

      await Nutrient.initialize(androidLicenseKey: 'ANDROID_KEY');

      expect(platform.activateLicenseCalled, isTrue);
      expect(platform.activatedKey, 'ANDROID_KEY');
    });

    test('initialize licenses with a null key when none is provided', () async {
      // No key ⇒ trial mode; activation still runs (with null) so the platform
      // can decide what to do.
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final platform =
          FakeNutrientFlutterPlatform(RecordingAdapter(TargetPlatform.iOS));
      NutrientFlutterPlatform.instance = platform;
      addTearDown(() => NutrientFlutterPlatform.instance = null);

      await Nutrient.initialize();

      expect(platform.activateLicenseCalled, isTrue);
      expect(platform.activatedKey, isNull);
    });

    test('initialize licenses with the current platform key only', () async {
      // Both keys supplied, Android target ⇒ the platform is licensed with the
      // Android key (currentLicenseKey), never the iOS one.
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final platform =
          FakeNutrientFlutterPlatform(RecordingAdapter(TargetPlatform.android));
      NutrientFlutterPlatform.instance = platform;
      addTearDown(() => NutrientFlutterPlatform.instance = null);

      await Nutrient.initialize(
        androidLicenseKey: 'ANDROID_KEY',
        iosLicenseKey: 'IOS_KEY',
      );

      expect(platform.activatedKey, 'ANDROID_KEY');
    });

    test(
        'initialize falls back to the platform default adapter when none '
        'is provided', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final fallback = RecordingAdapter(TargetPlatform.android);
      final platform = FakeNutrientFlutterPlatform(fallback);
      NutrientFlutterPlatform.instance = platform;
      addTearDown(() => NutrientFlutterPlatform.instance = null);

      await Nutrient.initialize(androidLicenseKey: 'ANDROID_KEY');

      // The default adapter was registered (so NutrientDocumentView works with
      // no adapter passed) and the platform was licensed.
      expect(Nutrient.currentAdapter, same(fallback));
      expect(platform.createDefaultAdapterCalled, isTrue);
      expect(platform.activatedKey, 'ANDROID_KEY');
    });

    test('an explicit adapter takes precedence over the platform default',
        () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final explicit = RecordingAdapter(TargetPlatform.android);
      final fallback = RecordingAdapter(TargetPlatform.android);
      final platform = FakeNutrientFlutterPlatform(fallback);
      NutrientFlutterPlatform.instance = platform;
      addTearDown(() => NutrientFlutterPlatform.instance = null);

      await Nutrient.initialize(androidAdapter: explicit);

      expect(Nutrient.currentAdapter, same(explicit));
      // The platform default wasn't needed.
      expect(platform.createDefaultAdapterCalled, isFalse);
    });

    test('version is a real semantic version (not the dev placeholder)', () {
      expect(Nutrient.version, isNot('1.0.0-dev'));
      expect(Nutrient.version, matches(RegExp(r'^\d+\.\d+\.\d+')));
    });

    test('frameworkVersion reads from the platform implementation', () async {
      final platform = FakeNutrientFlutterPlatform(
        RecordingAdapter(TargetPlatform.android),
        platformVersion: '11.5.1',
      );
      NutrientFlutterPlatform.instance = platform;
      addTearDown(() => NutrientFlutterPlatform.instance = null);
      expect(await Nutrient.frameworkVersion, '11.5.1');
    });

    // ── Type-keyed adapter registry (A2 / Option D) ──────────────────────────
    // These prove the Dart mechanism the design relies on: reified generics let
    // us key a registry by the controller TYPE and build a fresh instance per
    // view, with no reflection.

    test('addAdapterClass + buildAdapter resolves a factory by reified type',
        () {
      Nutrient.addAdapterClass<FakeReaderController>(
          () => FakeReaderAdapter(7));
      final FakeReaderController c =
          Nutrient.buildAdapter<FakeReaderController>();
      expect(c.marker, 7);
      expect(c, isA<FakeReaderAdapter>());
    });

    test('buildAdapter returns a FRESH instance on every call', () {
      Nutrient.addAdapterClass<FakeReaderController>(
          () => FakeReaderAdapter(1));
      final a = Nutrient.buildAdapter<FakeReaderController>();
      final b = Nutrient.buildAdapter<FakeReaderController>();
      expect(identical(a, b), isFalse);
    });

    test('two distinct controller types coexist in the registry', () {
      Nutrient.addAdapterClass<FakeReaderController>(
          () => FakeReaderAdapter(1));
      Nutrient.addAdapterClass<TestController>(() => TestController());
      expect(Nutrient.buildAdapter<FakeReaderController>(),
          isA<FakeReaderAdapter>());
      expect(Nutrient.buildAdapter<TestController>(), isA<TestController>());
    });

    test(
        'buildAdapter throws an actionable StateError for an unregistered type',
        () {
      expect(
        () => Nutrient.buildAdapter<FakeReaderController>(),
        throwsA(isA<StateError>().having((e) => e.toString(), 'toString',
            contains('No adapter registered for FakeReaderController'))),
      );
    });

    test('removeAdapterClass unregisters a factory', () {
      Nutrient.addAdapterClass<TestController>(() => TestController());
      expect(Nutrient.hasAdapterClass<TestController>(), isTrue);
      Nutrient.removeAdapterClass<TestController>();
      expect(Nutrient.hasAdapterClass<TestController>(), isFalse);
      expect(() => Nutrient.buildAdapter<TestController>(),
          throwsA(isA<StateError>()));
    });

    test('reset clears the registry', () async {
      Nutrient.addAdapterClass<TestController>(() => TestController());
      await Nutrient.reset();
      expect(Nutrient.hasAdapterClass<TestController>(), isFalse);
    });

    test(
        'buildAdapter<NutrientController> falls back to the platform default '
        'viewer', () {
      final def = TestPlatformAdapter();
      NutrientFlutterPlatform.instance = FakeNutrientFlutterPlatform(def);
      addTearDown(() => NutrientFlutterPlatform.instance = null);
      // No specific type requested ⇒ the platform's built-in default viewer.
      expect(
          identical(Nutrient.buildAdapter<NutrientController>(), def), isTrue);
    });

    test(
        'buildAdapter<NutrientInstantController> falls back to the platform '
        'default Instant controller', () {
      final instantDef = TestInstantAdapter();
      final platform = FakeNutrientFlutterPlatform(TestPlatformAdapter())
        ..createInstantDefault = (() => instantDef);
      NutrientFlutterPlatform.instance = platform;
      addTearDown(() => NutrientFlutterPlatform.instance = null);
      expect(
        identical(
            Nutrient.buildAdapter<NutrientInstantController>(), instantDef),
        isTrue,
      );
    });

    test(
        'buildAdapter<NutrientInstantController> throws an actionable error '
        'when the platform has no Instant default', () {
      NutrientFlutterPlatform.instance =
          FakeNutrientFlutterPlatform(TestPlatformAdapter());
      addTearDown(() => NutrientFlutterPlatform.instance = null);
      expect(
        () => Nutrient.buildAdapter<NutrientInstantController>(),
        throwsStateError,
      );
    });

    test(
        'bare-view default is a FRESH instance per call, NOT the shared global '
        'slot (multi-view safe, even after initialize)', () async {
      // Regression for the Tier-1 collision: after initialize() fills the global
      // slot with one default, two bare NutrientDocumentView()s must each build
      // their OWN default — not share the slot. Without resolving the fresh
      // default BEFORE the slot, both calls would return the one shared slot
      // instance and this fails.
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final platform = FakeNutrientFlutterPlatform.freshDefaults(
        () => TestPlatformAdapter(),
      );
      NutrientFlutterPlatform.instance = platform;
      addTearDown(() => NutrientFlutterPlatform.instance = null);

      await Nutrient.initialize(); // populates the global slot with a default

      final a = Nutrient.buildAdapter<NutrientController>();
      final b = Nutrient.buildAdapter<NutrientController>();
      expect(identical(a, b), isFalse, reason: 'each bare view gets its own');
      expect(identical(a, Nutrient.currentAdapter), isFalse,
          reason: 'not the shared global slot');
    });

    test(
        'a deprecated global-slot instance resolves via buildAdapter<its type>',
        () async {
      // Back-compat: an instance registered through initialize()'s global slot
      // still resolves when a view is typed to that adapter's concrete type.
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final adapter = FakeReaderAdapter(42);
      await Nutrient.initialize(androidAdapter: adapter);
      expect(identical(Nutrient.buildAdapter<FakeReaderAdapter>(), adapter),
          isTrue);
    });

    // ── Headless Nutrient.openDocument (A2 / S5) ─────────────────────────────
    test('openDocument hosts on the platform default when no adapter is given',
        () async {
      NutrientFlutterPlatform.instance =
          FakeNutrientFlutterPlatform(RecordingAdapter(TargetPlatform.android));
      addTearDown(() => NutrientFlutterPlatform.instance = null);
      final doc = await Nutrient.openDocument('doc.pdf');
      expect(doc, isA<NutrientDocumentInterface>());
    });

    test('openDocument hosts on the supplied adapter', () async {
      final adapter = TestPlatformAdapter();
      final doc = await Nutrient.openDocument('doc.pdf', adapter: adapter);
      expect(identical(doc, adapter.document), isTrue);
    });

    test('openDocument throws when no adapter and no platform default', () {
      NutrientFlutterPlatform.instance = null;
      expect(
        () => Nutrient.openDocument('doc.pdf'),
        throwsA(isA<StateError>().having((e) => e.toString(), 'message',
            contains('needs a platform adapter'))),
      );
    });
  });
}

/// Fake federated platform whose [createDefaultAdapter] returns a known
/// adapter, and which records [activateLicense] / reports a [platformVersion],
/// so tests can assert [Nutrient.initialize] drives license activation through
/// the platform (not the adapter) and [Nutrient.frameworkVersion] reads from it.
/// Extending [NutrientFlutterPlatform] satisfies the platform-interface token
/// check.
class FakeNutrientFlutterPlatform extends NutrientFlutterPlatform {
  /// Returns the same [defaultAdapter] instance on every [createDefaultAdapter]
  /// call (fine for tests that don't care about default-instance identity).
  FakeNutrientFlutterPlatform(NutrientPlatformAdapter defaultAdapter,
      {this.platformVersion})
      : _createDefault = (() => defaultAdapter);

  /// Returns a FRESH instance on every [createDefaultAdapter] call (mirrors the
  /// real federation: `() => DefaultAndroidAdapter()`), so tests can assert that
  /// bare `NutrientDocumentView()`s each get their own default controller.
  FakeNutrientFlutterPlatform.freshDefaults(this._createDefault,
      {this.platformVersion});

  final NutrientPlatformAdapter Function() _createDefault;

  /// The value returned by [getPlatformVersion].
  final String? platformVersion;

  /// Records the last [activateLicense] call.
  bool activateLicenseCalled = false;
  String? activatedKey;

  /// Whether [createDefaultAdapter] was invoked (i.e. no explicit adapter).
  bool createDefaultAdapterCalled = false;

  @override
  Future<String?> getPlatformVersion() async => platformVersion;

  @override
  Future<void> activateLicense(String? licenseKey) async {
    activateLicenseCalled = true;
    activatedKey = licenseKey;
  }

  @override
  NutrientPlatformAdapter createDefaultAdapter() {
    createDefaultAdapterCalled = true;
    return _createDefault();
  }

  /// Optional Instant default — set to serve [createDefaultInstantAdapter];
  /// left null, the base [UnimplementedError] behavior applies.
  NutrientPlatformAdapter Function()? createInstantDefault;

  @override
  NutrientPlatformAdapter createDefaultInstantAdapter() {
    final factory = createInstantDefault;
    if (factory == null) return super.createDefaultInstantAdapter();
    return factory();
  }
}

/// A platform-adapter double that also implements the Instant controller
/// surface, standing in for the real `AndroidInstantController` /
/// `IOSInstantController` defaults.
class TestInstantAdapter extends TestPlatformAdapter
    implements NutrientInstantController {
  @override
  Future<bool> setDelayForSyncingLocalChanges(double delay) async => true;
  @override
  Future<bool> setListenToServerChanges(bool listen) async => true;
  @override
  Future<bool> syncAnnotations() async => true;
}
