///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter_platform_interface/src/api/nutrient_api.g.dart' as pigeon;
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

/// Converts a public [DocumentSaveOptions] to its pigeon-generated counterpart.
///
/// Enum members are mapped by [Enum.name] rather than ordinal index so that
/// future reordering of either enum cannot silently produce wrong values.
pigeon.DocumentSaveOptions? toPigeonSaveOptions(DocumentSaveOptions? opts) {
  if (opts == null) return null;
  return pigeon.DocumentSaveOptions(
    userPassword: opts.userPassword,
    ownerPassword: opts.ownerPassword,
    flatten: opts.flatten,
    incremental: opts.incremental,
    excludeAnnotations: opts.excludeAnnotations,
    saveForPrinting: opts.saveForPrinting,
    permissions: opts.permissions
        ?.map((p) => p == null ? null : _toPigeonPermission(p))
        .toList(),
    pdfVersion:
        opts.pdfVersion == null ? null : _toPigeonPdfVersion(opts.pdfVersion!),
    includeComments: opts.includeComments,
    outputFormat: opts.outputFormat,
    optimize: opts.optimize,
  );
}

pigeon.DocumentPermissions _toPigeonPermission(DocumentPermissions p) =>
    pigeon.DocumentPermissions.values.byName(p.name);

pigeon.PdfVersion _toPigeonPdfVersion(PdfVersion v) =>
    pigeon.PdfVersion.values.byName(v.name);
