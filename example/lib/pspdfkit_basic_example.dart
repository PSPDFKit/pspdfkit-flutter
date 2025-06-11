///
///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:io';

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
                  configuration: PdfConfiguration(
                      toolbarTitle: '',
                      scrollDirection: PspdfkitScrollDirection.vertical,
                      pageLayoutMode: PspdfkitPageLayoutMode.single,
                      pageTransition: PspdfkitPageTransition.scrollContinuous,
                      spreadFitting: PspdfkitSpreadFitting.fit,
                      userInterfaceViewMode: Platform.isIOS
                          ? PspdfkitUserInterfaceViewMode.automatic
                          : PspdfkitUserInterfaceViewMode.never,
                      showThumbnailBar: PspdfkitThumbnailBarMode.floating,
                      disableAutosave: true,
                      immersiveMode: false,
                      showPageLabels: true,
                      showActionNavigationButtons: false,
                      androidShowSearchAction: true,
                      inlineSearch: false,
                      androidShowThumbnailGridAction: false,
                      androidShowOutlineAction: false,
                      androidShowAnnotationListAction: false,
                      documentLabelEnabled: false,
                      invertColors: false,
                      androidGrayScale: false,
                      enableAnnotationEditing: true,
                      enableTextSelection: false,
                      androidShowBookmarksAction: false,
                      androidEnableDocumentEditor: false,
                      androidShowShareAction: false,
                      androidShowPrintAction: false,
                      androidShowDocumentInfoView: true,
                      appearanceMode: PspdfkitAppearanceMode.defaultMode,
                      toolbarMenuItems: [],
                      iOSRightBarButtonItems: [
                        'thumbnailsButtonItem',
                        'searchButtonItem'
                      ],
                      iOSLeftBarButtonItems: ['settingsButtonItem'],
                      iOSAllowToolbarTitleChange: false,
                      firstPageAlwaysSingle: true,
                      enableInstantComments: false,
                      webConfiguration: null,
                      signatureSavingStrategy:
                          SignatureSavingStrategy.alwaysSave,
                      editableAnnotationTypes: [
                        'pspdfkit/text',
                        'pspdfkit/signature'
                      ],
                      signatureCreationConfiguration:
                          SignatureCreationConfiguration(
                              colorOptions: SignatureColorOptions(
                                  option1:
                                      SignatureColorPreset(color: Colors.red),
                                  option2: SignatureColorPreset(
                                      color: Colors.yellow),
                                  option3: SignatureColorPreset(
                                      color: Colors.green)))),
                ))));
  }
}
