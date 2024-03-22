///
///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/material.dart';

import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'utils/platform_utils.dart';

class PspdfkitToolbarCustomization extends StatelessWidget {
  final String documentPath;

  const PspdfkitToolbarCustomization({super.key, required this.documentPath});

  @override
  Widget build(BuildContext context) {
    // Get the default web toolbar items.
    var defaultWebToolbarItems = Pspdfkit.defaultWebToolbarItems;

    return Scaffold(
        extendBodyBehindAppBar: PlatformUtils.isAndroid(),
        // Do not resize the the document view on Android or
        // it won't be rendered correctly when filling forms.
        resizeToAvoidBottomInset: PlatformUtils.isIOS(),
        appBar: AppBar(
          title: const Text('Toolbar Customization'),
        ),
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
                        androidShowAnnotationListAction: false,
                        androidShowSearchAction: false,
                        androidShowShareAction: false,
                        androidShowDocumentInfoView: false,
                        androidShowThumbnailGridAction: false,
                        annotationToolsGrouping: [
                          AnnotationToolbarItem.square,
                          AnnotationToolbarItem.line,
                          AnnotationToolbarItem.eraser,
                          AnnotationToolsGroup(
                              type: AnnotationToolbarItem.markup,
                              items: [
                                AnnotationToolbarItem.strikeout,
                                AnnotationToolbarItem.highlight,
                                AnnotationToolbarItem.underline
                              ]),
                        ],
                        webConfiguration: PdfWebConfiguration(
                            toolbarItems: [
                              ...defaultWebToolbarItems.reversed,
                              // Add custom web toolbar item.
                              PspdfkitWebToolbarItem(
                                  type: PspdfkitWebToolbarItemType.custom,
                                  title: 'Custom ToolbarItem',
                                  onPress: (event) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Hello from custom button!')));
                                  }),
                              PspdfkitWebToolbarItem(
                                  type: PspdfkitWebToolbarItemType.custom,
                                  title: 'Custom Button',
                                  onPress: (event) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Hello Custom Button! $event')));
                                  }),
                              PspdfkitWebToolbarItem(
                                type:
                                    PspdfkitWebToolbarItemType.responsiveGroup,
                                title: 'Responsive Group',
                                id: 'my-responsive-group',
                                mediaQueries: ['(max-width: 600px)'],
                              ),
                              PspdfkitWebToolbarItem(
                                type: PspdfkitWebToolbarItemType.custom,
                                title: 'Custom Button 2',
                                id: 'my-custom-button-2',
                                responsiveGroup: 'my-responsive-group',
                              ),
                              PspdfkitWebToolbarItem(
                                type: PspdfkitWebToolbarItemType.custom,
                                title: 'Custom Button 3',
                                id: 'my-custom-button-3',
                                responsiveGroup: 'my-responsive-group',
                              ),
                              PspdfkitWebToolbarItem(
                                type: PspdfkitWebToolbarItemType.custom,
                                title: 'Custom Button 4',
                                id: 'my-custom-button-4',
                                dropdownGroup: 'my-dropdown-group',
                              ),
                              PspdfkitWebToolbarItem(
                                type: PspdfkitWebToolbarItemType.custom,
                                title: 'Custom Button 5',
                                id: 'my-custom-button-5',
                                dropdownGroup: 'my-dropdown-group',
                              ),
                              PspdfkitWebToolbarItem(
                                type: PspdfkitWebToolbarItemType.custom,
                                title: 'Custom Button 6',
                                id: 'my-custom-button-6',
                                dropdownGroup: 'my-dropdown-group',
                              ),
                            ],
                            annotationToolbarItems: (annotation, options) {
                              // Add custom web annotation toolbar item.
                              const icon = '''
                              <svg xmlns="http://www.w3.org/2000/svg" height="24" width="24" fill="none" 
                              viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round"
                              stroke-linejoin="round" stroke-width="2" d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0
                                0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" /></svg>
                              ''';

                              return [
                                PspdfkitWebAnnotationToolbarItem(
                                    type: PspdfkitWebAnnotationToolbarItemType
                                        .fillColor),
                                PspdfkitWebAnnotationToolbarItem(
                                    type: PspdfkitWebAnnotationToolbarItemType
                                        .custom,
                                    id: 'custom-annotation-button',
                                    icon: icon,
                                    onPress: (event) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Hello from custom annotation button!')));
                                    })
                              ];
                            }))))));
  }
}
