///
///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pspdfkit_example/models/papsdkit_example_item.dart';
import 'package:pspdfkit_example/pspdfkit_toolbar_customization.dart';

import 'instant_collaboration_web.dart';
import 'pspdfkit_annotation_preset_customisation.dart';
import 'pspdfkit_document_example.dart';
import 'pspdfkit_event_listeners_example.dart';
import 'pspdfkit_zoom_example.dart';
import 'utils/file_utils.dart';
import 'utils/platform_utils.dart';
import 'package:pspdfkit_example/pspdfkit_configuration_example.dart';
import 'package:pspdfkit_example/pspdfkit_instant_collaboration_example.dart';
import 'package:pspdfkit_example/pspdfkit_measurement_tools.dart';
import 'package:pspdfkit_example/pspdfkit_pdf_generation_example.dart';
import 'package:pspdfkit_example/pspdfkit_save_as_example.dart';

import 'package:pspdfkit_flutter/pspdfkit.dart';

import 'pspdfkit_basic_example.dart';
import 'pspdfkit_form_example.dart';
import 'pspdfkit_instantjson_example.dart';
import 'pspdfkit_annotations_example.dart';
import 'pspdfkit_manual_save_example.dart';
import 'pspdfkit_annotation_processing_example.dart';
import 'pspdfkit_password_example.dart';

const String _documentPath = 'PDFs/PSPDFKit.pdf';
const String _measurementsDocs = 'PDFs/Measurements.pdf';
const String _lockedDocumentPath = 'PDFs/protected.pdf';
const String _imagePath = 'PDFs/PSPDFKit_Image_Example.jpg';
const String _formPath = 'PDFs/Form_example.pdf';
const String _instantDocumentJsonPath = 'PDFs/Instant/instant-document.json';
const String _xfdfPath = 'PDFs/Instant/document.xfdf';
const String _processedDocumentPath = 'PDFs/Embedded/PSPDFKit-processed.pdf';

List<PspdfkitExampleItem> examples(BuildContext context) => [
      PspdfkitExampleItem(
        title: 'Basic Example',
        description: 'Opens a PDF Document.',
        onTap: () async {
          await extractAsset(context, _documentPath).then((value) =>
              goTo(PspdfkitBasicExample(documentPath: value.path), context));
        },
      ),
      if (!kIsWeb)
        PspdfkitExampleItem(
          title: 'Basic Example using Platform Style',
          description:
              'Opens a PDF Document using Material page scaffolding for Android, and Cupertino page scaffolding for iOS.',
          onTap: () async {
            await extractAsset(context, _documentPath).then((value) =>
                goTo(PspdfkitBasicExample(documentPath: value.path), context));
          },
        ),
      PspdfkitExampleItem(
        title: 'Image Document',
        description: 'Opens an image document.',
        onTap: () => showImage(context),
      ),
      PspdfkitExampleItem(
          title: 'Document Example',
          description: 'Shows how to get document properties after loading.',
          onTap: () async {
            await extractAsset(context, _documentPath).then((value) => goTo(
                PspdfkitDocumentExample(documentPath: value.path), context));
          }),
      PspdfkitExampleItem(
        title: 'Dark Theme',
        description: 'Opens a document in night mode with a custom dark theme.',
        onTap: () => applyDarkTheme(context),
      ),
      PspdfkitExampleItem(
        title: 'Custom configuration options',
        description: 'Opens a document with custom configuration options.',
        onTap: () => applyCustomConfiguration(context),
      ),
      PspdfkitExampleItem(
        title: 'Opens and unlocks a password protected document',
        description: 'Programmatically unlocks a password protected document.',
        onTap: () => unlockPasswordProtectedDocument(context),
      ),
      PspdfkitExampleItem(
        title: 'Programmatic Form Filling Example',
        description:
            'Programmatically sets and gets the value of a form field using a custom Widget.',
        onTap: () => showFormDocumentExample(context),
      ),
      PspdfkitExampleItem(
        title: 'Programmatically Adds and Removes Annotations',
        description:
            'Programmatically adds and removes annotations using a custom Widget.',
        onTap: () => annotationsExample(context),
      ),
      if (!kIsWeb)
        PspdfkitExampleItem(
          title: 'PDF generation',
          description:
              'Programmatically generate PDFs from images, templates, and HTML.',
          onTap: () => pdfGenerationExample(context),
        ),
      PspdfkitExampleItem(
        title: 'Manual Save',
        description:
            'Add a save button at the bottom and disable automatic saving.',
        onTap: () => manualSaveExample(context),
      ),
      if (PlatformUtils.isCupertino(context))
        PspdfkitExampleItem(
          title: 'Save As',
          description:
              'Embed and save the changes made to a document into a new file',
          onTap: () => saveAsExample(context),
        ),
      if (PlatformUtils.isCupertino(context) || PlatformUtils.isAndroid())
        PspdfkitExampleItem(
          title: 'Process Annotations',
          description:
              'Programmatically adds and removes annotations using a custom Widget.',
          onTap: () => annotationProcessingExample(context),
        ),
      PspdfkitExampleItem(
        title: 'Import Instant Document JSON',
        description:
            'Shows how to programmatically import Instant Document JSON using a custom Widget.',
        onTap: () => importInstantJsonExample(context),
      ),
      if (PlatformUtils.isCupertino(context))
        PspdfkitExampleItem(
          title: 'Shows two PSPDFKit Widgets simultaneously',
          description:
              'Opens two different PDF documents simultaneously using two PSPDFKit Widgets.',
          onTap: () => pushTwoPspdfWidgetsSimultaneously(context),
        ),
      PspdfkitExampleItem(
          title: 'PSPDFKit Events Listeners',
          description: 'Shows how to use PSPDFKit Events Listeners.',
          onTap: () async {
            await extractAsset(context, _documentPath).then((value) => goTo(
                PspdfkitEventListenerExample(documentPath: value.path),
                context));
          }),
      PspdfkitExampleItem(
          title: 'Measurement tools',
          description: 'Shows how to use PSPDFKit Measurement tools.',
          onTap: () async {
            await extractAsset(context, _measurementsDocs).then((value) => goTo(
                PspdfkitMeasurementsExample(documentPath: value.path),
                context));
          }),
      if (!kIsWeb)
        PspdfkitExampleItem(
            title: 'Annotations Preset Customization',
            description: 'PSPDFKit Annotations Preset Customization Example.',
            onTap: () async {
              await extractAsset(context, _documentPath).then((value) => goTo(
                  PspdfkitAnnotationPresetCustomization(
                      documentPath: value.path),
                  context));
            }),
      PspdfkitExampleItem(
          title: 'Toolbar Customization',
          description: 'Shows how to customize the toolbar items.',
          onTap: () async {
            await extractAsset(context, _documentPath).then((value) => goTo(
                PspdfkitToolbarCustomization(
                  documentPath: value.path,
                ),
                context));
          }),
      if (kIsWeb)
        PspdfkitExampleItem(
          title: 'Instant collaboration Web',
          description: 'Instant Synchronization Web Example',
          onTap: () => goTo(const InstantCollaborationWeb(), context),
        ),
      PspdfkitExampleItem(
          title: 'Zoom to Rect',
          description: 'Zoom and restore page zoom example ',
          onTap: () async {
            await extractAsset(context, _documentPath).then((value) =>
                goTo(PspdfkitZoomExample(documentPath: value.path), context));
          }),
    ];

List<PspdfkitExampleItem> globalExamples(BuildContext context) => [
      PspdfkitExampleItem(
        title: 'Basic Example',
        description: 'Opens a PDF Document.',
        onTap: () => showDocumentGlobal(context),
      ),
      PspdfkitExampleItem(
        title: 'Image Document',
        description: 'Opens an image document.',
        onTap: () => showImageGlobal(context),
      ),
      PspdfkitExampleItem(
        title: 'Dark Theme',
        description: 'Opens a document in night mode with a custom dark theme.',
        onTap: () => applyDarkThemeGlobal(context),
      ),
      PspdfkitExampleItem(
        title: 'Custom configuration options',
        description: 'Opens a document with custom configuration options.',
        onTap: () => applyCustomConfigurationGlobal(context),
      ),
      PspdfkitExampleItem(
        title: 'Opens and unlocks a password protected document',
        description: 'Programmatically unlocks a password protected document.',
        onTap: () => unlockPasswordProtectedDocumentGlobal(context),
      ),
      PspdfkitExampleItem(
        title: 'Programmatic Form Filling Example',
        description:
            'Programmatically sets and gets the value of a form field.',
        onTap: () => showFormDocumentExampleGlobal(context),
      ),
      PspdfkitExampleItem(
        title: 'Import Instant Document JSON',
        description:
            'Shows how to programmatically import Instant Document JSON.',
        onTap: () => importInstantJsonExampleGlobal(context),
      ),
      PspdfkitExampleItem(
        title: 'PSPDFKit Instant',
        description: 'PSPDFKit Instant Synchronisation Example',
        onTap: () => presentInstant(context),
      ),
      PspdfkitExampleItem(
        title: 'Measurement tools',
        description: 'Shows how to use PSPDFKit Measurement tools.',
        onTap: () => showMeasurementExampleGlobal(context),
      ),
    ];

void showDocument(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) =>
          PspdfkitBasicExample(documentPath: extractedDocument.path)));
}

void showImage(context) async {
  final extractedImage = await extractAsset(context, _imagePath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => Scaffold(
          extendBodyBehindAppBar:
              PlatformUtils.isCupertino(context) ? false : true,
          appBar: AppBar(),
          body: SafeArea(
              top: false,
              bottom: false,
              child: Container(
                  padding: PlatformUtils.isCupertino(context)
                      ? null
                      : const EdgeInsets.only(top: kToolbarHeight),
                  child: PspdfkitWidget(documentPath: extractedImage.path))))));
}

void applyDarkTheme(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => Scaffold(
          extendBodyBehindAppBar:
              PlatformUtils.isCupertino(context) ? false : true,
          appBar: AppBar(),
          body: SafeArea(
              top: false,
              bottom: false,
              child: Container(
                  padding: PlatformUtils.isCupertino(context)
                      ? null
                      : const EdgeInsets.only(top: kToolbarHeight),
                  child: PspdfkitWidget(
                      documentPath: extractedDocument.path,
                      configuration: PdfConfiguration(
                          appearanceMode: PspdfkitAppearanceMode.night,
                          androidDarkThemeResource:
                              'PSPDFKit.Theme.Example.Dark')))))));
}

void applyCustomConfiguration(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) =>
          PspdfkitConfigurationExample(documentPath: extractedDocument.path)));
}

void unlockPasswordProtectedDocument(context) async {
  final extractedLockedDocument =
      await extractAsset(context, _lockedDocumentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) =>
          PspdfkitPasswordExample(documentPath: extractedLockedDocument.path)));
}

void showFormDocumentExample(context) async {
  final extractedFormDocument = await extractAsset(context, _formPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) =>
          PspdfkitFormExampleWidget(documentPath: extractedFormDocument.path)));
}

void importInstantJsonExample(context) async {
  final extractedFormDocument = await extractAsset(context, _documentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => PspdfkitInstantJsonExampleWidget(
            documentPath: extractedFormDocument.path,
            instantJsonPath: _instantDocumentJsonPath,
            xfaPath: _xfdfPath,
          )));
}

void annotationsExample(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => PspdfkitAnnotationsExampleWidget(
          documentPath: extractedDocument.path)));
}

void pdfGenerationExample(context) async {
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => PspdfkitPDFGenerationExampleWidget()));
}

void manualSaveExample(context) async {
  final extractedWritableDocument = await extractAsset(context, _documentPath,
      shouldOverwrite: false, prefix: 'persist');

  // Automatic Saving of documents is enabled by default in certain scenarios [see for details: https://pspdfkit.com/guides/flutter/save-a-document/#auto-save]
  // In order to manually save documents, you might consider disabling automatic saving with disableAutosave: true in the config
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => PspdfkitManualSaveExampleWidget(
          documentPath: extractedWritableDocument.path,
          configuration: PdfConfiguration(disableAutosave: true))));
}

void saveAsExample(context) async {
  final extractedWritableDocument = await extractAsset(context, _documentPath,
      shouldOverwrite: false, prefix: 'persist');

  // Automatic Saving of documents is enabled by default in certain scenarios [see for details: https://pspdfkit.com/guides/flutter/save-a-document/#auto-save]
  // In order to manually save documents, you might consider disabling automatic saving with disableAutosave: true in the config
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => PspdfkitSaveAsExampleWidget(
          documentPath: extractedWritableDocument.path,
          configuration: PdfConfiguration(disableAutosave: true))));
}

void annotationProcessingExample(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => PspdfkitAnnotationProcessingExampleWidget(
          documentPath: extractedDocument.path,
          exportPath: _processedDocumentPath)));
}

void pushTwoPspdfWidgetsSimultaneously(context) async {
  try {
    final extractedDocument = await extractAsset(context, _documentPath);
    final extractedFormDocument = await extractAsset(context, _formPath);

    if (PlatformUtils.isCupertino(context)) {
      await Navigator.of(context).push<dynamic>(CupertinoPageRoute<dynamic>(
          builder: (_) => CupertinoPageScaffold(
              navigationBar: const CupertinoNavigationBar(),
              child: SafeArea(
                  bottom: false,
                  child: Column(children: <Widget>[
                    Expanded(
                        child: PspdfkitWidget(
                            documentPath: extractedDocument.path)),
                    Expanded(
                        child: PspdfkitWidget(
                            documentPath: extractedFormDocument.path))
                  ])))));
    } else {
      // This example is only supported in iOS at the moment.
      // Support for Android is coming soon.
    }
  } on PlatformException catch (e) {
    print("Failed to present document: '${e.message}'.");
  }
}

void showDocumentGlobal(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Pspdfkit.present(extractedDocument.path);
}

void showImageGlobal(context) async {
  final extractedImage = await extractAsset(context, _imagePath);
  await Pspdfkit.present(extractedImage.path);
}

void applyDarkThemeGlobal(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Pspdfkit.present(extractedDocument.path,
      configuration: PdfConfiguration(
          appearanceMode: PspdfkitAppearanceMode.night,
          androidDarkThemeResource: 'PSPDFKit.Theme.Example.Dark'));
}

void applyCustomConfigurationGlobal(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Pspdfkit.present(extractedDocument.path,
      configuration: PdfConfiguration(
          scrollDirection: PspdfkitScrollDirection.vertical,
          pageTransition: PspdfkitPageTransition.scrollPerSpread,
          spreadFitting: PspdfkitSpreadFitting.fit,
          userInterfaceViewMode: PspdfkitUserInterfaceViewMode.always,
          androidShowSearchAction: true,
          inlineSearch: false,
          showThumbnailBar: PspdfkitThumbnailBarMode.floating,
          androidShowThumbnailGridAction: true,
          androidShowOutlineAction: true,
          androidShowAnnotationListAction: true,
          showPageLabels: true,
          documentLabelEnabled: false,
          invertColors: false,
          androidGrayScale: false,
          startPage: 2,
          enableAnnotationEditing: true,
          enableTextSelection: false,
          androidShowBookmarksAction: false,
          androidEnableDocumentEditor: false,
          androidShowShareAction: true,
          androidShowPrintAction: false,
          androidShowDocumentInfoView: true,
          appearanceMode: PspdfkitAppearanceMode.defaultMode,
          androidDefaultThemeResource: 'PSPDFKit.Theme.Example',
          iOSRightBarButtonItems: [
            'thumbnailsButtonItem',
            'activityButtonItem',
            'searchButtonItem',
            'annotationButtonItem'
          ],
          iOSLeftBarButtonItems: ['settingsButtonItem'],
          iOSAllowToolbarTitleChange: false,
          toolbarTitle: 'Custom Title',
          settingsMenuItems: [
            'pageTransition',
            'scrollDirection',
            'androidTheme',
            'iOSAppearance',
            'androidPageLayout',
            'iOSPageMode',
            'iOSSpreadFitting',
            'androidScreenAwake',
            'iOSBrightness'
          ],
          showActionNavigationButtons: false,
          pageLayoutMode: PspdfkitPageLayoutMode.double,
          firstPageAlwaysSingle: true));
}

void unlockPasswordProtectedDocumentGlobal(context) async {
  final extractedLockedDocument =
      await extractAsset(context, _lockedDocumentPath);
  await Pspdfkit.present(extractedLockedDocument.path,
      configuration: PdfConfiguration(password: 'test123'));
}

void showFormDocumentExampleGlobal(context) async {
  final formDocument = await extractAsset(context, _formPath);
  await Pspdfkit.present(formDocument.path);

  try {
    await Pspdfkit.setFormFieldValue('Lastname', 'Name_Last');
    await Pspdfkit.setFormFieldValue('0123456789', 'Telephone_Home');
    await Pspdfkit.setFormFieldValue('City', 'City');
    await Pspdfkit.setFormFieldValue('selected', 'Sex.0');
    await Pspdfkit.setFormFieldValue('deselected', 'Sex.1');
    await Pspdfkit.setFormFieldValue('selected', 'HIGH SCHOOL DIPLOMA');
  } on PlatformException catch (e) {
    print("Failed to set form field values '${e.message}'.");
  }

  String? lastName;
  try {
    lastName = await Pspdfkit.getFormFieldValue('Name_Last');
  } on PlatformException catch (e) {
    print("Failed to get form field value '${e.message}'.");
  }

  if (lastName != null) {
    print(
        "Retrieved form field for fully qualified name 'Name_Last' is $lastName.");
  }
}

void importInstantJsonExampleGlobal(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Pspdfkit.present(extractedDocument.path);

  // Extract a string from a file.
  final annotationsJson =
      await DefaultAssetBundle.of(context).loadString(_instantDocumentJsonPath);

  try {
    await Pspdfkit.applyInstantJson(annotationsJson);
  } on PlatformException catch (e) {
    print("Failed to import Instant Document JSON '${e.message}'.");
  }
}

void presentInstant(BuildContext context) async {
  await Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
          builder: (context) => const PspdfkitInstantCollaborationExample()));
}

void measurementExample(BuildContext context) async {
  await extractAsset(context, _measurementsDocs).then((value) {
    Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (context) => PspdfkitMeasurementsExample(
                  documentPath: value.path,
                )));
  });
}

void showMeasurementExampleGlobal(BuildContext context) {
  var scale = MeasurementScale(
      unitFrom: UnitFrom.inch,
      valueFrom: 1.0,
      unitTo: UnitTo.cm,
      valueTo: 2.54);
  var precision = MeasurementPrecision.fourDP;
  var measurementValueConfigurations = [
    MeasurementValueConfiguration(
        name: 'Custom Scale', scale: scale, precision: precision)
  ];
  extractAsset(context, _measurementsDocs).then((value) {
    Pspdfkit.present(
      value.path,
      configuration: PdfConfiguration(
        measurementValueConfigurations: measurementValueConfigurations,
      ),
    );
  });
}

void goTo(Widget widget, BuildContext context) {
  Navigator.push<dynamic>(
      context, MaterialPageRoute<dynamic>(builder: (context) => widget));
}
