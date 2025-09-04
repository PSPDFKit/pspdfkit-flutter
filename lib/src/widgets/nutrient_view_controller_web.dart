///
///  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:ui';

import 'dart:js';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'package:nutrient_flutter/src/events/nutrient_events_extension.dart';
import '../document/annotation_json_converter.dart';
import '../web/nutrient_web.dart';
import '../web/nutrient_web_instance.dart';

/// A controller for a Nutrient viewer widget.
class NutrientViewControllerWeb extends NutrientViewController
    with AnnotationJsonConverter {
  final NutrientWebInstance pspdfkitInstance;

  NutrientViewControllerWeb(this.pspdfkitInstance);

  // Map to store original callbacks against their allowInterop-wrapped versions for removal.
  // Key: NutrientWebEvent, Value: Map<Original Dart Callback, Wrapped JS Callback>
  final Map<NutrientWebEvent, Map<Function, Function>> _webEventListeners = {};

  // Map to track legacy NutrientEvent listeners (for backward compatibility)
  final Map<NutrientEvent, Function> _legacyEventListeners = {};

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
  Future<bool?> save() async {
    await pspdfkitInstance.save();
    return Future.value(true);
  }

  @override
  Future<bool?> setAnnotationMenuConfiguration(
    AnnotationMenuConfiguration configuration,
  ) {
    // Web implementation: annotation menu configuration is handled differently on web
    // This would need to be implemented using the web-specific API
    // For now, we'll return true to indicate the API is available
    if (kDebugMode) {
      print(
          'setAnnotationMenuConfiguration called on web - not yet implemented');
    }
    return Future.value(true);
  }

  @override
  Future<bool?> setAnnotationConfigurations(
      Map<AnnotationTool, AnnotationConfiguration> configurations) async {
    throw UnimplementedError('This method is not supported on the web!');
  }

  void dispose() {
    // Remove all web event listeners before unloading
    final eventsCopy =
        Map<NutrientWebEvent, Map<Function, Function>>.from(_webEventListeners);
    for (final eventEntry in eventsCopy.entries) {
      final event = eventEntry.key;
      final callbacksCopy = Map<Function, Function>.from(eventEntry.value);
      for (final callbackEntry in callbacksCopy.entries) {
        final originalCallback = callbackEntry.key as Function(dynamic);
        removeWebEventListener(event, originalCallback);
      }
    }
    _webEventListeners.clear();

    // Remove all legacy event listeners
    final legacyEventsCopy =
        Map<NutrientEvent, Function>.from(_legacyEventListeners);
    for (final eventEntry in legacyEventsCopy.entries) {
      removeEventListener(eventEntry.key);
    }
    _legacyEventListeners.clear();

    NutrientWeb.unload(pspdfkitInstance.jsObject);
  }

  @override
  Future<void> addEventListener(
      NutrientEvent event, Function(dynamic) callback) async {
    // Note: This uses the older NutrientEvent enum.
    // Store the wrapped function for later removal
    final wrappedCallback = allowInterop((dynamic data) {
      _processAndInvokeCallback(data, callback, event);
    });

    _legacyEventListeners[event] = wrappedCallback;
    pspdfkitInstance.addEventListener(event.webName, wrappedCallback);
  }

  @override
  Future<void> removeEventListener(NutrientEvent event) async {
    final wrappedCallback = _legacyEventListeners[event];
    if (wrappedCallback != null) {
      try {
        pspdfkitInstance.removeEventListener(event.webName, wrappedCallback);
        _legacyEventListeners.remove(event);
      } catch (e) {
        if (kDebugMode) {
          print('Error removing legacy event listener for $event: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('Warning: No legacy event listener found for $event');
      }
    }
  }

  @override
  void addWebEventListener(NutrientWebEvent event, Function(dynamic) callback) {
    // Create the wrapped JS function that calls our common processor
    final Function wrappedJsFunction = allowInterop((dynamic data) {
      _processAndInvokeCallback(data, callback, event);
    });

    // Store the mapping before adding the listener
    _webEventListeners.putIfAbsent(event, () => {})[callback] =
        wrappedJsFunction;

    // Make sure we're properly converting the function to the right type
    dynamic jsFunction = wrappedJsFunction;

    // Add the listener using the wrapped function
    try {
      if (kDebugMode) {
        print('Adding event listener for: ${event.name}');
      }
      pspdfkitInstance.addEventListener(event.name, jsFunction);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding web event listener for ${event.name}: $e');
      }
    }
  }

  @override
  void removeWebEventListener(
      NutrientWebEvent event, Function(dynamic) callback) {
    // Find the map for the specific event
    final eventCallbacks = _webEventListeners[event];
    if (eventCallbacks != null) {
      // Find the wrapped JS function associated with the original Dart callback
      final wrappedJsFunction = eventCallbacks[callback];
      if (wrappedJsFunction != null) {
        try {
          // Remove the listener using the stored wrapped function
          pspdfkitInstance.removeEventListener(event.name, wrappedJsFunction);
        } catch (e) {
          if (kDebugMode) {
            print('Error removing web event listener for $event: $e');
          }
          // Log error but proceed to remove from map
        }
        // Remove the entry from our tracking map
        eventCallbacks.remove(callback);
        // Clean up the outer map if the inner map becomes empty
        if (eventCallbacks.isEmpty) {
          _webEventListeners.remove(event);
        }
      }
    }
  }

  @override
  Future<bool?> enterAnnotationCreationMode(
      [AnnotationTool? annotationTool]) async {
    try {
      if (annotationTool != null) {
        await pspdfkitInstance.setToolMode(annotationTool);
      } else {
        // Use a default annotation tool (ink) if none is specified
        // This is consistent with native implementations
        await pspdfkitInstance.setToolMode(AnnotationTool.inkPen);
      }
      return Future.value(true);
    } catch (e) {
      if (kDebugMode) {
        print('Error entering annotation creation mode: $e');
      }
      return Future.value(false);
    }
  }

  @override
  Future<bool?> exitAnnotationCreationMode() async {
    try {
      // Set tool mode to null to exit annotation creation mode
      // This will reset to the default interaction mode
      await pspdfkitInstance.setToolMode(null);
      return Future.value(true);
    } catch (e) {
      if (kDebugMode) {
        print('Error exiting annotation creation mode: $e');
      }
      return Future.value(false);
    }
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

  // Helper method to process event data and invoke the user callback
  void _processAndInvokeCallback(
      dynamic data, Function(dynamic) userCallback, dynamic eventEnum) {
    try {
      // Improved detection for annotation objects
      bool isAnnotation(dynamic obj) {
        if (obj is! Map<String, dynamic>) return false;

        // Primary check: Type property with pspdfkit/ prefix
        if (obj.containsKey('type') &&
            obj['type'] is String &&
            (obj['type'] as String).startsWith('pspdfkit/')) {
          return true;
        }

        // Secondary check: has id and common annotation properties
        if (obj.containsKey('id')) {
          final annotationProps = [
            'boundingBox',
            'pageIndex',
            'rects',
            'creatorName',
            'createdAt',
            'updatedAt'
          ];
          int matchCount = 0;
          for (final prop in annotationProps) {
            if (obj.containsKey(prop)) matchCount++;
          }
          if (matchCount >= 2) return true;
        }

        return false;
      }

      // Function to recursively process objects and convert annotations
      dynamic processObject(dynamic obj) {
        // Case 1: Map that could be an annotation or contain annotations
        if (obj is Map<String, dynamic>) {
          // If it's an annotation, convert it to Annotation object
          if (isAnnotation(obj)) {
            try {
              return Annotation.fromJson(obj);
            } catch (e) {
              if (kDebugMode) {
                print('Failed to convert annotation to Dart object: $e');
              }
              return obj; // Return original on error
            }
          }

          // Otherwise recursively process each value in the map
          final result = <String, dynamic>{};
          for (final entry in obj.entries) {
            result[entry.key] = processObject(entry.value);
          }
          return result;
        }

        // Case 2: List that might contain annotations
        else if (obj is List) {
          return obj.map((item) => processObject(item)).toList();
        }

        // Case 3: Primitive value, just return it
        return obj;
      }

      dynamic finalData;
      dynamic processedEvent1;
      dynamic processedEvent2;

      // --- Process event 1 and event 2 (if provided from JS) ---
      if (data is Map<String, dynamic> &&
          data.containsKey('argument1') &&
          data.containsKey('argument2')) {
        // This is a multi-argument event from JavaScript
        processedEvent1 = processObject(data['argument1']);
        processedEvent2 = processObject(data['argument2']);

        // Package into the expected format
        finalData = {
          'argument1': processedEvent1,
          'argument2': processedEvent2,
        };
      } else {
        // Standard single-argument event
        finalData = processObject(data);
      }

      // Debug log for events with annotations (useful for troubleshooting)
      if (kDebugMode && eventEnum.toString().contains('annotations')) {
        if (kDebugMode) {
          print('Processing ${eventEnum.toString()} event: $finalData');
        }
      }

      userCallback(finalData);
    } catch (e) {
      if (kDebugMode) {
        print('Error processing event listener data for $eventEnum: $e');
      }
      // Fallback: Pass original data if processing fails
      userCallback(data);
    }
  }

  @override
  Future<bool?> exportXfdf(String xfdfPath) async {
    await pspdfkitInstance.exportXfdf(xfdfPath);
    return Future.value(true);
  }
}
