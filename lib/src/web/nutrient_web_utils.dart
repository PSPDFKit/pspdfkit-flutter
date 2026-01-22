///  Copyright © 2023-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'dart:convert';
// ignore: deprecated_member_use
import 'dart:js';
import 'dart:js_interop';
import 'models/models.dart';

// Re-export the toJS extension for use by other files
export 'dart:js_interop' show FunctionToJSExportedDartFunction;

/// Wraps a Dart function that takes one argument to be callable from JavaScript.
/// This is a compatibility wrapper for the deprecated allowInterop function.
/// Use this instead of the removed allowInterop function.
Function jsAllowInterop(Function(dynamic) dartFunction) {
  // Convert Dart function to JS function and back to get an interop-compatible function
  JSAny? wrapper(JSAny? arg) {
    final result = dartFunction(arg?.dartify());
    return result?.jsify();
  }

  return wrapper.toJS.toDart;
}

/// Wraps a Dart function that takes two optional arguments to be callable from JavaScript.
Function jsAllowInterop2(Function([dynamic, dynamic]) dartFunction) {
  JSAny? wrapper(JSAny? arg1, JSAny? arg2) {
    final result = dartFunction(arg1?.dartify(), arg2?.dartify());
    return result?.jsify();
  }

  return wrapper.toJS.toDart;
}

/// Wraps a Dart function that takes no arguments to be callable from JavaScript.
Function jsAllowInteropNoArgs(Function() dartFunction) {
  JSAny? wrapper() {
    final result = dartFunction();
    return result?.jsify();
  }

  return wrapper.toJS.toDart;
}

/// Converts a JavaScript promise to a Dart future.
Future<dynamic> promiseToFuture(JsObject promise) {
  final completer = Completer();
  promise.callMethod('then', [
    jsAllowInterop((value) {
      completer.complete(value);
    })
  ]);
  promise.callMethod('catch', [
    jsAllowInterop((error) {
      completer.completeError(error);
    })
  ]);
  return completer.future;
}

List<JsObject> jsObjectListToDartList(JsObject jsObjectList) {
  // Create a new Dart List<JsObject>.
  List<JsObject> dartList = [];

  if (jsObjectList is List<JsObject>) {
    return jsObjectList as List<JsObject>;
  }

  // Iterate over the JavaScript object (list) and add each element to the Dart List<JsObject>.
  for (var i = 0; i < jsObjectList['length']; i++) {
    dartList.add(jsObjectList[i]);
  }
  return dartList;
}

class Console {
  static void log(dynamic message) {
    context['console'].callMethod('log', [message]);
  }
}

extension JSObjectX on JsObject {
  dynamic toJson() {
    return const JsonDecoder()
        .convert(context['JSON'].callMethod('stringify', [this]));
  }
}

extension NutrientToolbarItemsExtension on NutrientWebToolbarItem {
  /// Converts a [NutrientWebToolbarItem] to a [JsObject].
  JsObject toJsObject() {
    var jsObject = JsObject(context['Object']);
    jsObject['type'] = type.name;
    if (title != null) {
      jsObject['title'] = title;
    }
    if (className != null) {
      jsObject['className'] = className;
    }
    if (disabled != null) {
      jsObject['disabled'] = disabled;
    }
    if (dropdownGroup != null) {
      jsObject['dropdownGroup'] = dropdownGroup;
    }
    if (icon != null) {
      jsObject['icon'] = icon;
    }
    if (id != null) {
      jsObject['id'] = id;
    }
    if (mediaQueries != null) {
      jsObject['mediaQueries'] = JsObject.jsify(mediaQueries ?? []);
    }
    if (onPress != null) {
      jsObject['onPress'] = onPress;
    }
    if (preset != null) {
      jsObject['preset'] = preset;
    }
    if (responsiveGroup != null) {
      jsObject['responsiveGroup'] = responsiveGroup;
    }
    if (selected != null) {
      jsObject['selected'] = selected;
    }
    return jsObject;
  }
}

NutrientWebToolbarItem webToolbarItemFromJsObject(JsObject jsObject) {
  var json = jsObject.toJson();

  return NutrientWebToolbarItem(
    type: NutrientWebToolbarItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () =>
            // Introduction of a new toolbar item type causes a runtime error.
            throw Exception('Unknown toolbar item type: ${json['type']}')),
    title: json['title'],
    className: json['className'],
    disabled: json['disabled'],
    dropdownGroup: json['dropdownGroup'],
    icon: json['icon'],
    id: json['id'],
    mediaQueries: json['mediaQueries'],
    onPress: json['onPress'],
    preset: json['preset'],
    responsiveGroup: json['responsiveGroup'],
    selected: json['selected'],
  );
}

NutrientWebAnnotationToolbarItem annotationToolbarItemFromJson(dynamic json) {
  var map = (json as JsObject).toJson();

  try {
    return NutrientWebAnnotationToolbarItem(
      className: map['className'],
      disabled: map['disabled'],
      icon: map['icon'],
      id: map['id'],
      onPress: map['onPress'],
      title: map['title'],
      type: NutrientWebAnnotationToolbarItemType.values
          .firstWhere((e) => e.name == map['type']),
    );
  } catch (e) {
    throw Exception('Failed to convert annotation toolbar item: $e');
  }
}

extension NutrientAnnotationToolbarItemsExtension
    on NutrientWebAnnotationToolbarItem {
  /// Converts a [NutrientWebAnnotationToolbarItem] to a [JsObject].
  JsObject toJsObject() {
    var jsObject = JsObject(context['Object']);
    jsObject['type'] = type.name;
    if (title != null) {
      jsObject['title'] = title;
    }
    if (className != null) {
      jsObject['className'] = className;
    }
    if (disabled != null) {
      jsObject['disabled'] = disabled;
    }
    if (icon != null) {
      jsObject['icon'] = icon;
    }
    if (id != null) {
      jsObject['id'] = id;
    }
    if (onPress != null) {
      jsObject['onPress'] = onPress;
    }
    return jsObject;
  }
}

NutrientAnnotationToolbarItemsCallbackOptions
    annotationToolbarItemsCallbackOptionsFromJsObject(JsObject jsObject) {
  var json = jsObject.toJson();

  var defaultAnnotationToolbarItems = jsObjectListToDartList(
      jsObject['defaultAnnotationToolbarItems'] as JsObject);

  return NutrientAnnotationToolbarItemsCallbackOptions(
    defaultAnnotationToolbarItems: defaultAnnotationToolbarItems
        .map((item) => annotationToolbarItemFromJson(item))
        .toList(),
    hasDesktopLayout: json['hasDesktopLayout'],
  );
}
