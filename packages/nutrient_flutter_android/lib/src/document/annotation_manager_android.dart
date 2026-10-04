///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

import 'package:jni/jni.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    hide StampAnnotation, AnnotationType;

import '../bindings/nutrient_android_sdk_bindings.dart'
    hide Nutrient, DocumentSaveOptions, Bookmark;
import '../utils/annotation_provider_blocking.dart';
import '../utils/jni_io.dart';
import 'nutrient_document_android.dart';

/// Android implementation of [AnnotationManagerInterface].
///
/// Uses JNI bindings to the Nutrient Android SDK's [AnnotationProvider].
/// Obtained via `document.annotations`.
class AnnotationManagerAndroid implements AnnotationManagerInterface {
  /// The document this manager operates on.
  final NutrientDocumentAndroid document;

  AnnotationManagerAndroid(this.document);

  AnnotationProvider _requireProvider() =>
      document.requireDocument().getAnnotationProvider();

  @override
  Future<String> getAnnotationsJson(int pageIndex, String type) async {
    // `AnnotationProvider`'s methods are Kotlin `suspend` fns that the jnigen
    // bindings can't call (they throw NoSuchMethodError), so all reads/writes
    // here go through [AnnotationProviderBlocking], the documented facade over
    // the SDK's synchronous companions. See that class for the why.
    final provider = _requireProvider();
    final annotations =
        AnnotationProviderBlocking.getAnnotations(provider, pageIndex);
    final filterAll = type == 'all';
    final annotationType = filterAll ? null : annotationTypeFromString(type);
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < annotations.size(); i++) {
      final annotation = annotations.get(i)!;
      if (!filterAll &&
          annotationType != null &&
          annotation.type$1.toString() != annotationType.toString()) {
        annotation.release();
        continue;
      }
      final jsonStr =
          annotation.toInstantJson().toDartString(releaseOriginal: true);
      annotation.release();
      try {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        result.add(decoded);
      } catch (_) {
        // skip malformed annotations
      }
    }
    annotations.release();
    return jsonEncode(result);
  }

  @override
  Future<String> getUnsavedAnnotationsJson() async {
    final doc = document.requireDocument();
    final provider = _requireProvider();
    final result = <Map<String, dynamic>>[];
    final pageCount = doc.getPageCount();
    for (var i = 0; i < pageCount; i++) {
      final annotations =
          AnnotationProviderBlocking.getAnnotations(provider, i);
      for (var j = 0; j < annotations.size(); j++) {
        final annotation = annotations.get(j)!;
        if (annotation.isModified) {
          try {
            final jsonStr =
                annotation.toInstantJson().toDartString(releaseOriginal: true);
            result.add(jsonDecode(jsonStr) as Map<String, dynamic>);
          } catch (_) {
            // Skip annotations that can't serialise to Instant JSON — same
            // tolerance as getAnnotationsJson.
          }
        }
        annotation.release();
      }
      annotations.release();
    }
    return jsonEncode(result);
  }

  @override
  Future<String> addAnnotationJson(String jsonAnnotation,
      {String? attachment}) async {
    final provider = _requireProvider();

    // When an attachment is provided for an image or stamp annotation, we must
    // inject a placeholder title into the JSON BEFORE creating the annotation.
    //
    // Reason: the Nutrient SDK fires `onAnnotationCreated` synchronously during
    // `createAnnotationFromInstantJson`, and the event handler calls
    // `toInstantJson()` on the newly created annotation. For stamp/image
    // annotations that call fails with "Can't create Instant JSON for stamp
    // annotation that has no content" unless the annotation already has a title,
    // stamp-type, or attached image. Since the image isn't attached yet at that
    // point, we inject a temporary title to satisfy the validator.
    String processedJson = jsonAnnotation;
    if (attachment != null) {
      try {
        final jsonMap =
            Map<String, dynamic>.from(jsonDecode(jsonAnnotation) as Map);
        final type = jsonMap['type'] as String? ?? '';
        if ((type == 'pspdfkit/image' || type == 'pspdfkit/stamp') &&
            (jsonMap['title'] == null ||
                (jsonMap['title'] as String).isEmpty)) {
          jsonMap['title'] = type == 'pspdfkit/image' ? 'Image' : 'Stamp';
          processedJson = jsonEncode(jsonMap);
        }
      } catch (_) {
        // Parsing failed — proceed with the original JSON.
      }
    }

    // `createAnnotationFromInstantJson` already attaches the annotation to the
    // document; a subsequent `addAnnotationToPage` would throw "already
    // attached".
    final annotation =
        AnnotationProviderBlocking.createAnnotationFromInstantJson(
            provider, processedJson);

    if (attachment != null) {
      try {
        final attachMap =
            Map<String, dynamic>.from(jsonDecode(attachment) as Map);
        final binary = attachMap['binary'] as String? ?? '';
        final contentType =
            attachMap['contentType'] as String? ?? 'application/octet-stream';

        if (binary.isNotEmpty) {
          final dataProvider =
              bytesDataProvider(base64Decode(binary), uid: 'attachment');

          try {
            // For stamp/image annotations ensure title is set on the Java
            // object so subsequent `toInstantJson()` calls succeed until the
            // appearance stream is generated.
            final type = (jsonDecode(jsonAnnotation) as Map)['type'] as String?;
            if (type == 'pspdfkit/image' || type == 'pspdfkit/stamp') {
              final stamp = annotation.as(StampAnnotation.type);
              final existingTitle =
                  stamp.title?.toDartString(releaseOriginal: true);
              if (existingTitle == null || existingTitle.isEmpty) {
                final titleStr =
                    (type == 'pspdfkit/image' ? 'Image' : 'Stamp').toJString();
                stamp.title = titleStr;
                titleStr.release();
              }
            }

            final mimeTypeJString = contentType.toJString();
            try {
              annotation.attachBinaryInstantJsonAttachment(
                  dataProvider, mimeTypeJString);
            } finally {
              mimeTypeJString.release();
            }

            // Generate the appearance stream synchronously so the annotation
            // renders immediately.  The sync overload is available in the
            // bindings and avoids RxJava subscription boilerplate.
            annotation.generateAppearanceStream();
          } finally {
            dataProvider.release();
          }
        }
      } catch (_) {
        // Attachment wiring failed — the annotation is already in the document
        // without its image, which matches the previous (no-op) behaviour.
      }
    }

    annotation.release();
    return jsonAnnotation;
  }

  @override
  Future<bool> removeAnnotation(int pageIndex, String annotationId) async {
    final provider = _requireProvider();
    final annotations =
        AnnotationProviderBlocking.getAnnotations(provider, pageIndex);
    Annotation? target;
    for (int i = 0; i < annotations.size(); i++) {
      final a = annotations.get(i)!;
      final uuid = a.uuid.toDartString(releaseOriginal: true);
      if (uuid == annotationId) {
        target = a;
        break;
      }
      a.release();
    }
    annotations.release();
    if (target == null) return false;
    AnnotationProviderBlocking.removeAnnotationFromPage(provider, target);
    target.release();
    return true;
  }

  @override
  Future<AnnotationProperties?> getAnnotationProperties(
    int pageIndex,
    String annotationId,
  ) async {
    final provider = _requireProvider();
    final annotations =
        AnnotationProviderBlocking.getAnnotations(provider, pageIndex);
    Annotation? target;
    for (int i = 0; i < annotations.size(); i++) {
      final a = annotations.get(i)!;
      final uuid = a.uuid.toDartString(releaseOriginal: true);
      if (uuid == annotationId) {
        target = a;
        break;
      }
      a.release();
    }
    annotations.release();
    if (target == null) return null;
    final jsonStr = target.toInstantJson().toDartString(releaseOriginal: true);
    target.release();
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      // InstantJSON keys the id as `name`, not `annotationId`, so fromJson
      // leaves annotationId null. Stamp the authoritative id/page we were
      // queried with so the caller can round-trip into saveAnnotationProperties.
      return AnnotationProperties.fromJson(json).copyWith(
        annotationId: annotationId,
        pageIndex: pageIndex,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> saveAnnotationProperties(AnnotationProperties properties) async {
    final annotationId = properties.annotationId;
    if (annotationId == null) return false;
    final provider = _requireProvider();
    // Find the existing annotation and capture its full InstantJSON before
    // removing it.
    final existing = AnnotationProviderBlocking.getAnnotations(
        provider, properties.pageIndex ?? 0);
    Map<String, dynamic>? currentJson;
    for (int i = 0; i < existing.size(); i++) {
      final a = existing.get(i)!;
      final uuid = a.uuid.toDartString(releaseOriginal: true);
      if (uuid == annotationId) {
        // `toInstantJson()` returns a *new* JString, so releasing it does not
        // touch `a` — keep `a` alive for the `removeAnnotationFromPage(a)`
        // below, but release the intermediate JString.
        final jsonStr = a.toInstantJson().toDartString(releaseOriginal: true);
        try {
          currentJson = jsonDecode(jsonStr) as Map<String, dynamic>;
        } catch (_) {
          currentJson = null;
        }
        AnnotationProviderBlocking.removeAnnotationFromPage(provider, a);
        a.release();
        break;
      }
      a.release();
    }
    existing.release();
    if (currentJson == null) return false;
    // Overlay only the changed properties onto the existing InstantJSON —
    // keeps the annotation's type / bbox / geometry intact. Building from the
    // property map alone would produce invalid InstantJSON (no type or bbox)
    // and destroy the annotation.
    final merged = {...currentJson, ...properties.toInstantJsonOverrides()};
    // `createAnnotationFromInstantJsonSingle` attaches the annotation itself;
    // no separate `addAnnotationToPage` (that would throw "already attached").
    //
    // The original was already removed above, so guard the recreate: if it
    // throws, restore the original from the InstantJSON we captured rather than
    // silently leaving the user's document with the annotation deleted.
    try {
      final updated =
          AnnotationProviderBlocking.createAnnotationFromInstantJson(
        provider,
        jsonEncode(merged),
      );
      updated.release();
      return true;
    } catch (_) {
      try {
        final restored =
            AnnotationProviderBlocking.createAnnotationFromInstantJson(
          provider,
          jsonEncode(currentJson),
        );
        restored.release();
      } catch (_) {
        // Best-effort restore; nothing more we can do for the caller.
      }
      return false;
    }
  }

  @override
  Future<String> searchAnnotationsJson(String query, {int? pageIndex}) async {
    final doc = document.requireDocument();
    final provider = _requireProvider();
    final lowerQuery = query.toLowerCase();
    final result = <Map<String, dynamic>>[];

    final startPage = pageIndex ?? 0;
    final endPage = pageIndex != null ? pageIndex + 1 : doc.getPageCount();
    for (var i = startPage; i < endPage; i++) {
      final annotations =
          AnnotationProviderBlocking.getAnnotations(provider, i);
      for (var j = 0; j < annotations.size(); j++) {
        final annotation = annotations.get(j)!;
        final contents =
            annotation.contents?.toDartString(releaseOriginal: true) ?? '';
        final name = annotation.name?.toDartString(releaseOriginal: true) ?? '';
        final subject =
            annotation.subject?.toDartString(releaseOriginal: true) ?? '';
        if (contents.toLowerCase().contains(lowerQuery) ||
            name.toLowerCase().contains(lowerQuery) ||
            subject.toLowerCase().contains(lowerQuery)) {
          try {
            final jsonStr =
                annotation.toInstantJson().toDartString(releaseOriginal: true);
            result.add(jsonDecode(jsonStr) as Map<String, dynamic>);
          } catch (_) {
            // Skip annotations that can't serialise to Instant JSON (e.g.
            // content-less stamps) — same tolerance as getAnnotationsJson.
          }
        }
        annotation.release();
      }
      annotations.release();
    }
    return jsonEncode(result);
  }

  @override
  Future<String> exportXfdf({int? pageIndex}) async {
    final doc = document.requireDocument();
    final provider = _requireProvider();

    // Collect the annotations to export — one page, or all of them. The Java
    // list keeps its own references, so each Dart-side wrapper is released as
    // soon as it's been added.
    final annotationsToExport = JArrayList<Annotation>();
    final formFields = JArrayList<FormField>();
    final startPage = pageIndex ?? 0;
    final endPage = pageIndex != null ? pageIndex + 1 : doc.getPageCount();
    for (var i = startPage; i < endPage; i++) {
      final pageAnnotations =
          AnnotationProviderBlocking.getAnnotations(provider, i);
      for (var j = 0; j < pageAnnotations.size(); j++) {
        final annotation = pageAnnotations.get(j);
        if (annotation != null) {
          annotationsToExport.add(annotation);
          annotation.release();
        }
      }
      pageAnnotations.release();
    }

    final byteStream = ByteArrayOutputStreamJni.create();
    try {
      XfdfFormatter.writeXfdf(
        doc,
        annotationsToExport as JList<Annotation>,
        formFields as JList<FormField>,
        byteStream as OutputStream,
        false, // ignorePageRotation
      );
      return utf8.decode(ByteArrayOutputStreamJni.toBytes(byteStream));
    } finally {
      byteStream.release();
      annotationsToExport.release();
      formFields.release();
    }
  }

  @override
  Future<bool> importXfdf(String xfdfString) async {
    final doc = document.requireDocument();
    final provider = _requireProvider();

    final dataProvider =
        bytesDataProvider(utf8.encode(xfdfString), uid: 'xfdf-import');

    try {
      final parsed = XfdfFormatter.parseXfdf(doc, dataProvider, false);
      try {
        // parseXfdf only parses — each annotation still has to be attached to
        // the document (its page index comes from the XFDF itself).
        for (var i = 0; i < parsed.size(); i++) {
          final annotation = parsed.get(i);
          if (annotation == null) continue;
          AnnotationProviderBlocking.addAnnotationToPage(provider, annotation);
          annotation.release();
        }
      } finally {
        parsed.release();
      }
      return true;
    } catch (_) {
      // Malformed XFDF — mirror iOS, which returns false when parsing fails.
      return false;
    } finally {
      dataProvider.release();
    }
  }

  // ---------------------------------------------------------------------------
  // Static converters
  // ---------------------------------------------------------------------------

  /// Map a type string to an [AnnotationType] JNI object for filtering.
  static AnnotationType? annotationTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'pspdfkit/ink':
        return AnnotationType.INK;
      case 'pspdfkit/text':
        return AnnotationType.FREETEXT;
      case 'pspdfkit/highlight':
        return AnnotationType.HIGHLIGHT;
      case 'pspdfkit/strikeout':
        return AnnotationType.STRIKEOUT;
      case 'pspdfkit/underline':
        return AnnotationType.UNDERLINE;
      case 'pspdfkit/squiggly':
        return AnnotationType.SQUIGGLY;
      case 'pspdfkit/note':
        return AnnotationType.NOTE;
      case 'pspdfkit/line':
        return AnnotationType.LINE;
      case 'pspdfkit/square':
        return AnnotationType.SQUARE;
      case 'pspdfkit/circle':
        return AnnotationType.CIRCLE;
      case 'pspdfkit/polygon':
        return AnnotationType.POLYGON;
      case 'pspdfkit/polyline':
        return AnnotationType.POLYLINE;
      case 'pspdfkit/link':
        return AnnotationType.LINK;
      case 'pspdfkit/stamp':
      case 'pspdfkit/image':
        return AnnotationType.STAMP;
      default:
        return null;
    }
  }
}
