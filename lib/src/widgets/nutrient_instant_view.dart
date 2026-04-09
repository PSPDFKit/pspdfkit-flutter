///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';
import 'package:nutrient_flutter_android/nutrient_flutter_android.dart'
    show NutrientInstantViewAndroid;
import 'package:nutrient_flutter_ios/nutrient_flutter_ios.dart'
    show NutrientInstantViewIOS;

import '../configuration/web_view_configuration.dart';

/// A cross-platform widget that opens a Nutrient Instant document.
///
/// [NutrientInstantView] connects to a Document Engine server using the
/// provided [serverUrl] and [jwt] credentials and renders the resulting
/// document with real-time collaboration support.
///
/// On Android the widget delegates to [NutrientInstantViewAndroid]; on iOS it
/// delegates to [NutrientInstantViewIOS]. Both share the same callback
/// contract: [onViewCreated] receives a [NutrientViewHandle] once the
/// underlying platform view is ready.
///
/// Pass an optional [configuration] to customise the viewer appearance and
/// behaviour. Set [NutrientViewConfiguration.webConfig] to a
/// [WebViewConfiguration] instance for web-specific options.
///
/// Example:
/// ```dart
/// NutrientInstantView(
///   serverUrl: 'https://your-server.example.com/api/1/documents/abc123',
///   jwt: 'eyJhbGci...',
///   configuration: NutrientViewConfiguration(
///     pageLayoutMode: PageLayoutMode.single,
///     appearanceMode: AppearanceMode.night,
///     iosConfig: IOSViewConfiguration(
///       spreadFitting: SpreadFitting.adaptive,
///     ),
///     webConfig: WebViewConfiguration(
///       locale: 'de',
///     ),
///   ),
///   onViewCreated: (handle) {
///     // The view is ready — store the handle for later use.
///   },
/// )
/// ```
class NutrientInstantView extends StatelessWidget {
  /// The Document Engine server URL for the Instant document to open.
  final String serverUrl;

  /// The JWT used to authenticate with the Document Engine server.
  final String jwt;

  /// Optional viewer configuration.
  final NutrientViewConfiguration? configuration;

  /// Called when the platform view has been created and is ready to use.
  final void Function(NutrientViewHandle handle)? onViewCreated;

  /// Creates a [NutrientInstantView].
  const NutrientInstantView({
    super.key,
    required this.serverUrl,
    required this.jwt,
    this.configuration,
    this.onViewCreated,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve webConfig: if it is a WebViewConfiguration, pre-serialize it
    // into the builder-map format so nutrient_flutter_web can consume it
    // without importing nutrient_flutter.
    NutrientViewConfiguration? resolvedConfig = configuration;
    if (resolvedConfig != null &&
        resolvedConfig.webConfig is WebViewConfiguration) {
      resolvedConfig = NutrientViewConfiguration(
        scrollDirection: resolvedConfig.scrollDirection,
        pageLayoutMode: resolvedConfig.pageLayoutMode,
        pageTransition: resolvedConfig.pageTransition,
        firstPageAlwaysSingle: resolvedConfig.firstPageAlwaysSingle,
        userInterfaceViewMode: resolvedConfig.userInterfaceViewMode,
        thumbnailBarMode: resolvedConfig.thumbnailBarMode,
        appearanceMode: resolvedConfig.appearanceMode,
        startPage: resolvedConfig.startPage,
        enableTextSelection: resolvedConfig.enableTextSelection,
        enableAnnotationEditing: resolvedConfig.enableAnnotationEditing,
        enableFormEditing: resolvedConfig.enableFormEditing,
        disableAutosave: resolvedConfig.disableAutosave,
        minimumZoomScale: resolvedConfig.minimumZoomScale,
        maximumZoomScale: resolvedConfig.maximumZoomScale,
        androidConfig: resolvedConfig.androidConfig,
        iosConfig: resolvedConfig.iosConfig,
        webConfig:
            (resolvedConfig.webConfig as WebViewConfiguration).toBuilderMap(),
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return NutrientInstantViewAndroid(
        serverUrl: serverUrl,
        jwt: jwt,
        configuration: resolvedConfig,
        onViewCreated: onViewCreated,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return NutrientInstantViewIOS(
        serverUrl: serverUrl,
        jwt: jwt,
        configuration: resolvedConfig,
        onViewCreated: onViewCreated,
      );
    }
    return Text(
      '$defaultTargetPlatform is not yet supported by Nutrient Instant for Flutter.',
    );
  }
}
