///
///  Copyright © 2018-2021 PSPDFKit GmbH. All rights reserved.
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

import 'package:pspdfkit_flutter/src/pspdfkit_view.dart';

typedef PspdfkitWidgetCreatedCallback = void Function(PspdfkitView view);

/// This widget is currently only supported for iOS.
/// Support for Android is coming soon.
class PspdfkitWidget extends StatefulWidget {
  final String documentPath;
  final dynamic configuration;
  final PspdfkitWidgetCreatedCallback onPspdfkitWidgetCreated;

  PspdfkitWidget({
    Key key,
    @required this.documentPath,
    this.configuration,
    this.onPspdfkitWidgetCreated
  }) : super(key: key);

  @override
  PspdfkitWidgetState createState() => PspdfkitWidgetState();
}

class PspdfkitWidgetState extends State<PspdfkitWidget> {
  PspdfkitView view;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'com.pspdfkit.widget',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'com.pspdfkit.widget',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return Text('$defaultTargetPlatform is not yet supported by pspdfkit.');
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    view = PspdfkitView.init(id, widget.documentPath, widget.configuration);
    if (widget.onPspdfkitWidgetCreated != null) {
      widget.onPspdfkitWidgetCreated(view);
    }
  }
}
