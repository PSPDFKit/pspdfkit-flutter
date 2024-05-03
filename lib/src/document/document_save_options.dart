///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:pspdfkit_flutter/src/document/document_permissions.dart';
import 'package:pspdfkit_flutter/src/document/pdf_version.dart';

/// Options for saving/exporting a document.
class DocumentSaveOptions {
  /// The password is used to encrypt the document. On Web, it's used as the user password.
  final String? userPassword;

  /// The owner password is used to encrypt the document and set permissions. It's only used on Web.
  final String? ownerPassword;

  /// Flatten annotations and form fields into the page content.
  final bool? flatten;

  /// Whether to save the document incrementally.
  final bool? incremental;

  /// The permissions to set on the document. See [DocumentPermissions] for more information.
  final List<DocumentPermissions>? permissions;

  /// The PDF version to save the document as.
  final PdfVersion? pdfVersion;

  /// Whether to exclude annotations from the exported document.
  final bool? excludeAnnotations;

  /// Whether to exclude annotations that have the noPrint flag set to true from the exported document (Standalone only)
  final bool? saveForPrinting;

  ///// Whether to include comments in the exported document (Server-Backed only).
  final bool? includeComments;

  /// Whether tp allow you to export a PDF in PDF/A format.
  final dynamic outputFormat;

  /// Whether to optimize the document for the web.
  final bool? optimize;

  DocumentSaveOptions(
      {this.userPassword,
      this.ownerPassword,
      this.flatten,
      this.incremental,
      this.permissions,
      this.pdfVersion,
      this.excludeAnnotations,
      this.saveForPrinting,
      this.includeComments,
      this.outputFormat,
      this.optimize});

  /// Converts the options to a map that can be passed to the platform channel.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userPassword': userPassword,
      'ownerPassword': ownerPassword,
      'flatten': flatten,
      'incremental': incremental,
      'permissions': permissions?.map((e) => e.name).toList(),
      'pdfVersion': pdfVersion?.name,
    }..removeWhere((key, value) => value == null);
  }

  /// Converts the options to a map that can be passed to the web function call.
  Map<String, dynamic> toWebOptions() {
    return <String, dynamic>{
      'flatten': flatten,
      'incremental': incremental,
      'excludeAnnotations': excludeAnnotations,
      'saveForPrinting': saveForPrinting,
      'outputFormat': outputFormat,
      'optimize': optimize,
      'includeComments': includeComments,
      'permissions': {
        'documentPermissions': permissions?.map((e) => e.name).toList() ?? [],
        'userPassword': userPassword,
        'ownerPassword': ownerPassword,
      }..removeWhere((key, value) => value == null)
    }..removeWhere((key, value) =>
        value == null ||
        value is List && value.isEmpty ||
        value is Map && value.isEmpty);
  }
}
