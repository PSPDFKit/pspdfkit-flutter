///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import '../nutrient_web_bindings.dart';
import '../nutrient_web_types.dart' show NutrientViewStateExtension;

/// Provides document-level operations on a Nutrient Web SDK instance.
///
/// Includes save, export (PDF, Instant JSON, XFDF), import, and
/// apply-operations functionality.
///
/// Accessible via [NutrientWebAdapter.documentOperations] after the instance
/// is loaded.
class NutrientDocumentOperations {
  final NutrientWebInstance _instance;

  NutrientDocumentOperations(this._instance);

  /// Saves the current state of the document.
  Future<void> save() async {
    await _instance.save().toDart;
  }

  /// Checks if the document has unsaved changes.
  bool hasUnsavedChanges() {
    return _instance.hasUnsavedChanges();
  }

  /// Exports the document as raw PDF bytes.
  ///
  /// The optional [options] map can contain export flags (e.g., `flatten`).
  Future<Uint8List> exportPdf({Map<String, dynamic>? options}) async {
    final jsOptions = (options ?? {}).jsify();
    final result = await _instance.exportPDF(jsOptions).toDart;

    // The result is an ArrayBuffer — convert to Uint8List
    final arrayBuffer = result as JSArrayBuffer;
    return arrayBuffer.toDart.asUint8List();
  }

  /// Applies Instant JSON to the document.
  ///
  /// [annotationsJson] can be a JSON string or a `Map<String, dynamic>`.
  Future<void> applyInstantJson(dynamic annotationsJson) async {
    Map<String, dynamic> instantJsonObject;
    if (annotationsJson is String) {
      instantJsonObject = jsonDecode(annotationsJson) as Map<String, dynamic>;
    } else if (annotationsJson is Map<String, dynamic>) {
      instantJsonObject = annotationsJson;
    } else {
      throw ArgumentError(
        'annotationsJson must be a String or Map<String, dynamic>',
      );
    }

    final operations = [
      {'type': 'applyInstantJson', 'instantJson': instantJsonObject}
    ];
    await applyOperations(operations);
  }

  /// Exports the document as Instant JSON.
  ///
  /// Returns the JSON string representation.
  Future<String?> exportInstantJson() async {
    final result = await _instance.exportInstantJSON(null).toDart;
    if (result == null) return null;
    final dartValue = result.dartify();
    return jsonEncode(dartValue);
  }

  /// Imports XFDF annotations from an XFDF string.
  Future<void> importXfdf(String xfdf) async {
    final operations = [
      {
        'type': 'applyXfdf',
        'xfdf': xfdf,
      }
    ];
    await applyOperations(operations);
  }

  /// Exports the document annotations as XFDF.
  ///
  /// Returns the XFDF string.
  Future<String?> exportXfdf() async {
    final result = await _instance.exportXFDF(null).toDart;
    if (result == null) return null;
    return (result as JSString).toDart;
  }

  /// Applies a list of operations to the document.
  ///
  /// See [PSPDFKit.DocumentOperation](https://www.nutrient.io/api/web/PSPDFKit.DocumentOperation.html)
  /// for supported operations.
  Future<void> applyOperations(List<Map<String, dynamic>> operations) async {
    await _instance.applyOperations(operations.jsify()!).toDart;
  }

  /// Gets the total number of pages in the document.
  int get pageCount => _instance.totalPageCount ?? 0;

  /// Gets the current page index.
  int get currentPageIndex => _instance.viewState.currentPageIndex;

  /// Sets the annotation creator name.
  void setAnnotationCreatorName(String name) {
    _instance.setAnnotationCreatorName(name);
  }
}
