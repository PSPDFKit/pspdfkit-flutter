///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// File extensions Nutrient treats as image documents — a single annotatable
/// image page rather than a PDF. Mirrors the image formats supported by the
/// native image-document loaders on Android, iOS, and Web.
const Set<String> kImageDocumentExtensions = {
  'jpg',
  'jpeg',
  'png',
  'tif',
  'tiff',
  'gif',
  'bmp',
  'webp',
};

/// Whether [path] points at an image document (vs. a PDF), detected purely by
/// file extension.
///
/// This is the shared signal every platform view + headless `openDocument`
/// uses to decide whether to open the path as an image document. Pass the
/// **original** document path (e.g. `assets/photo.png`, `/tmp/x.jpg`,
/// `https://host/img.PNG?token=abc`) — query strings and fragments are
/// stripped before the extension is read, and matching is case-insensitive.
///
/// Returns `false` for `null`/empty paths and for anything without a
/// recognised image extension (PDFs and unknown types load as PDF documents).
bool isImageDocumentPath(String? path) {
  if (path == null || path.isEmpty) return false;

  // Drop query/fragment so remote URLs like `img.png?token=…` still match, but
  // only for actual URLs — a local file whose name contains `?` or `#` must
  // keep those characters so its extension is read correctly.
  var cleaned = path;
  if (_hasUrlScheme(cleaned)) {
    final queryIndex = cleaned.indexOf('?');
    if (queryIndex != -1) cleaned = cleaned.substring(0, queryIndex);
    final fragmentIndex = cleaned.indexOf('#');
    if (fragmentIndex != -1) cleaned = cleaned.substring(0, fragmentIndex);
  }

  final dotIndex = cleaned.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == cleaned.length - 1) return false;

  final extension = cleaned.substring(dotIndex + 1).toLowerCase();
  return kImageDocumentExtensions.contains(extension);
}

/// Matches a leading `http://` or `https://` scheme. Used to decide whether
/// `?query`/`#fragment` should be treated as URL syntax (and stripped) rather
/// than literal characters in a local file name.
final RegExp _urlSchemePattern = RegExp(r'^https?://', caseSensitive: false);

bool _hasUrlScheme(String path) => _urlSchemePattern.hasMatch(path);
