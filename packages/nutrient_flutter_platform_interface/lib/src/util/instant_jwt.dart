///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

/// Extracts the `document_id` claim from an Instant (Document Engine) JWT.
///
/// Shared by the per-platform `NutrientInstantView` implementations: the web
/// view needs the document ID as a `NutrientViewer.load()` key, and the iOS
/// view stamps it onto the typed `InstantSync*` / `InstantAuth*` events.
///
/// The payload (middle segment) is base64url-decoded — re-padded first, since
/// JWTs strip padding while `dart:convert`'s decoder requires it. Throws a
/// [FormatException] with a descriptive message when the JWT is malformed or
/// the claim is missing, so callers can choose between surfacing the message
/// (web renders it inline) and falling back (iOS uses an empty ID — the
/// server rejects such a token anyway, and the auth-failure event says so).
String instantDocumentIdFromJwt(String jwt) {
  final parts = jwt.split('.');
  if (parts.length != 3) {
    throw FormatException(
      'Invalid JWT — expected 3 segments, got ${parts.length}.',
    );
  }

  String payload = parts[1];
  final remainder = payload.length % 4;
  if (remainder != 0) {
    payload = payload.padRight(payload.length + (4 - remainder), '=');
  }

  final Map<String, dynamic> claims;
  try {
    claims = json.decode(utf8.decode(base64Url.decode(payload)))
        as Map<String, dynamic>;
  } catch (e) {
    throw FormatException('Failed to decode JWT payload — $e.');
  }

  final documentId = claims['document_id'];
  if (documentId == null) {
    throw const FormatException(
      'JWT payload is missing the "document_id" claim.',
    );
  }
  if (documentId is! String || documentId.isEmpty) {
    throw FormatException(
      '"document_id" claim must be a non-empty string, got: $documentId.',
    );
  }

  return documentId;
}
