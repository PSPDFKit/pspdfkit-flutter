// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';
import '../utils/jwt_util.dart';

/// Instant View example — real-time collaboration.
///
/// Connects [NutrientInstantView] to a Document Engine server and renders an
/// Instant document with live sync: open the same document from two devices
/// (or this page plus the DE dashboard) and annotations replicate between
/// them. Covers legacy rows #32 (Instant View) and #31 (Instant
/// collaboration Web).
///
/// The Document Engine JWT is minted on-device with the demo key
/// ([JwtUtil.generateInstantToken] — `document_id` claim + read/write/download
/// permissions; demo only, mint server-side in production). Run a local
/// Document Engine whose `JWT_PUBLIC_KEY` matches the demo keypair (the
/// `ai-assistant-demo` stack does), with the document uploaded under the
/// entered Document ID.
///
/// The status bar surfaces the typed `InstantAuth*` / `InstantSync*` events
/// from `controller.events` (emitted on iOS by bridging the Instant
/// framework's lifecycle notifications; Android currently surfaces the
/// document-load signal only, and the web SDK manages sync internally, so
/// both fall back to the document-loaded status).
class InstantExamplePage extends StatefulWidget {
  const InstantExamplePage({super.key});

  @override
  State<InstantExamplePage> createState() => _InstantExamplePageState();
}

class _InstantExamplePageState extends State<InstantExamplePage> {
  // Android emulators reach the host's loopback via 10.0.2.2.
  static String get _defaultServerUrl => !kIsWeb && Platform.isAndroid
      ? 'http://10.0.2.2:5001'
      : 'http://localhost:5001';

  late final TextEditingController _serverController =
      TextEditingController(text: _defaultServerUrl);
  final TextEditingController _documentIdController =
      TextEditingController(text: 'simple-test-doc');

  /// Non-null once Connect is tapped — drives the viewer subtree.
  ({String serverUrl, String jwt})? _connection;
  int _viewGeneration = 0;
  String _status = 'Not connected';
  StreamSubscription<NutrientEvent>? _eventsSub;

  /// Set from [NutrientInstantView.onDocumentLoadFailed]. A failed open is
  /// terminal — the viewer stays on its spinner and `onControllerReady` never
  /// fires — so the example swaps in its own error state with a Retry that
  /// remounts the view. Try it by connecting to a document the device has
  /// never downloaded while offline.
  DocumentLoadFailure? _loadFailure;

  /// The Instant controller surfaced by [NutrientInstantView.onControllerReady]
  /// — the view builds (and owns) the platform's default Instant controller,
  /// which carries the Instant sync methods alongside the regular controller
  /// surface. Not surfaced on web, where the Web SDK manages sync internally.
  NutrientInstantController? _controller;

  @override
  void dispose() {
    _eventsSub?.cancel();
    _serverController.dispose();
    _documentIdController.dispose();
    super.dispose();
  }

  void _connect() {
    final serverUrl = _serverController.text.trim();
    final documentId = _documentIdController.text.trim();
    if (serverUrl.isEmpty || documentId.isEmpty) {
      setState(() => _status = 'Server URL and Document ID are required');
      return;
    }
    setState(() {
      _connection = (
        serverUrl: serverUrl,
        jwt: JwtUtil.generateInstantToken(documentId: documentId),
      );
      _viewGeneration++;
      _loadFailure = null;
      _status = 'Connecting…';
    });
  }

  void _disconnect() {
    _eventsSub?.cancel();
    _eventsSub = null;
    setState(() {
      _connection = null;
      _controller = null;
      _loadFailure = null;
      _status = 'Not connected';
    });
  }

  /// Bumping the view generation changes the widget's key, which tears the
  /// platform view down and builds a fresh one — the only way to retry a
  /// failed open, since the failed view will not recover on its own.
  void _retry() {
    setState(() {
      _viewGeneration++;
      _loadFailure = null;
      _status = 'Connecting…';
    });
  }

  void _onDocumentLoadFailed(DocumentLoadFailure failure) {
    if (!mounted) return;
    setState(() {
      _loadFailure = failure;
      _controller = null;
      // `code` is Android-only; on iOS and web the message is all there is.
      _status = failure.code == null
          ? 'Load failed: ${failure.message}'
          : 'Load failed (${failure.code}): ${failure.message}';
    });
  }

  /// Trigger an immediate sync via the Instant controller — one of the sync
  /// controls that live on [NutrientInstantController].
  Future<void> _syncNow() async {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _status = 'Sync requested…');
    await controller.syncAnnotations();
  }

  /// Called from [NutrientInstantView.onControllerReady]: keep the controller
  /// for the sync controls and listen to its typed Instant events. Early
  /// events are buffered by the controller, so subscribing here misses none.
  void _onControllerReady(NutrientInstantController controller) {
    _controller = controller;
    _eventsSub?.cancel();
    _eventsSub = controller.events.listen((event) {
      if (!mounted) return;
      final message = switch (event) {
        InstantAuthFinishedEvent(:final documentId) =>
          'Authenticated · $documentId',
        InstantAuthFailedEvent(:final error) => 'Auth failed: $error',
        InstantSyncStartedEvent() => 'Syncing…',
        InstantSyncFinishedEvent(:final documentId) =>
          'In sync · $documentId — edits replicate live',
        InstantSyncFailedEvent(:final error) => 'Sync failed: $error',
        DocumentLoadedEvent() => 'Document loaded',
        _ => null,
      };
      if (message != null) setState(() => _status = message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: _connection == null,
      appBar: AppBar(
        title: const Text('Instant View'),
        actions: [
          if (_connection != null && !kIsWeb)
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'Sync now (syncAnnotations)',
              onPressed: _controller == null ? null : _syncNow,
            ),
          if (_connection != null)
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
      body: _connection == null
          ? _buildConnectionForm(context)
          : _loadFailure != null
              ? _LoadFailureView(failure: _loadFailure!, onRetry: _retry)
              : NutrientInstantView(
                  key: ValueKey('instant-view-$_viewGeneration'),
                  serverUrl: _connection!.serverUrl,
                  jwt: _connection!.jwt,
                  // The bare (untyped) view builds the platform's default Instant
                  // controller and surfaces it here with the Instant sync methods.
                  onControllerReady: _onControllerReady,
                  // The document never loads on failure, so this is the only
                  // signal: onControllerReady won't fire and there is no
                  // controller whose events stream could carry the error.
                  onDocumentLoadFailed: _onDocumentLoadFailed,
                  // On web the view-created callback is the readiness signal —
                  // the Web SDK manages sync internally and the typed
                  // InstantSync*/InstantAuth* events are not emitted there.
                  onViewCreated: (_) {
                    if (kIsWeb && mounted) {
                      setState(
                        () => _status = 'Document loaded — edits sync live',
                      );
                    }
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
            'Connect to a Document Engine and open an Instant document '
            'with live collaboration. The JWT is minted on-device with '
            'the demo key — the server must trust the matching public key.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: BrandSpacing.lg),
          TextField(
            controller: _serverController,
            decoration: const InputDecoration(
              labelText: 'Document Engine URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: BrandSpacing.md),
          TextField(
            controller: _documentIdController,
            decoration: const InputDecoration(
              labelText: 'Document ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: BrandSpacing.lg),
          FilledButton.icon(
            onPressed: _connect,
            icon: const Icon(Icons.sync_outlined),
            label: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}

/// Error state shown in place of the viewer when the document fails to open.
///
/// Retry remounts [NutrientInstantView] under a new key — a failed view does
/// not recover on its own.
class _LoadFailureView extends StatelessWidget {
  final DocumentLoadFailure failure;
  final VoidCallback onRetry;

  const _LoadFailureView({required this.failure, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // type/code are Android-only; iOS and web report the message alone.
    final details = [
      if (failure.type != null) failure.type!,
      if (failure.code != null) failure.code!,
    ].join(' · ');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BrandSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: BrandSpacing.lg),
            Text(
              'Could not open the document',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: BrandSpacing.sm),
            Text(
              failure.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: BrandSpacing.xs),
              Text(
                details,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
            const SizedBox(height: BrandSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
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
