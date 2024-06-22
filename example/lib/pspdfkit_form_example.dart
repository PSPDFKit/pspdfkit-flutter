///
///  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pspdfkit_example/utils/platform_utils.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

typedef PspdfkitFormExampleWidgetCreatedCallback = void Function(
    PspdfkitWidgetController view);

class PspdfkitFormExampleWidget extends StatefulWidget {
  final String documentPath;
  final PdfConfiguration? configuration;

  const PspdfkitFormExampleWidget({
    Key? key,
    required this.documentPath,
    this.configuration,
  }) : super(key: key);

  @override
  _PspdfkitFormExampleWidgetState createState() =>
      _PspdfkitFormExampleWidgetState();
}

class _PspdfkitFormExampleWidgetState extends State<PspdfkitFormExampleWidget> {
  late PspdfkitWidgetController view;
  late PdfDocument? document;

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCurrentPlatformSupported()) {
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
                  padding: PlatformUtils.isIOS() || kIsWeb
                      ? null
                      : const EdgeInsets.only(top: kToolbarHeight),
                  child: Column(children: <Widget>[
                    Expanded(
                        child: PspdfkitWidget(
                            documentPath: widget.documentPath,
                            configuration: widget.configuration,
                            onPdfDocumentLoaded: (document) {
                              setState(() {
                                this.document = document;
                              });
                            },
                            onPspdfkitWidgetCreated: (controller) {
                              setState(() {
                                view = controller;
                              });
                              onWidgetCreated();
                            })),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton(
                                  onPressed: () {
                                    view.setFormFieldValue(
                                        'Updated Form Field Value',
                                        'Name_Last');
                                  },
                                  child: const Text('Set form field value')),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                  onPressed: () async {
                                    await view
                                        .getFormFieldValue('Name_Last')
                                        .then((formFieldValue) async {
                                      await showDialog<AlertDialog>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                title: const Text(
                                                    'Form Field Value'),
                                                content:
                                                    Text(formFieldValue ?? ''),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text('OK'))
                                                ],
                                              ));
                                    });
                                  },
                                  child: const Text('Get form field value')),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                  onPressed: () {
                                    document
                                        ?.getFormFields()
                                        .then((List<PdfFormField> formFields) {
                                      if (kDebugMode) {
                                        print('Form fields: $formFields');
                                      }
                                      showDialog<AlertDialog>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                title:
                                                    const Text('Form Fields'),
                                                content: Text(formFields
                                                    .map((formField) =>
                                                        formField
                                                            .fullyQualifiedName)
                                                    .join('\n')),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text('OK'))
                                                ],
                                              ));
                                    }).catchError((error) {
                                      print(
                                          'Failed to get form fields: $error');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Failed to get form fields: $error'),
                                        ),
                                      );
                                    });
                                  },
                                  child: const Text('Get form fields')),
                            ]),
                      ),
                    )
                  ]))));
    } else {
      return Text(
          '$defaultTargetPlatform is not yet supported by PSPDFKit for Flutter.');
    }
  }

  void onWidgetCreated() async {
    try {
      await view.setFormFieldValue('Lastname', 'Name_Last');
      await view.setFormFieldValue('0123456789', 'Telephone_Home');
      await view.setFormFieldValue('City', 'City');
      await view.setFormFieldValue('selected', 'Sex.0');
      await view.setFormFieldValue('deselected', 'Sex.1');
      await view.setFormFieldValue('selected', 'HIGH SCHOOL DIPLOMA');
    } on PlatformException catch (e) {
      print("Failed to set form field values '${e.message}'.");
    }

    String? lastName;
    try {
      lastName = await view.getFormFieldValue('Name_Last');
    } on PlatformException catch (e) {
      print("Failed to get form field value '${e.message}'.");
    }

    if (lastName != null) {
      print(
          "Retrieved form field for fully qualified name 'Name_Last' is $lastName.");
    }
  }
}
