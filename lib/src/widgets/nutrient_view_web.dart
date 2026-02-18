///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
library nutrient_viewer_web;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter/src/widgets/nutrient_view_controller_web.dart';
import 'package:nutrient_flutter/src/web/nutrient_web_configuration_helper.dart';
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    as platform show NativeInstanceRegistry;
import 'package:nutrient_flutter_web/nutrient_flutter_web.dart' as web
    show
        NutrientViewWeb,
        NutrientWebAdapter,
        NutrientWebInstance,
        NutrientWebInstanceExtension,
        NutrientAnnotationOperations,
        NutrientDocumentOperations,
        NutrientFormOperations,
        NutrientBookmarkOperations,
        WebColorUtils;
// Import extension types without prefix so extension methods are accessible
import 'package:nutrient_flutter_web/nutrient_flutter_web.dart'
    show NutrientViewStateExtension, NutrientPageInfoExtension;

/// Callback type for when the web instance is loaded.
/// This allows adapters to receive the NutrientWebInstance for direct SDK access.
typedef OnWebInstanceLoadedCallback = Future<void> Function(
    web.NutrientWebInstance instance);

/// A widget that displays a PDF document using Nutrient on the web.
///
/// This widget delegates to [NutrientViewWeb] from `nutrient_flutter_web`
/// internally while providing the standard `nutrient_flutter` API surface
/// including callbacks, configuration, and adapter support.
class NutrientView extends StatefulWidget {
  /// The path to the document to display.
  final String documentPath;

  /// The configuration to use for the document.
  final dynamic configuration;

  /// Called when the widget is created.
  final NutrientViewCreatedCallback? onViewCreated;

  /// Called when the document is loaded.
  final OnDocumentLoadedCallback? onDocumentLoaded;

  /// Called when the document fails to load.
  final OnDocumentLoadingFailedCallback? onDocumentError;

  /// Called when the page changes.
  final PageChangedCallback? onPageChanged;

  /// Called when a page is clicked.
  final PageClickedCallback? onPageClicked;

  /// Called when the document is saved.
  final OnDocumentSavedCallback? onDocumentSaved;

  /// Custom toolbar items to add to the toolbar.
  final List<CustomToolbarItem> customToolbarItems;

  /// Called when a custom toolbar item is tapped.
  final OnCustomToolbarItemTappedCallback? onCustomToolbarItemTapped;

  /// Optional adapter for web SDK access.
  ///
  /// If provided, the adapter will receive native instance callbacks,
  /// enabling direct access to the Nutrient Web SDK via JavaScript interop.
  ///
  /// Example:
  /// ```dart
  /// class MyWebAdapter extends NutrientWebAdapter {
  ///   @override
  ///   Future<void> onInstanceLoaded(NutrientWebInstance instance) async {
  ///     await super.onInstanceLoaded(instance);
  ///     final pageCount = instance.totalPageCount;
  ///   }
  /// }
  ///
  /// NutrientView(
  ///   documentPath: 'assets/document.pdf',
  ///   adapter: MyWebAdapter(),
  /// )
  /// ```
  final NutrientPlatformAdapter? adapter;

  /// Called when the web instance is loaded, providing direct SDK access.
  ///
  /// This callback receives the new `dart:js_interop`-based [NutrientWebInstance].
  ///
  /// If an [adapter] is provided, prefer using its `onInstanceLoaded` method
  /// instead of this callback.
  final OnWebInstanceLoadedCallback? onWebInstanceLoaded;

  /// Creates a new [NutrientView] widget.
  const NutrientView({
    Key? key,
    required this.documentPath,
    this.configuration,
    this.onViewCreated,
    this.onDocumentLoaded,
    this.onDocumentError,
    this.onPageChanged,
    this.onPageClicked,
    this.onDocumentSaved,
    this.customToolbarItems = const [],
    this.onCustomToolbarItemTapped,
    this.adapter,
    this.onWebInstanceLoaded,
  }) : super(key: key);

  @override
  State<NutrientView> createState() => _NutrientViewState();
}

class _NutrientViewState extends State<NutrientView> {
  _CallbackBridgeAdapter? _bridgeAdapter;
  web.NutrientWebInstance? _webInstance;
  final Map<String, JSFunction> _eventListeners = {};

  @override
  void initState() {
    super.initState();
    _setupAdapter();
  }

  void _setupAdapter() {
    // Parse configuration
    PdfConfiguration? pdfConfig;
    if (widget.configuration != null) {
      if (widget.configuration is PdfConfiguration) {
        pdfConfig = widget.configuration;
      } else {
        throw ArgumentError(
            'The configuration must be a PdfConfiguration on the web platform.');
      }
    }

    // Create a bridge adapter that applies PdfConfiguration and chains
    // with the user-provided adapter. This adapter is passed directly to
    // NutrientViewWeb via its `adapter` parameter — no global state needed.
    _bridgeAdapter = _CallbackBridgeAdapter(
      configuration: pdfConfig,
      userAdapter: widget.adapter is web.NutrientWebAdapter
          ? widget.adapter as web.NutrientWebAdapter
          : null,
    );
  }

  void _onViewCreated(NutrientViewHandle handle) {
    if (!mounted) return;

    try {
      // Get the new NutrientWebInstance from the registry
      final instance =
          platform.NativeInstanceRegistry.get(handle.viewId, 'instance')
              as web.NutrientWebInstance?;

      if (instance == null) {
        debugPrint('[NutrientView Web] Instance not found in registry');
        widget.onDocumentError
            ?.call('Failed to load document: instance not found');
        return;
      }

      _webInstance = instance;

      // Attach event listeners for widget callbacks (onPageChanged, etc.)
      _attachEventListeners(instance);

      // Create controller and notify user
      final controller = NutrientViewControllerWeb(instance);
      widget.onViewCreated?.call(controller);

      // Build operations from the instance for the document stub
      final annotationOps = web.NutrientAnnotationOperations(instance);
      final documentOps = web.NutrientDocumentOperations(instance);
      final formOps = web.NutrientFormOperations(instance);
      final bookmarkOps = web.NutrientBookmarkOperations(instance);

      // Notify document loaded with a stub document.
      // Full PdfDocument functionality on web is available through the
      // controller or adapter.
      widget.onDocumentLoaded?.call(
        _WebPdfDocumentStub(
          documentId: handle.viewId.toString(),
          instance: instance,
          annotationOps: annotationOps,
          documentOps: documentOps,
          formOps: formOps,
          bookmarkOps: bookmarkOps,
        ),
      );

      // Call onWebInstanceLoaded callback
      widget.onWebInstanceLoaded?.call(instance);
    } catch (e) {
      debugPrint('[NutrientView Web] Error in onViewCreated: $e');
      widget.onDocumentError?.call(e.toString());
    }
  }

  void _attachEventListeners(web.NutrientWebInstance instance) {
    // Page change event listener
    if (widget.onPageChanged != null) {
      final JSFunction listener = ((JSAny? event) {
        if (!mounted) return;
        // currentPageIndex is on viewState, not the instance directly
        final pageIndex = instance.viewState.currentPageIndex;
        widget.onPageChanged?.call(pageIndex);
      }).toJS;

      instance.addEventListener('viewState.currentPageIndex.change', listener);
      _eventListeners['viewState.currentPageIndex.change'] = listener;
    }

    // Page press event listener
    if (widget.onPageClicked != null) {
      final JSFunction listener = ((JSAny? event) {
        if (!mounted) return;
        try {
          final dartEvent = event?.dartify();
          if (dartEvent is Map) {
            final point = dartEvent['point'];
            final pageIndex = dartEvent['pageIndex'];
            if (point != null && pageIndex != null) {
              final x = point['x'];
              final y = point['y'];
              if (x != null && y != null) {
                widget.onPageClicked?.call(
                  '',
                  pageIndex is int ? pageIndex : 0,
                  PointF(
                    x: x is num ? x.toDouble() : 0.0,
                    y: y is num ? y.toDouble() : 0.0,
                  ),
                  null,
                );
              }
            }
          }
        } catch (e) {
          debugPrint('Error processing page press event: $e');
        }
      }).toJS;

      instance.addEventListener('page.press', listener);
      _eventListeners['page.press'] = listener;
    }

    // Document save state change event listener
    if (widget.onDocumentSaved != null) {
      final JSFunction listener = ((JSAny? event) {
        if (!mounted) return;
        try {
          final dartEvent = event?.dartify();
          if (dartEvent is Map) {
            final hasUnsavedChanges = dartEvent['hasUnsavedChanges'];
            if (hasUnsavedChanges == false) {
              widget.onDocumentSaved?.call('', widget.documentPath);
            }
          }
        } catch (e) {
          debugPrint('Error processing save state change event: $e');
        }
      }).toJS;

      instance.addEventListener('document.saveStateChange', listener);
      _eventListeners['document.saveStateChange'] = listener;
    }
  }

  void _removeEventListeners() {
    if (_webInstance != null) {
      for (final entry in _eventListeners.entries) {
        try {
          _webInstance!.removeEventListener(entry.key, entry.value);
        } catch (e) {
          debugPrint('Error removing event listener: $e');
        }
      }
      _eventListeners.clear();
    }
  }

  @override
  void dispose() {
    _removeEventListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return web.NutrientViewWeb(
      documentPath: widget.documentPath,
      onViewCreated: _onViewCreated,
      adapter: _bridgeAdapter,
    );
  }
}

/// Internal adapter that bridges PdfConfiguration to the Web SDK's
/// configureLoad() method, and optionally chains with a user-provided adapter.
class _CallbackBridgeAdapter extends web.NutrientWebAdapter {
  final PdfConfiguration? configuration;
  final web.NutrientWebAdapter? userAdapter;

  _CallbackBridgeAdapter({
    this.configuration,
    this.userAdapter,
  });

  @override
  Future<void> configureLoad(
    NutrientViewHandle handle,
    Map<String, dynamic> config,
  ) async {
    // Skip super.configureLoad() to avoid duplicate logging — it only logs.
    // Apply PdfConfiguration to the config map
    WebConfigurationHelper.populateConfiguration(config, configuration);

    // Let user adapter further customize (user adapter will call its own super)
    if (userAdapter != null) {
      await userAdapter!.configureLoad(handle, config);
    }
  }

  @override
  Future<void> onInstanceLoaded(web.NutrientWebInstance instance) async {
    // Call super to set _instance property (needed for bridge functionality)
    await super.onInstanceLoaded(instance);

    // Forward to user adapter (user adapter will call its own super, but that's
    // acceptable since it's a different adapter instance with its own state)
    if (userAdapter != null) {
      await userAdapter!.onInstanceLoaded(instance);
    }
  }

  @override
  Future<void> onPlatformViewCreated(NutrientViewHandle handle) async {
    // Skip super.onPlatformViewCreated() to avoid duplicate logging — it only logs.
    // Forward to user adapter (user adapter will call its own super)
    if (userAdapter != null) {
      await userAdapter!.onPlatformViewCreated(handle);
    }
  }

  @override
  Future<void> dispose() async {
    if (userAdapter != null) {
      await userAdapter!.dispose();
    }
    await super.dispose();
  }
}

/// Minimal [PdfDocument] implementation for the web platform.
///
/// Delegates to operation classes from `nutrient_flutter_web` for all
/// document operations. The operations are provided at construction time
/// from the adapter/view.
///
/// For direct Web SDK access, use [NutrientViewControllerWeb] or
/// [NutrientWebAdapter].
class _WebPdfDocumentStub implements PdfDocument {
  @override
  final String documentId;

  final web.NutrientWebInstance? _instance;
  final web.NutrientAnnotationOperations? _annotationOps;
  final web.NutrientDocumentOperations? _documentOps;
  final web.NutrientFormOperations? _formOps;
  final web.NutrientBookmarkOperations? _bookmarkOps;

  _WebPdfDocumentStub({
    required this.documentId,
    web.NutrientWebInstance? instance,
    web.NutrientAnnotationOperations? annotationOps,
    web.NutrientDocumentOperations? documentOps,
    web.NutrientFormOperations? formOps,
    web.NutrientBookmarkOperations? bookmarkOps,
  })  : _instance = instance,
        _annotationOps = annotationOps,
        _documentOps = documentOps,
        _formOps = formOps,
        _bookmarkOps = bookmarkOps;

  // ========================================================================
  // Form Field Methods (delegating to NutrientFormOperations)
  // ========================================================================

  @override
  Future<bool?> setFormFieldValue(
      String value, String fullyQualifiedName) async {
    final ops = _formOps;
    if (ops == null) return false;
    try {
      await ops.setFormFieldValue(fullyQualifiedName, value);
      return true;
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] setFormFieldValue error: $e');
      return false;
    }
  }

  @override
  Future<String?> getFormFieldValue(String fullyQualifiedName) async {
    final ops = _formOps;
    if (ops == null) return null;
    try {
      return ops.getFormFieldValue(fullyQualifiedName);
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] getFormFieldValue error: $e');
      return null;
    }
  }

  @override
  Future<List<PdfFormField>> getFormFields() async {
    final ops = _formOps;
    if (ops == null) return [];
    try {
      final fields = await ops.getFormFields();
      return fields.map((f) => PdfFormField.fromMap(f)).toList();
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] getFormFields error: $e');
      return [];
    }
  }

  @override
  Future<PdfFormField> getFormField(String fieldName) async {
    final fields = await getFormFields();
    return fields.firstWhere(
      (f) => f.name == fieldName || f.fullyQualifiedName == fieldName,
      orElse: () => throw Exception('Form field "$fieldName" not found'),
    );
  }

  // ========================================================================
  // Page Methods (direct instance access — no operations class needed)
  // ========================================================================

  @override
  Future<int> getPageCount() async {
    final inst = _instance;
    if (inst == null) return 0;
    return inst.totalPageCount ?? inst.pageCount ?? 0;
  }

  @override
  Future<PageInfo> getPageInfo(int pageIndex) async {
    final inst = _instance;
    if (inst == null) {
      return PageInfo(
          pageIndex: pageIndex, width: 0, height: 0, rotation: 0, label: '');
    }
    try {
      final jsPageInfo = inst.pageInfoForIndex(pageIndex);
      if (jsPageInfo != null) {
        return PageInfo(
          pageIndex: pageIndex,
          width: jsPageInfo.width.toDouble(),
          height: jsPageInfo.height.toDouble(),
          rotation: jsPageInfo.rotation,
          label: jsPageInfo.label ?? '',
        );
      }
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] getPageInfo error: $e');
    }
    return PageInfo(
        pageIndex: pageIndex, width: 0, height: 0, rotation: 0, label: '');
  }

  // ========================================================================
  // Bookmark Methods (delegating to NutrientBookmarkOperations)
  // ========================================================================

  @override
  Future<List<Bookmark>> getBookmarks() async {
    final ops = _bookmarkOps;
    if (ops == null) return [];
    try {
      final maps = await ops.getBookmarks();
      return maps.map((m) {
        return Bookmark(
          pdfBookmarkId: m['pdfBookmarkId']?.toString(),
          name: m['name']?.toString(),
          actionJson: m['actionJson']?.toString(),
        );
      }).toList();
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] getBookmarks error: $e');
      return [];
    }
  }

  @override
  Future<Bookmark> addBookmark(Bookmark bookmark) async {
    final ops = _bookmarkOps;
    if (ops == null) throw Exception('Web instance not available');
    try {
      final result = await ops.addBookmark({
        'name': bookmark.name,
        'actionJson': bookmark.actionJson,
        'pdfBookmarkId': bookmark.pdfBookmarkId,
      });
      if (result != null) {
        return Bookmark(
          pdfBookmarkId: result['pdfBookmarkId']?.toString(),
          name: result['name']?.toString(),
          actionJson: result['actionJson']?.toString(),
        );
      }
      return bookmark;
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] addBookmark error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> removeBookmark(Bookmark bookmark) async {
    final ops = _bookmarkOps;
    if (ops == null) return false;
    try {
      return await ops.removeBookmark({
        'pdfBookmarkId': bookmark.pdfBookmarkId,
        'name': bookmark.name,
        'actionJson': bookmark.actionJson,
        if (bookmark.pageIndex != null) 'pageIndex': bookmark.pageIndex,
      });
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] removeBookmark error: $e');
      return false;
    }
  }

  @override
  Future<bool> updateBookmark(Bookmark bookmark) async {
    final ops = _bookmarkOps;
    if (ops == null) return false;
    try {
      return await ops.updateBookmark({
        'pdfBookmarkId': bookmark.pdfBookmarkId,
        'name': bookmark.name,
        'actionJson': bookmark.actionJson,
      });
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] updateBookmark error: $e');
      return false;
    }
  }

  @override
  Future<List<Bookmark>> getBookmarksForPage(int pageIndex) async {
    final allBookmarks = await getBookmarks();
    return allBookmarks
        .where((bookmark) => bookmark.pageIndex == pageIndex)
        .toList();
  }

  @override
  Future<bool> hasBookmarkForPage(int pageIndex) async {
    final bookmarks = await getBookmarksForPage(pageIndex);
    return bookmarks.isNotEmpty;
  }

  // ========================================================================
  // Annotation Methods (delegating to NutrientAnnotationOperations)
  // ========================================================================

  @override
  Future<void> addAnnotations(List<Annotation> annotations) async {
    final ops = _annotationOps;
    if (ops == null) return;
    try {
      await ops.addAnnotations(annotations.map((a) => a.toJson()).toList());
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] addAnnotations error: $e');
    }
  }

  @override
  Future<bool?> addAnnotation(dynamic annotation,
      [Map<String, dynamic>? attachment]) async {
    final ops = _annotationOps;
    if (ops == null) return false;
    try {
      Map<String, dynamic> jsonAnnotation;
      if (annotation is Annotation) {
        jsonAnnotation = annotation.toJson();
      } else if (annotation is String) {
        jsonAnnotation = jsonDecode(annotation) as Map<String, dynamic>;
      } else if (annotation is Map<String, dynamic>) {
        jsonAnnotation = annotation;
      } else {
        return false;
      }
      await ops.addAnnotation(jsonAnnotation);
      return true;
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] addAnnotation error: $e');
      return false;
    }
  }

  @override
  Future<bool?> removeAnnotation(dynamic annotation) async {
    final ops = _annotationOps;
    if (ops == null) return false;
    try {
      Map<String, dynamic> jsonAnnotation;
      if (annotation is Annotation) {
        jsonAnnotation = annotation.toJson();
      } else if (annotation is String) {
        jsonAnnotation = jsonDecode(annotation) as Map<String, dynamic>;
      } else if (annotation is Map<String, dynamic>) {
        jsonAnnotation = annotation;
      } else {
        return false;
      }
      await ops.removeAnnotation(jsonAnnotation);
      return true;
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] removeAnnotation error: $e');
      return false;
    }
  }

  @override
  Future<List<Annotation>> getAnnotations(
      int pageIndex, AnnotationType type) async {
    final ops = _annotationOps;
    if (ops == null) return [];
    try {
      final typeFilter = type == AnnotationType.all ? null : type.fullName;
      final maps = await ops.getAnnotations(pageIndex, typeFilter);
      return maps.map((m) => Annotation.fromJson(m)).toList();
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] getAnnotations error: $e');
      return [];
    }
  }

  @override
  Future<dynamic> getAnnotationsAsJson(
      int pageIndex, AnnotationType type) async {
    final ops = _annotationOps;
    if (ops == null) return <dynamic>[];
    try {
      final typeFilter = type == AnnotationType.all ? null : type.fullName;
      return await ops.getAnnotations(pageIndex, typeFilter);
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] getAnnotationsAsJson error: $e');
      return <dynamic>[];
    }
  }

  @override
  Future<List<Annotation>> getUnsavedAnnotations() async {
    final docOps = _documentOps;
    if (docOps == null) return [];
    try {
      final json = await docOps.exportInstantJson();
      if (json == null) return [];
      final parsed = jsonDecode(json);
      if (parsed is! Map) return [];

      final annotations = parsed['annotations'];
      if (annotations is! List) return [];

      return annotations
          .whereType<Map>()
          .map((ann) => Annotation.fromJson(Map<String, dynamic>.from(ann)))
          .toList();
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] getUnsavedAnnotations error: $e');
      return [];
    }
  }

  @override
  @Deprecated('Use getUnsavedAnnotations instead')
  Future<Object> getAllUnsavedAnnotations() async {
    final docOps = _documentOps;
    if (docOps == null) return {};
    try {
      final json = await docOps.exportInstantJson();
      if (json == null) return {};
      return jsonDecode(json) ?? {};
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] getAllUnsavedAnnotations error: $e');
      return {};
    }
  }

  @override
  @Deprecated(
      'Use getAnnotationProperties/saveAnnotationProperties for safe property updates. '
      'This method causes data loss for annotations with attachments. '
      'Will be removed in version 7.0.0')
  Future<void> updateAnnotation(Annotation annotation) async {
    await removeAnnotation(annotation);
    await addAnnotation(annotation);
  }

  @override
  Future<AnnotationProperties?> getAnnotationProperties(
    int pageIndex,
    String annotationId,
  ) async {
    final ops = _annotationOps;
    if (ops == null) return null;
    try {
      final existing = await ops.findAnnotation(annotationId, pageIndex);
      if (existing == null) return null;

      final jsonMap = ops.webAnnotationToJson(existing);
      if (jsonMap == null) return null;

      // Debug: log the fontColor from the live annotation JSON
      debugPrint(
          '[_WebPdfDocumentStub] getAnnotationProperties jsonMap fontColor: ${jsonMap['fontColor']}');
      debugPrint(
          '[_WebPdfDocumentStub] getAnnotationProperties jsonMap type: ${jsonMap['type']}');

      return _webJsonToAnnotationProperties(jsonMap, pageIndex);
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] getAnnotationProperties error: $e');
      return null;
    }
  }

  /// Converts a Web SDK annotation JSON map to an [AnnotationProperties] object.
  static AnnotationProperties _webJsonToAnnotationProperties(
      Map<String, dynamic> json, int pageIndex) {
    final bbox = json['bbox'];
    String? bboxJson;
    if (bbox is List) bboxJson = jsonEncode(bbox);

    final flags = json['flags'];
    String? flagsJson;
    if (flags is List) flagsJson = jsonEncode(flags);

    final customData = json['customData'];
    String? customDataJson;
    if (customData is Map) customDataJson = jsonEncode(customData);

    // For TextAnnotation (pspdfkit/text), the text color is stored in
    // 'fontColor', not 'strokeColor'. Map fontColor → strokeColor for
    // consistency with the Flutter API.
    final annotationType = json['type']?.toString() ?? '';
    final isTextAnnotation = annotationType == 'pspdfkit/text';

    int? strokeColor;
    if (isTextAnnotation && json['fontColor'] != null) {
      strokeColor = web.WebColorUtils.parseColorFromJson(json['fontColor']);
    } else {
      strokeColor = web.WebColorUtils.parseColorFromJson(json['strokeColor']);
    }

    return AnnotationProperties(
      annotationId: json['id']?.toString() ?? json['name']?.toString() ?? '',
      pageIndex: pageIndex,
      strokeColor: strokeColor,
      fillColor: web.WebColorUtils.parseColorFromJson(json['fillColor']),
      opacity: (json['opacity'] as num?)?.toDouble(),
      lineWidth: (json['lineWidth'] as num?)?.toDouble() ??
          (json['strokeWidth'] as num?)?.toDouble(),
      flagsJson: flagsJson,
      customDataJson: customDataJson,
      contents: json['text'] is Map
          ? (json['text'] as Map)['value']?.toString()
          : json['text']?.toString(),
      subject: json['subject']?.toString(),
      creator: json['creatorName']?.toString(),
      bboxJson: bboxJson,
      note: json['note']?.toString(),
      fontName: json['font']?.toString(),
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      iconName: json['icon']?.toString(),
    );
  }

  @override
  Future<bool> saveAnnotationProperties(AnnotationProperties properties) async {
    final ops = _annotationOps;
    if (ops == null) return false;
    try {
      // Build a properties map for the operations layer
      final propsMap = <String, dynamic>{
        'id': properties.annotationId,
        'pageIndex': properties.pageIndex,
      };
      if (properties.opacity != null) propsMap['opacity'] = properties.opacity;
      if (properties.lineWidth != null) {
        propsMap['lineWidth'] = properties.lineWidth;
      }
      if (properties.strokeColor != null) {
        final c = Color(properties.strokeColor!);
        propsMap['strokeColor'] = {'r': c.red, 'g': c.green, 'b': c.blue};
      }
      if (properties.fillColor != null) {
        final c = Color(properties.fillColor!);
        propsMap['fillColor'] = {'r': c.red, 'g': c.green, 'b': c.blue};
      }
      if (properties.contents != null)
        propsMap['contents'] = properties.contents;
      if (properties.creator != null) propsMap['creator'] = properties.creator;
      final customData = properties.customData;
      if (customData != null) propsMap['customData'] = customData;
      final flags = properties.flags;
      if (flags != null) propsMap['flags'] = flags;

      debugPrint(
          '[_WebPdfDocumentStub] saveAnnotationProperties propsMap: $propsMap');
      await ops.updateAnnotationProperties(propsMap);
      return true;
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] saveAnnotationProperties error: $e');
      return false;
    }
  }

  @override
  Future<List<Annotation>> searchAnnotations(String query,
      [int? pageIndex]) async {
    try {
      final inst = _instance;
      if (inst == null) return [];
      final pageCount = inst.totalPageCount ?? inst.pageCount ?? 0;
      final result = <Annotation>[];
      final queryLower = query.toLowerCase();

      final startPage = pageIndex ?? 0;
      final endPage = pageIndex != null ? pageIndex + 1 : pageCount;

      for (var p = startPage; p < endPage; p++) {
        final annotations = await getAnnotations(p, AnnotationType.all);
        for (final ann in annotations) {
          if (ann.toString().toLowerCase().contains(queryLower)) {
            result.add(ann);
          }
        }
      }
      return result;
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] searchAnnotations error: $e');
      return [];
    }
  }

  // ========================================================================
  // Document Methods (delegating to NutrientDocumentOperations)
  // ========================================================================

  @override
  Future<bool?> applyInstantJson(String annotationsJson) async {
    final ops = _documentOps;
    if (ops == null) return false;
    try {
      await ops.applyInstantJson(annotationsJson);
      return true;
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] applyInstantJson error: $e');
      return false;
    }
  }

  @override
  Future<String?> exportInstantJson() async {
    final ops = _documentOps;
    if (ops == null) return null;
    try {
      return await ops.exportInstantJson();
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] exportInstantJson error: $e');
      return null;
    }
  }

  @override
  Future<Uint8List> exportPdf({DocumentSaveOptions? options}) async {
    final ops = _documentOps;
    if (ops == null) throw Exception('Web instance not available');
    try {
      return await ops.exportPdf();
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] exportPdf error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> save({String? outputPath, DocumentSaveOptions? options}) async {
    final ops = _documentOps;
    if (ops == null) return false;
    try {
      await ops.save();
      return true;
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] save error: $e');
      return false;
    }
  }

  @override
  Future<bool> importXfdf(String xfdfString) async {
    final ops = _documentOps;
    if (ops == null) return false;
    try {
      await ops.importXfdf(xfdfString);
      return true;
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] importXfdf error: $e');
      return false;
    }
  }

  @override
  Future<bool> exportXfdf(String xfdfPath) async {
    final ops = _documentOps;
    if (ops == null) return false;
    try {
      await ops.exportXfdf();
      return true;
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] exportXfdf error: $e');
      return false;
    }
  }

  // ========================================================================
  // Document Dirty State - Cross-Platform
  // ========================================================================

  @override
  Future<bool> hasUnsavedChanges() async {
    final ops = _documentOps;
    if (ops == null) return false;
    try {
      return ops.hasUnsavedChanges();
    } catch (e) {
      debugPrint('[_WebPdfDocumentStub] hasUnsavedChanges error: $e');
      return false;
    }
  }

  // ========================================================================
  // Document Dirty State - Web Specific
  // ========================================================================

  @override
  Future<bool> webHasUnsavedChanges() async {
    return hasUnsavedChanges();
  }

  // ========================================================================
  // Document Dirty State - iOS Specific (Not supported on Web)
  // ========================================================================

  @override
  Future<bool> iOSHasDirtyAnnotations() {
    throw UnsupportedError(
        'iOSHasDirtyAnnotations is only available on iOS. Use webHasUnsavedChanges() on Web.');
  }

  @override
  Future<bool> iOSGetAnnotationIsDirty(int pageIndex, String annotationId) {
    throw UnsupportedError('iOSGetAnnotationIsDirty is only available on iOS.');
  }

  @override
  Future<bool> iOSSetAnnotationIsDirty(
      int pageIndex, String annotationId, bool isDirty) {
    throw UnsupportedError('iOSSetAnnotationIsDirty is only available on iOS.');
  }

  @override
  Future<bool> iOSClearNeedsSaveFlag() {
    throw UnsupportedError('iOSClearNeedsSaveFlag is only available on iOS.');
  }

  // ========================================================================
  // Document Dirty State - Android Specific (Not supported on Web)
  // ========================================================================

  @override
  Future<bool> androidHasUnsavedAnnotationChanges() {
    throw UnsupportedError(
        'androidHasUnsavedAnnotationChanges is only available on Android.');
  }

  @override
  Future<bool> androidHasUnsavedFormChanges() {
    throw UnsupportedError(
        'androidHasUnsavedFormChanges is only available on Android.');
  }

  @override
  Future<bool> androidHasUnsavedBookmarkChanges() {
    throw UnsupportedError(
        'androidHasUnsavedBookmarkChanges is only available on Android.');
  }

  @override
  Future<bool> androidGetBookmarkIsDirty(String bookmarkId) {
    throw UnsupportedError(
        'androidGetBookmarkIsDirty is only available on Android.');
  }

  @override
  Future<bool> androidClearBookmarkDirtyState(String bookmarkId) {
    throw UnsupportedError(
        'androidClearBookmarkDirtyState is only available on Android.');
  }

  @override
  Future<bool> androidGetFormFieldIsDirty(String fullyQualifiedName) {
    throw UnsupportedError(
        'androidGetFormFieldIsDirty is only available on Android.');
  }

  // ========================================================================
  // Misc
  // ========================================================================

  @override
  bool get isHeadless => false;

  @override
  Future<bool> close() async {
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      '${invocation.memberName} is not available on the web PdfDocument stub. '
      'Use NutrientViewController or NutrientWebAdapter for web document operations.',
    );
  }
}
