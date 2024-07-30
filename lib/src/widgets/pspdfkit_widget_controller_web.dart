///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
///

import 'dart:ui';

import 'package:pspdfkit_flutter/src/web/pspdfkit_web_instance.dart';
import '../../pspdfkit.dart';
import '../web/pspdfkit_web.dart';

/// A controller for a PSPDFKit widget for Web.
class PspdfkitWidgetControllerWeb extends PspdfkitWidgetController {
  final PspdfkitWebInstance pspdfkitInstance;

  PspdfkitWidgetControllerWeb(this.pspdfkitInstance);

  @override
  Future<dynamic> getAnnotations(int pageIndex, String type) async {
    return pspdfkitInstance.getAnnotations(pageIndex);
  }

  @override
  Future<bool?> addAnnotation(Map<String, dynamic> jsonAnnotation) async {
    await pspdfkitInstance.addAnnotation(jsonAnnotation);
    return Future.value(true);
  }

  @override
  Future<bool?> applyInstantJson(String annotationsJson) async {
    await pspdfkitInstance.applyInstantJson(annotationsJson);
    return Future.value(true);
  }

  @override
  Future<String?> exportInstantJson() {
    return pspdfkitInstance.exportInstantJson();
  }

  @override
  Future<bool?> exportXfdf(String xfdfPath) async {
    await pspdfkitInstance.exportXfdf(xfdfPath);
    return Future.value(true);
  }

  @override
  Future<dynamic> getAllUnsavedAnnotations() {
    return pspdfkitInstance.getAllAnnotations();
  }

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) {
    return pspdfkitInstance.getFormFieldValue(fullyQualifiedName);
  }

  @override
  Future<bool?> importXfdf(String xfdfPath) async {
    await pspdfkitInstance.importXfdf(xfdfPath);
    return Future.value(true);
  }

  @override
  Future<bool?> processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  ) {
    throw UnimplementedError('This method is not supported on the web!');
  }

  @override
  Future<bool?> removeAnnotation(jsonAnnotation) async {
    await pspdfkitInstance.removeAnnotation(jsonAnnotation);
    return Future.value(true);
  }

  @override
  Future<bool?> save() async {
    await pspdfkitInstance.save();
    return Future.value(true);
  }

  @override
  Future<bool?> setAnnotationConfigurations(
      Map<AnnotationTool, AnnotationConfiguration> configurations) async {
    throw UnimplementedError('This method is not supported on the web!');
  }

  @override
  Future<bool?> setFormFieldValue(
      String value, String fullyQualifiedName) async {
    await pspdfkitInstance.setFormFieldValue(value, fullyQualifiedName);
    return Future.value(true);
  }

  void dispose() {
    PSPDFKitWeb.unload(pspdfkitInstance.jsObject);
  }

  @override
  void addEventListener(String eventName, Function(dynamic) callback) {
    pspdfkitInstance.addEventListener(eventName, callback);
  }

  @override
  Future<Rect> getVisibleRect(int pageIndex) {
    // This method is not supported on the web.
    throw UnimplementedError('This method is not supported yet on web!');
  }

  @override
  Future<void> zoomToRect(int pageIndex, Rect rect) {
    return pspdfkitInstance.zoomToRect(pageIndex, rect);
  }

  @override
  Future<double> getZoomScale(int pageIndex) {
    return pspdfkitInstance.getZoomScale(pageIndex);
  }
}
