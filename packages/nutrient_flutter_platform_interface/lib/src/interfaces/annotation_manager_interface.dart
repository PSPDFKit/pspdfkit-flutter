///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

import '../api/nutrient_api.g.dart' show AnnotationType;
import '../models/annotation_properties.dart';
import '../models/annotations/annotation_attachment.dart';
import '../models/annotations/annotation_models.dart';

/// Abstract interface for annotation operations on a PDF document.
///
/// Concrete implementations are provided by each platform package:
/// - `AnnotationManagerAndroid` in `nutrient_flutter_android`
/// - `AnnotationManagerIOS` in `nutrient_flutter_ios`
/// - `AnnotationManagerWeb` in `nutrient_flutter_web`
///
/// Access via [NutrientDocumentInterface.annotations] or
/// [NutrientController.document.annotations].
///
/// ## Customising Behaviour
///
/// Override the annotation manager in your platform adapter:
///
/// ```dart
/// class MyAndroidAdapter extends AndroidAdapter {
///   @override
///   AnnotationManagerInterface createAnnotationManager() =>
///       MyAnnotationManager(this);
/// }
///
/// class MyAnnotationManager extends AnnotationManagerAndroid {
///   @override
///   Future<String> getAnnotationsJson(int pageIndex, String type) async {
///     // custom logic before delegating
///     return super.getAnnotationsJson(pageIndex, type);
///   }
/// }
/// ```
abstract class AnnotationManagerInterface {
  /// Returns a JSON string of all annotations on [pageIndex] matching [type].
  ///
  /// [type] is one of the Pigeon `AnnotationType` string values (e.g. `"all"`,
  /// `"highlight"`, `"ink"`).
  Future<String> getAnnotationsJson(int pageIndex, String type);

  /// Returns a JSON string of all annotations that have unsaved changes.
  Future<String> getUnsavedAnnotationsJson();

  /// Adds an annotation from an Instant JSON string (low-level transport).
  ///
  /// Prefer the typed [addAnnotation] for most use cases.
  ///
  /// [jsonAnnotation] is a JSON-encoded annotation object.
  /// [attachment] is an optional base64-encoded image attachment for stamp/image
  /// annotations.
  ///
  /// Returns the Instant JSON string of the created annotation.
  Future<String> addAnnotationJson(String jsonAnnotation, {String? attachment});

  /// Removes the annotation at [pageIndex] with [annotationId].
  Future<bool> removeAnnotation(int pageIndex, String annotationId);

  /// Returns the typed properties of the annotation at [pageIndex] with
  /// [annotationId], or `null` if not found.
  Future<AnnotationProperties?> getAnnotationProperties(
    int pageIndex,
    String annotationId,
  );

  /// Saves the given [properties] back to the annotation.
  ///
  /// Only non-null fields in [properties] are written.
  Future<bool> saveAnnotationProperties(AnnotationProperties properties);

  /// Searches annotations by [query] string (low-level transport).
  ///
  /// Prefer the typed [searchAnnotations] for most use cases.
  ///
  /// If [pageIndex] is provided, the search is scoped to that page.
  /// Returns a JSON string of matching annotations.
  Future<String> searchAnnotationsJson(String query, {int? pageIndex});

  /// Exports annotations as an XFDF string.
  ///
  /// If [pageIndex] is provided, only annotations on that page are included.
  ///
  /// Note: This returns the XFDF content as a string. In previous versions
  /// (Pigeon API) this wrote to a file path — that signature has changed in
  /// v6.0.0. Callers are responsible for persisting the string if needed.
  Future<String> exportXfdf({int? pageIndex});

  /// Imports annotations from an XFDF string.
  Future<bool> importXfdf(String xfdfString);
}

/// Typed convenience layer over the JSON transport on
/// [AnnotationManagerInterface].
///
/// These wrap the `*Json` methods and parse Instant JSON into the typed
/// [Annotation] models. They are platform-agnostic: at the `getAnnotationsJson`
/// boundary all platforms emit spec Instant JSON. Parsing is defensive
/// ([Annotation.tryFromJson]) so one malformed annotation never fails a page.
///
/// Implemented as an extension (not default methods) because the platform
/// managers `implements` the interface; a custom adapter customizes behavior by
/// overriding the `*Json` transport methods, which these delegate to.
/// See documentation/typed-annotations-cross-platform.md.
extension AnnotationManagerTyped on AnnotationManagerInterface {
  /// Returns the typed annotations on [pageIndex], optionally filtered by
  /// [type] (defaults to all types).
  ///
  /// Filtering is done on the parsed annotation type rather than via the native
  /// filter argument, which is inconsistent across platforms — this keeps
  /// behavior identical on Android, iOS, and Web.
  Future<List<Annotation>> getAnnotations(
    int pageIndex, [
    AnnotationType type = AnnotationType.all,
  ]) async {
    final annotations =
        _parseAnnotationList(await getAnnotationsJson(pageIndex, 'all'));
    if (type == AnnotationType.all) return annotations;
    return annotations.where((a) => a.type == type).toList();
  }

  /// Adds a typed [annotation] to the document.
  ///
  /// Returns the created annotation parsed back from the platform, or `null`
  /// if the platform did not return a parseable result.
  ///
  /// Annotations that carry binary content mix in [HasAttachment] — currently
  /// [ImageAnnotation] and [RichMediaAnnotation]. For those, the
  /// [AnnotationAttachment]'s Base64 `binary` + `contentType` are forwarded to
  /// the platform so the annotation renders; the binary travels out-of-band via
  /// [addAnnotationJson]'s `attachment` argument rather than inline in the
  /// Instant JSON. Other types (including [StampAnnotation]) don't carry an
  /// attachment and are written from their Instant JSON alone.
  Future<Annotation?> addAnnotation(Annotation annotation) async {
    String? attachment;
    if (annotation is HasAttachment) {
      final att = (annotation as HasAttachment).attachment;
      if (att != null && att.binary.isNotEmpty) {
        attachment = jsonEncode(att.toJson());
      }
    }
    final created = await addAnnotationJson(
      jsonEncode(annotation.toJson()),
      attachment: attachment,
    );
    if (created.isEmpty) return null;
    try {
      final decoded = jsonDecode(created);
      if (decoded is Map) {
        return Annotation.tryFromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
    return null;
  }

  /// Returns the typed annotations that have unsaved changes.
  ///
  /// Not supported on Web (returns an empty list there).
  Future<List<Annotation>> getUnsavedAnnotations() async =>
      _parseAnnotationList(await getUnsavedAnnotationsJson());

  /// Searches annotations by [query], returning typed results.
  ///
  /// Not supported on Web (returns an empty list there).
  Future<List<Annotation>> searchAnnotations(
    String query, {
    int? pageIndex,
  }) async =>
      _parseAnnotationList(
        await searchAnnotationsJson(query, pageIndex: pageIndex),
      );
}

/// Parses an Instant JSON payload — either a bare annotation array or an
/// `{ "annotations": [...] }` envelope — into typed models, skipping any
/// unknown/malformed entries.
List<Annotation> _parseAnnotationList(String jsonString) {
  if (jsonString.isEmpty) return const [];
  final dynamic decoded = jsonDecode(jsonString);
  final List<dynamic> raw = decoded is List
      ? decoded
      : (decoded is Map
          ? (decoded['annotations'] as List? ?? const [])
          : const []);
  final result = <Annotation>[];
  for (final item in raw) {
    if (item is Map) {
      final a = Annotation.tryFromJson(Map<String, dynamic>.from(item));
      if (a != null) result.add(a);
    }
  }
  return result;
}
