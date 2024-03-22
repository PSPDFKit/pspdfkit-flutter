///
///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

enum PspdfkitWebToolbarItemType {
  sidebarThumbnails,
  sidebarDocumentOutline,
  sidebarAnnotations,
  sidebarBookmarks,
  sidebarSignatures,
  sidebarLayers,
  pager,
  pan,
  zoomOut,
  zoomIn,
  zoomMode,
  spacer,
  annotate,
  ink,
  highlighter,
  textHighlighter,
  inkEraser,
  signature,
  image,
  stamp,
  note,
  text,
  line,
  arrow,
  rectangle,
  cloudyRectangle,
  dashedRectangle,
  ellipse,
  cloudyEllipse,
  dashedEllipse,
  polygon,
  cloudyPolygon,
  dashedPolygon,
  polyline,
  print,
  documentEditor,
  documentCrop,
  search,
  exportPdf,
  debug,
  contentEditor,
  link,
  multiAnnotationsSelection,
  callout,
  responsiveGroup,
  custom,
  measurements
}

extension WebToolbarItemTypeX on PspdfkitWebToolbarItemType {
  String get name {
    switch (this) {
      case PspdfkitWebToolbarItemType.sidebarThumbnails:
        return 'sidebar-thumbnails';
      case PspdfkitWebToolbarItemType.sidebarDocumentOutline:
        return 'sidebar-document-outline';
      case PspdfkitWebToolbarItemType.sidebarAnnotations:
        return 'sidebar-annotations';
      case PspdfkitWebToolbarItemType.sidebarBookmarks:
        return 'sidebar-bookmarks';
      case PspdfkitWebToolbarItemType.sidebarSignatures:
        return 'sidebar-signatures';
      case PspdfkitWebToolbarItemType.sidebarLayers:
        return 'sidebar-layers';
      case PspdfkitWebToolbarItemType.pager:
        return 'pager';
      case PspdfkitWebToolbarItemType.pan:
        return 'pan';
      case PspdfkitWebToolbarItemType.zoomOut:
        return 'zoom-out';
      case PspdfkitWebToolbarItemType.zoomIn:
        return 'zoom-in';
      case PspdfkitWebToolbarItemType.zoomMode:
        return 'zoom-mode';
      case PspdfkitWebToolbarItemType.spacer:
        return 'spacer';
      case PspdfkitWebToolbarItemType.annotate:
        return 'annotate';
      case PspdfkitWebToolbarItemType.ink:
        return 'ink';
      case PspdfkitWebToolbarItemType.highlighter:
        return 'highlighter';
      case PspdfkitWebToolbarItemType.textHighlighter:
        return 'text-highlighter';
      case PspdfkitWebToolbarItemType.inkEraser:
        return 'ink-eraser';
      case PspdfkitWebToolbarItemType.signature:
        return 'signature';
      case PspdfkitWebToolbarItemType.image:
        return 'image';
      case PspdfkitWebToolbarItemType.stamp:
        return 'stamp';
      case PspdfkitWebToolbarItemType.note:
        return 'note';
      case PspdfkitWebToolbarItemType.text:
        return 'text';
      case PspdfkitWebToolbarItemType.line:
        return 'line';
      case PspdfkitWebToolbarItemType.arrow:
        return 'arrow';
      case PspdfkitWebToolbarItemType.rectangle:
        return 'rectangle';
      case PspdfkitWebToolbarItemType.cloudyRectangle:
        return 'cloudy-rectangle';
      case PspdfkitWebToolbarItemType.dashedRectangle:
        return 'dashed-rectangle';
      case PspdfkitWebToolbarItemType.ellipse:
        return 'ellipse';
      case PspdfkitWebToolbarItemType.cloudyEllipse:
        return 'cloudy-ellipse';
      case PspdfkitWebToolbarItemType.dashedEllipse:
        return 'dashed-ellipse';
      case PspdfkitWebToolbarItemType.polygon:
        return 'polygon';
      case PspdfkitWebToolbarItemType.cloudyPolygon:
        return 'cloudy-polygon';
      case PspdfkitWebToolbarItemType.dashedPolygon:
        return 'dashed-polygon';
      case PspdfkitWebToolbarItemType.polyline:
        return 'polyline';
      case PspdfkitWebToolbarItemType.print:
        return 'print';
      case PspdfkitWebToolbarItemType.documentEditor:
        return 'document-editor';
      case PspdfkitWebToolbarItemType.documentCrop:
        return 'document-crop';
      case PspdfkitWebToolbarItemType.search:
        return 'search';
      case PspdfkitWebToolbarItemType.exportPdf:
        return 'export-pdf';
      case PspdfkitWebToolbarItemType.debug:
        return 'debug';
      case PspdfkitWebToolbarItemType.contentEditor:
        return 'content-editor';
      case PspdfkitWebToolbarItemType.link:
        return 'link';
      case PspdfkitWebToolbarItemType.multiAnnotationsSelection:
        return 'multi-annotations-selection';
      case PspdfkitWebToolbarItemType.callout:
        return 'callout';
      case PspdfkitWebToolbarItemType.responsiveGroup:
        return 'responsive-group';
      case PspdfkitWebToolbarItemType.custom:
        return 'custom';
      case PspdfkitWebToolbarItemType.measurements:
        return 'measure';
    }
  }
}
