///
///  Copyright © 2023 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:html';
import 'dart:js';
import 'package:pspdfkit_flutter/src/web/models/pspdfkit_web_toolbar_item.dart';
import 'package:pspdfkit_flutter/src/web/pspdfkit_web_instance.dart';
import 'package:pspdfkit_flutter/src/web/pspdfkit_web_configuration_helper.dart';
import '../pdf_configuration.dart';
import 'pspdfkit_web_utils.dart';

const flutterWebProductId = 'FlutterForWeb';

/// Provides access to PSPDFKit for web.
///
/// This class represents the [PSPDFKit](https://pspdfkit.com/api/web/PSPDFKit.html) object in the PSPDFKit Web SDK.
/// All methods are static and can be accessed directly from the class.
class PSPDFKitWeb {
  static final JsObject _pspdfkit = context['PSPDFKit'];
  static String? _pspdfkitLicenseKey;

  /// Sets the license key for PSPDFKit Web.
  ///
  /// This method tries to set the license key to confirm it is valid, then store it in a static variable to be used later in [PSPDFKit.load].
  /// Throws an exception if it fails to set the license key.
  ///
  static Future<void> setLicenseKey(String? licenseKey) async {
    try {
      if (licenseKey == null) {
        return;
      }
      // Try to set the license key to confirm it is valid, then store it in local storage.
      var config = JsObject.jsify({
        'licenseKey': licenseKey,
        'productId': flutterWebProductId,
      });
      _pspdfkitLicenseKey = licenseKey;
      await promiseToFuture(_pspdfkit.callMethod('preloadWorker', [config]));
    } catch (e) {
      throw Exception('Failed to set license key: $e');
    }
  }

  /// Loads a document and returns a [PspdfkitWebInstance] that can be used to interact with the document.
  ///
  /// The [documentPath] parameter specifies the path to the document that will be loaded.
  ///
  /// The [element] parameter is used to identify the container element in which the PSPDFKit instance will be rendered.
  ///
  /// The [configuration] parameter is an optional configuration object that can be used to customize the behavior of PSPDFKit.
  ///
  /// Throws a [PSPDFKitException] if the document fails to load.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final instance = await PSPDFKit.load(
  ///   documentPath: 'path/to/document.pdf',
  ///   id: 'pdf-viewer',
  ///   configuration: PSPDFKitConfiguration(
  ///     scrollDirection: PdfScrollDirection.vertical,
  ///     pageTransition: PdfPageTransition.curl,
  ///   ),
  /// );
  ///
  /// // Use the instance to interact with the document.
  /// ```
  static Future<PspdfkitWebInstance> load(String documentPath, Element element,
      PdfConfiguration? configuration) async {
    var webConfiguration = WebConfigurationHelper.populateWebConfiguration(
      element,
      documentPath,
      _pspdfkitLicenseKey,
      configuration,
    );
    JsObject pspdfkit = context['PSPDFKit'];
    try {
      var instance = await promiseToFuture(
          pspdfkit.callMethod('load', [webConfiguration]));
      return PspdfkitWebInstance(instance);
    } catch (e) {
      throw Exception('Failed to load: $e');
    }
  }

  /// Unloads a PSPDFKit instance.
  /// This is useful for cleaning up PSPDFKit instances that are no longer needed.
  static void unload(JsObject pspdfkitInstance) {
    try {
      _pspdfkit.callMethod('unload', [pspdfkitInstance]);
    } catch (e) {
      throw Exception('Failed to unload: $e');
    }
  }

  /// Returns the version of PSPDFKit for Web.
  /// This is useful for debugging purposes.
  static Future<String> get version async {
    try {
      return "Web ${_pspdfkit['version']}";
    } catch (e) {
      throw Exception('Failed to get version: $e');
    }
  }

  static String get authorName => _pspdfkit['annotationCreatorName'];

  /// Returns a list of [PspdfkitWebToolbarItem]s default main toolbar items from [PSPDFKit.defaultToolbarItems]
  /// (https://pspdfkit.com/api/web/PSPDFKit.html#.defaultToolbarItems)
  static List<PspdfkitWebToolbarItem> get defaultToolbarItems {
    try {
      var jsObjectList = _pspdfkit['defaultToolbarItems'];
      return jsObjectListToDartList(jsObjectList)
          .map((jsObject) => webToolbarItemFromJsObject(jsObject))
          .toList();
    } catch (e) {
      throw Exception('Failed to get defaultToolbarItems: $e');
    }
  }
}
