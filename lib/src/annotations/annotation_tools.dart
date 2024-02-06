///
///  Copyright © 2019-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
part of pspdfkit;

/// Available annotation tools.
enum AnnotationTool {
  inkPen,
  inkMagic,
  inkHighlighter,
  freeText,
  freeTextCallOut,
  stamp,
  image,
  highlight,
  underline,
  squiggly,
  strikeOut,
  line,
  arrow,
  square,
  circle,
  polygon,
  polyline,
  eraser,
  cloudy,
  link,
  caret,
  richMedia,
  screen,
  file,
  widget,
  redaction,
  signature,
  stampImage,
  note,
  sound,
  measurementAreaRect,
  measurementAreaPolygon,
  measurementAreaEllipse,
  measurementPerimeter,
  measurementDistance,
}
