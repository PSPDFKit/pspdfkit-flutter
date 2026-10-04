///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:objective_c/objective_c.dart' as objc;

import '../bindings/nutrient_ios_bindings.dart';
import 'nutrient_document_ios.dart';

/// iOS implementation of [AnnotationManagerInterface].
///
/// Uses FFI bindings to the Nutrient iOS SDK's [PSPDFAnnotationManager].
/// Obtained via `document.annotations`.
class AnnotationManagerIOS implements AnnotationManagerInterface {
  /// The document this manager operates on.
  final NutrientDocumentIOS document;

  AnnotationManagerIOS(this.document);

  // ---------------------------------------------------------------------------
  // Annotation type helpers
  // ---------------------------------------------------------------------------

  /// Converts the cross-platform type string (e.g. `"all"`, `"pspdfkit/ink"`)
  /// to a [PSPDFAnnotationType] bitmask used by the iOS SDK.
  static int annotationTypeMask(String type) {
    if (type == 'all' || type.isEmpty) {
      return PSPDFAnnotationType.PSPDFAnnotationTypeAll;
    }
    // Map Instant JSON type strings to PSPDFAnnotationType constants.
    const typeMap = {
      'pspdfkit/ink': PSPDFAnnotationType.PSPDFAnnotationTypeInk,
      'pspdfkit/text': PSPDFAnnotationType.PSPDFAnnotationTypeFreeText,
      'pspdfkit/note': PSPDFAnnotationType.PSPDFAnnotationTypeNote,
      'pspdfkit/markup/highlight':
          PSPDFAnnotationType.PSPDFAnnotationTypeHighlight,
      'pspdfkit/markup/underline':
          PSPDFAnnotationType.PSPDFAnnotationTypeUnderline,
      'pspdfkit/markup/squiggly':
          PSPDFAnnotationType.PSPDFAnnotationTypeSquiggly,
      'pspdfkit/markup/strikeout':
          PSPDFAnnotationType.PSPDFAnnotationTypeStrikeOut,
      'pspdfkit/shape/line': PSPDFAnnotationType.PSPDFAnnotationTypeLine,
      'pspdfkit/shape/rectangle': PSPDFAnnotationType.PSPDFAnnotationTypeSquare,
      'pspdfkit/shape/ellipse': PSPDFAnnotationType.PSPDFAnnotationTypeCircle,
      'pspdfkit/shape/polygon': PSPDFAnnotationType.PSPDFAnnotationTypePolygon,
      'pspdfkit/shape/polyline':
          PSPDFAnnotationType.PSPDFAnnotationTypePolyLine,
      'pspdfkit/link': PSPDFAnnotationType.PSPDFAnnotationTypeLink,
      'pspdfkit/image': PSPDFAnnotationType.PSPDFAnnotationTypeStamp,
      'pspdfkit/stamp': PSPDFAnnotationType.PSPDFAnnotationTypeStamp,
      'pspdfkit/markup/redaction':
          PSPDFAnnotationType.PSPDFAnnotationTypeRedaction,
      'pspdfkit/widget': PSPDFAnnotationType.PSPDFAnnotationTypeWidget,
      'pspdfkit/media': PSPDFAnnotationType.PSPDFAnnotationTypeRichMedia,
    };
    return typeMap[type] ?? PSPDFAnnotationType.PSPDFAnnotationTypeAll;
  }

  @override
  Future<String> getAnnotationsJson(int pageIndex, String type) async {
    final doc = document.requireDocument();
    final annotations = doc.annotationsForPageAtIndex(
      pageIndex,
      type: annotationTypeMask(type),
    );
    final result = <Map<String, dynamic>>[];
    for (final item in annotations.asDart()) {
      final annotation = PSPDFAnnotation.as(item);
      // `generateInstantJSONWithError` throws via NSErrorException for
      // annotation types that the iOS SDK can't serialize to InstantJSON
      // (e.g. some Popup / PolyLine subtypes in bundled samples).
      // Skip those rather than aborting the whole page — the Dart catalog
      // expects a complete list of "serializable" annotations, not a
      // hard failure when one widget happens to be exotic.
      try {
        final data = annotation.generateInstantJSONWithError();
        if (data != null) {
          final jsonStr = utf8.decode(data.toList());
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          result.add(map);
        }
      } catch (_) {
        // Best-effort: this annotation can't be expressed in InstantJSON.
        // Surface its name/uuid so removeAnnotation can still find it by
        // identity (which iterates the same page-annotations array).
        final id =
            annotation.name?.toDartString() ?? annotation.uuid.toDartString();
        result.add({'id': id, 'type': 'pspdfkit/unknown'});
      }
    }
    return jsonEncode(result);
  }

  @override
  Future<String> getUnsavedAnnotationsJson() async {
    final doc = document.requireDocument();
    // iOS tracks dirty annotations via the annotation save mode — collect
    // annotations from all pages that have been modified but not saved.
    final result = <Map<String, dynamic>>[];
    if (!doc.hasDirtyAnnotations) return jsonEncode(result);

    final pageCount = doc.pageCount;
    for (var i = 0; i < pageCount; i++) {
      final annotations = doc.annotationsForPageAtIndex(
        i,
        type: PSPDFAnnotationType.PSPDFAnnotationTypeAll,
      );
      for (final item in annotations.asDart()) {
        final annotation = PSPDFAnnotation.as(item);
        if (!annotation.isDirty) continue;
        final data = annotation.generateInstantJSONWithError();
        if (data != null) {
          final jsonStr = utf8.decode(data.toList());
          result.add(jsonDecode(jsonStr) as Map<String, dynamic>);
        }
      }
    }
    return jsonEncode(result);
  }

  @override
  Future<String> addAnnotationJson(
    String jsonAnnotation, {
    String? attachment,
  }) async {
    final doc = document.requireDocument();
    final docProvider = doc.documentProviderForPageAtIndex(0);
    if (docProvider == null) return jsonAnnotation;

    final bytes = utf8.encode(jsonAnnotation);
    final nsData = bytes.toNSData();

    // Build an attachment data provider from the optional binary. Parsing is
    // defensive: a malformed/invalid attachment falls back to adding the
    // annotation without it — matching the graceful degradation on Android and
    // Web (the annotation is still added, the image just doesn't render) rather
    // than throwing and failing the whole call.
    PSPDFDataContainerProvider? dataProvider;
    if (attachment != null) {
      try {
        // attachment is a JSON string: {"binary": "<base64>", "contentType": "image/png"}
        final attachmentMap = jsonDecode(attachment) as Map<String, dynamic>;
        final base64Binary = attachmentMap['binary'] as String;
        final binaryBytes = base64Decode(base64Binary);
        final binaryNSData = binaryBytes.toNSData();
        // Wrap raw bytes in a data provider the SDK can read from.
        dataProvider = PSPDFDataContainerProvider.alloc().initWithData(
          binaryNSData,
        );
      } catch (_) {
        // Malformed attachment — proceed without it.
        dataProvider = null;
      }
    }

    if (dataProvider != null) {
      // addAnnotationFromInstantJSON: deserialises from JSON, adds the
      // annotation to the document, AND attaches the binary in one step.
      final annotation = docProvider.addAnnotationFromInstantJSON(
        nsData,
        attachmentDataProvider: dataProvider,
      );
      if (annotation == null) return jsonAnnotation;
      final resultData = annotation.generateInstantJSONWithError();
      if (resultData != null) {
        return utf8.decode(resultData.toList());
      }
      return jsonAnnotation;
    }

    final annotation = InstantJSON$1.annotationFromInstantJSON(
      nsData,
      documentProvider: docProvider,
    );
    if (annotation == null) return jsonAnnotation;

    doc.addAnnotations(objc.NSMutableArray.of([annotation]), options: null);
    // Return the serialised form of the added annotation.
    final resultData = annotation.generateInstantJSONWithError();
    if (resultData != null) {
      return utf8.decode(resultData.toList());
    }
    return jsonAnnotation;
  }

  @override
  Future<bool> removeAnnotation(int pageIndex, String annotationId) async {
    final doc = document.requireDocument();
    final annotations = doc.annotationsForPageAtIndex(
      pageIndex,
      type: PSPDFAnnotationType.PSPDFAnnotationTypeAll,
    );
    for (final item in annotations.asDart()) {
      final annotation = PSPDFAnnotation.as(item);
      final name =
          annotation.name?.toDartString() ??
          ''; // ignore: invalid_null_aware_operator
      final uuid = annotation.uuid.toDartString();
      if (name == annotationId || uuid == annotationId) {
        doc.removeAnnotations(
          objc.NSMutableArray.of([annotation]),
          options: null,
        );
        return true;
      }
    }
    return false;
  }

  @override
  Future<AnnotationProperties?> getAnnotationProperties(
    int pageIndex,
    String annotationId,
  ) async {
    final doc = document.requireDocument();
    final annotations = doc.annotationsForPageAtIndex(
      pageIndex,
      type: PSPDFAnnotationType.PSPDFAnnotationTypeAll,
    );
    for (final item in annotations.asDart()) {
      final annotation = PSPDFAnnotation.as(item);
      final name =
          annotation.name?.toDartString() ??
          ''; // ignore: invalid_null_aware_operator
      final uuid = annotation.uuid.toDartString();
      if (name != annotationId && uuid != annotationId) continue;
      final data = annotation.generateInstantJSONWithError();
      if (data == null) return null;
      final map =
          jsonDecode(utf8.decode(data.toList())) as Map<String, dynamic>;
      // InstantJSON keys the id as `name`, not `annotationId`, so fromJson
      // leaves annotationId null. Stamp the authoritative id/page we were
      // queried with so the caller can round-trip into saveAnnotationProperties.
      return AnnotationProperties.fromJson(
        map,
      ).copyWith(annotationId: annotationId, pageIndex: pageIndex);
    }
    return null;
  }

  @override
  Future<bool> saveAnnotationProperties(AnnotationProperties properties) async {
    final pageIndex = properties.pageIndex ?? 0;
    final annotationId = properties.annotationId ?? '';
    final doc = document.requireDocument();
    final docProvider = doc.documentProviderForPageAtIndex(pageIndex);
    if (docProvider == null) return false;

    // Find the annotation.
    final annotations = doc.annotationsForPageAtIndex(
      pageIndex,
      type: PSPDFAnnotationType.PSPDFAnnotationTypeAll,
    );
    for (final item in annotations.asDart()) {
      final annotation = PSPDFAnnotation.as(item);
      final name =
          annotation.name?.toDartString() ??
          ''; // ignore: invalid_null_aware_operator
      final uuid = annotation.uuid.toDartString();
      if (name != annotationId && uuid != annotationId) continue;

      // Apply changes via removing and re-adding with merged JSON.
      final currentData = annotation.generateInstantJSONWithError();
      if (currentData == null) return false;
      final current =
          jsonDecode(utf8.decode(currentData.toList())) as Map<String, dynamic>;
      // Translate the model props into InstantJSON-shaped overrides:
      // `AnnotationProperties.toJson()` emits ARGB-int colours + an
      // `annotationId` key, neither valid InstantJSON (colours must be
      // `"#RRGGBB"` hex; there's no `annotationId`). Merging the raw map can
      // silently fail to apply colour changes (or be rejected).
      final updated = {...current, ...properties.toInstantJsonOverrides()};
      final updatedBytes = utf8.encode(jsonEncode(updated));
      final updatedNSData = updatedBytes.toNSData();
      final updatedAnnotation = InstantJSON$1.annotationFromInstantJSON(
        updatedNSData,
        documentProvider: docProvider,
      );
      if (updatedAnnotation == null) return false;

      doc.removeAnnotations(
        objc.NSMutableArray.of([annotation]),
        options: null,
      );
      doc.addAnnotations(
        objc.NSMutableArray.of([updatedAnnotation]),
        options: null,
      );
      return true;
    }
    return false;
  }

  @override
  Future<String> searchAnnotationsJson(String query, {int? pageIndex}) async {
    final doc = document.requireDocument();
    final result = <Map<String, dynamic>>[];
    final lowerQuery = query.toLowerCase();

    final startPage = pageIndex ?? 0;
    final endPage = pageIndex != null ? pageIndex + 1 : doc.pageCount;

    for (var i = startPage; i < endPage; i++) {
      final annotations = doc.annotationsForPageAtIndex(
        i,
        type: PSPDFAnnotationType.PSPDFAnnotationTypeAll,
      );
      for (final item in annotations.asDart()) {
        final annotation = PSPDFAnnotation.as(item);
        final contents = annotation.contents?.toDartString() ?? '';
        final name = annotation.name?.toDartString() ?? '';
        if (contents.toLowerCase().contains(lowerQuery) ||
            name.toLowerCase().contains(lowerQuery)) {
          final data = annotation.generateInstantJSONWithError();
          if (data != null) {
            result.add(
              jsonDecode(utf8.decode(data.toList())) as Map<String, dynamic>,
            );
          }
        }
      }
    }
    return jsonEncode(result);
  }

  @override
  Future<String> exportXfdf({int? pageIndex}) async {
    final doc = document.requireDocument();
    final docProvider = doc.documentProviderForPageAtIndex(0);
    if (docProvider == null) return '';

    // Collect annotations to export.
    final allAnnotations = <PSPDFAnnotation>[];
    final startPage = pageIndex ?? 0;
    final endPage = pageIndex != null ? pageIndex + 1 : doc.pageCount;
    for (var i = startPage; i < endPage; i++) {
      final pageAnnotations = doc.annotationsForPageAtIndex(
        i,
        type: PSPDFAnnotationType.PSPDFAnnotationTypeAll,
      );
      for (final item in pageAnnotations.asDart()) {
        allAnnotations.add(PSPDFAnnotation.as(item));
      }
    }

    final nsAnnotations = objc.NSMutableArray.of(allAnnotations);
    // Same no-arg `init` crash pattern as PSPDFDataContainerProvider:
    // PSPDFDataContainerSink raises an ObjC exception from plain `init`,
    // so use `alloc + initWithData:` (data is nullable; the Sink fills
    // up as the Writer writes to it).
    final sink = PSPDFDataContainerSink.alloc().initWithData(null);
    final writer = PSPDFXFDFWriter();
    writer.writeAnnotations_toDataSink_documentProvider_error(
      nsAnnotations,
      dataSink: sink,
      documentProvider: docProvider,
    );
    sink.finish();
    return utf8.decode(sink.data.toList());
  }

  @override
  Future<bool> importXfdf(String xfdfString) async {
    final doc = document.requireDocument();
    final docProvider = doc.documentProviderForPageAtIndex(0);
    if (docProvider == null) return false;

    final bytes = utf8.encode(xfdfString);
    final nsData = bytes.toNSData();
    // `PSPDFDataContainerProvider()` and `PSPDFXFDFParser()` invoke the
    // class's no-arg `+new` (and hence `-init`), which both classes
    // raise an Objective-C exception from because they require data /
    // a data-provider at init time. Crash signature:
    //   *** -[PSPDFDataContainerProvider init] (SIGABRT)
    // Use the designated initializers (`alloc + initWith...`) instead so
    // each native object gets its required arguments atomically.
    final dataProvider = PSPDFDataContainerProvider.alloc().initWithData(
      nsData,
    );
    final parser = PSPDFXFDFParser.alloc()
        .initWithDataProvider_documentProvider(
          dataProvider,
          documentProvider: docProvider,
        );
    final parsed = parser.parseWithError();
    if (parsed == null) return false;

    doc.addAnnotations(parsed, options: null);
    return true;
  }
}
