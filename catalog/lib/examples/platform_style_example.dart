// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';

/// Semantic marker surfaced once the viewer's controller reports ready.
const String platformStyleReadyLabel = 'platform_style_document_ready';

/// Basic Example using Platform Style.
///
/// Identical document-loading to the Basic example, but the surrounding Flutter
/// chrome adapts to the host platform: a [CupertinoPageScaffold] +
/// [CupertinoNavigationBar] on iOS, a Material [Scaffold] + [AppBar]
/// everywhere else. The embedded [NutrientDocumentView] is unchanged — this
/// shows how to wrap the viewer in platform-idiomatic navigation without
/// touching the SDK surface.
class PlatformStyleExamplePage extends StatefulWidget {
  const PlatformStyleExamplePage({super.key});

  @override
  State<PlatformStyleExamplePage> createState() =>
      _PlatformStyleExamplePageState();
}

class _PlatformStyleExamplePageState extends State<PlatformStyleExamplePage> {
  Future<String>? _documentPath;
  bool _documentReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentPath ??= CatalogDocuments.welcome(context);
  }

  void _onControllerReady(NutrientController _) {
    if (!mounted || _documentReady) return;
    setState(() => _documentReady = true);
  }

  Widget _buildViewer(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<String>(
          future: _documentPath,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Failed to load: ${snapshot.error}'));
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
        if (_documentReady)
          Positioned(
            left: 0,
            top: 0,
            child: Semantics(
              label: platformStyleReadyLabel,
              child: const SizedBox(width: 1, height: 1),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    // iOS → Cupertino chrome.
    if (isIOS) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Platform Style · Cupertino'),
        ),
        child: SafeArea(child: _buildViewer(context)),
      );
    }

    // Android / Web → Material chrome.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Platform Style · Material')),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _buildViewer(context),
      ),
    );
  }
}
