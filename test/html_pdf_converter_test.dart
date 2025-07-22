import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

///Tests for the [HtmlPdfConverter] class.
///run 'flutter pub run build_runner build' to generate the Mocks.
///
@GenerateMocks([MethodChannel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName =
      'dev.flutter.pigeon.nutrient_flutter.NutrientApi.generatePdfFromHtmlString.nutrient';
  String html = '<html><body><h1>Hello World</h1></body></html>';
  String outPutFile = 'test.pdf';

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      channelName,
      (ByteData? message) async {
        final List<Object?> args = NutrientApi.pigeonChannelCodec
            .decodeMessage(message) as List<Object?>;
        final String htmlInput = args[0] as String;
        final String outputPath = args[1] as String;

        if (htmlInput.isEmpty || outputPath.isEmpty) {
          // Return a single-element list with null to indicate a null result
          return NutrientApi.pigeonChannelCodec.encodeMessage([null]);
        }

        final List<Object?> response = [outputPath];
        return NutrientApi.pigeonChannelCodec.encodeMessage(response);
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      channelName,
      null,
    );
  });

  test('Generate Pdf from HTML', () async {
    String? result = await Nutrient.generatePdfFromHtmlString(html, outPutFile);
    expect(result, 'test.pdf');
  });

  test('Test empty output file', () async {
    String? result = await Nutrient.generatePdfFromHtmlString(html, '');
    expect(result, null);
  });

  test('Test empty html', () async {
    String? result = await Nutrient.generatePdfFromHtmlString('', outPutFile);
    expect(result, null);
  });
}
