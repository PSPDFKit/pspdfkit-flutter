///
///  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
import '../../pspdfkit.dart';

/// A controller for a PSPDFKit widget.
abstract class PspdfkitWidgetController {
  /// Sets the value of a form field by specifying its fully qualified field name.
  Future<bool?> setFormFieldValue(String value, String fullyQualifiedName);

  /// Gets the form field value by specifying its fully qualified name.
  Future<String?> getFormFieldValue(String fullyQualifiedName);

  /// Applies Instant document JSON to the presented document.
  Future<bool?> applyInstantJson(String annotationsJson);

  /// Exports Instant document JSON from the presented document.
  Future<String?> exportInstantJson();

  /// Adds the given annotation to the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  Future<bool?> addAnnotation(Map<String, dynamic> jsonAnnotation);

  /// Removes the given annotation from the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  Future<bool?> removeAnnotation(dynamic jsonAnnotation);

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  Future<dynamic> getAnnotations(int pageIndex, String type);

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  Future<dynamic> getAllUnsavedAnnotations();

  /// Processes annotations of the given type with the provided processing
  /// mode and stores the PDF at the given destination path.
  Future<bool?> processAnnotations(
      String type, String processingMode, String destinationPath);

  /// Imports annotations from the XFDF file at the given path.
  Future<bool?> importXfdf(String xfdfPath);

  /// Exports annotations to the XFDF file at the given path.
  Future<bool?> exportXfdf(String xfdfPath);

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  Future<bool?> save();

  /// Sets the measurement scale of the document.
  /// The scale is used to convert between real world measurements and points.
  /// The default scale is 1 inch = 1 inch.
  /// @param scale The scale to be used for the document.
  /// @return True if the scale was set successfully, false otherwise.
  Future<bool?> setMeasurementScale(MeasurementScale scale);

  /// Sets the measurement precision of the document.
  /// The precision is used to round the measurement values.
  /// The default precision is 2 decimal places.
  /// @param precision The precision to be used for the document.
  /// @return True if the precision was set successfully, false otherwise.
  Future<bool?> setMeasurementPrecision(MeasurementPrecision precision);

  /// Sets the annotation preset configurations for the given annotation tools.
  /// @param configurations A map of annotation tools and their corresponding configurations.
  /// @return True if the configurations were set successfully, false otherwise.
  Future<bool?> setAnnotationConfigurations(
      Map<AnnotationTool, AnnotationConfiguration> configurations);

  void addEventListener(String eventName, Function(dynamic) callback);
}
