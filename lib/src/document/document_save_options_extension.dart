///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Options for saving/exporting a document.
extension DocumentSaveOptionsX on DocumentSaveOptions {
  /// Converts the options to a map that can be passed to the platform channel.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userPassword': userPassword,
      'ownerPassword': ownerPassword,
      'flatten': flatten,
      'incremental': incremental,
      'permissions': permissions?.map((e) => e).toList(),
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
        'documentPermissions': permissions?.map((e) => e).toList() ?? [],
        'userPassword': userPassword,
        'ownerPassword': ownerPassword,
      }..removeWhere((key, value) => value == null)
    }..removeWhere((key, value) =>
        value == null ||
        value is List && value.isEmpty ||
        value is Map && value.isEmpty);
  }
}
