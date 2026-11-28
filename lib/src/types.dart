///  Copyright © 2023-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:nutrient_flutter/nutrient_flutter.dart';

// ScrollDirection, PageTransition, PageLayoutMode, SpreadFitting,
// UserInterfaceViewMode, AppearanceMode, and ThumbnailBarMode used to be
// declared here. They now live in
// nutrient_flutter_platform_interface/lib/src/configuration/view_configuration_enums.dart
// and are re-exported through the public barrel. Importing this file from
// the public barrel still resolves them transitively.

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

// SignatureSavingStrategy, SignatureCreationMode, SignatureColorPreset,
// SignatureColorOptions, NutrientAndroidSignatureOrientation and
// SignatureCreationConfiguration used to be declared here. They now live in
// nutrient_flutter_platform_interface/lib/src/configuration/signature_creation_configuration.dart
// (so the bindings' NutrientViewConfiguration can use them too) and are
// re-exported through the public barrel.

// IOSBookmarkIndicatorMode used to be declared here. It now lives in
// nutrient_flutter_platform_interface/lib/src/configuration/ios_view_configuration.dart
// and is re-exported through the public barrel.

// IOSFileConflictResolution used to be declared here. It now lives in
// nutrient_flutter_platform_interface/lib/src/configuration/ios_view_configuration.dart
// (so the bindings' IOSViewConfiguration can use it too) and is re-exported
// through the public barrel.

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

typedef OnBuildAnnotationMenuCallback = AnnotationMenuConfigurationData?
    Function(String documentId, Object annotation);

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
    }
  }
}

// WebPageLayoutMode and WebPageTransition extensions removed — equivalent
// versions live as `PageLayoutModeWebName` and `PageTransitionWebName` in
// nutrient_flutter_platform_interface/lib/src/configuration/view_configuration_enums.dart.

extension WebAutoSaveMode on AutoSaveMode {
  String? get webName {
    switch (this) {
      case AutoSaveMode.disabled:
        return 'DISABLED';
      case AutoSaveMode.intelligent:
        return 'INTELLIGENT';
      case AutoSaveMode.immediate:
        return 'IMMEDIATE';
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
    }
  }
}

// WebAppearanceMode extension removed — `AppearanceModeWebName` in
// nutrient_flutter_platform_interface/lib/src/configuration/view_configuration_enums.dart
// provides the equivalent webName getter. The custom `name` getter that
// shadowed the built-in enum `.name` was already dead code (instance members
// take precedence over extension members in Dart resolution).

extension WebToolbarPlacement on ToolbarPlacement {
  String? get webName {
    switch (this) {
      case ToolbarPlacement.top:
        return 'TOP';
      case ToolbarPlacement.bottom:
        return 'BOTTOM';
    }
  }
}
