///
///  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:pspdfkit_flutter/widgets/pspdfkit_widget_controller.dart';

import 'utils/platform_utils.dart';

class PspdfkitInstantJsonExampleWidget extends StatefulWidget {
  final String documentPath;
  final String instantJsonPath;
  final dynamic configuration;

  const PspdfkitInstantJsonExampleWidget({
    Key? key,
    required this.documentPath,
    required this.instantJsonPath,
    this.configuration,
  }) : super(key: key);

  @override
  _PspdfkitInstantJsonExampleWidgetState createState() =>
      _PspdfkitInstantJsonExampleWidgetState();
}

class _PspdfkitInstantJsonExampleWidgetState
    extends State<PspdfkitInstantJsonExampleWidget> {
  late PspdfkitWidgetController view;

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'com.pspdfkit.widget';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'document': widget.documentPath,
      'configuration': widget.configuration,
    };

    if (PlatformUtils.isIOS()) {
      return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(),
          child: SafeArea(
              bottom: false,
              child: Column(children: <Widget>[
                Expanded(
                    child: UiKitView(
                        viewType: viewType,
                        layoutDirection: TextDirection.ltr,
                        creationParams: creationParams,
                        onPlatformViewCreated: onPlatformViewCreated,
                        creationParamsCodec: const StandardMessageCodec())),
                SizedBox(
                    height: 80,
                    child: Row(children: <Widget>[
                      CupertinoButton(
                          onPressed: () async {
                            final annotationsJson =
                                await DefaultAssetBundle.of(context)
                                    .loadString(widget.instantJsonPath);
                            await view.applyInstantJson(annotationsJson);
                          },
                          child: const Text('Apply Instant JSON')),
                      CupertinoButton(
                          onPressed: () async {
                            const title = 'Exported Instant JSON';
                            final exportedInstantJson =
                                await view.exportInstantJson() ?? '';
                            await showCupertinoDialog<CupertinoAlertDialog>(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoAlertDialog(
                                      title: const Text(title),
                                      content: Text(exportedInstantJson),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('OK'))
                                      ],
                                    ));
                          },
                          child: const Text('Export Instant JSON'))
                    ]))
              ])));
    } else if (PlatformUtils.isAndroid()) {
      // This example is only supported in iOS at the moment.
      // Support for Android is coming soon.
      return const Text('Unsupported Widget');
    } else {
      return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    view = PspdfkitWidgetController(id);
  }
}
