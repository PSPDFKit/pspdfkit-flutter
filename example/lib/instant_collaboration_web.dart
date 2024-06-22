///
///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/material.dart';
import 'utils/platform_utils.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class InstantCollaborationWeb extends StatelessWidget {
  const InstantCollaborationWeb({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: PlatformUtils.isAndroid(),
        // Do not resize the the document view on Android or
        // it won't be rendered correctly when filling forms.
        resizeToAvoidBottomInset: PlatformUtils.isIOS(),
        appBar: AppBar(
          title: const Text('Instant Collaboration Web'),
        ),
        body: SafeArea(
            top: false,
            bottom: false,
            child: Container(
                padding: PlatformUtils.isAndroid()
                    ? const EdgeInsets.only(top: kToolbarHeight)
                    : null,
                child: PspdfkitWidget(
                  documentPath: '',
                  configuration: PdfConfiguration(
                      webConfiguration: PdfWebConfiguration(
                          serverUrl: 'http://localhost:8080/',
                          instant: true,
                          documentId: 'example-document-id',
                          authPayload: {'jwt': '<your-jwt-token-goes-here>'})),
                ))));
  }
}
