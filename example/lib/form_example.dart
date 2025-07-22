///
///  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutrient_example/utils/platform_utils.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

typedef FormExampleWidgetCreatedCallback = void Function(
    NutrientViewController controller);

class FormExampleWidget extends StatefulWidget {
  final String documentPath;
  final PdfConfiguration? configuration;

  const FormExampleWidget({
    Key? key,
    required this.documentPath,
    this.configuration,
  }) : super(key: key);

  @override
  State<FormExampleWidget> createState() => _FormExampleWidgetState();
}

class _FormExampleWidgetState extends State<FormExampleWidget> {
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
                        child: NutrientView(
                      documentPath: widget.documentPath,
                      configuration: widget.configuration,
                      onDocumentLoaded: (document) {
                        setState(() {
                          this.document = document;
                        });
                        onWidgetCreated();
                      },
                    )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton(
                                  onPressed: () {
                                    document?.setFormFieldValue(
                                        'Updated Form Field Value',
                                        'Name_Last');
                                  },
                                  child: const Text('Set form field value')),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                  onPressed: () async {
                                    await document
                                        ?.getFormFieldValue('Name_Last')
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
                                      if (kDebugMode) {
                                        print(
                                            'Failed to get form fields: $error');
                                      }
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
      await document?.setFormFieldValue('Lastname', 'Name_Last');
      await document?.setFormFieldValue('0123456789', 'Telephone_Home');
      await document?.setFormFieldValue('City', 'City');
      await document?.setFormFieldValue('selected', 'Sex.0');
      await document?.setFormFieldValue('deselected', 'Sex.1');
      await document?.setFormFieldValue('selected', 'HIGH SCHOOL DIPLOMA');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to set form field values '${e.message}'.");
      }
    }

    String? lastName;
    try {
      lastName = await document?.getFormFieldValue('Name_Last');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to get form field value '${e.message}'.");
      }
    }

    if (lastName != null) {
      if (kDebugMode) {
        print(
            "Retrieved form field for fully qualified name 'Name_Last' is $lastName.");
      }
    }
  }
}
