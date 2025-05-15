///
///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/material.dart';
import 'utils/platform_utils.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class PspdfkitBasicExample extends StatelessWidget {
  final String documentPath;

  const PspdfkitBasicExample({super.key, required this.documentPath});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: PlatformUtils.isAndroid(),
      // Do not resize the the document view on Android or
      // it won't be rendered correctly when filling forms.
      resizeToAvoidBottomInset: PlatformUtils.isIOS(),
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          padding: PlatformUtils.isAndroid()
              ? const EdgeInsets.only(top: kToolbarHeight)
              : null,
          child: PspdfkitWidget(
            documentPath: documentPath,
            onAnnotationsChanged: (controller) async {
              print("test annotation changed");
              print("test controller ${await controller.getZoomScale(0)}");
            },
            onPspdfkitWidgetCreated: (controller) async {
              await controller.setAnnotationConfigurations({
                AnnotationTool.inkPen: InkAnnotationConfiguration(
                  thickness: 2,
                  color: Colors.black,
                )
              });
            },
            configuration: PdfConfiguration(
              askForAnnotationUsername: false,
              allowAnnotationDeletion: false,
              enableAnnotationEditing: true,
            ),
          ),
        ),
      ),
    );
  }
}
