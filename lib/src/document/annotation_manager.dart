///  Copyright © 2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Abstract base class for managing annotations in a PDF document.
///
/// This class provides a safe way to update annotations without losing
/// attachments or custom data, which was a critical issue with the
/// deprecated `updateAnnotation` method.
///
/// Usage:
/// ```dart
/// final manager = await document.annotationManager;
/// final properties = await manager.getAnnotationProperties(pageIndex, annotationId);
/// if (properties != null) {
///   final updated = properties.withColor(Colors.red).withOpacity(0.7);
///   await manager.saveAnnotationProperties(updated);
/// }
/// ```
abstract class AnnotationManager {
  final String documentId;

  AnnotationManager({required this.documentId});

  /// Gets annotation properties for modification.
  /// Returns null if the annotation doesn't exist.
  ///
  /// The returned [AnnotationProperties] can be modified using
  /// extension methods like `withColor()`, `withOpacity()`, etc.
  Future<AnnotationProperties?> getAnnotationProperties(
    int pageIndex,
    String annotationId,
  );

  /// Saves modified annotation properties.
  /// Only non-null properties in [properties] will be updated.
  /// All other properties (including attachments and custom data) are preserved.
  ///
  /// Returns true if successfully saved, false otherwise.
  Future<bool> saveAnnotationProperties(AnnotationProperties properties);

  /// Gets all annotations on a specific page.
  ///
  /// [pageIndex] is the zero-based page index.
  /// [type] specifies the type of annotations to retrieve.
  Future<List<Annotation>> getAnnotations(
    int pageIndex, [
    AnnotationType type = AnnotationType.all,
  ]);

  /// Adds a new annotation to the document.
  ///
  /// Returns the unique identifier of the created annotation.
  Future<String> addAnnotation(Annotation annotation);

  /// Removes an annotation from the document.
  ///
  /// Returns true if successfully removed, false otherwise.
  Future<bool> removeAnnotation(int pageIndex, String annotationId);

  /// Searches for annotations containing specific text.
  ///
  /// [query] is the search term.
  /// [pageIndex] optionally limits the search to a specific page.
  Future<List<Annotation>> searchAnnotations(String query, [int? pageIndex]);

  /// Exports annotations as XFDF format.
  ///
  /// [pageIndex] optionally exports only annotations from a specific page.
  Future<String> exportXFDF([int? pageIndex]);

  /// Imports annotations from XFDF format.
  ///
  /// Returns true if successfully imported, false otherwise.
  Future<bool> importXFDF(String xfdfString);

  /// Gets all annotations that have unsaved changes.
  Future<List<Annotation>> getUnsavedAnnotations();
}
