///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart';

void main() {
  group('ToolbarItem', () {
    test('ToolbarItemType values are ToolbarItems (no wrapper needed)', () {
      const ToolbarItem item = ToolbarItemType.zoomIn;
      expect(item, isA<ToolbarItem>());
      expect(item, isA<ToolbarItemType>());
    });

    test('ToolbarItemType maps to its Web SDK id', () {
      expect(ToolbarItemType.zoomIn.id, 'zoom-in');
      expect(ToolbarItemType.sidebarThumbnails.id, 'sidebar-thumbnails');
      expect(ToolbarItemType.exportPdf.id, 'export-pdf');
      expect(ToolbarItemType.measurements.id, 'measure');
    });

    test('built-in and custom items coexist in one List<ToolbarItem>', () {
      final items = <ToolbarItem>[
        ToolbarItemType.search,
        CustomToolbarItem(id: 'greet', title: 'Greet', onPressed: () {}),
      ];
      expect(items.whereType<ToolbarItemType>(), hasLength(1));
      expect(items.whereType<CustomToolbarItem>(), hasLength(1));
    });

    test('exhaustive switch covers both ToolbarItem subtypes', () {
      String describe(ToolbarItem item) => switch (item) {
            ToolbarItemType type => 'builtin:${type.id}',
            CustomToolbarItem custom => 'custom:${custom.id}',
          };
      expect(describe(ToolbarItemType.zoomOut), 'builtin:zoom-out');
      expect(
        describe(const CustomToolbarItem(id: 'x')),
        'custom:x',
      );
    });

    test('CustomToolbarItem retains its fields', () {
      void onTap() {}
      final item = CustomToolbarItem(
        id: 'greet',
        title: 'Greet',
        icon: 'data:image/svg+xml,<svg/>',
        disabled: true,
        onPressed: onTap,
      );
      expect(item.id, 'greet');
      expect(item.title, 'Greet');
      expect(item.disabled, isTrue);
      expect(item.onPressed, same(onTap));
    });
  });
}
