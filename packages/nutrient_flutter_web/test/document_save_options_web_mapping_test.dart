///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:nutrient_flutter_web/src/utils/document_save_options_web_mapping.dart';

void main() {
  group('webExportFlagsFor', () {
    test('returns an empty map for all-null options', () {
      expect(webExportFlagsFor(const DocumentSaveOptions()), isEmpty);
    });

    test('maps flatten', () {
      expect(
        webExportFlagsFor(const DocumentSaveOptions(flatten: true)),
        {'flatten': true},
      );
      expect(
        webExportFlagsFor(const DocumentSaveOptions(flatten: false)),
        {'flatten': false},
      );
    });

    test('maps incremental', () {
      expect(
        webExportFlagsFor(const DocumentSaveOptions(incremental: true)),
        {'incremental': true},
      );
    });

    test('maps excludeAnnotations', () {
      expect(
        webExportFlagsFor(
          const DocumentSaveOptions(excludeAnnotations: true),
        ),
        {'excludeAnnotations': true},
      );
    });

    test('maps saveForPrinting', () {
      expect(
        webExportFlagsFor(const DocumentSaveOptions(saveForPrinting: true)),
        {'saveForPrinting': true},
      );
    });

    test('maps includeComments', () {
      expect(
        webExportFlagsFor(const DocumentSaveOptions(includeComments: false)),
        {'includeComments': false},
      );
    });

    test('maps optimize', () {
      expect(
        webExportFlagsFor(const DocumentSaveOptions(optimize: true)),
        {'optimize': true},
      );
    });

    test('passes outputFormat through as-is when a bool', () {
      expect(
        webExportFlagsFor(const DocumentSaveOptions(outputFormat: true)),
        {'outputFormat': true},
      );
    });

    test('passes outputFormat through as-is when a map (PDFAFlags shape)', () {
      final options = DocumentSaveOptions(
        outputFormat: {'conformance': 'pdfa-2b', 'vectorization': true},
      );
      expect(
        webExportFlagsFor(options),
        {
          'outputFormat': {'conformance': 'pdfa-2b', 'vectorization': true},
        },
      );
    });

    test('does not emit permissions when no password/permissions are set', () {
      final flags = webExportFlagsFor(const DocumentSaveOptions(
        flatten: true,
      ));
      expect(flags.containsKey('permissions'), isFalse);
    });

    test(
        'builds permissions object when only userPassword is set, '
        'backfilling all permissions (password-only must not lock down)', () {
      final flags = webExportFlagsFor(const DocumentSaveOptions(
        userPassword: 'open123',
      ));
      expect(flags['permissions'], {
        'userPassword': 'open123',
        'ownerPassword': '',
        'documentPermissions':
            DocumentPermissions.values.map((p) => p.name).toList(),
      });
    });

    test('builds permissions object when only ownerPassword is set', () {
      final flags = webExportFlagsFor(const DocumentSaveOptions(
        ownerPassword: 'owner123',
      ));
      expect(flags['permissions'], {
        'userPassword': '',
        'ownerPassword': 'owner123',
        'documentPermissions':
            DocumentPermissions.values.map((p) => p.name).toList(),
      });
    });

    test('an explicitly empty permissions list is a deliberate lockdown', () {
      final flags = webExportFlagsFor(const DocumentSaveOptions(
        userPassword: 'open123',
        permissions: [],
      ));
      expect(flags['permissions'], {
        'userPassword': 'open123',
        'ownerPassword': '',
        'documentPermissions': <String>[],
      });
    });

    test('builds permissions object when only permissions list is set', () {
      final flags = webExportFlagsFor(const DocumentSaveOptions(
        permissions: [
          DocumentPermissions.printing,
          DocumentPermissions.fillForms
        ],
      ));
      expect(flags['permissions'], {
        'userPassword': '',
        'ownerPassword': '',
        'documentPermissions': ['printing', 'fillForms'],
      });
    });

    test('combines passwords and permissions into a single permissions map',
        () {
      final flags = webExportFlagsFor(const DocumentSaveOptions(
        userPassword: 'user',
        ownerPassword: 'owner',
        permissions: [DocumentPermissions.printing],
      ));
      expect(flags['permissions'], {
        'userPassword': 'user',
        'ownerPassword': 'owner',
        'documentPermissions': ['printing'],
      });
    });

    test('filters out null entries in the permissions list', () {
      final flags = webExportFlagsFor(const DocumentSaveOptions(
        userPassword: 'user',
        permissions: [DocumentPermissions.printing, null],
      ));
      expect(
        flags['permissions'],
        {
          'userPassword': 'user',
          'ownerPassword': '',
          'documentPermissions': ['printing'],
        },
      );
    });

    test('pdfVersion has no Web equivalent and is dropped', () {
      final flags = webExportFlagsFor(const DocumentSaveOptions(
        pdfVersion: PdfVersion.pdf_1_7,
      ));
      expect(flags.containsKey('pdfVersion'), isFalse);
      expect(flags, isEmpty);
    });

    test('maps every field simultaneously', () {
      final options = DocumentSaveOptions(
        userPassword: 'user',
        ownerPassword: 'owner',
        flatten: true,
        incremental: false,
        excludeAnnotations: false,
        saveForPrinting: true,
        permissions: const [DocumentPermissions.assemble],
        pdfVersion: PdfVersion.pdf_1_7,
        includeComments: true,
        outputFormat: false,
        optimize: true,
      );
      final flags = webExportFlagsFor(options);
      expect(flags, {
        'flatten': true,
        'incremental': false,
        'excludeAnnotations': false,
        'saveForPrinting': true,
        'includeComments': true,
        'optimize': true,
        'outputFormat': false,
        'permissions': {
          'userPassword': 'user',
          'ownerPassword': 'owner',
          'documentPermissions': ['assemble'],
        },
      });
      expect(flags.containsKey('pdfVersion'), isFalse);
    });
  });
}
