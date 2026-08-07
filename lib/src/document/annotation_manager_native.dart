///  Copyright © 2025-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter_platform_interface/src/api/nutrient_api.g.dart' as pigeon;

/// Native implementation of AnnotationManager for iOS and Android platforms.
class AnnotationManagerNative extends AnnotationManager {
  late final pigeon.AnnotationManagerApi _api;

  AnnotationManagerNative({required super.documentId}) {
    _api = pigeon.AnnotationManagerApi(
      binaryMessenger: ServicesBinding.instance.defaultBinaryMessenger,
      messageChannelSuffix: '${documentId}_annotation_manager',
    );
    _api.initialize(documentId);
  }

  @override
  Future<AnnotationProperties?> getAnnotationProperties(
    int pageIndex,
    String annotationId,
  ) async {
    final dto = await _api.getAnnotationProperties(pageIndex, annotationId);
    return dto == null ? null : _fromDto(dto);
  }

  @override
  Future<bool> saveAnnotationProperties(AnnotationProperties properties) async {
    return _api.saveAnnotationProperties(_toDto(properties));
  }

  @override
  Future<List<Annotation>> getAnnotations(
    int pageIndex, [
    AnnotationType type = AnnotationType.all,
  ]) async {
    var jsonString = await _api.getAnnotationsJson(pageIndex, type.name);
    var results = jsonDecode(jsonString) as List<dynamic>;

    List<Annotation> annotations = [];
    for (var element in results) {
      if (element is Map) {
        if (element['type'] == null ||
            element['type'] == '' ||
            element['type'] == 'pspdfkit/undefined') {
          continue;
        }
        var annotationJSON = Map<String, dynamic>.from(element);
        try {
          annotations.add(Annotation.fromJson(annotationJSON));
        } catch (e) {
          // Skip annotations that can't be parsed
        }
      }
    }
    return annotations;
  }

  @override
  Future<String> addAnnotation(Annotation annotation) async {
    String? attachmentJson;

    if (annotation is FileAnnotation && annotation.attachment != null) {
      attachmentJson = jsonEncode(annotation.attachment!.toJson());
    } else if (annotation is ImageAnnotation && annotation.attachment != null) {
      attachmentJson = jsonEncode(annotation.attachment!.toJson());
    }

    return _api.addAnnotation(
      jsonEncode(annotation.toJson()),
      attachmentJson,
    );
  }

  @override
  Future<bool> removeAnnotation(int pageIndex, String annotationId) {
    return _api.removeAnnotation(pageIndex, annotationId);
  }

  @override
  Future<List<Annotation>> searchAnnotations(String query,
      [int? pageIndex]) async {
    var jsonString = await _api.searchAnnotationsJson(query, pageIndex);
    var results = jsonDecode(jsonString) as List<dynamic>;

    List<Annotation> annotations = [];
    for (var element in results) {
      if (element is Map) {
        if (element['type'] == null || element['type'] == '') {
          continue;
        }
        var annotationJSON = Map<String, dynamic>.from(element);
        annotations.add(Annotation.fromJson(annotationJSON));
      }
    }
    return annotations;
  }

  @override
  Future<String> exportXFDF([int? pageIndex]) {
    return _api.exportXFDF(pageIndex);
  }

  @override
  Future<bool> importXFDF(String xfdfString) {
    return _api.importXFDF(xfdfString);
  }

  @override
  Future<List<Annotation>> getUnsavedAnnotations() async {
    var jsonString = await _api.getUnsavedAnnotationsJson();
    var results = jsonDecode(jsonString) as List<dynamic>;

    List<Annotation> annotations = [];
    for (var element in results) {
      if (element is Map) {
        if (element['type'] == null || element['type'] == '') {
          continue;
        }
        var annotationJSON = Map<String, dynamic>.from(element);
        annotations.add(Annotation.fromJson(annotationJSON));
      }
    }
    return annotations;
  }

  static AnnotationProperties _fromDto(pigeon.AnnotationProperties dto) =>
      AnnotationProperties(
        annotationId: dto.annotationId,
        pageIndex: dto.pageIndex,
        strokeColor: dto.strokeColor,
        fillColor: dto.fillColor,
        opacity: dto.opacity,
        lineWidth: dto.lineWidth,
        flagsJson: dto.flagsJson,
        customDataJson: dto.customDataJson,
        contents: dto.contents,
        subject: dto.subject,
        creator: dto.creator,
        bboxJson: dto.bboxJson,
        note: dto.note,
        inkLinesJson: dto.inkLinesJson,
        fontName: dto.fontName,
        fontSize: dto.fontSize,
        iconName: dto.iconName,
      );

  static pigeon.AnnotationProperties _toDto(AnnotationProperties p) =>
      pigeon.AnnotationProperties(
        annotationId: p.annotationId ?? '',
        pageIndex: p.pageIndex ?? 0,
        strokeColor: p.strokeColor,
        fillColor: p.fillColor,
        opacity: p.opacity,
        lineWidth: p.lineWidth,
        flagsJson: p.flagsJson,
        customDataJson: p.customDataJson,
        contents: p.contents,
        subject: p.subject,
        creator: p.creator,
        bboxJson: p.bboxJson,
        note: p.note,
        inkLinesJson: p.inkLinesJson,
        fontName: p.fontName,
        fontSize: p.fontSize,
        iconName: p.iconName,
      );
}
