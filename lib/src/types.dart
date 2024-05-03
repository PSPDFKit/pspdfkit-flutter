import '../pspdfkit.dart';

///  Copyright © 2023 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Enum representing the scroll direction of PSPDFKit.
///
/// The possible values are:
/// - `horizontal`: horizontal scroll direction.
/// - `vertical`: vertical scroll direction.
enum PspdfkitScrollDirection {
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
enum PspdfkitPageTransition {
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
enum PspdfkitPageLayoutMode {
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
enum PspdfkitSpreadFitting {
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
enum PspdfkitUserInterfaceViewMode {
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
enum PspdfkitAppearanceMode {
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
enum PspdfkitThumbnailBarMode {
  none,
  defaultStyle,
  pinned,
  scrubberBar,
  scrollable,
  floating
}

enum PspdfkitAutoSaveMode {
  disabled,
  immediate,
  intelligent,
}

/// An enum to represent the placement of the PSPDFKit toolbar.
///
/// The toolbar can be placed at the top or bottom of the screen.
enum PspdfKitToolbarPlacement {
  top,
  bottom,
}

/// Enum representing the different zoom modes available in PSPDFKit.
///
/// [auto] - Zoom mode is automatically determined based on the document's layout.
/// [fitToWidth] - Zoom mode scales the document to fit the width of the viewport.
/// [fitToViewPort] - Zoom mode scales the document to fit the viewport.
enum PspdfkitZoomMode { auto, fitToWidth, fitToViewPort }

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
enum PspdfkitToolbarMenuItems {
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
enum PspdfkitSidebarMode {
  annotations,
  bookmarks,
  thumbnails,
  documentOutline,
  custom
}

/// Defines the available interaction modes for the PSPDFKit Flutter plugin on the web platform.
enum PspdfkitWebInteractionMode {
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

typedef PspdfkitWidgetCreatedCallback = void Function(
    PspdfkitWidgetController view);

typedef PdfDocumentLoadedCallback = void Function(PdfDocument document);

typedef PdfDocumentLoadFailedCallback = void Function(String error);

typedef PageChangedCallback = void Function(int pageIndex);

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

extension WebPageLayoutMode on PspdfkitPageLayoutMode {
  String? get webName {
    switch (this) {
      case PspdfkitPageLayoutMode.double:
        return 'DOUBLE';
      case PspdfkitPageLayoutMode.automatic:
        return 'AUTOMATIC';
      case PspdfkitPageLayoutMode.single:
      default:
        return 'SINGLE';
    }
  }
}

extension WebPageTransition on PspdfkitPageTransition {
  String? get webName {
    switch (this) {
      case PspdfkitPageTransition.scrollContinuous:
        return 'CONTINUOUS';
      case PspdfkitPageTransition.disabled:
        return 'DISABLED';
      case PspdfkitPageTransition.scrollPerSpread:
      default:
        return 'PER_SPREAD';
    }
  }
}

extension WebAutoSaveMode on PspdfkitAutoSaveMode {
  String? get webName {
    switch (this) {
      case PspdfkitAutoSaveMode.disabled:
        return 'DISABLED';
      case PspdfkitAutoSaveMode.intelligent:
        return 'INTELLIGENT';
      case PspdfkitAutoSaveMode.immediate:
        return 'IMMEDIATE';
      default:
        return null;
    }
  }
}

extension WebSidebarMode on PspdfkitSidebarMode {
  String? get webName {
    switch (this) {
      case PspdfkitSidebarMode.annotations:
        return 'ANNOTATIONS';
      case PspdfkitSidebarMode.bookmarks:
        return 'BOOKMARKS';
      case PspdfkitSidebarMode.thumbnails:
        return 'THUMBNAILS';
      case PspdfkitSidebarMode.documentOutline:
        return 'DOCUMENT_OUTLINE';
      case PspdfkitSidebarMode.custom:
        return 'CUSTOM';
      default:
        return null;
    }
  }
}

extension WebZoomMode on PspdfkitZoomMode {
  String? get webName {
    switch (this) {
      case PspdfkitZoomMode.auto:
        return 'AUTO';
      case PspdfkitZoomMode.fitToWidth:
        return 'FIT_TO_WIDTH';
      case PspdfkitZoomMode.fitToViewPort:
        return 'FIT_TO_VIEWPORT';
      default:
        return null;
    }
  }
}

extension WebWebInteractionMode on PspdfkitWebInteractionMode {
  String? get webName {
    switch (this) {
      case PspdfkitWebInteractionMode.textHighlighter:
        return 'TEXT_HIGHLIGHTER';
      case PspdfkitWebInteractionMode.ink:
        return 'INK';
      case PspdfkitWebInteractionMode.inkSignature:
        return 'INK_SIGNATURE';
      case PspdfkitWebInteractionMode.signature:
        return 'SIGNATURE';
      case PspdfkitWebInteractionMode.stampPicker:
        return 'STAMP_PICKER';
      case PspdfkitWebInteractionMode.stampCustom:
        return 'STAMP_CUSTOM';
      case PspdfkitWebInteractionMode.shapeLine:
        return 'SHAPE_LINE';
      case PspdfkitWebInteractionMode.shapeRectangle:
        return 'SHAPE_RECTANGLE';
      case PspdfkitWebInteractionMode.shapeEllipse:
        return 'SHAPE_ELLIPSE';
      case PspdfkitWebInteractionMode.shapePolygon:
        return 'SHAPE_POLYGON';
      case PspdfkitWebInteractionMode.shapePolyline:
        return 'SHAPE_POLYLINE';
      case PspdfkitWebInteractionMode.inkEraser:
        return 'INK_ERASER';
      case PspdfkitWebInteractionMode.note:
        return 'NOTE';
      case PspdfkitWebInteractionMode.commentMarker:
        return 'COMMENT_MARKER';
      case PspdfkitWebInteractionMode.text:
        return 'TEXT';
      case PspdfkitWebInteractionMode.callout:
        return 'CALLOUT';
      case PspdfkitWebInteractionMode.pan:
        return 'PAN';
      case PspdfkitWebInteractionMode.search:
        return 'SEARCH';
      case PspdfkitWebInteractionMode.documentEditor:
        return 'DOCUMENT_EDITOR';
      case PspdfkitWebInteractionMode.marqueeZoom:
        return 'MARQUEE_ZOOM';
      case PspdfkitWebInteractionMode.redactTextHighlighter:
        return 'REDACT_TEXT_HIGHLIGHTER';
      case PspdfkitWebInteractionMode.redactShapeRectangle:
        return 'REDACT_SHAPE_RECTANGLE';
      case PspdfkitWebInteractionMode.documentCrop:
        return 'DOCUMENT_CROP';
      case PspdfkitWebInteractionMode.buttonWidget:
        return 'BUTTON_WIDGET';
      case PspdfkitWebInteractionMode.textWidget:
        return 'TEXT_WIDGET';
      case PspdfkitWebInteractionMode.radioButtonWidget:
        return 'RADIO_BUTTON_WIDGET';
      case PspdfkitWebInteractionMode.checkboxWidget:
        return 'CHECKBOX_WIDGET';
      case PspdfkitWebInteractionMode.comboBoxWidget:
        return 'COMBO_BOX_WIDGET';
      case PspdfkitWebInteractionMode.listBoxWidget:
        return 'LIST_BOX_WIDGET';
      case PspdfkitWebInteractionMode.signatureWidget:
        return 'SIGNATURE_WIDGET';
      case PspdfkitWebInteractionMode.dateWidget:
        return 'DATE_WIDGET';
      case PspdfkitWebInteractionMode.formCreator:
        return 'FORM_CREATOR';
      case PspdfkitWebInteractionMode.link:
        return 'LINK';
      case PspdfkitWebInteractionMode.distance:
        return 'DISTANCE';
      case PspdfkitWebInteractionMode.perimeter:
        return 'PERIMETER';
      case PspdfkitWebInteractionMode.rectangleArea:
        return 'RECTANGLE_AREA';
      case PspdfkitWebInteractionMode.ellipseArea:
        return 'ELLIPSE_AREA';
      case PspdfkitWebInteractionMode.polygonArea:
        return 'POLYGON_AREA';
      case PspdfkitWebInteractionMode.contentEditor:
        return 'CONTENT_EDITOR';
      case PspdfkitWebInteractionMode.multiAnnotationsSelection:
        return 'MULTI_ANNOTATIONS_SELECTION';
      case PspdfkitWebInteractionMode.measurement:
        return 'MEASUREMENT';
      case PspdfkitWebInteractionMode.measurementSettings:
        return 'MEASUREMENT_SETTINGS';
      default:
        return null;
    }
  }
}

extension WebAppearanceMode on PspdfkitAppearanceMode {
  String? get webName {
    switch (this) {
      case PspdfkitAppearanceMode.night:
        return 'DARK';
      case PspdfkitAppearanceMode.defaultMode:
      case PspdfkitAppearanceMode.sepia:
      case PspdfkitAppearanceMode.allCustomColors:
        return 'LIGHT';
      default:
        return null;
    }
  }

  String? get name {
    switch (this) {
      case PspdfkitAppearanceMode.night:
        return 'night';
      case PspdfkitAppearanceMode.defaultMode:
        return 'default';
      case PspdfkitAppearanceMode.sepia:
        return 'sepia';
      case PspdfkitAppearanceMode.allCustomColors:
        return 'allCustomColors';
      default:
        return null;
    }
  }
}

extension WebToolbarPlacement on PspdfKitToolbarPlacement {
  String? get webName {
    switch (this) {
      case PspdfKitToolbarPlacement.top:
        return 'TOP';
      case PspdfKitToolbarPlacement.bottom:
        return 'BOTTOM';
      default:
        return null;
    }
  }
}
