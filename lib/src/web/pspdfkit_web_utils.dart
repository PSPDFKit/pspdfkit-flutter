///  Copyright © 2023 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:async';
import 'dart:convert';
import 'dart:js';
import 'models/models.dart';

/// Converts a JavaScript promise to a Dart future.
Future<dynamic> promiseToFuture(JsObject promise) {
  final completer = Completer();
  promise.callMethod('then', [
    allowInterop((value) {
      completer.complete(value);
    })
  ]);
  promise.callMethod('catch', [
    allowInterop((error) {
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

extension PSPDFKitToolbarItemsExtension on PspdfkitWebToolbarItem {
  /// Converts a [PspdfkitWebToolbarItem] to a [JsObject].
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

PspdfkitWebToolbarItem webToolbarItemFromJsObject(JsObject jsObject) {
  var json = jsObject.toJson();

  return PspdfkitWebToolbarItem(
    type: PspdfkitWebToolbarItemType.values
        .firstWhere((e) => e.name == json['type']),
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

PspdfkitWebAnnotationToolbarItem annotationToolbarItemFromJson(dynamic json) {
  return PspdfkitWebAnnotationToolbarItem(
    className: json['className'],
    disabled: json['disabled'],
    icon: json['icon'],
    id: json['id'],
    onPress: json['onPress'],
    title: json['title'],
    type: PspdfkitWebAnnotationToolbarItemType.values
        .firstWhere((e) => e.name == json['type']),
  );
}

extension PSPDFKitAnnotationToolbarItemsExtension
    on PspdfkitWebAnnotationToolbarItem {
  /// Converts a [PspdfkitWebAnnotationToolbarItem] to a [JsObject].
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

PspdfkitAnnotationToolbarItemsCallbackOptions
    annotationToolbarItemsCallbackOptionsFromJsObject(JsObject jsObject) {
  var json = jsObject.toJson();

  var defaultAnnotationToolbarItems = jsObjectListToDartList(
      jsObject['defaultAnnotationToolbarItems'] as JsObject);

  return PspdfkitAnnotationToolbarItemsCallbackOptions(
    defaultAnnotationToolbarItems: defaultAnnotationToolbarItems
        .map((item) => annotationToolbarItemFromJson(item))
        .toList(),
    hasDesktopLayout: json['hasDesktopLayout'],
  );
}
