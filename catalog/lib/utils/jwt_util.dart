// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

/// JWT minting for the AI Assistant and Instant examples.
///
/// Signs with the **demo** RSA keypair from the `ai-assistant-demo` stack
/// (<https://github.com/PSPDFKit/ai-assistant-demo>) — its Docker compose
/// configures the matching public key as `JWT_PUBLIC_KEY` for both the
/// Document Engine and the AI Assistant containers, so tokens minted here
/// validate against a locally-running demo backend. **Demo/testing only**:
/// a real app must never embed a private key; mint JWTs on your own server.
class JwtUtil {
  JwtUtil._();

  // Demo private key — pairs with the ai-assistant-demo JWT_PUBLIC_KEY.
  static const String _demoPrivateKey = '''
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEA2gzhmJ9TDanEzWdP1WG+0Ecwbe7f3bv6e5UUpvcT5q68IQJK
P47AQdBAnSlFVi4X9SaurbWoXdS6jpmPpk24QvitzLNFphHdwjFBelTAOa6taZrS
usoFvrtK9x5xsW4zzt/bkpUraNx82Z8MwLwrt6HlY7dgO9+xBAabj4t1d2t+0HS8
O/ed3CB6T2lj6S8AbLDSEFc9ScO6Uc1XJlSorgyJJSPCpNhSq3AubEZ1wMS1iEtg
AzTPRDsQv50qWIbn634HLWxTP/UH6YNJBwzt3O6q29kTtjXlMGXCvin37PyX4Jy1
IiPFwJm45aWJGKSfVGMDojTJbuUtM+8P9RrnAwIDAQABAoIBAQDSKxhGw0qKINhQ
IwQP5+bDWdqUG2orjsQf2dHOHNhRwJoUNuDZ4f3tcYzV7rGmH0d4Q5CaXj2qMyCd
0eVjpgW0h3z9kM3RA+d7BX7XKlkdQABliZUT9SUUcfIPvohXPKEzBRHed2kf6WVt
XKAuJTD+Dk3LjzRygWldOAE4mnLeZjU61kxPYriynyre+44Gpsgy37Tj25MAmVCY
Flotr/1WZx6bg3HIyFRGxnoJ1zU1MkGxwS4IsrQwOpWEHBiD5nvo54hF5I00NHj/
ccz+MwpgGdjyl02IGCy1fF+Q5SYyH86DG52Mgn8VI9dseGmanLGcgNvrdJFILoJR
SZW7gQoBAoGBAP+D6ZmRF7EqPNMypEHQ5qHHDMvil3mhNQJyIC5rhhl/nn063wnm
zhg96109hVh4zUAj3Rmjb9WqPiW7KBMJJdnEPjmZ/NOXKmgjs2BF+c8oiLQyTQml
xB7LnptvBDi8MnEd3uemfxNuZc+2siuSzgditshNru8xPG2Sn99JC271AoGBANp2
xj5EfdlqNLd11paLOtJ7dfREgc+8FxQCiKSxbaOlVXNk0DW1w4+zLnFohj2m/wRr
bBIzSL+eufoQ9y4BT/AA+ln4qxOpC0isOGK5SxwIjB6OHhCuP8L3anj1IFYM+NX0
Xr1/qdZHKulgbS49cq+TDpB74WyKLLnsvQFyINMXAoGABR5+cp4ujFUdTNnp4out
4zXasscCY+Rv7HGe5W8wC5i78yRXzZn7LQ8ohQCziDc7XXqadmYI2o4DmrvqLJ91
S6yb1omYQCD6L4XvlREx1Q2p13pegr/4cul/bvvFaOGUXSHNEnUKfLgsgAHYBfl1
+T3oDZFI3O/ulv9mBpIvEXUCgYEApeRnqcUM49o4ac/7wZm8czT5XyHeiUbFJ5a8
+IMbRJc6CkRVr1N1S1u/OrMqrQpwwIRqLm/vIEOB6hiT+sVYVGIJueSQ1H8baHYO
4zjdhk4fSNyWjAgltwF2Qp+xjGaRVrcYckHNUD/+n/VvMxvKSPUcrC7GAUvzpsPU
ypJFxsUCgYEA6GuP6M2zIhCYYeB2iLRD4ZHw92RfjikaYmB0++T0y2TVrStlzXHl
c8H6tJWNchtHH30nfLCj9WIMb/cODpm/DrzlSigHffo3+5XUpD/2nSrcFKESw4Xs
a4GXoAxqU44w4Mckg2E19b2MrcNkV9eWAyTACbEO4oFcZcSZOCKj8Fw=
-----END RSA PRIVATE KEY-----
''';

  /// Mints an AI Assistant JWT (claims: `userId`, `iat`/`exp`/`jti`).
  static String generateAiToken({
    required String userId,
    int expiresInMinutes = 60,
  }) {
    final now = DateTime.now();
    final jwt = JWT({
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp':
          now.add(Duration(minutes: expiresInMinutes)).millisecondsSinceEpoch ~/
              1000,
      'jti': const Uuid().v4(),
      'userId': userId,
    });
    return jwt.sign(RSAPrivateKey(_demoPrivateKey),
        algorithm: JWTAlgorithm.RS256);
  }

  /// Mints a Document Engine / Instant JWT for [documentId] with
  /// `read-document`, `write`, and `download` permissions.
  static String generateInstantToken({
    required String documentId,
    int expiresInMinutes = 60,
  }) {
    final now = DateTime.now();
    final jwt = JWT({
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp':
          now.add(Duration(minutes: expiresInMinutes)).millisecondsSinceEpoch ~/
              1000,
      'jti': const Uuid().v4(),
      'document_id': documentId,
      'permissions': ['read-document', 'write', 'download'],
    });
    return jwt.sign(RSAPrivateKey(_demoPrivateKey),
        algorithm: JWTAlgorithm.RS256);
  }
}
