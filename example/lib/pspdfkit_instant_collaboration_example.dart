///
///  Copyright © 2018-2023 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

final client = http.Client();

class PspdfkitInstantCollaborationExample extends StatefulWidget {
  const PspdfkitInstantCollaborationExample({Key? key}) : super(key: key);

  @override
  State<PspdfkitInstantCollaborationExample> createState() =>
      _PspdfkitInstantCollaborationExampleState();
}

class _PspdfkitInstantCollaborationExampleState
    extends State<PspdfkitInstantCollaborationExample> {
  double delayTime = 0.0;
  bool enableListenToServerChanges = true;
  bool enableComments = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instant Synchronization'),
      ),
      body: Builder(builder: (scaffoldContext) {
        return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  RichText(
                      text: TextSpan(
                          text: 'Copy the collaboration URL from ',
                          style: const TextStyle(color: Colors.black),
                          children: [
                        TextSpan(
                          text: 'https://web-examples.services.demo.pspdfkit.com',
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Open the URL in the browser.
                              launchUrl(Uri.parse(
                                  'https://web-examples.services.demo.pspdfkit.com'));
                            },
                        ),
                        const TextSpan(
                          text: ' > Collaborate in Real-time - ',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text:
                              'to connect to the document shown in your browser.',
                          style: TextStyle(color: Colors.black),
                        )
                      ])),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Show input dialog
                        await showDialog<dynamic>(
                            context: context,
                            builder: (BuildContext context) {
                              var documentUrl = '';
                              return AlertDialog(
                                title: const Text('Enter Document URL'),
                                content: TextField(
                                  onChanged: (String value) {
                                    // Update the state of the app.
                                    // ...
                                    documentUrl = value;
                                  },
                                  decoration: const InputDecoration(
                                      hintText: 'Document URL'),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Connect'),
                                    onPressed: () {
                                      // Validate and save the form.
                                      // ...
                                      if (documentUrl.isEmpty) {
                                        return;
                                      }
                                      // Dismiss the dialog.
                                      Navigator.of(context).pop();
                                      // if is valid url
                                      if (Uri.parse(documentUrl).isAbsolute) {
                                        _loadDocument(
                                            scaffoldContext, documentUrl);
                                      }
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      child: const Text('Enter Document URL'),
                    ),
                  ),
                  // Delay for syncing local changes
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Row(
                    children: [
                      const Text('Delay for syncing local changes: '),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          onChanged: (String value) {
                            // Update the state of the app.
                            // ...
                            delayTime = double.parse(value);
                          },
                          decoration: const InputDecoration(
                              hintText: 'Delay time in seconds'),
                        ),
                      ),
                    ],
                  ),
                  // Listen to server changes
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Row(
                    children: [
                      const Text('Listen to server changes: '),
                      Checkbox(
                        value: enableListenToServerChanges,
                        onChanged: (bool? value) {
                          setState(() {
                            enableListenToServerChanges = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  // Enable comments
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Row(
                    children: [
                      const Text('Enable comments: '),
                      Checkbox(
                        value: enableComments,
                        onChanged: (bool? value) {
                          setState(() {
                            enableComments = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ));
      }),
    );
  }

  void _loadDocument(BuildContext context, String? url) {
    if (url != null) {
      showDialog<dynamic>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      _getDocument(url).then((doc) async {
        Navigator.of(context).pop();
        await Pspdfkit.presentInstant(doc.serverUrl, doc.jwt,
            PdfConfiguration(enableInstantComments: enableComments));

        await Pspdfkit.setDelayForSyncingLocalChanges(delayTime);
        await Pspdfkit.setListenToServerChanges(enableListenToServerChanges);
      }).catchError((dynamic onError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(onError.toString()),
        ));
        Navigator.of(context).pop();
      });
    } else {
      if (kDebugMode) {
        print('No URL');
      }
    }
  }

  /// Fetches the document from the instant demo server.
  /// The server returns a JWT token that is used to authenticate the user.
  Future<InstantDocumentDescriptor> _getDocument(String url) async {
    // The header is necessary to receive valid json response.
    http.Response response = await client.get(Uri.parse(url),
        headers: {'Accept': 'application/vnd.instant-example+json'});
    final data = json.decode(response.body) as Map<String, dynamic>;
    final document = InstantDocumentDescriptor.fromJson(data);
    return document;
  }
}

class InstantDocumentDescriptor {
  final String serverUrl;
  final String documentId;
  final String jwt;
  final String documentCode;
  final String webUrl;

  InstantDocumentDescriptor(this.serverUrl, this.documentId, this.jwt,
      this.documentCode, this.webUrl);

  // From json
  factory InstantDocumentDescriptor.fromJson(Map<String, dynamic> json) {
    return InstantDocumentDescriptor(
      json['serverUrl'] as String,
      json['documentId'] as String,
      json['jwt'] as String,
      json['encodedDocumentId'] as String,
      json['url'] as String,
    );
  }
}
