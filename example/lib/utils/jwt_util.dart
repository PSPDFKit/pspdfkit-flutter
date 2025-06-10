import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

/// Utility class for JWT token generation and management for Nutrient AI Assistant
class JwtUtil {
  // Demo private key for testing purposes only
  // In production, you should use your own private key
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

  /// Generate a JWT token for Nutrient AI Assistant authentication
  ///
  /// [userId] - User identifier for the AI Assistant
  /// [expiresInMinutes] - Token expiration time in minutes (default: 60)
  /// [requestLimit] - Optional limit on number of requests
  /// [privateKey] - Private key for signing the JWT (default: demo key)
  /// [algorithm] - Algorithm to use for signing (default: RS256)
  static String generateToken({
    required String userId,
    int expiresInMinutes = 60,
    RequestLimit? requestLimit,
    String privateKey = _demoPrivateKey,
    JWTAlgorithm algorithm = JWTAlgorithm.RS256,
  }) {
    const uuid = Uuid();
    final now = DateTime.now();

    // Create claims for the JWT
    final Map<String, dynamic> claims = {
      // Standard claims
      'iat': now.millisecondsSinceEpoch ~/ 1000, // Issued at
      'exp':
          now.add(Duration(minutes: expiresInMinutes)).millisecondsSinceEpoch ~/
              1000, // Expiration time
      'jti': uuid.v4(), // JWT ID

      // Nutrient-specific claims
      'userId': userId,
    };

    // Add request limit if specified
    if (requestLimit != null) {
      claims['request_limit'] = {
        'requests': requestLimit.requests,
        'time_period_s': requestLimit.timePeriodInSeconds,
      };
    }

    // Create and sign the JWT
    final jwt = JWT(claims);

    String token;
    if (algorithm == JWTAlgorithm.RS256) {
      // Use RS256 algorithm with private key
      token = jwt.sign(
        RSAPrivateKey(privateKey),
        algorithm: algorithm,
      );
    } else {
      // Fallback to HS256 for simpler testing
      token = jwt.sign(
        SecretKey('your-256-bit-secret'),
        algorithm: JWTAlgorithm.HS256,
      );
    }

    return token;
  }

  /// Verify a JWT token
  ///
  /// [token] - JWT token to verify
  /// [publicKey] - Public key used to verify the JWT (for RS256)
  /// [secret] - Secret key used to verify the JWT (for HS256)
  static bool verifyToken(
    String token, {
    String? publicKey,
    String secret = 'your-256-bit-secret',
  }) {
    try {
      // Try to verify with RS256 first if public key is provided
      if (publicKey != null) {
        JWT.verify(token, RSAPublicKey(publicKey));
        return true;
      }

      // Fallback to HS256
      JWT.verify(token, SecretKey(secret));
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Class to represent request limits for AI Assistant
class RequestLimit {
  /// Maximum number of requests allowed
  final int requests;

  /// Time period in seconds for the request limit
  final int timePeriodInSeconds;

  /// Create a new request limit
  RequestLimit({
    required this.requests,
    required this.timePeriodInSeconds,
  });
}
