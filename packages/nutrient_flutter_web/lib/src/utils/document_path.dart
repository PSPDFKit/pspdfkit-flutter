///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Returns the URL the Web SDK should load for a `documentPath`.
///
/// A path that's one of the app's declared Flutter assets (a key in
/// [assetKeys], such as `assets/document.pdf`) maps to [assetUrl]. Flutter
/// doesn't serve assets at their key: a release build serves
/// `assets/document.pdf` at `assets/assets/document.pdf`, under the app's
/// base href. Any other path, such as a file the app serves itself from
/// `web/`, passes through unchanged.
///
/// URLs (`http:`, `https:`, `blob:`, `data:`) pass through without reading
/// [assetKeys], and so does every path when [assetKeys] fails.
Future<String> resolveDocumentPath(
  String path, {
  required Future<Set<String>> Function() assetKeys,
  required String Function(String assetKey) assetUrl,
}) async {
  if (path.isEmpty || _isUrl(path)) return path;

  final Set<String> keys;
  try {
    keys = await assetKeys();
  } catch (_) {
    return path;
  }
  return keys.contains(path) ? assetUrl(path) : path;
}

bool _isUrl(String path) =>
    path.startsWith('http://') ||
    path.startsWith('https://') ||
    path.startsWith('blob:') ||
    path.startsWith('data:');
