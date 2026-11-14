///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_web/src/utils/document_path.dart';

void main() {
  const declared = {
    'assets/documents/welcome.pdf',
    'packages/some_package/assets/form.pdf',
  };

  // Mirrors what Flutter's asset manager does for an app with base href
  // `/app/`: prefix the `assets/` directory, under the base href.
  String assetUrl(String key) => '/app/assets/$key';

  group('resolveDocumentPath', () {
    var manifestReads = 0;

    Future<String> resolve(String path) => resolveDocumentPath(
          path,
          assetKeys: () async {
            manifestReads++;
            return declared;
          },
          assetUrl: assetUrl,
        );

    setUp(() => manifestReads = 0);

    test('maps a declared asset to its served URL', () async {
      expect(
        await resolve('assets/documents/welcome.pdf'),
        '/app/assets/assets/documents/welcome.pdf',
      );
      expect(
        await resolve('packages/some_package/assets/form.pdf'),
        '/app/assets/packages/some_package/assets/form.pdf',
      );
    });

    test('passes through a path that is not a declared asset', () async {
      // A file served from the app's own `web/` directory.
      expect(await resolve('documents/served.pdf'), 'documents/served.pdf');
      expect(await resolve('/documents/served.pdf'), '/documents/served.pdf');
      // Under `assets/`, but not declared in the pubspec.
      expect(await resolve('assets/undeclared.pdf'), 'assets/undeclared.pdf');
    });

    test('passes URLs through without reading the manifest', () async {
      for (final url in [
        'https://example.com/assets/documents/welcome.pdf',
        'http://localhost:8080/doc.pdf',
        'blob:https://example.com/1234',
        'data:application/pdf;base64,JVBERi0=',
        '',
      ]) {
        expect(await resolve(url), url);
      }
      expect(manifestReads, 0);
    });

    test('passes the path through when the manifest cannot be read', () async {
      final resolved = await resolveDocumentPath(
        'assets/documents/welcome.pdf',
        assetKeys: () async => throw StateError('no manifest'),
        assetUrl: assetUrl,
      );
      expect(resolved, 'assets/documents/welcome.pdf');
    });
  });
}
