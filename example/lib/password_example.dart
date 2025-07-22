import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

import 'utils/platform_utils.dart';

class PasswordExample extends StatelessWidget {
  final String documentPath;
  const PasswordExample({super.key, required this.documentPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: NutrientView(
                    documentPath: documentPath,
                    configuration: PdfConfiguration(password: 'test123')))));
  }
}
