// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getFormFields', (WidgetTester tester) async {
    // Setup the PSPDFKit widget
    await tester
        .pumpWidget(PspdfkitWidget(
      documentPath: 'assets/pspdfkit_example_document.pdf',
      onPdfDocumentLoaded: (document) async {
        // Get the form fields
        final List<PdfFormField> formFields = await document.getFormFields();
        // Assert that the form fields are not empty
        expect(formFields.isNotEmpty, true);
      },
    ))
        .then((_) {
      // Pump the widget
      tester.pumpAndSettle();
    });
  });

  testWidgets('validate form field properties', (WidgetTester tester) async {
    // Setup the PSPDFKit widget
    await tester.pumpWidget(PspdfkitWidget(
      documentPath: 'assets/pspdfkit_example_document.pdf',
      onPspdfkitWidgetCreated: (view) {
        // Set the form field value
        view.setFormFieldValue('Updated Form Field Value', 'Name_Last');
      },
      onPdfDocumentLoaded: (document) async {
        // Get the form fields
        final List<PdfFormField> formFields = await document.getFormFields();
        // Assert that the form fields are not empty
        expect(formFields.isNotEmpty, false);

        // Get the first form field
        final PdfFormField formField = formFields.first;
        // Assert that the form field is not null
        expect(formField, isNotNull);
        // Assert that the form field has a name
        expect(formField.name?.isNotEmpty, true);
        // Assert that the form field has a type
        expect(formField.type, isNotNull);
        // Assert that the form field has a fully qualified name
        expect(formField.fullyQualifiedName?.isNotEmpty, true);
        // Assert that the form field is not read-only
        expect(formField.isReadOnly, isNotNull);
        // Assert that the form field is not required
        expect(formField.isRequired, isNotNull);
        // Assert that the form field is exported
        expect(formField.isNoExport, isNotNull);
        // Assert that the form field is not dirty
        expect(formField.isDirty, isNotNull);
      },
    ));
  });
}
