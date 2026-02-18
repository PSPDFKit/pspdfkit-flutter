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
import 'utils/platform_utils.dart';

class ThemeExample extends StatelessWidget {
  final String documentPath;

  const ThemeExample({super.key, required this.documentPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: PlatformUtils.isAndroid(),
      resizeToAvoidBottomInset: PlatformUtils.isIOS(),
      // appBar: AppBar(title: const Text('Custom Theme')),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          padding: PlatformUtils.isAndroid()
              ? const EdgeInsets.only(top: kToolbarHeight)
              : null,
          child: NutrientView(
            documentPath: documentPath,
            configuration: PdfConfiguration(
              themeConfiguration: const ThemeConfiguration(
                backgroundColor: Color(0xFF1E1E2E),
                separatorColor: Color(0xFF313244),
                toolbar: ToolbarTheme(
                  backgroundColor: Color(0xFF181825),
                  iconColor: Color(0xFFCDD6F4),
                  activeIconColor: Color(0xFF89B4FA),
                  titleColor: Color(0xFFCDD6F4),
                  statusBarColor: Color(0xFF11111B),
                ),
                annotationToolbar: AnnotationToolbarTheme(
                  backgroundColor: Color(0xFF1E1E2E),
                  iconColor: Color(0xFFBAC2DE),
                  activeIconColor: Color(0xFF89B4FA),
                  activeToolBackgroundColor: Color(0xFF313244),
                ),
                navigationTab: NavigationTabTheme(
                  backgroundColor: Color(0xFF181825),
                  iconColor: Color(0xFF6C7086),
                  selectedIconColor: Color(0xFF89B4FA),
                ),
                search: SearchTheme(
                  backgroundColor: Color(0xFF313244),
                  highlightColor: Color(0xFF585B70),
                ),
                thumbnailBar: ThumbnailBarTheme(
                  backgroundColor: Color(0xFF181825),
                ),
                selection: SelectionTheme(
                  textHighlightColor: Color(0x8089B4FA),
                  textHandleColor: Color(0xFF89B4FA),
                  annotationBorderColor: Color(0xFF89B4FA),
                ),
                dialog: ViewerDialogTheme(
                  backgroundColor: Color(0xFF1E1E2E),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
