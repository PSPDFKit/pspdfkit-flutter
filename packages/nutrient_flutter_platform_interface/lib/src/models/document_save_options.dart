///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Permissions that can be set on an encrypted PDF document.
enum DocumentPermissions {
  /// Allow printing of document.
  printing,

  /// Modify the contents of the document.
  modification,

  /// Copy text and images from the document.
  extract,

  /// Add or modify text annotations, fill in interactive form fields.
  annotationsAndForms,

  /// Fill in existing interactive form fields (including signature fields).
  fillForms,

  /// Extract text and images from the document (accessibility).
  extractAccessibility,

  /// Assemble the document (insert, rotate, or delete pages and create document
  /// outline items or thumbnail images).
  assemble,

  /// Print at high quality.
  printHighQuality,
}

/// The PDF version to target when saving a document.
enum PdfVersion {
  pdf_1_0,
  pdf_1_1,
  pdf_1_2,
  pdf_1_3,
  pdf_1_4,
  pdf_1_5,
  pdf_1_6,
  pdf_1_7,
}

/// Options controlling how a PDF document is saved or exported.
class DocumentSaveOptions {
  /// User (open) password for the output PDF.
  final String? userPassword;

  /// Owner (permissions) password for the output PDF.
  final String? ownerPassword;

  /// Whether to flatten annotations and form fields into the page content.
  final bool? flatten;

  /// Whether to use incremental save (appends changes rather than rewriting).
  final bool? incremental;

  /// Whether to exclude annotations from the saved file.
  final bool? excludeAnnotations;

  /// Whether to optimise the file for printing (standalone only).
  final bool? saveForPrinting;

  /// Permissions to set on the document when encrypting.
  ///
  /// The listed permissions are what user-password holders are *allowed* to
  /// do. Leaving this unset (`null`) while setting a password does not
  /// restrict anything: iOS and Web grant all permissions, Android preserves
  /// the document's existing permissions (all, for a previously unencrypted
  /// document). Pass an explicit list (or an empty one) to restrict.
  final List<DocumentPermissions?>? permissions;

  /// The PDF version to target when saving.
  final PdfVersion? pdfVersion;

  /// Whether to include comments in the exported document (server-backed only).
  final bool? includeComments;

  /// Output format override, e.g. `'pdf/a-2b'` (web/standalone only).
  final Object? outputFormat;

  /// Whether to optimise the document for web delivery.
  final bool? optimize;

  const DocumentSaveOptions({
    this.userPassword,
    this.ownerPassword,
    this.flatten,
    this.incremental,
    this.excludeAnnotations,
    this.saveForPrinting,
    this.permissions,
    this.pdfVersion,
    this.includeComments,
    this.outputFormat,
    this.optimize,
  });

  /// Converts options to a JSON map, omitting null values.
  Map<String, dynamic> toJson() => {
        if (userPassword != null) 'userPassword': userPassword,
        if (ownerPassword != null) 'ownerPassword': ownerPassword,
        if (flatten != null) 'flatten': flatten,
        if (incremental != null) 'incremental': incremental,
        if (excludeAnnotations != null)
          'excludeAnnotations': excludeAnnotations,
        if (saveForPrinting != null) 'saveForPrinting': saveForPrinting,
        if (permissions != null)
          'permissions':
              permissions!.where((p) => p != null).map((p) => p!.name).toList(),
        if (pdfVersion != null) 'pdfVersion': pdfVersion?.name,
        if (includeComments != null) 'includeComments': includeComments,
        if (outputFormat != null) 'outputFormat': outputFormat,
        if (optimize != null) 'optimize': optimize,
      };
}
