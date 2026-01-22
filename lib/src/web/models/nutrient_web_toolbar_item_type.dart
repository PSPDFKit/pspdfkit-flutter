///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

enum NutrientWebToolbarItemType {
  sidebarThumbnails,
  sidebarDocumentOutline,
  sidebarAnnotations,
  sidebarBookmarks,
  sidebarSignatures,
  sidebarLayers,
  sidebarAttachments,
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
  measurements,
  linearizedDownloadIndicator,
  comment,
  aiAssistant,
}

extension WebToolbarItemTypeX on NutrientWebToolbarItemType {
  String get name {
    switch (this) {
      case NutrientWebToolbarItemType.sidebarThumbnails:
        return 'sidebar-thumbnails';
      case NutrientWebToolbarItemType.sidebarDocumentOutline:
        return 'sidebar-document-outline';
      case NutrientWebToolbarItemType.sidebarAnnotations:
        return 'sidebar-annotations';
      case NutrientWebToolbarItemType.sidebarBookmarks:
        return 'sidebar-bookmarks';
      case NutrientWebToolbarItemType.sidebarSignatures:
        return 'sidebar-signatures';
      case NutrientWebToolbarItemType.sidebarLayers:
        return 'sidebar-layers';
      case NutrientWebToolbarItemType.pager:
        return 'pager';
      case NutrientWebToolbarItemType.pan:
        return 'pan';
      case NutrientWebToolbarItemType.zoomOut:
        return 'zoom-out';
      case NutrientWebToolbarItemType.zoomIn:
        return 'zoom-in';
      case NutrientWebToolbarItemType.zoomMode:
        return 'zoom-mode';
      case NutrientWebToolbarItemType.spacer:
        return 'spacer';
      case NutrientWebToolbarItemType.annotate:
        return 'annotate';
      case NutrientWebToolbarItemType.ink:
        return 'ink';
      case NutrientWebToolbarItemType.highlighter:
        return 'highlighter';
      case NutrientWebToolbarItemType.textHighlighter:
        return 'text-highlighter';
      case NutrientWebToolbarItemType.inkEraser:
        return 'ink-eraser';
      case NutrientWebToolbarItemType.signature:
        return 'signature';
      case NutrientWebToolbarItemType.image:
        return 'image';
      case NutrientWebToolbarItemType.stamp:
        return 'stamp';
      case NutrientWebToolbarItemType.note:
        return 'note';
      case NutrientWebToolbarItemType.text:
        return 'text';
      case NutrientWebToolbarItemType.line:
        return 'line';
      case NutrientWebToolbarItemType.arrow:
        return 'arrow';
      case NutrientWebToolbarItemType.rectangle:
        return 'rectangle';
      case NutrientWebToolbarItemType.cloudyRectangle:
        return 'cloudy-rectangle';
      case NutrientWebToolbarItemType.dashedRectangle:
        return 'dashed-rectangle';
      case NutrientWebToolbarItemType.ellipse:
        return 'ellipse';
      case NutrientWebToolbarItemType.cloudyEllipse:
        return 'cloudy-ellipse';
      case NutrientWebToolbarItemType.dashedEllipse:
        return 'dashed-ellipse';
      case NutrientWebToolbarItemType.polygon:
        return 'polygon';
      case NutrientWebToolbarItemType.cloudyPolygon:
        return 'cloudy-polygon';
      case NutrientWebToolbarItemType.dashedPolygon:
        return 'dashed-polygon';
      case NutrientWebToolbarItemType.polyline:
        return 'polyline';
      case NutrientWebToolbarItemType.print:
        return 'print';
      case NutrientWebToolbarItemType.documentEditor:
        return 'document-editor';
      case NutrientWebToolbarItemType.documentCrop:
        return 'document-crop';
      case NutrientWebToolbarItemType.search:
        return 'search';
      case NutrientWebToolbarItemType.exportPdf:
        return 'export-pdf';
      case NutrientWebToolbarItemType.debug:
        return 'debug';
      case NutrientWebToolbarItemType.contentEditor:
        return 'content-editor';
      case NutrientWebToolbarItemType.link:
        return 'link';
      case NutrientWebToolbarItemType.multiAnnotationsSelection:
        return 'multi-annotations-selection';
      case NutrientWebToolbarItemType.callout:
        return 'callout';
      case NutrientWebToolbarItemType.responsiveGroup:
        return 'responsive-group';
      case NutrientWebToolbarItemType.custom:
        return 'custom';
      case NutrientWebToolbarItemType.measurements:
        return 'measure';
      case NutrientWebToolbarItemType.linearizedDownloadIndicator:
        return 'linearized-download-indicator';
      case NutrientWebToolbarItemType.comment:
        return 'comment';
      case NutrientWebToolbarItemType.sidebarAttachments:
        return 'sidebar-attachments';
      case NutrientWebToolbarItemType.aiAssistant:
        return 'ai-assistant';
    }
  }
}
