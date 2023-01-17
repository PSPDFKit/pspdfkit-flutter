import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
                  if (Platform.isAndroid)
                    RichText(
                        text: TextSpan(
                            text: 'Scan the QR code from  ',
                            style: const TextStyle(color: Colors.black),
                            children: [
                          TextSpan(
                            text: 'pspdfkit.com/instant/try',
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Open the URL in the browser.
                                launchUrl(Uri.parse(
                                    'https://pspdfkit.com/instant/try'));
                              },
                          ),
                          const TextSpan(
                            text:
                                ' to connect to the document shown in your browser.',
                            style: TextStyle(color: Colors.black),
                          )
                        ])),
                  if (Platform.isAndroid)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push<String>(context,
                              MaterialPageRoute<String>(builder: (context) {
                            return const InstantBarcodeScanner();
                          })).then(
                              (value) => _loadDocument(scaffoldContext, value));
                        },
                        child: const Text('Scan QR code'),
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                  ),
                  RichText(
                      text: TextSpan(
                          text: 'Copy the collaboration URL from  ',
                          style: const TextStyle(color: Colors.black),
                          children: [
                        TextSpan(
                          text: 'pspdfkit.com/instant/try',
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Open the URL in the browser.
                              launchUrl(Uri.parse(
                                  'https://pspdfkit.com/instant/try'));
                            },
                        ),
                        const TextSpan(
                          text:
                              ' to connect to the document shown in your browser.',
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
        await Pspdfkit.presentInstant(doc.serverUrl, doc.jwt, {
          enableInstantComments: enableComments,
        });

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

class InstantBarcodeScanner extends StatefulWidget {
  const InstantBarcodeScanner({Key? key}) : super(key: key);

  @override
  State<InstantBarcodeScanner> createState() => _InstantBarcodeScannerState();
}

class _InstantBarcodeScannerState extends State<InstantBarcodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    try {
      if (Platform.isAndroid) {
        controller?.resumeCamera();
      } else if (Platform.isIOS) {
        controller?.resumeCamera();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RichText(
                  text: TextSpan(
                      text: 'Scan the QR code from ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                    TextSpan(
                      text: 'pspdfkit.com/instant/try',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Open the URL in the browser.
                          launchUrl(
                              Uri.parse('https://pspdfkit.com/instant/try'));
                        },
                    ),
                    const TextSpan(
                      text:
                          ' to connect to the document shown in your browser.',
                      style: TextStyle(color: Colors.black),
                    )
                  ])),
            )),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    var counter = 0;
    controller.scannedDataStream.listen((scanData) {
      // Show the document in PSPDFKit.
      if (counter == 0) {
        counter++;
        Navigator.pop(context, scanData.code);
      }
    });
    try {
      controller.resumeCamera();
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
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
