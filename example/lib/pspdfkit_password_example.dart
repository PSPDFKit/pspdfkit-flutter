import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

import 'utils/platform_utils.dart';

class PspdfkitPasswordExample extends StatelessWidget {
  final String documentPath;
  const PspdfkitPasswordExample({super.key, required this.documentPath});

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
                child: PspdfkitWidget(
                    documentPath: documentPath,
                    configuration: PdfConfiguration(password: 'test123')))));
  }
}
