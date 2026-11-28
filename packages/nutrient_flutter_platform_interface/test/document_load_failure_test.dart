// Tests DocumentLoadFailure.fromMap, which parses the payload the native
// platform views send when a document fails to open. It has to survive a
// partial or malformed payload: dropping the failure is the bug this type
// exists to fix (https://linear.app/nutrient/issue/HYB-1050).
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/src/models/document_load_failure.dart';

void main() {
  group('DocumentLoadFailure.fromMap', () {
    test('reads message, type and code from a full payload', () {
      final failure = DocumentLoadFailure.fromMap(const {
        'message': 'Failed to connect to /10.0.2.2:5001',
        'type': 'InstantDownloadException',
        'code': 'REQUEST_FAILED',
      });

      expect(failure.message, 'Failed to connect to /10.0.2.2:5001');
      expect(failure.type, 'InstantDownloadException');
      expect(failure.code, 'REQUEST_FAILED');
    });

    test('leaves type and code null when the platform omits them', () {
      final failure = DocumentLoadFailure.fromMap(const {'message': 'Boom'});

      expect(failure.message, 'Boom');
      expect(failure.type, isNull);
      expect(failure.code, isNull);
    });

    test('falls back to the type when there is no message', () {
      final failure = DocumentLoadFailure.fromMap(const {
        'type': 'InstantException',
        'code': 'AUTHENTICATION_FAILED',
      });

      expect(failure.message, 'InstantException');
      expect(failure.code, 'AUTHENTICATION_FAILED');
    });

    test('falls back to a generic message for an empty payload', () {
      expect(
        DocumentLoadFailure.fromMap(const {}).message,
        'Document failed to load.',
      );
    });

    test('tolerates a null or non-map payload', () {
      for (final arguments in <Object?>[null, 'oops', 42]) {
        final failure = DocumentLoadFailure.fromMap(arguments);
        expect(failure.message, 'Document failed to load.');
        expect(failure.type, isNull);
        expect(failure.code, isNull);
      }
    });

    test('treats blank and non-string fields as absent', () {
      final failure = DocumentLoadFailure.fromMap(const {
        'message': '   ',
        'type': '',
        'code': 7,
      });

      expect(failure.message, 'Document failed to load.');
      expect(failure.type, isNull);
      expect(failure.code, isNull);
    });

    test('trims surrounding whitespace', () {
      final failure = DocumentLoadFailure.fromMap(const {
        'message': '  Failed to open document.  ',
        'type': ' InstantDownloadException ',
      });

      expect(failure.message, 'Failed to open document.');
      expect(failure.type, 'InstantDownloadException');
    });
  });

  group('DocumentLoadFailure', () {
    test('value equality covers all three fields', () {
      const a = DocumentLoadFailure(
        message: 'Boom',
        type: 'InstantException',
        code: 'REQUEST_FAILED',
      );
      const same = DocumentLoadFailure(
        message: 'Boom',
        type: 'InstantException',
        code: 'REQUEST_FAILED',
      );
      const differentCode = DocumentLoadFailure(
        message: 'Boom',
        type: 'InstantException',
        code: 'AUTHENTICATION_FAILED',
      );

      expect(a, same);
      expect(a.hashCode, same.hashCode);
      expect(a, isNot(differentCode));
    });

    test('toString includes the details that are present', () {
      expect(
        const DocumentLoadFailure(message: 'Boom').toString(),
        'DocumentLoadFailure(Boom)',
      );
      expect(
        const DocumentLoadFailure(
          message: 'Boom',
          type: 'InstantDownloadException',
          code: 'REQUEST_FAILED',
        ).toString(),
        'DocumentLoadFailure(Boom '
        '[type: InstantDownloadException, code: REQUEST_FAILED])',
      );
    });
  });
}
