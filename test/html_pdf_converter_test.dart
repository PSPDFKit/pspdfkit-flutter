import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

import 'html_pdf_converter_test.mocks.dart';

///Tests for the [HtmlPdfConverter] class.
///run 'flutter pub run build_runner build' to generate the Mocks.
///
@GenerateMocks([MethodChannel])
void main() {
  final channel = MockMethodChannel();
  String html = '<html><body><h1>Hello World</h1></body></html>';
  String outPutFile = 'test.pdf';

  setUp(() {
    when(channel.invokeMethod<String>(any, any)).thenAnswer((invocation) async {
      return (invocation.positionalArguments[1]
          as Map<String, dynamic>)['outputPath'] as String;
    });
  });

  test('Generate Pdf from HTML', () async {
    PspdfkitProcessor pdfProcessor = PspdfkitProcessor(channel);
    String? result =
        await pdfProcessor.generatePdfFromHtmlString(html, outPutFile);
    expect(result, 'test.pdf');
  });

  test('Test empty output file', () async {
    PspdfkitProcessor pdfProcessor = PspdfkitProcessor(channel);
    String? result = await pdfProcessor.generatePdfFromHtmlString(html, '');
    expect(result, null);
  });

  test('Test empty html', () async {
    PspdfkitProcessor pdfProcessor = PspdfkitProcessor(channel);
    String? result =
        await pdfProcessor.generatePdfFromHtmlString('', outPutFile);
    expect(result, null);
  });
}
