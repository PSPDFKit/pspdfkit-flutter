///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../nutrient_web_bindings.dart';
import '../utils/color_utils.dart';
import '../utils/immutable_utils.dart';
import '../utils/namespace_utils.dart';

/// Map of Nutrient Web SDK annotation class names to their type strings.
///
/// Used for `instanceof` type detection since the Web SDK does not include
/// a `type` field in serialized annotation objects.
const annotationTypeMap = <String, String>{
  'TextAnnotation': 'pspdfkit/text',
  'NoteAnnotation': 'pspdfkit/note',
  'InkAnnotation': 'pspdfkit/ink',
  'HighlightAnnotation': 'pspdfkit/markup/highlight',
  'UnderlineAnnotation': 'pspdfkit/markup/underline',
  'SquiggleAnnotation': 'pspdfkit/markup/squiggly',
  'StrikeOutAnnotation': 'pspdfkit/markup/strikeout',
  'LineAnnotation': 'pspdfkit/shape/line',
  'RectangleAnnotation': 'pspdfkit/shape/rectangle',
  'EllipseAnnotation': 'pspdfkit/shape/ellipse',
  'PolygonAnnotation': 'pspdfkit/shape/polygon',
  'PolylineAnnotation': 'pspdfkit/shape/polyline',
  'LinkAnnotation': 'pspdfkit/link',
  'ImageAnnotation': 'pspdfkit/image',
  'RedactionAnnotation': 'pspdfkit/markup/redaction',
  'StampAnnotation': 'pspdfkit/stamp',
  'MediaAnnotation': 'pspdfkit/media',
  'WidgetAnnotation': 'pspdfkit/widget',
  'CommentMarkerAnnotation': 'pspdfkit/comment',
  'MarkupAnnotation': 'pspdfkit/markup',
};

/// Provides annotation CRUD operations on a Nutrient Web SDK instance.
///
/// This class wraps the raw [NutrientWebInstance] annotation APIs and provides
/// Dart-friendly methods for creating, reading, updating, and deleting annotations.
///
/// Accessible via [NutrientWebAdapter.annotationOperations] after the instance
/// is loaded.
class NutrientAnnotationOperations {
  final NutrientWebInstance _instance;

  NutrientAnnotationOperations(this._instance);

  /// Adds a single annotation from its JSON representation.
  ///
  /// The [jsonAnnotation] should match the structure returned by
  /// `PSPDFKit.Annotations.toSerializableObject`.
  ///
  /// Note: Widget annotations (form fields) cannot be created via this method
  /// as they require a corresponding form field to be created together.
  /// Use the form operations API instead for form field creation.
  Future<void> addAnnotation(Map<String, dynamic> jsonAnnotation) async {
    // Skip widget annotations - they require form fields to be created together
    final type = jsonAnnotation['type'] as String?;
    if (type == 'pspdfkit/widget') {
      // Widget annotations cannot be created standalone - they need form fields
      return;
    }

    final webAnnotation = annotationToWebObject(jsonAnnotation);
    if (webAnnotation == null) {
      throw Exception('Failed to convert annotation to Web SDK object');
    }
    await _instance.create(webAnnotation).toDart;
  }

  /// Adds multiple annotations from their JSON representations.
  Future<void> addAnnotations(List<Map<String, dynamic>> annotations) async {
    for (final annotation in annotations) {
      await addAnnotation(annotation);
    }
  }

  /// Removes an annotation identified by its JSON representation.
  ///
  /// Matches by `id` or `name` on the specified `pageIndex`.
  Future<void> removeAnnotation(dynamic jsonAnnotation) async {
    Map<String, dynamic> annotationMap;
    if (jsonAnnotation is String) {
      annotationMap = jsonDecode(jsonAnnotation) as Map<String, dynamic>;
    } else if (jsonAnnotation is Map<String, dynamic>) {
      annotationMap = jsonAnnotation;
    } else if (jsonAnnotation is Map) {
      annotationMap = Map<String, dynamic>.from(jsonAnnotation);
    } else {
      throw ArgumentError('jsonAnnotation must be a String or Map');
    }

    final annotationId = annotationMap['id'];
    final pageIndex = annotationMap['pageIndex'];
    final name = annotationMap['name'];

    if (pageIndex == null) {
      throw ArgumentError('pageIndex is required to remove an annotation');
    }

    final rawAnnotations = await _getRawAnnotations(pageIndex as int);
    final items = ImmutableList.toList(rawAnnotations);

    for (final item in items) {
      final itemId = (item['id'] as JSString?)?.toDart;
      final itemName = (item['name'] as JSString?)?.toDart;
      final itemPage = (item['pageIndex'] as JSNumber?)?.toDartInt;

      if ((itemId == annotationId && itemPage == pageIndex) ||
          (itemName == name && itemPage == pageIndex)) {
        await _instance.delete(itemId ?? itemName ?? '').toDart;
        return;
      }
    }
  }

  /// Gets all annotations on a page as Dart JSON maps.
  ///
  /// Optionally filter by [annotationType] (e.g., `'pspdfkit/ink'`).
  /// Pass `'pspdfkit/all'` to get all annotations (same as passing null).
  Future<List<Map<String, dynamic>>> getAnnotations(
    int pageIndex, [
    String? annotationType,
  ]) async {
    final rawAnnotations = await _getRawAnnotations(pageIndex);
    final items = ImmutableList.toList(rawAnnotations);
    final result = <Map<String, dynamic>>[];

    for (final item in items) {
      final json = webAnnotationToJson(item);
      if (json == null) continue;

      if (annotationType != null && annotationType != 'pspdfkit/all') {
        if (json['type'] == annotationType) {
          result.add(json);
        }
      } else {
        result.add(json);
      }
    }

    return result;
  }

  /// Gets all annotations on a page as a JSON string.
  Future<String> getAnnotationsAsJson(int pageIndex) async {
    final annotations = await getAnnotations(pageIndex);
    return jsonEncode(annotations);
  }

  /// Finds an annotation by ID on a specific page and returns its raw JS object.
  Future<JSObject?> findAnnotation(String annotationId, int pageIndex) async {
    final rawAnnotations = await _getRawAnnotations(pageIndex);
    final items = ImmutableList.toList(rawAnnotations);

    for (final item in items) {
      final itemId = (item['id'] as JSString?)?.toDart;
      final itemName = (item['name'] as JSString?)?.toDart;
      if (itemId == annotationId || itemName == annotationId) {
        return item;
      }
    }
    return null;
  }

  /// Updates specific properties of an annotation.
  ///
  /// The [properties] map should contain:
  /// - `id` or `name`: to identify the annotation
  /// - `pageIndex`: the page the annotation is on
  /// - Any properties to update (e.g., `strokeColor`, `opacity`, `lineWidth`)
  ///
  /// Color properties should be maps with `{r, g, b}` keys.
  /// Flags should be a `List<String>` of active flag names.
  Future<void> updateAnnotationProperties(
    Map<String, dynamic> properties,
  ) async {
    final annotationId = properties['id'] ?? properties['name'];
    final pageIndex = properties['pageIndex'];

    if (annotationId == null || pageIndex == null) {
      throw ArgumentError('Annotation id and pageIndex are required');
    }

    final existing =
        await findAnnotation(annotationId.toString(), pageIndex as int);
    if (existing == null) {
      throw Exception('Annotation not found with id: $annotationId');
    }

    // Determine annotation type for property name mapping
    final existingJson = webAnnotationToJson(existing);
    final annotationType = existingJson?['type']?.toString() ?? '';
    final isInkAnnotation = annotationType == 'pspdfkit/ink';
    final isTextAnnotation = annotationType == 'pspdfkit/text';

    // For TextAnnotation, extract existing text format and fontColor
    // so we can handle the XHTML color embedding workaround.
    bool isRichText = false;
    String? existingTextValue;
    if (isTextAnnotation && existingJson != null) {
      final textProp = existingJson['text'];
      if (textProp is Map) {
        final format = textProp['format']?.toString();
        existingTextValue = textProp['value']?.toString();
        isRichText = format == 'xhtml' && existingTextValue != null;
      }
    }

    // -----------------------------------------------------------------------
    // TextAnnotation: Execute the ENTIRE update in pure JavaScript.
    //
    // dart:js_interop's Immutable.js Record.set() produces records that lose
    // fontColor when passed to instance.update(). To avoid this, we build
    // a JS function that does ALL set() calls (generic properties, text,
    // fontColor) and calls instance.update() entirely within JS.
    //
    // The Web SDK's TextAnnotation uses `fontColor` (not `strokeColor`) for
    // text color, and expects `text` to be `{format: 'xhtml', value: '...'}`.
    // -----------------------------------------------------------------------
    if (isTextAnnotation) {
      return _updateTextAnnotationViaJS(
        existing: existing,
        properties: properties,
        existingJson: existingJson,
        isRichText: isRichText,
        existingTextValue: existingTextValue,
        isInkAnnotation: isInkAnnotation,
      );
    }

    // ----- Non-TextAnnotation path: use dart:js_interop as normal -----
    var updated = existing;

    for (final entry in properties.entries) {
      final key = entry.key;
      dynamic value = entry.value;

      // Skip identity fields
      if (key == 'id' || key == 'pageIndex' || key == 'name') continue;

      // Map property names to Web SDK expected names
      var webKey = key;
      if (key == 'lineWidth' && !isInkAnnotation) {
        webKey = 'strokeWidth';
      } else if (key == 'contents') {
        webKey = 'text';
      } else if (key == 'creator') {
        webKey = 'creatorName';
      }

      // Handle color properties
      if ((webKey == 'strokeColor' || webKey == 'fillColor') && value is Map) {
        value = WebColorUtils.colorIntToWebColor(
          WebColorUtils.parseColorFromJson(value) ?? 0xFF000000,
        );
        updated = ImmutableRecord.set(updated, webKey, value as JSAny);
        continue;
      }

      // Handle flags
      if (key == 'flags' && value is List) {
        final flagsList = List<String>.from(value);
        final flagMappings = {
          'readOnly': 'readOnly',
          'locked': 'locked',
          'hidden': 'hidden',
          'invisible': 'invisible',
          'print': 'noPrint',
          'noView': 'noView',
          'noZoom': 'noZoom',
          'noRotate': 'noRotate',
          'toggleNoView': 'toggleNoView',
          'lockedContents': 'lockedContents',
        };

        for (final flagEntry in flagMappings.entries) {
          final isSet = flagsList.contains(flagEntry.key);
          final flagValue = flagEntry.key == 'print' ? !isSet : isSet;
          updated = ImmutableRecord.set(
            updated,
            flagEntry.value,
            flagValue.toJS,
          );
        }
        continue;
      }

      // Handle customData
      if (key == 'customData' && value is Map) {
        updated = ImmutableRecord.set(updated, webKey, value.jsify());
        continue;
      }

      // Handle generic properties
      if (key != 'flags') {
        JSAny? jsValue;
        if (value is String) {
          jsValue = value.toJS;
        } else if (value is num) {
          jsValue = value.toJS;
        } else if (value is bool) {
          jsValue = value.toJS;
        } else if (value != null) {
          jsValue = value.jsify();
        }
        updated = ImmutableRecord.set(updated, webKey, jsValue);
      }
    }

    await _instance.update(updated).toDart;
  }

  /// Searches for annotations matching a query string.
  Future<JSAny?> searchAnnotations(String query) async {
    return _instance.search(query, null).toDart;
  }

  // ---------------------------------------------------------------------------
  // Conversion helpers
  // ---------------------------------------------------------------------------

  /// Converts a Dart JSON map to a Web SDK annotation object.
  ///
  /// Uses `PSPDFKit.Annotations.fromSerializableObject()`.
  JSAny? annotationToWebObject(Map<String, dynamic> json) {
    final ns = NutrientNamespace.getAsJSObject();
    final annotationsNs = ns['Annotations'] as JSObject?;
    if (annotationsNs == null) return null;

    return annotationsNs.callMethod(
      'fromSerializableObject'.toJS,
      json.jsify(),
    );
  }

  /// Converts a Web SDK annotation JS object to a Dart JSON map.
  ///
  /// Uses `PSPDFKit.Annotations.toSerializableObject()` and adds
  /// type information via `instanceof` checks.
  Map<String, dynamic>? webAnnotationToJson(JSObject jsAnnotation) {
    final ns = NutrientNamespace.getAsJSObject();
    final annotationsNs = ns['Annotations'] as JSObject?;
    if (annotationsNs == null) return null;

    final jsJson = annotationsNs.callMethod(
      'toSerializableObject'.toJS,
      jsAnnotation,
    );
    if (jsJson == null) return null;

    final result = jsJson.dartify();
    Map<String, dynamic> typedMap;
    if (result is Map<String, dynamic>) {
      typedMap = _deepConvertMap(result);
    } else if (result is Map) {
      typedMap = _deepConvertMap(Map<String, dynamic>.from(result));
    } else {
      return null;
    }

    _addAnnotationTypeToMap(typedMap, jsAnnotation);

    // Convert color objects {r, g, b} to hex strings for Flutter annotation models
    _convertColorsToHex(typedMap);

    // For TextAnnotation, extract fontColor directly from the Immutable.js
    // Record since toSerializableObject() may not include it.
    if (typedMap['type'] == 'pspdfkit/text') {
      final fontColor = ImmutableRecord.get(jsAnnotation, 'fontColor');
      if (fontColor != null) {
        final colorObj = fontColor as JSObject;
        final r = (colorObj['r'] as JSNumber?)?.toDartInt;
        final g = (colorObj['g'] as JSNumber?)?.toDartInt;
        final b = (colorObj['b'] as JSNumber?)?.toDartInt;
        if (r != null && g != null && b != null) {
          typedMap['fontColor'] = _colorMapToHex({'r': r, 'g': g, 'b': b});
        }
      }
    }

    return typedMap;
  }

  /// Converts color object properties {r, g, b} to hex strings in the map.
  ///
  /// The Web SDK returns colors as objects like {r: 96, g: 125, b: 139}
  /// but Flutter annotation models expect hex strings like "#607d8b".
  void _convertColorsToHex(Map<String, dynamic> map) {
    final colorKeys = [
      'strokeColor',
      'fillColor',
      'backgroundColor',
      'color',
      'borderColor',
      'outlineColor',
      'fontColor'
    ];

    for (final key in colorKeys) {
      final value = map[key];
      if (value is Map &&
          value.containsKey('r') &&
          value.containsKey('g') &&
          value.containsKey('b')) {
        map[key] = _colorMapToHex(value);
      }
    }

    // Also handle nested rects that might have colors
    if (map['rects'] is List) {
      // rects don't have colors, skip
    }
  }

  /// Recursively converts a map and all nested maps/lists to proper Dart types.
  ///
  /// This is needed because `dartify()` may return `IdentityMap` instances
  /// for nested objects which don't behave like regular Dart maps.
  Map<String, dynamic> _deepConvertMap(Map<String, dynamic> input) {
    final result = <String, dynamic>{};
    for (final entry in input.entries) {
      result[entry.key] = _deepConvertValue(entry.value);
    }
    return result;
  }

  /// Recursively converts a value, handling maps and lists.
  dynamic _deepConvertValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return _deepConvertMap(value);
    } else if (value is Map) {
      final converted = <String, dynamic>{};
      for (final entry in value.entries) {
        converted[entry.key.toString()] = _deepConvertValue(entry.value);
      }
      return converted;
    } else if (value is List) {
      return value.map(_deepConvertValue).toList();
    }
    return value;
  }

  /// Detects the annotation type via `instanceof` and adds it to the map.
  void _addAnnotationTypeToMap(
    Map<String, dynamic> map,
    JSObject jsAnnotation,
  ) {
    final ns = NutrientNamespace.getAsJSObject();
    final annotationsNs = ns['Annotations'] as JSObject?;
    if (annotationsNs == null) return;

    for (final entry in annotationTypeMap.entries) {
      final className = entry.key;
      final typeString = entry.value;

      final annotationClass = annotationsNs[className];
      if (annotationClass == null) continue;

      if (jsAnnotation.instanceof(annotationClass as JSFunction)) {
        map['type'] = typeString;
        return;
      }
    }
  }

  /// Gets raw annotations from the Web SDK as a JS object (Immutable.List).
  Future<JSAny?> _getRawAnnotations(int pageIndex) async {
    return _instance.getAnnotations(pageIndex).toDart;
  }

  // ---------------------------------------------------------------------------
  // TextAnnotation XHTML helpers
  // ---------------------------------------------------------------------------

  static final _xmlDeclarationPattern = RegExp(r'<\?xml[^?]*\?>');
  static final _bodyTagPattern =
      RegExp(r'<body[^>]*>(.*?)</body>', dotAll: true);
  static final _spanWithColorPattern =
      RegExp(r'<span\s+style="[^"]*color:[^"]*"[^>]*>', caseSensitive: false);
  static final _spanColorUpdatePattern = RegExp(
      r'(<span\s+style="[^"]*?)color:\s*(?:#[a-fA-F0-9]+|rgb\([^)]*\)|rgba\([^)]*\)|[a-zA-Z]+)([;"])',
      caseSensitive: false);
  static final _pTagPattern = RegExp(r'<p(\s[^>]*)?>(.+?)</p>', dotAll: true);
  static final _spanTagPattern = RegExp(r'<span(\s+style="([^"]*)")?([^>]*)>');
  static final _colorStylePattern = RegExp(r'color:[^;]+;?');
  static final _htmlTagPattern = RegExp(r'<[^>]+>');

  /// Performs the entire TextAnnotation update in pure JavaScript.
  ///
  /// This mirrors the old `dart:js` implementation exactly:
  ///   updatedAnnotation = updatedAnnotation.callMethod('set', [key, value]);
  ///   await promiseToFuture(_nutrientInstance.callMethod('update', [updatedAnnotation]));
  ///
  /// By executing all Immutable.js set() calls and the instance.update() call
  /// inside a single JS function, we avoid any dart:js_interop wrapping issues.
  Future<void> _updateTextAnnotationViaJS({
    required JSObject existing,
    required Map<String, dynamic> properties,
    required Map<String, dynamic>? existingJson,
    required bool isRichText,
    required String? existingTextValue,
    required bool isInkAnnotation,
  }) async {
    // ---- Determine if color is being changed ----
    // Only rebuild XHTML when the user explicitly changes strokeColor.
    // When updating other properties (opacity, flags, etc.), leave the
    // existing XHTML text content untouched — it already has the correct
    // color from the last color update. Reading back fontColor from the
    // SDK Record is unreliable (returns black) after XHTML-only updates.
    final bool isColorChange = properties.containsKey('strokeColor');
    String? hexColorForXhtml;

    if (isColorChange) {
      final colorMap = properties['strokeColor'] as Map;
      hexColorForXhtml = _colorMapToHex(colorMap);
    }

    // ---- Compute updated XHTML (only when color is changing) ----
    String? updatedXhtml;
    if (isColorChange &&
        isRichText &&
        existingTextValue != null &&
        hexColorForXhtml != null) {
      updatedXhtml = _updateRichTextColor(existingTextValue, hexColorForXhtml);
    }

    // ---- Apply properties using dart:js_interop ImmutableRecord.set() ----
    var updated = existing;

    for (final entry in properties.entries) {
      final key = entry.key;
      dynamic value = entry.value;

      if (key == 'id' || key == 'pageIndex' || key == 'name') continue;

      var webKey = key;
      if (key == 'lineWidth' && !isInkAnnotation) {
        webKey = 'strokeWidth';
      } else if (key == 'contents') {
        webKey = 'text';
      } else if (key == 'creator') {
        webKey = 'creatorName';
      }

      // Skip strokeColor — handled as fontColor below
      if (webKey == 'strokeColor') continue;

      // Skip contents/text for rich text — handled via XHTML below
      if (webKey == 'text' && isRichText) continue;

      // Handle fillColor
      if (webKey == 'fillColor' && value is Map) {
        value = WebColorUtils.colorIntToWebColor(
          WebColorUtils.parseColorFromJson(value) ?? 0xFF000000,
        );
        updated = ImmutableRecord.set(updated, webKey, value as JSAny);
        continue;
      }

      // Handle flags
      if (key == 'flags' && value is List) {
        final flagsList = List<String>.from(value);
        const flagMappings = {
          'readOnly': 'readOnly',
          'locked': 'locked',
          'hidden': 'hidden',
          'invisible': 'invisible',
          'print': 'noPrint',
          'noView': 'noView',
          'noZoom': 'noZoom',
          'noRotate': 'noRotate',
          'toggleNoView': 'toggleNoView',
          'lockedContents': 'lockedContents',
        };
        for (final fe in flagMappings.entries) {
          final isSet = flagsList.contains(fe.key);
          final flagVal = fe.key == 'print' ? !isSet : isSet;
          updated = ImmutableRecord.set(updated, fe.value, flagVal.toJS);
        }
        continue;
      }

      // Handle customData
      if (key == 'customData' && value is Map) {
        updated = ImmutableRecord.set(updated, webKey, value.jsify());
        continue;
      }

      // Generic properties
      if (key != 'flags') {
        JSAny? jsValue;
        if (value is String) {
          jsValue = value.toJS;
        } else if (value is num) {
          jsValue = value.toJS;
        } else if (value is bool) {
          jsValue = value.toJS;
        } else if (value != null) {
          jsValue = value.jsify();
        }
        updated = ImmutableRecord.set(updated, webKey, jsValue);
      }
    }

    // ---- Set XHTML text with color embedded in spans ----
    // The Web SDK derives fontColor from XHTML inline styles for rich text
    // annotations. Setting fontColor explicitly via Immutable.js set() is
    // discarded by instance.update() in dart:js_interop. Instead, we rely
    // entirely on the XHTML color styling, which the SDK respects.
    //
    // IMPORTANT: Only update XHTML when the user is explicitly changing the
    // color (strokeColor in properties). When updating other properties
    // (opacity, flags, etc.), leave text untouched — the existing XHTML
    // already has the correct color from the last color update.
    if (updatedXhtml != null) {
      final textObj = {'format': 'xhtml', 'value': updatedXhtml}.jsify();
      updated = ImmutableRecord.set(updated, 'text', textObj);
    } else if (!isRichText && isColorChange) {
      // For non-rich-text TextAnnotations (plain text), set fontColor
      // directly since there's no XHTML to embed color in.
      final colorMap = properties['strokeColor'] as Map;
      final ns = NutrientNamespace.getAsJSObject();
      final colorClass = ns['Color'] as JSFunction;
      final colorArgs = {
        'r': (colorMap['r'] as int?) ?? 0,
        'g': (colorMap['g'] as int?) ?? 0,
        'b': (colorMap['b'] as int?) ?? 0,
      }.jsify();
      final fontColor = colorClass.callAsConstructor(colorArgs);
      updated = ImmutableRecord.set(updated, 'fontColor', fontColor);
    }

    await _instance.update(updated).toDart;
  }

  /// Converts a color map with r, g, b keys to a hex color string.
  static String _colorMapToHex(Map colorMap) {
    final r = (colorMap['r'] ?? 0) as int;
    final g = (colorMap['g'] ?? 0) as int;
    final b = (colorMap['b'] ?? 0) as int;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// Updates the color styles in rich text XHTML content.
  ///
  /// The Web SDK strips body/xml style attributes on update, so color must
  /// be embedded in <span> elements.
  static String _updateRichTextColor(String xhtml, String hexColor) {
    if (xhtml.length > 50000) {
      final truncated =
          xhtml.replaceAll(_htmlTagPattern, '').substring(0, 1000);
      return '<p><span style="color:$hexColor">$truncated...</span></p>';
    }

    String textContent = xhtml;
    textContent = textContent.replaceAll(_xmlDeclarationPattern, '');

    final bodyMatch = _bodyTagPattern.firstMatch(textContent);
    if (bodyMatch != null) {
      textContent = bodyMatch.group(1) ?? textContent;
    }

    if (_spanWithColorPattern.hasMatch(textContent)) {
      return textContent.replaceAllMapped(
        _spanColorUpdatePattern,
        (match) => '${match.group(1)}color:$hexColor${match.group(2)}',
      );
    }

    if (textContent.contains('<p>') || textContent.contains('<p ')) {
      return textContent.replaceAllMapped(_pTagPattern, (match) {
        final pAttrs = match.group(1) ?? '';
        var content = match.group(2) ?? '';

        if (content.contains('<span')) {
          content = content.replaceAllMapped(
            _spanTagPattern,
            (spanMatch) {
              final existingStyle = spanMatch.group(2) ?? '';
              final otherAttrs = spanMatch.group(3) ?? '';
              if (existingStyle.contains('color:')) {
                final newStyle = existingStyle.replaceAll(
                    _colorStylePattern, 'color:$hexColor;');
                return '<span style="$newStyle"$otherAttrs>';
              } else if (existingStyle.isNotEmpty) {
                return '<span style="color:$hexColor;$existingStyle"$otherAttrs>';
              } else {
                return '<span style="color:$hexColor"$otherAttrs>';
              }
            },
          );
          return '<p$pAttrs>$content</p>';
        }

        return '<p$pAttrs><span style="color:$hexColor">$content</span></p>';
      });
    }

    final plainText = textContent.replaceAll(_htmlTagPattern, '').trim();
    if (plainText.isNotEmpty) {
      return '<p><span style="color:$hexColor">$plainText</span></p>';
    }

    return '<p><span style="color:$hexColor">$textContent</span></p>';
  }
}
