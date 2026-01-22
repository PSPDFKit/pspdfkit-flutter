///
///  Copyright © 2025-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/material.dart';

import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'utils/platform_utils.dart';

/// Example demonstrating annotation contextual menu customization
/// Shows how to remove and disable menu items
class AnnotationMenuExample extends StatelessWidget {
  final String documentPath;

  const AnnotationMenuExample({super.key, required this.documentPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: PlatformUtils.isAndroid(),
      resizeToAvoidBottomInset: PlatformUtils.isIOS(),
      appBar: AppBar(
        title: const Text('Remove & Disable Menu Items'),
      ),
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
              // Enable annotation editing
              enableAnnotationEditing: true,

              // Configure annotation contextual menu
              annotationMenuConfiguration: const AnnotationMenuConfiguration(
                // Remove the delete and color actions from default menu
                itemsToRemove: [
                  AnnotationMenuAction.delete,
                  AnnotationMenuAction.color
                ],
                // Disable the copy action (keeps it visible but grayed out)
                itemsToDisable: [AnnotationMenuAction.copy],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
