///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Web implementation of [NutrientInstantView].
///
/// Mounts the Nutrient Web SDK viewer for an Instant document using
/// `NutrientViewer.load({ serverUrl, documentId, authPayload: {jwt}, instant: true })`.
///
/// The `documentId` claim is parsed from the JWT payload (base64url middle
/// segment). A malformed JWT or missing claim renders an inline error message
/// rather than crashing the widget tree.

library;

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:nutrient_flutter_web/nutrient_flutter_web.dart'
    hide Alignment, Theme;

import '../configuration/web_config_resolution.dart';

/// Web implementation of [NutrientInstantView].
///
/// Connects to a Document Engine server using [serverUrl] and [jwt], mounts
/// the Nutrient Web SDK viewer in Instant mode with live collaboration, and
/// surfaces the loaded view handle via [onViewCreated].
///
/// The [NutrientViewConfiguration] is applied the same way as in
/// [NutrientDocumentView] on web: cross-platform fields are translated to Web
/// SDK load-config keys via [WebConfigurationBuilder], and
/// [WebViewConfiguration] (if provided as [NutrientViewConfiguration.webConfig])
/// is serialised via its [WebViewConfiguration.toBuilderMap] helper to avoid a
/// circular import.
class NutrientInstantView<T extends NutrientInstantController>
    extends StatefulWidget {
  /// The Document Engine server URL for the Instant document.
  final String serverUrl;

  /// The JWT used to authenticate with the Document Engine server.
  ///
  /// The `document_id` claim is extracted from the JWT payload to form the
  /// Web SDK `documentId` load-config key.
  final String jwt;

  /// Optional viewer configuration.
  final NutrientViewConfiguration? configuration;

  /// Called when the platform view has been created and is ready to use.
  final void Function(NutrientViewHandle handle)? onViewCreated;

  /// Optional per-view controller — **ignored on web**.
  ///
  /// The web Instant view manages its own adapter internally (the Web SDK
  /// handles sync, and the typed `InstantSync*`/`InstantAuth*` events aren't
  /// emitted there). Accepted only so the cross-platform `NutrientInstantView`
  /// constructor matches the native one; see the native implementation for
  /// where it's used.
  final T? adapter;

  /// Called when the Instant controller is ready — **never called on web**,
  /// where Instant sync is configured at load time and the Web SDK manages it
  /// internally. Accepted so the constructor matches the native signature.
  final void Function(T controller)? onControllerReady;

  /// Creates a [NutrientInstantView].
  const NutrientInstantView({
    super.key,
    required this.serverUrl,
    required this.jwt,
    this.configuration,
    this.onViewCreated,
    this.adapter,
    this.onControllerReady,
  });

  @override
  State<NutrientInstantView<T>> createState() =>
      _NutrientInstantViewWebState<T>();
}

class _NutrientInstantViewWebState<T extends NutrientInstantController>
    extends State<NutrientInstantView<T>> {
  /// Result of parsing the JWT — either a `documentId` string or an error
  /// description. Computed once in [initState].
  late final _JwtParseResult _jwtResult;

  @override
  void initState() {
    super.initState();
    _jwtResult = _parseDocumentId(widget.jwt);
  }

  @override
  Widget build(BuildContext context) {
    if (_jwtResult is _JwtParseError) {
      return _ErrorWidget(message: (_jwtResult as _JwtParseError).message);
    }

    final documentId = (_jwtResult as _JwtParseSuccess).documentId;
    // Pre-serialise webConfig into the builder-map form WebConfigurationBuilder
    // consumes — it ignores a raw WebViewConfiguration (see resolveWebConfig).
    final resolvedConfig = resolveWebConfig(widget.configuration);

    return NutrientViewWeb(
      // A placeholder path is required by NutrientViewWeb's assertion; the
      // _InstantWebAdapter's configureLoad removes it before load() is called.
      documentPath: '',
      configuration: resolvedConfig,
      onViewCreated: widget.onViewCreated,
      adapter: _InstantWebAdapter(
        serverUrl: widget.serverUrl,
        documentId: documentId,
        jwt: widget.jwt,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// JWT parsing helpers
// ---------------------------------------------------------------------------

sealed class _JwtParseResult {}

final class _JwtParseSuccess extends _JwtParseResult {
  final String documentId;
  _JwtParseSuccess(this.documentId);
}

final class _JwtParseError extends _JwtParseResult {
  final String message;
  _JwtParseError(this.message);
}

/// Extracts `document_id` from [jwt] via the shared
/// [instantDocumentIdFromJwt] helper (also used by the iOS Instant view),
/// converting its [FormatException] into a [_JwtParseError] so the widget
/// can surface the message gracefully instead of crashing the tree.
_JwtParseResult _parseDocumentId(String jwt) {
  try {
    return _JwtParseSuccess(instantDocumentIdFromJwt(jwt));
  } on FormatException catch (e) {
    return _JwtParseError('NutrientInstantView: ${e.message}');
  }
}

// ---------------------------------------------------------------------------
// Instant adapter
// ---------------------------------------------------------------------------

/// A minimal [NutrientWebAdapter] that injects the Instant-specific keys into
/// the `PSPDFKit.load()` configuration before the instance is loaded.
///
/// Called from [NutrientInstantView] on web; not part of the public API.
class _InstantWebAdapter extends NutrientWebAdapter {
  final String serverUrl;
  final String documentId;
  final String jwt;

  _InstantWebAdapter({
    required this.serverUrl,
    required this.documentId,
    required this.jwt,
  });

  @override
  Future<void> configureLoad(
    NutrientViewHandle handle,
    Map<String, dynamic> config,
  ) async {
    await super.configureLoad(handle, config);

    // Remove the placeholder `document` key set by NutrientViewWeb; the Instant
    // load path uses `serverUrl` + `documentId` instead.
    config.remove('document');

    // Inject the Instant-specific keys required by the Nutrient Web SDK:
    //   https://www.nutrient.io/api/web/NutrientViewer.html#.load
    // The Web SDK requires `serverUrl` to end with a trailing slash —
    // without it, load() silently stalls after fetching its server chunks
    // (verified against a local Document Engine).
    config['serverUrl'] = serverUrl.endsWith('/') ? serverUrl : '$serverUrl/';
    config['documentId'] = documentId;
    config['instant'] = true;
    config['authPayload'] = {'jwt': jwt};
  }
}

// ---------------------------------------------------------------------------
// Inline error widget
// ---------------------------------------------------------------------------

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      child: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
