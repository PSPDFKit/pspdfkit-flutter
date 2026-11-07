// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nutrient_flutter/bindings.dart';

import '../adapters/catalog_adapter_controller.dart';
import '../adapters/catalog_adapters.dart';
import '../design/design.dart';

/// Document from Bytes example (HYB-951 coverage Track 3.4).
///
/// Opens a PDF from an in-memory `Uint8List` instead of a file path — both in
/// the **viewer** (`NutrientDocumentView(documentBytes: …)`) and **headlessly**
/// (`adapter.openDocumentFromBytes(…)`). The bytes are read straight from a
/// bundled asset with `rootBundle.load(...)`, simulating bytes that arrived
/// from the network, a database, or generated at runtime.
///
/// On Android and iOS the bytes are persisted to a temp file under the hood;
/// on web they're wrapped in a blob URL.
class DocumentFromBytesExamplePage extends StatefulWidget {
  const DocumentFromBytesExamplePage({super.key});

  @override
  State<DocumentFromBytesExamplePage> createState() =>
      _DocumentFromBytesExamplePageState();
}

class _DocumentFromBytesExamplePageState
    extends State<DocumentFromBytesExamplePage> {
  /// Per-view adapter for the embedded viewer.
  final CatalogAdapterController? _adapter = createCatalogAdapter();

  Uint8List? _bytes;
  String _status = 'Loading bytes…';

  @override
  void initState() {
    super.initState();
    _loadBytesAndReadHeadlessly();
  }

  @override
  void dispose() {
    _adapter?.dispose();
    super.dispose();
  }

  Future<void> _loadBytesAndReadHeadlessly() async {
    try {
      // Read the bundled PDF straight into memory — no file path involved.
      final data = await rootBundle.load(CatalogDocuments.welcome.assetPath);
      final bytes = data.buffer.asUint8List();
      if (!mounted) return;
      setState(() => _bytes = bytes);

      // Prove the headless path too: open the same bytes without a viewer and
      // read the page count, then close.
      final doc = await Nutrient.openDocumentFromBytes(bytes);
      try {
        final pageCount = await doc.getPageCount();
        if (!mounted) return;
        setState(() => _status =
            '${_kb(bytes.length)} loaded · headless read $pageCount pages');
      } finally {
        await doc.close();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Failed: $error');
    }
  }

  static String _kb(int bytes) => '${(bytes / 1024).toStringAsFixed(0)} KB';

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Document from Bytes')),
      body: Column(
        children: [
          Expanded(
            child: bytes == null
                ? const Center(child: CircularProgressIndicator())
                : NutrientDocumentView<CatalogAdapterController>(
                    documentBytes: bytes,
                    adapter: _adapter,
                  ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: BrandSpacing.lg,
                vertical: BrandSpacing.md,
              ),
              child: Row(
                children: [
                  const Icon(Icons.memory_outlined, size: 18),
                  const SizedBox(width: BrandSpacing.sm),
                  Expanded(
                    child: Text(
                      _status,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
