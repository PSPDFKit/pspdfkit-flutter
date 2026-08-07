// The smallest end-to-end Nutrient Flutter app: initialize the SDK, then show a
// PDF with `NutrientDocumentView`. Runs on Android, iOS, and web with no license
// key (trial mode, watermarked).

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nutrient_flutter/bindings.dart';
import 'package:path_provider/path_provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // No license key (trial mode) and no adapter: the SDK registers its built-in
  // default adapter for the current platform, which is all `NutrientDocumentView`
  // needs. Pass an adapter to `initialize()` only when you want to customize the
  // viewer or reach platform-specific APIs.
  await Nutrient.initialize();

  runApp(const SimpleApp());
}

class SimpleApp extends StatelessWidget {
  const SimpleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrient Simple',
      debugShowCheckedModeBanner: false,
      home: DocumentPage(),
    );
  }
}

/// Loads the bundled `assets/document.pdf` and displays it.
class DocumentPage extends StatelessWidget {
  DocumentPage({super.key});

  // Resolved once when the page is created and reused across rebuilds.
  final Future<String> _documentPath = _resolveDocument();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Nutrient Simple')),
      body: FutureBuilder<String>(
        future: _documentPath,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return NutrientDocumentView(documentPath: snapshot.data!);
        },
      ),
    );
  }
}

/// The native (Android/iOS) viewers need a real file path, so the bundled
/// asset is copied into the OS temp directory. On web the Nutrient viewer
/// loads the asset path directly, so it's returned unchanged.
Future<String> _resolveDocument() async {
  const assetPath = 'assets/document.pdf';
  if (kIsWeb) return assetPath;

  final bytes = await rootBundle.load(assetPath);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/document.pdf');
  await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
  return file.path;
}
