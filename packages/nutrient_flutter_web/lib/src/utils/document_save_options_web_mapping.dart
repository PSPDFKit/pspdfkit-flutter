///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

/// Maps a [DocumentSaveOptions] instance to the flag map accepted by the Web
/// SDK's `Instance.exportPDF(flags)` (`ExportPDFFlags` in
/// `@nutrient-sdk/viewer`'s `typings/backend.ts`).
///
/// Kept JS-free (pure Dart, no `dart:js_interop`) so the field-by-field
/// mapping is unit-testable without a browser/JS environment. The caller is
/// responsible for `.jsify()`-ing the result before handing it to the SDK.
///
/// Web SDK support, field by field:
/// - [DocumentSaveOptions.flatten] → `flatten`.
/// - [DocumentSaveOptions.incremental] → `incremental` (standalone only).
/// - [DocumentSaveOptions.excludeAnnotations] → `excludeAnnotations`.
/// - [DocumentSaveOptions.saveForPrinting] → `saveForPrinting` (standalone
///   only — excludes annotations with the "no print" flag).
/// - [DocumentSaveOptions.includeComments] → `includeComments`
///   (server-backed only).
/// - [DocumentSaveOptions.optimize] → `optimize` (server-backed only).
/// - [DocumentSaveOptions.outputFormat] → `outputFormat`, passed through
///   as-is: the Web SDK accepts either a `bool` or a `PDFAFlags`-shaped
///   object (`{conformance, vectorization, rasterization}`).
/// - [DocumentSaveOptions.userPassword] / [DocumentSaveOptions.ownerPassword]
///   / [DocumentSaveOptions.permissions] → combined into the Web SDK's
///   `permissions: {userPassword, ownerPassword, documentPermissions}`
///   object. The Web SDK requires all three sub-fields together, so this
///   mapping only emits `permissions` when at least one of the three source
///   fields is set, backfilling empty-string passwords. An unset permissions
///   list backfills as *all* permissions — password-protecting a document
///   doesn't restrict what password holders can do with it (matching Android
///   and iOS); pass an explicit list (or an empty one) to restrict.
///
/// N/A on Web (no equivalent in `ExportPDFFlags`; silently dropped):
/// - [DocumentSaveOptions.pdfVersion] — the Web SDK has no PDF-version
///   target knob for `exportPDF`.
Map<String, dynamic> webExportFlagsFor(DocumentSaveOptions options) {
  final permissions = _permissionsFlagFor(options);
  return {
    if (options.flatten != null) 'flatten': options.flatten,
    if (options.incremental != null) 'incremental': options.incremental,
    if (options.excludeAnnotations != null)
      'excludeAnnotations': options.excludeAnnotations,
    if (options.saveForPrinting != null)
      'saveForPrinting': options.saveForPrinting,
    if (options.includeComments != null)
      'includeComments': options.includeComments,
    if (options.optimize != null) 'optimize': options.optimize,
    if (options.outputFormat != null) 'outputFormat': options.outputFormat,
    if (permissions != null) 'permissions': permissions,
  };
}

/// Builds the Web SDK `permissions` sub-object, or `null` if none of
/// [DocumentSaveOptions.userPassword], [DocumentSaveOptions.ownerPassword],
/// or [DocumentSaveOptions.permissions] were provided.
///
/// The Web SDK requires `userPassword`, `ownerPassword`, and
/// `documentPermissions` to be passed together; this backfills whichever of
/// the three the caller omitted so a partially-specified
/// [DocumentSaveOptions] (e.g. only `ownerPassword`) still produces a valid
/// flag object instead of silently doing nothing.
///
/// An unset (`null`) permissions list backfills as *all* permissions rather
/// than none: `documentPermissions` is the set of actions *granted* to
/// user-password holders, so an empty backfill would turn a password-only
/// options object into a fully-locked document. An explicitly empty list is
/// passed through as-is (deliberate lockdown).
Map<String, dynamic>? _permissionsFlagFor(DocumentSaveOptions options) {
  final hasUserPassword = options.userPassword != null;
  final hasOwnerPassword = options.ownerPassword != null;
  final hasPermissions = options.permissions != null;
  if (!hasUserPassword && !hasOwnerPassword && !hasPermissions) {
    return null;
  }
  final permissions = options.permissions ?? DocumentPermissions.values;
  return {
    'userPassword': options.userPassword ?? '',
    'ownerPassword': options.ownerPassword ?? '',
    'documentPermissions': permissions
        .whereType<DocumentPermissions>()
        .map((p) => p.name)
        .toList(),
  };
}
