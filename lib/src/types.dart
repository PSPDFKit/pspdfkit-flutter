///  Copyright © 2023-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/widgets.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

/// Enum representing the scroll direction of PSPDFKit.
///
/// The possible values are:
/// - `horizontal`: horizontal scroll direction.
/// - `vertical`: vertical scroll direction.
enum ScrollDirection {
  horizontal,
  vertical,
}

/// Enum representing the available page transition modes in PSPDFKit.
///
/// The available modes are:
/// - `scrollContinuous`: Continuously scroll pages horizontally.
/// - `scrollPerSpread`: Scroll pages horizontally, one spread at a time.
/// - `curl`: Simulate a page curl effect.
/// - `slideHorizontal`: Slide pages horizontally.
/// - `slideVertical`: Slide pages vertically.
/// - `cover`: Slide pages horizontally with a cover effect.
/// - `fade`: Fade pages in and out.
/// - `scrollContinuousPerPage`: Continuously scroll pages vertically.
/// - `auto`: Automatically select the best transition mode based on the device and document.
/// - `disabled`: Disable page transitions.
enum PageTransition {
  scrollContinuous,
  scrollPerSpread,
  curl,
  slideHorizontal,
  slideVertical,
  cover,
  fade,
  scrollContinuousPerPage,
  auto,
  disabled
}

/// Enum representing the different page layout modes in PSPDFKit.
///
/// [single] displays one page at a time.
/// [double] displays two pages side by side.
/// [automatic] automatically selects the best layout mode based on the document and screen size.
enum PageLayoutMode {
  single,
  double,
  automatic,
}

/// An enum representing the different types of spread fitting modes in PSPDFKit.
///
/// The available modes are:
/// - `fit`: The page is scaled to fit the view.
/// - `fill`: The page is scaled to fill the view.
/// - `adaptive`: The page is scaled to fit the view, but only if it is smaller than the view. If it is larger, it is scaled to fill the view.
enum SpreadFitting {
  fit,
  fill,
  adaptive,
}

/// Enum representing the different user interface view modes for PSPDFKit.
///
/// [automatic]: The user interface view mode is determined automatically based on the context.
/// [always]: The user interface view mode is always shown.
/// [automaticNoFirstLastPage]: The user interface view mode is determined automatically, but the first and last page are always shown.
/// [never]: The user interface view mode is never shown.
enum UserInterfaceViewMode {
  automatic,
  always,
  automaticNoFirstLastPage,
  never,
}

/// An enum representing the appearance mode options for PSPDFKit.
///
/// The options are:
/// * `defaultMode`: The default appearance mode.
/// * `sepia`: The sepia appearance mode.
/// * `night`: The dark appearance mode.
/// * `allCustomColors`: The appearance mode with all custom colors.
enum AppearanceMode {
  defaultMode,
  sepia,
  night,
  allCustomColors,
}

/// Enum representing the different modes for the thumbnail bar in PSPDFKit.
/// This is only available on iOS and Android.
///
/// The modes are:
/// - `none`: No thumbnail bar is shown.
/// - `defaultStyle`: The default thumbnail bar is shown.
/// - `pinned`: The thumbnail bar is pinned to the bottom of the screen.
/// - `scrubberBar`: The thumbnail bar is shown as a scrubber bar.
/// - `scrollable`: The thumbnail bar is scrollable.
/// - `floating`: The thumbnail bar is floating over the document.
enum ThumbnailBarMode {
  none,
  defaultStyle,
  pinned,
  scrubberBar,
  scrollable,
  floating
}

enum AutoSaveMode {
  disabled,
  immediate,
  intelligent,
}

/// An enum to represent the placement of the PSPDFKit toolbar.
///
/// The toolbar can be placed at the top or bottom of the screen.
enum ToolbarPlacement {
  top,
  bottom,
}

/// Enum representing the different zoom modes available in PSPDFKit.
///
/// [auto] - Zoom mode is automatically determined based on the document's layout.
/// [fitToWidth] - Zoom mode scales the document to fit the width of the viewport.
/// [fitToViewPort] - Zoom mode scales the document to fit the viewport.
enum ZoomMode { auto, fitToWidth, fitToViewPort }

/// Enum representing the available menu items for the PSPDFKit toolbar.
///
/// The available menu items are:
/// - closeButtonItem
/// - outlineButtonItem
/// - searchButtonItem
/// - thumbnailsButtonItem
/// - documentEditorButtonItem
/// - printButtonItem
/// - openInButtonItem
/// - emailButtonItem
/// - messageButtonItem
/// - annotationButtonItem
/// - bookmarkButtonItem
/// - brightnessButtonItem
/// - activityButtonItem
/// - settingsButtonItem
/// - readerViewButtonItem
enum ToolbarMenuItems {
  closeButtonItem,
  outlineButtonItem,
  searchButtonItem,
  thumbnailsButtonItem,
  documentEditorButtonItem,
  printButtonItem,
  openInButtonItem,
  emailButtonItem,
  messageButtonItem,
  annotationButtonItem,
  bookmarkButtonItem,
  brightnessButtonItem,
  activityButtonItem,
  settingsButtonItem,
  readerViewButtonItem
}

/// Enum representing the different sidebar modes available in PSPDFKit.
///
/// [annotations] displays the annotations sidebar.
/// [bookmarks] displays the bookmarks sidebar.
/// [thumbnails] displays the thumbnails sidebar.
/// [documentOutline] displays the document outline sidebar.
/// [custom] displays a custom sidebar.
enum SidebarMode { annotations, bookmarks, thumbnails, documentOutline, custom }

/// Defines the available interaction modes for the PSPDFKit Flutter plugin on the web platform.
enum NutrientWebInteractionMode {
  textHighlighter,
  ink,
  inkSignature,
  signature,
  stampPicker,
  stampCustom,
  shapeLine,
  shapeRectangle,
  shapeEllipse,
  shapePolygon,
  shapePolyline,
  inkEraser,
  note,
  commentMarker,
  text,
  callout,
  pan,
  search,
  documentEditor,
  marqueeZoom,
  redactTextHighlighter,
  redactShapeRectangle,
  documentCrop,
  buttonWidget,
  textWidget,
  radioButtonWidget,
  checkboxWidget,
  comboBoxWidget,
  listBoxWidget,
  signatureWidget,
  dateWidget,
  formCreator,
  link,
  distance,
  perimeter,
  rectangleArea,
  ellipseArea,
  polygonArea,
  contentEditor,
  multiAnnotationsSelection,
  measurement,
  measurementSettings;
}

/// An enum that represents the mode for showing signature validation status.
///
/// The possible values are:
/// - `ifSigned`: Show the validation status only if the document is signed.
/// - `hasWarnings`: Show the validation status if the document has warnings.
/// - `hasErrors`: Show the validation status if the document has errors.
/// - `never`: Never show the validation status.
enum ShowSignatureValidationStatusMode {
  ifSigned,
  hasWarnings,
  hasErrors,
  never
}

/// Enum representing the different saving strategies for a signature.
///
/// The possible values are:
/// - `neverSave`: Never save the signature.
/// - `alwaysSave`: Always save the signature.
/// - `saveIfSelected`: Save the signature only if it is selected.
enum SignatureSavingStrategy { neverSave, alwaysSave, saveIfSelected }

/// Enum representing the different creation modes for a signature.
///
/// The possible values are:
/// - `draw`: Draw the signature.
/// - `image`: Use an image as the signature.
/// - `type`: Type the signature.
enum SignatureCreationMode { draw, image, type }

/// A class representing a color preset for a signature.
///
/// The possible values are:
/// - `color`: The color of the signature.
/// - `id`: The unique identifier of the color preset.
/// - `defaultMessage`: The default message associated with the color preset.
/// - `description`: The description of the color preset.
class SignatureColorPreset {
  final Color color;
  final String? id;
  final String? defaultMessage;
  final String? description;

  SignatureColorPreset(
      {required this.color, this.id, this.defaultMessage, this.description});

  Map<String, dynamic> toMap() {
    return {
      'color': color.toHex(),
      'id': id,
      'defaultMessage': defaultMessage,
      'description': description
    }..removeWhere((key, value) => value == null);
  }
}

/// A class representing a set of color presets for a signature.
///
/// The possible values are:
/// - `option1`: The first color preset.
/// - `option2`: The second color preset.
/// - `option3`: The third color preset.
class SignatureColorOptions {
  final SignatureColorPreset option1;
  final SignatureColorPreset option2;
  final SignatureColorPreset option3;

  SignatureColorOptions(
      {required this.option1, required this.option2, required this.option3});

  Map<String, dynamic> toMap() {
    return {
      'option1': option1.toMap(),
      'option2': option2.toMap(),
      'option3': option3.toMap()
    }..removeWhere((key, value) => value == null);
  }
}

/// Enum representing the different orientations for a signature on Android.
///
/// The possible values are:
/// - `portrait`: Portrait orientation.
/// - `landscape`: Landscape orientation.
/// - `automatic`: Automatic orientation.
/// - `unlocked`: Unlocked orientation.
enum NutrientAndroidSignatureOrientation {
  portrait,
  landscape,
  automatic,
  unlocked
}

/// A class representing the configuration for creating a signature.
///
/// The possible values are:
/// - `creationModes`: The list of creation modes for the signature.
/// - `colorOptions`: The set of color presets for the signature.
/// - `iosSignatureAspectRatio`: The aspect ratio for the signature on iOS.
/// - `androidSignatureOrientation`: The orientation for the signature on Android.
/// - `fonts`: The list of fonts available for the signature.
class SignatureCreationConfiguration {
  final List<SignatureCreationMode>? creationModes;
  final SignatureColorOptions? colorOptions;
  final AspectRatio? iosSignatureAspectRatio;
  final NutrientAndroidSignatureOrientation? androidSignatureOrientation;
  final List<String>? fonts;

  SignatureCreationConfiguration(
      {this.creationModes,
      this.colorOptions,
      this.iosSignatureAspectRatio,
      this.androidSignatureOrientation,
      this.fonts});

  Map<String, dynamic> toMap() {
    return {
      'creationModes': creationModes?.map((e) => e.name).toList(),
      'colorOptions': colorOptions?.toMap(),
      'iosSignatureAspectRatio': iosSignatureAspectRatio?.aspectRatio,
      'androidSignatureOrientation': androidSignatureOrientation?.name,
      'fonts': fonts
    }..removeWhere((key, value) => value == null);
  }
}

@Deprecated(
    'Use [NutrientViewCreatedCallback] instead. This will be removed in a future version.')
typedef PspdfkitWidgetCreatedCallback = void Function(
    PspdfkitWidgetController view);

@Deprecated(
    'Use [OnDocumentLoadedCallback] instead. This will be removed in a future version.')
typedef PdfDocumentLoadedCallback = void Function(PdfDocument document);

@Deprecated(
    'Use [OnDocumentLoadingFailedCallback] instead. This will be removed in a future version.')
typedef PdfDocumentLoadFailedCallback = void Function(String error);

typedef PageChangedCallback = void Function(int pageIndex);

typedef OnDocumentLoadedCallback = void Function(PdfDocument document);

typedef OnDocumentLoadingFailedCallback = void Function(String error);

typedef PageClickedCallback = void Function(
    String documentId, int pageIndex, PointF? point, dynamic annotation);

@Deprecated(
    'Use [OnDocumentSavedCallback] instead. This will be removed in a future version.')
typedef PdfDocumentSavedCallback = void Function(
    String documentId, String? path);

typedef OnDocumentSavedCallback = void Function(
    String documentId, String? path);

typedef OnCustomToolbarItemTappedCallback = void Function(String identifier);

typedef NutrientViewCreatedCallback = void Function(
    NutrientViewController controller);

extension WebShowSignatureValidationStatusMode
    on ShowSignatureValidationStatusMode {
  String? get webName {
    switch (this) {
      case ShowSignatureValidationStatusMode.ifSigned:
        return 'IF_SIGNED';
      case ShowSignatureValidationStatusMode.hasWarnings:
        return 'HAS_WARNINGS';
      case ShowSignatureValidationStatusMode.hasErrors:
        return 'HAS_ERRORS';
      case ShowSignatureValidationStatusMode.never:
        return 'NEVER';
      default:
        return null;
    }
  }
}

extension WebPageLayoutMode on PageLayoutMode {
  String? get webName {
    switch (this) {
      case PageLayoutMode.double:
        return 'DOUBLE';
      case PageLayoutMode.automatic:
        return 'AUTOMATIC';
      case PageLayoutMode.single:
      default:
        return 'SINGLE';
    }
  }
}

extension WebPageTransition on PageTransition {
  String? get webName {
    switch (this) {
      case PageTransition.scrollContinuous:
        return 'CONTINUOUS';
      case PageTransition.disabled:
        return 'DISABLED';
      case PageTransition.scrollPerSpread:
      default:
        return 'PER_SPREAD';
    }
  }
}

extension WebAutoSaveMode on AutoSaveMode {
  String? get webName {
    switch (this) {
      case AutoSaveMode.disabled:
        return 'DISABLED';
      case AutoSaveMode.intelligent:
        return 'INTELLIGENT';
      case AutoSaveMode.immediate:
        return 'IMMEDIATE';
      default:
        return null;
    }
  }
}

extension WebSidebarMode on SidebarMode {
  String? get webName {
    switch (this) {
      case SidebarMode.annotations:
        return 'ANNOTATIONS';
      case SidebarMode.bookmarks:
        return 'BOOKMARKS';
      case SidebarMode.thumbnails:
        return 'THUMBNAILS';
      case SidebarMode.documentOutline:
        return 'DOCUMENT_OUTLINE';
      case SidebarMode.custom:
        return 'CUSTOM';
      default:
        return null;
    }
  }
}

extension WebZoomMode on ZoomMode {
  String? get webName {
    switch (this) {
      case ZoomMode.auto:
        return 'AUTO';
      case ZoomMode.fitToWidth:
        return 'FIT_TO_WIDTH';
      case ZoomMode.fitToViewPort:
        return 'FIT_TO_VIEWPORT';
      default:
        return null;
    }
  }
}

extension WebWebInteractionMode on NutrientWebInteractionMode {
  String? get webName {
    switch (this) {
      case NutrientWebInteractionMode.textHighlighter:
        return 'TEXT_HIGHLIGHTER';
      case NutrientWebInteractionMode.ink:
        return 'INK';
      case NutrientWebInteractionMode.inkSignature:
        return 'INK_SIGNATURE';
      case NutrientWebInteractionMode.signature:
        return 'SIGNATURE';
      case NutrientWebInteractionMode.stampPicker:
        return 'STAMP_PICKER';
      case NutrientWebInteractionMode.stampCustom:
        return 'STAMP_CUSTOM';
      case NutrientWebInteractionMode.shapeLine:
        return 'SHAPE_LINE';
      case NutrientWebInteractionMode.shapeRectangle:
        return 'SHAPE_RECTANGLE';
      case NutrientWebInteractionMode.shapeEllipse:
        return 'SHAPE_ELLIPSE';
      case NutrientWebInteractionMode.shapePolygon:
        return 'SHAPE_POLYGON';
      case NutrientWebInteractionMode.shapePolyline:
        return 'SHAPE_POLYLINE';
      case NutrientWebInteractionMode.inkEraser:
        return 'INK_ERASER';
      case NutrientWebInteractionMode.note:
        return 'NOTE';
      case NutrientWebInteractionMode.commentMarker:
        return 'COMMENT_MARKER';
      case NutrientWebInteractionMode.text:
        return 'TEXT';
      case NutrientWebInteractionMode.callout:
        return 'CALLOUT';
      case NutrientWebInteractionMode.pan:
        return 'PAN';
      case NutrientWebInteractionMode.search:
        return 'SEARCH';
      case NutrientWebInteractionMode.documentEditor:
        return 'DOCUMENT_EDITOR';
      case NutrientWebInteractionMode.marqueeZoom:
        return 'MARQUEE_ZOOM';
      case NutrientWebInteractionMode.redactTextHighlighter:
        return 'REDACT_TEXT_HIGHLIGHTER';
      case NutrientWebInteractionMode.redactShapeRectangle:
        return 'REDACT_SHAPE_RECTANGLE';
      case NutrientWebInteractionMode.documentCrop:
        return 'DOCUMENT_CROP';
      case NutrientWebInteractionMode.buttonWidget:
        return 'BUTTON_WIDGET';
      case NutrientWebInteractionMode.textWidget:
        return 'TEXT_WIDGET';
      case NutrientWebInteractionMode.radioButtonWidget:
        return 'RADIO_BUTTON_WIDGET';
      case NutrientWebInteractionMode.checkboxWidget:
        return 'CHECKBOX_WIDGET';
      case NutrientWebInteractionMode.comboBoxWidget:
        return 'COMBO_BOX_WIDGET';
      case NutrientWebInteractionMode.listBoxWidget:
        return 'LIST_BOX_WIDGET';
      case NutrientWebInteractionMode.signatureWidget:
        return 'SIGNATURE_WIDGET';
      case NutrientWebInteractionMode.dateWidget:
        return 'DATE_WIDGET';
      case NutrientWebInteractionMode.formCreator:
        return 'FORM_CREATOR';
      case NutrientWebInteractionMode.link:
        return 'LINK';
      case NutrientWebInteractionMode.distance:
        return 'DISTANCE';
      case NutrientWebInteractionMode.perimeter:
        return 'PERIMETER';
      case NutrientWebInteractionMode.rectangleArea:
        return 'RECTANGLE_AREA';
      case NutrientWebInteractionMode.ellipseArea:
        return 'ELLIPSE_AREA';
      case NutrientWebInteractionMode.polygonArea:
        return 'POLYGON_AREA';
      case NutrientWebInteractionMode.contentEditor:
        return 'CONTENT_EDITOR';
      case NutrientWebInteractionMode.multiAnnotationsSelection:
        return 'MULTI_ANNOTATIONS_SELECTION';
      case NutrientWebInteractionMode.measurement:
        return 'MEASUREMENT';
      case NutrientWebInteractionMode.measurementSettings:
        return 'MEASUREMENT_SETTINGS';
      default:
        return null;
    }
  }
}

extension WebAppearanceMode on AppearanceMode {
  String? get webName {
    switch (this) {
      case AppearanceMode.night:
        return 'DARK';
      case AppearanceMode.defaultMode:
      case AppearanceMode.sepia:
      case AppearanceMode.allCustomColors:
        return 'LIGHT';
      default:
        return null;
    }
  }

  String? get name {
    switch (this) {
      case AppearanceMode.night:
        return 'night';
      case AppearanceMode.defaultMode:
        return 'default';
      case AppearanceMode.sepia:
        return 'sepia';
      case AppearanceMode.allCustomColors:
        return 'allCustomColors';
      default:
        return null;
    }
  }
}

extension WebToolbarPlacement on ToolbarPlacement {
  String? get webName {
    switch (this) {
      case ToolbarPlacement.top:
        return 'TOP';
      case ToolbarPlacement.bottom:
        return 'BOTTOM';
      default:
        return null;
    }
  }
}
