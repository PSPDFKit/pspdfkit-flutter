// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';

/// Semantic identifier exposed by this page once the underlying viewer
/// controller reports the document is fully loaded. Maestro flows assert on
/// this to confirm the document actually rendered (not just that the page
/// navigated).
const String basicExampleReadyLabel = 'basic_example_document_ready';

/// Basic example: load a PDF asset with the default [NutrientDocumentView].
///
/// Demonstrates the minimum integration:
/// 1. Extract the bundled asset to the OS temp directory (no-op on web).
/// 2. Pass the resulting path to [NutrientDocumentView].
/// 3. Track when the controller is ready and surface a semantic marker so
///    automated tests (e.g. Maestro) can assert the document loaded.
class BasicExamplePage extends StatefulWidget {
  const BasicExamplePage({super.key});

  @override
  State<BasicExamplePage> createState() => _BasicExamplePageState();
}

class _BasicExamplePageState extends State<BasicExamplePage> {
  Future<String>? _documentPath;
  bool _documentReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resolve once — the future is reused across rebuilds.
    _documentPath ??= CatalogDocuments.welcome(context);
  }

  void _onControllerReady(NutrientController _) {
    if (!mounted || _documentReady) return;
    setState(() => _documentReady = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The viewer manages its own keyboard insets; avoid Flutter resize.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Basic Example')),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            FutureBuilder<String>(
              future: _documentPath,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return NutrientDocumentView(
                  documentPath: snapshot.data!,
                  onControllerReady: _onControllerReady,
                );
              },
            ),
            // Invisible marker for automated UI tests. Maestro can read text
            // from a zero-size widget if it has Semantics; the marker only
            // appears once the controller fires `onControllerReady`.
            if (_documentReady)
              Positioned(
                left: 0,
                top: 0,
                child: Semantics(
                  label: basicExampleReadyLabel,
                  child: const SizedBox(width: 1, height: 1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
