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
import 'package:nutrient_flutter/nutrient_flutter.dart';

class InstantCollaborationWeb extends StatelessWidget {
  const InstantCollaborationWeb({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: FutureBuilder<Map<String, String>?>(
                    future: instantCredentials(context),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return const Center(
                          child: Text(
                              'Please enter Instant Collaboration credentials.'),
                        );
                      }
                      return NutrientView(
                        documentPath: '',
                        configuration: PdfConfiguration(
                            webConfiguration: PdfWebConfiguration(
                                serverUrl: snapshot.data?['serverUrl'],
                                instant: true,
                                documentId: snapshot.data?['documentId'],
                                authPayload: {
                              'jwt': snapshot.data?['jwt'],
                            })),
                      );
                    }))));
  }

  Future<Map<String, String>?> instantCredentials(BuildContext context) async {
    // Show dialog to capture the server URL, document ID, and JWT.
    return showAdaptiveDialog<Map<String, String>>(
        context: context,
        builder: (context) {
          final serverUrlController = TextEditingController();
          final documentIdController = TextEditingController();
          final jwtController = TextEditingController();
          return AlertDialog(
            title: const Text('Enter Instant Collaboration Credentials'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: serverUrlController,
                  decoration: const InputDecoration(labelText: 'Server URL'),
                ),
                TextField(
                  controller: documentIdController,
                  decoration: const InputDecoration(labelText: 'Document ID'),
                ),
                TextField(
                  controller: jwtController,
                  decoration: const InputDecoration(labelText: 'JWT'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'serverUrl': serverUrlController.text,
                    'documentId': documentIdController.text,
                    'jwt': jwtController.text,
                  });
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }
}
