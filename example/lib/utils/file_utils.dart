import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

Future<String> getOutputPath(String filename) async {
  final tempDir = await Pspdfkit.getTemporaryDirectory();
  final tempDocumentPath = '${tempDir.path}/$filename';
  return tempDocumentPath;
}

Future<File> extractAsset(BuildContext context, String assetPath,
    {bool shouldOverwrite = true, String prefix = ''}) async {
  final bytes = await DefaultAssetBundle.of(context).load(assetPath);
  final list = bytes.buffer.asUint8List();

  final tempDir = await Pspdfkit.getTemporaryDirectory();
  final tempDocumentPath = '${tempDir.path}/$prefix$assetPath';
  final file = File(tempDocumentPath);

  if (shouldOverwrite || !file.existsSync()) {
    await file.create(recursive: true);
    file.writeAsBytesSync(list);
  }
  return file;
}
