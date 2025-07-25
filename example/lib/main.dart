///
///  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutrient_example/examples.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'example_list_view.dart';

const String _nutrientFlutterPluginTitle =
    'Nutrient Flutter Plugin example app';
const String _nutrientWidgetExamples = 'Nutrient Widget Examples';
const String _nutrientGlobalPluginExamples = 'Nutrient Modal View Examples';
const String _nutrientFor = 'Nutrient ';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // To set the license key platforms, use:
  // Nutrient.initialize(
  // androidLicenseKey: "YOUR_FLUTTER_ANDROID_LICENSE_KEY_GOES_HERE",
  // iosLicenseKey: "YOUR_FLUTTER_IOS_LICENSE_KEY_GOES_HERE",
  // webLicenseKey: "YOUR_FLUTTER_WEB_LICENSE_KEY_GOES_HERE");
  //
  Nutrient.initialize();
  if (!kIsWeb) Nutrient.enableAnalytics(true);
  Nutrient.analyticsEventsListener = (eventName, attributes) {
    if (kDebugMode) {
      print('Analytics event: $eventName with attributes: $attributes');
    }
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String _frameworkVersion = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String frameworkVersion() {
    return '$_nutrientFor $_frameworkVersion\n';
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    String? frameworkVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      frameworkVersion = await Nutrient.frameworkVersion;
    } on PlatformException {
      frameworkVersion = 'Failed to get platform version. ';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _frameworkVersion = frameworkVersion ?? '';
    });

    Nutrient.flutterPdfActivityOnPause =
        () => flutterPdfActivityOnPauseHandler();
    Nutrient.pdfViewControllerWillDismiss =
        () => pdfViewControllerWillDismissHandler();
    Nutrient.pdfViewControllerDidDismiss =
        () => pdfViewControllerDidDismissHandler();
    Nutrient.flutterPdfFragmentAdded = () => flutterPdfFragmentAdded();
    Nutrient.onDocumentLoaded = (documentId) => onDocumentLoaded(documentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text(_nutrientFlutterPluginTitle)),
        body: ExampleListView(frameworkVersion(), [
          Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Text(_nutrientWidgetExamples,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold))),
          ...examples(context),

          /// Global plugin examples are not supported on web.
          if (!kIsWeb)
            Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Text(_nutrientGlobalPluginExamples,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold))),
          if (!kIsWeb) ...globalExamples(context),
        ]));
  }

  void flutterPdfActivityOnPauseHandler() {
    if (kDebugMode) {
      print('flutterPdfActivityOnPauseHandler');
    }
  }

  void pdfViewControllerWillDismissHandler() {
    if (kDebugMode) {
      print('pdfViewControllerWillDismissHandler');
    }
  }

  void pdfViewControllerDidDismissHandler() {
    if (kDebugMode) {
      print('pdfViewControllerDidDismissHandler');
    }
  }

  void flutterPdfFragmentAdded() {
    if (kDebugMode) {
      print('flutterPdfFragmentAdded');
    }
  }

  void onDocumentLoaded(String? documentId) {
    if (kDebugMode) {
      print('onDocumentLoaded: $documentId');
    }
  }
}
