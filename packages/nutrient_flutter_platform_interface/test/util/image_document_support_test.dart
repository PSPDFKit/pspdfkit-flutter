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

void main() {
  group('isImageDocumentPath', () {
    test('detects every supported extension', () {
      for (final ext in kImageDocumentExtensions) {
        expect(isImageDocumentPath('photo.$ext'), isTrue,
            reason: 'expected .$ext to be detected as an image');
      }
    });

    test('is case-insensitive on the extension', () {
      expect(isImageDocumentPath('photo.PNG'), isTrue);
      expect(isImageDocumentPath('photo.Jpeg'), isTrue);
      expect(isImageDocumentPath('photo.TIFF'), isTrue);
    });

    test('treats PDFs and unknown types as non-images', () {
      expect(isImageDocumentPath('document.pdf'), isFalse);
      expect(isImageDocumentPath('archive.zip'), isFalse);
      expect(isImageDocumentPath('notes.txt'), isFalse);
    });

    test('returns false for null/empty input', () {
      expect(isImageDocumentPath(null), isFalse);
      expect(isImageDocumentPath(''), isFalse);
    });

    test('returns false for paths with no extension', () {
      expect(isImageDocumentPath('photo'), isFalse);
      expect(isImageDocumentPath('/tmp/folder/photo'), isFalse);
    });

    test('returns false for a trailing dot', () {
      expect(isImageDocumentPath('photo.'), isFalse);
    });

    test('strips query and fragment from remote URLs', () {
      expect(isImageDocumentPath('https://host/img.png?token=abc'), isTrue);
      expect(
          isImageDocumentPath('https://host/img.PNG?token=abc#frag'), isTrue);
      expect(isImageDocumentPath('http://host/photo.jpeg#section'), isTrue);
      // Query/fragment that hides the real (non-image) extension.
      expect(isImageDocumentPath('https://host/doc.pdf?name=img.png'), isFalse);
    });

    test('preserves ? and # in local file names', () {
      // Local paths are not URLs, so embedded `?`/`#` must not be stripped.
      expect(isImageDocumentPath('/tmp/my?weird.png'), isTrue);
      expect(isImageDocumentPath('/tmp/note#1.jpg'), isTrue);
      expect(isImageDocumentPath('relative/dir/photo#draft.gif'), isTrue);
    });

    test('handles directories containing dots', () {
      expect(isImageDocumentPath('/a.b.c/photo.png'), isTrue);
      expect(isImageDocumentPath('/a.b.c/document'), isFalse);
    });
  });
}
