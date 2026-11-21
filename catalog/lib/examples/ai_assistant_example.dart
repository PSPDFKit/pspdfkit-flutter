// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';
import '../utils/jwt_util.dart';

/// AI Assistant example — standalone document.
///
/// Demonstrates the AI Assistant on a **plain** [NutrientDocumentView]: the
/// bundled scientific paper is opened locally and
/// `NutrientViewConfiguration.aiAssistantConfiguration` points the SDK's
/// built-in chat UI at an AI Assistant server. No Document Engine / Instant
/// connection is involved — the only backend is the AI Assistant server
/// (run the `ai-assistant-demo` Docker stack locally; default port 4000).
///
/// The JWT is minted on-device with the demo key ([JwtUtil]) — demo only;
/// production apps must mint JWTs server-side.
///
/// The connection form and status bar are Flutter-owned (Maestro-reachable);
/// the AI chat itself is the native SDK UI behind the ✨ toolbar button, so
/// the chat round-trip is verified manually against a local backend.
///
/// **Web:** the bindings web adapter doesn't map `aiAssistantConfiguration`
/// into the Web SDK's load options yet, so the page degrades to an
/// explanatory panel there.
class AiAssistantExamplePage extends StatefulWidget {
  const AiAssistantExamplePage({super.key});

  @override
  State<AiAssistantExamplePage> createState() => _AiAssistantExamplePageState();
}

class _AiAssistantExamplePageState extends State<AiAssistantExamplePage> {
  // Android emulators reach the host's loopback via 10.0.2.2.
  static String get _defaultAiServerUrl => !kIsWeb && Platform.isAndroid
      ? 'http://10.0.2.2:4000'
      : 'http://localhost:4000';

  late final TextEditingController _aiServerController =
      TextEditingController(text: _defaultAiServerUrl);
  final TextEditingController _userIdController =
      TextEditingController(text: 'catalog-user');

  Future<String>? _documentPath;

  /// Non-null once Connect is tapped — drives the viewer subtree. Each
  /// connect mints a fresh JWT and remounts the view (the configuration is
  /// read once at view creation).
  Map<String, String>? _aiConfiguration;
  int _viewGeneration = 0;
  String _status = 'Not connected';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentPath ??= CatalogDocuments.scientificPaper(context);
  }

  @override
  void dispose() {
    _aiServerController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  void _connect() {
    final userId = _userIdController.text.trim();
    final serverUrl = _aiServerController.text.trim();
    if (serverUrl.isEmpty) {
      setState(() => _status = 'AI Assistant server URL is required');
      return;
    }
    setState(() {
      _aiConfiguration = {
        'serverUrl': serverUrl,
        'jwt': JwtUtil.generateAiToken(userId: userId),
        'sessionId': 'catalog-session',
        if (userId.isNotEmpty) 'userId': userId,
      };
      _viewGeneration++;
      _status = 'Opening document with AI Assistant…';
    });
  }

  void _disconnect() {
    setState(() {
      _aiConfiguration = null;
      _status = 'Not connected';
    });
  }

  void _onControllerReady(NutrientController _) {
    if (!mounted) return;
    setState(
      () => _status = 'AI Assistant configured — tap the ✨ toolbar button',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: _aiConfiguration == null,
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          if (_aiConfiguration != null)
            IconButton(
              icon: const Icon(Icons.link_off),
              tooltip: 'Disconnect',
              onPressed: _disconnect,
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _StatusBar(status: _status),
      ),
      body: kIsWeb
          ? const _UnsupportedPanel()
          : _aiConfiguration == null
              ? _buildConnectionForm(context)
              : FutureBuilder<String>(
                  future: _documentPath,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Failed to load: ${snapshot.error}'),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return NutrientDocumentView(
                      key: ValueKey('ai-view-$_viewGeneration'),
                      documentPath: snapshot.data!,
                      configuration: NutrientViewConfiguration(
                        aiAssistantConfiguration: _aiConfiguration,
                      ),
                      onControllerReady: _onControllerReady,
                    );
                  },
                ),
    );
  }

  Widget _buildConnectionForm(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BrandSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Opens the bundled scientific paper with the AI Assistant '
            'enabled. Run the ai-assistant-demo server locally, then '
            'Connect — the JWT is minted on-device with the demo key.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: BrandSpacing.lg),
          TextField(
            controller: _aiServerController,
            decoration: const InputDecoration(
              labelText: 'AI Assistant server URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: BrandSpacing.md),
          TextField(
            controller: _userIdController,
            decoration: const InputDecoration(
              labelText: 'User ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: BrandSpacing.lg),
          FilledButton.icon(
            onPressed: _connect,
            icon: const Icon(Icons.smart_toy_outlined),
            label: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String status;

  const _StatusBar({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BrandSpacing.lg,
          vertical: BrandSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Status',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              status,
              style: theme.textTheme.titleSmall?.copyWith(
                color: BrandColors.codeCoral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnsupportedPanel extends StatelessWidget {
  const _UnsupportedPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BrandSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.web_asset_off_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: BrandSpacing.md),
            Text(
              'The bindings web adapter does not map '
              'aiAssistantConfiguration into the Web SDK load options yet, '
              'so the AI Assistant example is not supported on web.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
