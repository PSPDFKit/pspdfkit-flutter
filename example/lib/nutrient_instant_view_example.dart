///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

// Default connection values for the bundled test Document Engine server.
// Use your machine's local IP so both iOS (physical/simulator) and Android
// emulators can reach the server on the same network.
const String _defaultServerUrl = 'http://192.168.1.65:5001';
const String _defaultDocumentId = '7KPT3CCM4NMSAJ2QT7JWM54DRT';
const String _defaultJwt =
    'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudF9pZCI6IjdLUFQzQ0NNNE5NU0FKMlFUN0pXTTU0RFJUIiwicGVybWlzc2lvbnMiOlsicmVhZC1kb2N1bWVudCIsIndyaXRlIiwiZG93bmxvYWQiXSwiaWF0IjoxNzczNzc5ODY4LCJleHAiOjIwODkzNTU4Njh9.WfbPXCc9stJ2f7jR47veV44RDuqIRxvfJE-09Ei3L3i3be5JMpEYDPBV6R667BmX3ioe_F6dmtDZJ3hppjrlepFd6suvBLLoqtYPxZRlkvFZIYsleLC0rdxT-HqAPpJkesNXoT_YOlT-fR_sm2JoiT6mSabvCRDDQySQRD_l87T5kuWzDL7q4GFIPMy-c2aGsertW5N6w7gPD1TESvvl7OqStffsAyHSBtKKtIZZoPeXch18TfNYpkeclpJ3Kb_UbcE35dIoKY3-ql0VmDpj1jKP-g252mGwemnKx4jpqwlQumBCCPITzNGUkJZnif5LveaaVbX_H_xBLdIOX9ckWeBc-EF3-4FKWKbeU-aj6H6x2UVW2h8u-xyMQ_QjblcAv4TkXb2wl_hI6CIuojMkuOIxKBpmTNzeuyLCAlWslww_xMPzuSe-a0-JS6XroN_ONOTY-rJvp0uyHUeCwHLrDrLB28hbLXXIi-IYsV2dutJwTeTWns6etUGX0JhPAq9zn7P1YBIkis3m_h7BaY3Qy6HoJytT1pAjIq0zIH2w4vvjL23blpq1wtkmlUaCA3Aur2TYS2DtNv0JXIUiSrW02-YjXfowVEUPkHegKB8IsT3-2qEmBYgHdSw_m11kY-XGzD4jvcCcCnP013uS25w8KIJRMReiX0CVIpNWHQwlFSU';


/// Demonstrates embedding a live Instant document as a widget using
/// [NutrientInstantView].
class NutrientInstantViewExample extends StatefulWidget {
  const NutrientInstantViewExample({super.key});

  @override
  State<NutrientInstantViewExample> createState() =>
      _NutrientInstantViewExampleState();
}

class _NutrientInstantViewExampleState
    extends State<NutrientInstantViewExample> {
  bool _connected = false;

  // Connection values — null until the user connects via the sheet.
  String? _serverUrl;
  String? _documentId;
  String? _jwt;

  // Incremented each time the user applies new connection settings,
  // causing NutrientInstantView to be fully recreated.
  int _viewKey = 0;

  void _showConnectionSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ConnectionSheet(
        initialServerUrl: _serverUrl ?? '',
        initialDocumentId: _documentId ?? '',
        initialJwt: _jwt ?? '',
        defaultServerUrl: _defaultServerUrl,
        defaultDocumentId: _defaultDocumentId,
        defaultJwt: _defaultJwt,
        onConnect: (serverUrl, documentId, jwt) => setState(() {
          _serverUrl = serverUrl;
          _documentId = documentId;
          _jwt = jwt;
          _connected = false;
          _viewKey++;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serverUrl = _serverUrl;
    final jwt = _jwt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrient Instant View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet),
            tooltip: 'Connection',
            onPressed: _showConnectionSheet,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Icon(
              _connected ? Icons.cloud_done : Icons.cloud_off,
              color: _connected ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (serverUrl != null)
            Container(
              width: double.infinity,
              color: Colors.grey.shade100,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Text(
                _connected
                    ? 'Connected · $_documentId · $serverUrl'
                    : 'Connecting to $serverUrl…',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Expanded(
            child: serverUrl == null || jwt == null
                ? _Placeholder(onConnect: _showConnectionSheet)
                : NutrientInstantView(
                    key: ValueKey(_viewKey),
                    serverUrl: serverUrl,
                    jwt: jwt,
                    configuration: const NutrientViewConfiguration(
                      pageLayoutMode: PageLayoutMode.single,
                      thumbnailBarMode: ThumbnailBarMode.floating,
                      enableAnnotationEditing: true,
                      enableFormEditing: true,
                      androidConfig: AndroidViewConfiguration(
                        showSearchAction: true,
                        showOutlineAction: true,
                      ),
                      iosConfig: IOSViewConfiguration(
                        spreadFitting: SpreadFitting.adaptive,
                      ),
                    ),
                    onViewCreated: (handle) {
                      debugPrint(
                          '[NutrientInstantViewExample] view ready: $handle');
                      setState(() => _connected = true);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Placeholder shown before the user connects
// ---------------------------------------------------------------------------

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.onConnect});
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No connection configured.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onConnect,
              icon: const Icon(Icons.settings_ethernet),
              label: const Text('Connect'),
            ),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// Connection sheet — server URL, document ID, and JWT
// ---------------------------------------------------------------------------

class _ConnectionSheet extends StatefulWidget {
  const _ConnectionSheet({
    required this.initialServerUrl,
    required this.initialDocumentId,
    required this.initialJwt,
    required this.defaultServerUrl,
    required this.defaultDocumentId,
    required this.defaultJwt,
    required this.onConnect,
  });

  final String initialServerUrl;
  final String initialDocumentId;
  final String initialJwt;
  final String defaultServerUrl;
  final String defaultDocumentId;
  final String defaultJwt;
  final void Function(String serverUrl, String documentId, String jwt)
      onConnect;

  @override
  State<_ConnectionSheet> createState() => _ConnectionSheetState();
}

class _ConnectionSheetState extends State<_ConnectionSheet> {
  late final TextEditingController _serverUrlController;
  late final TextEditingController _documentIdController;
  late final TextEditingController _jwtController;

  @override
  void initState() {
    super.initState();
    _serverUrlController =
        TextEditingController(text: widget.initialServerUrl);
    _documentIdController =
        TextEditingController(text: widget.initialDocumentId);
    _jwtController = TextEditingController(text: widget.initialJwt);
    _serverUrlController.addListener(_onTextChanged);
    _documentIdController.addListener(_onTextChanged);
    _jwtController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _serverUrlController.dispose();
    _documentIdController.dispose();
    _jwtController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final serverUrl = _serverUrlController.text.trim();
    final documentId = _documentIdController.text.trim();
    final jwt = _jwtController.text.trim();
    return serverUrl.isNotEmpty &&
        documentId.isNotEmpty &&
        jwt.isNotEmpty &&
        !serverUrl.startsWith('YOUR_') &&
        !documentId.startsWith('YOUR_') &&
        !jwt.startsWith('YOUR_');
  }

  void _connect() {
    if (!_isValid) return;
    widget.onConnect(
      _serverUrlController.text.trim(),
      _documentIdController.text.trim(),
      _jwtController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Connection',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  _serverUrlController.text = widget.defaultServerUrl;
                  _documentIdController.text = widget.defaultDocumentId;
                  _jwtController.text = widget.defaultJwt;
                }),
                child: const Text('Use Defaults'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _serverUrlController,
            decoration: const InputDecoration(
              labelText: 'Server URL',
              hintText: 'http://localhost:5001',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            autocorrect: false,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _documentIdController,
            decoration: const InputDecoration(
              labelText: 'Document ID',
              border: OutlineInputBorder(),
            ),
            autocorrect: false,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _jwtController,
            decoration: const InputDecoration(
              labelText: 'JWT',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            autocorrect: false,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isValid ? _connect : null,
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
