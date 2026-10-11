///  Copyright © 2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

void main() {
  group('NutrientViewConfiguration.copyWith', () {
    // A configuration with every field set, used to verify that copyWith
    // carries all of them over. When adding a field to
    // NutrientViewConfiguration, add it here and to the assertions below so
    // this test keeps guarding against silently dropped fields (the original
    // webConfig-resolution copies dropped enableInstantComments,
    // signatureSavingStrategy, signatureCreationConfiguration and password).
    final full = NutrientViewConfiguration(
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
      signatureCreationConfiguration: SignatureCreationConfiguration(
        fonts: ['Helvetica'],
      ),
      androidConfig: const AndroidViewConfiguration(),
      iosConfig: const IOSViewConfiguration(
        leftBarButtonItems: ['closeButtonItem'],
        rightBarButtonItems: ['searchButtonItem'],
      ),
      webConfig: {'viewState': <String, dynamic>{}},
      aiAssistantConfiguration: {'serverUrl': 'https://example.com'},
      password: 'secret',
    );

    void expectMatchesFullExceptWebConfig(NutrientViewConfiguration copy) {
      expect(copy.scrollDirection, full.scrollDirection);
      expect(copy.pageLayoutMode, full.pageLayoutMode);
      expect(copy.pageTransition, full.pageTransition);
      expect(copy.firstPageAlwaysSingle, full.firstPageAlwaysSingle);
      expect(copy.userInterfaceViewMode, full.userInterfaceViewMode);
      expect(copy.thumbnailBarMode, full.thumbnailBarMode);
      expect(copy.appearanceMode, full.appearanceMode);
      expect(copy.startPage, full.startPage);
      expect(copy.enableTextSelection, full.enableTextSelection);
      expect(copy.enableAnnotationEditing, full.enableAnnotationEditing);
      expect(copy.enableFormEditing, full.enableFormEditing);
      expect(copy.disableAutosave, full.disableAutosave);
      expect(copy.enableInstantComments, full.enableInstantComments);
      expect(copy.minimumZoomScale, full.minimumZoomScale);
      expect(copy.maximumZoomScale, full.maximumZoomScale);
      expect(copy.signatureSavingStrategy, full.signatureSavingStrategy);
      expect(
        copy.signatureCreationConfiguration,
        same(full.signatureCreationConfiguration),
      );
      expect(copy.androidConfig, same(full.androidConfig));
      expect(copy.iosConfig, same(full.iosConfig));
      expect(copy.aiAssistantConfiguration, full.aiAssistantConfiguration);
      expect(copy.password, full.password);
    }

    test('with no arguments preserves every field', () {
      final copy = full.copyWith();
      expectMatchesFullExceptWebConfig(copy);
      expect(copy.webConfig, same(full.webConfig));
    });

    test('replaces webConfig and preserves the rest', () {
      final replacement = {'topLevel': <String, dynamic>{}};
      final copy = full.copyWith(webConfig: replacement);
      expectMatchesFullExceptWebConfig(copy);
      expect(copy.webConfig, same(replacement));
    });

    test('replaces individual fields', () {
      final copy = full.copyWith(
        startPage: 7,
        appearanceMode: AppearanceMode.sepia,
      );
      expect(copy.startPage, 7);
      expect(copy.appearanceMode, AppearanceMode.sepia);
      expect(copy.scrollDirection, full.scrollDirection);
      expect(copy.password, full.password);
    });
  });
}
