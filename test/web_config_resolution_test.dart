///  Copyright © 2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter/src/configuration/web_config_resolution.dart';

void main() {
  group('resolveWebConfig', () {
    test('returns null for null config', () {
      expect(resolveWebConfig(null), isNull);
    });

    test('returns the same instance when webConfig is unset', () {
      const config = NutrientViewConfiguration(startPage: 2);
      expect(resolveWebConfig(config), same(config));
    });

    test('returns the same instance when webConfig is already a map', () {
      const config = NutrientViewConfiguration(
        webConfig: {'viewState': <String, dynamic>{}},
      );
      expect(resolveWebConfig(config), same(config));
    });

    // Regression test: NutrientDocumentView used to forward a raw
    // WebViewConfiguration to the web layer, where WebConfigurationBuilder
    // only consumes the pre-serialised builder-map form — so the entire
    // webConfig was silently ignored on Web.
    test('serialises a WebViewConfiguration into the builder-map form', () {
      const config = NutrientViewConfiguration(
        webConfig: WebViewConfiguration(
          readOnly: true,
          locale: 'de',
        ),
      );

      final resolved = resolveWebConfig(config)!;
      final webConfig = resolved.webConfig;
      expect(webConfig, isA<Map<String, dynamic>>());
      final map = webConfig! as Map<String, dynamic>;
      expect(map['viewState'], {'readOnly': true});
      expect(map['topLevel'], {'locale': 'de'});
    });

    // Regression test: the previous per-widget copies rebuilt the
    // configuration field-by-field and silently dropped
    // enableInstantComments, signatureSavingStrategy,
    // signatureCreationConfiguration and password.
    test('preserves all other fields while resolving webConfig', () {
      final signatureCreation = SignatureCreationConfiguration(
        fonts: ['Helvetica'],
      );
      final config = NutrientViewConfiguration(
        scrollDirection: ScrollDirection.horizontal,
        pageLayoutMode: PageLayoutMode.single,
        pageTransition: PageTransition.curl,
        firstPageAlwaysSingle: true,
        userInterfaceViewMode: UserInterfaceViewMode.always,
        thumbnailBarMode: ThumbnailBarMode.floating,
        appearanceMode: AppearanceMode.night,
        startPage: 3,
        enableTextSelection: true,
        enableAnnotationEditing: false,
        enableFormEditing: true,
        disableAutosave: true,
        enableInstantComments: true,
        minimumZoomScale: 0.5,
        maximumZoomScale: 4.0,
        signatureSavingStrategy: SignatureSavingStrategy.alwaysSave,
        signatureCreationConfiguration: signatureCreation,
        androidConfig: const AndroidViewConfiguration(),
        iosConfig: const IOSViewConfiguration(
          leftBarButtonItems: ['closeButtonItem'],
        ),
        webConfig: const WebViewConfiguration(readOnly: true),
        aiAssistantConfiguration: const {'serverUrl': 'https://example.com'},
        password: 'secret',
      );

      final resolved = resolveWebConfig(config)!;
      expect(resolved.scrollDirection, config.scrollDirection);
      expect(resolved.pageLayoutMode, config.pageLayoutMode);
      expect(resolved.pageTransition, config.pageTransition);
      expect(resolved.firstPageAlwaysSingle, config.firstPageAlwaysSingle);
      expect(resolved.userInterfaceViewMode, config.userInterfaceViewMode);
      expect(resolved.thumbnailBarMode, config.thumbnailBarMode);
      expect(resolved.appearanceMode, config.appearanceMode);
      expect(resolved.startPage, config.startPage);
      expect(resolved.enableTextSelection, config.enableTextSelection);
      expect(resolved.enableAnnotationEditing, config.enableAnnotationEditing);
      expect(resolved.enableFormEditing, config.enableFormEditing);
      expect(resolved.disableAutosave, config.disableAutosave);
      expect(resolved.enableInstantComments, config.enableInstantComments);
      expect(resolved.minimumZoomScale, config.minimumZoomScale);
      expect(resolved.maximumZoomScale, config.maximumZoomScale);
      expect(resolved.signatureSavingStrategy, config.signatureSavingStrategy);
      expect(
        resolved.signatureCreationConfiguration,
        same(signatureCreation),
      );
      expect(resolved.androidConfig, same(config.androidConfig));
      expect(resolved.iosConfig, same(config.iosConfig));
      expect(
        resolved.aiAssistantConfiguration,
        config.aiAssistantConfiguration,
      );
      expect(resolved.password, config.password);
      expect(resolved.webConfig, isA<Map<String, dynamic>>());
    });
  });
}
