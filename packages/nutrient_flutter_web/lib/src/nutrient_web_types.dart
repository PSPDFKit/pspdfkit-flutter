///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:js_interop';

// ============================================================================
// Nutrient Web SDK Type Definitions
// ============================================================================
//
// These type definitions provide structured access to Nutrient Web SDK types.
// For complete API documentation, see: https://www.nutrient.io/api/web/
//
// Note: These types represent JavaScript objects from the Nutrient Web SDK.
// Most types are based on Immutable.js records and cannot be directly
// instantiated from Dart. Instead, create plain JavaScript objects and
// convert them using .jsify().
//
// Example:
// ```dart
// final annotation = {
//   'pageIndex': 0,
//   'boundingBox': {'left': 100, 'top': 100, 'width': 200, 'height': 50},
//   'text': 'Note text',
//   'type': 'pspdfkit/text',
// }.jsify();
// await instance.create(annotation).toDart;
// ```

// ============================================================================
// Geometry Types
// ============================================================================

/// Represents a rectangle with position and dimensions
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Geometry.Rect.html
@JS()
@staticInterop
class NutrientRect {}

extension NutrientRectExtension on NutrientRect {
  /// Left coordinate
  external num get left;

  /// Top coordinate
  external num get top;

  /// Width of the rectangle
  external num get width;

  /// Height of the rectangle
  external num get height;
}

/// Represents a 2D point
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Geometry.Point.html
@JS()
@staticInterop
class NutrientPoint {}

extension NutrientPointExtension on NutrientPoint {
  /// X coordinate
  external num get x;

  /// Y coordinate
  external num get y;
}

/// Represents a size with width and height
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Geometry.Size.html
@JS()
@staticInterop
class NutrientSize {}

extension NutrientSizeExtension on NutrientSize {
  /// Width
  external num get width;

  /// Height
  external num get height;
}

/// Drawing point for ink annotations
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Geometry.DrawingPoint.html
@JS()
@staticInterop
class NutrientDrawingPoint {}

extension NutrientDrawingPointExtension on NutrientDrawingPoint {
  /// X coordinate
  external num get x;

  /// Y coordinate
  external num get y;

  /// Pressure value (optional)
  external num? get pressure;
}

// ============================================================================
// Color Types
// ============================================================================

/// Represents a color
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Color.html
@JS()
@staticInterop
class NutrientColor {}

extension NutrientColorExtension on NutrientColor {
  /// Red component (0-255)
  external int get r;

  /// Green component (0-255)
  external int get g;

  /// Blue component (0-255)
  external int get b;

  /// Alpha component (0-1)
  external num? get a;

  /// Convert to CSS color string
  external String toCSSValue();

  /// Convert to hex string
  external String toHex();
}

// ============================================================================
// ViewState Type
// ============================================================================

/// Represents the current view state of the document instance
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.ViewState.html
@JS()
@staticInterop
class NutrientViewState {}

/// ViewState constructor for creating initial view state objects.
///
/// Usage:
/// ```dart
/// final viewState = NutrientViewStateConstructor({
///   'currentPageIndex': 5,
///   'layoutMode': 'DOUBLE',
///   'scrollMode': 'CONTINUOUS',
/// }.jsify()!);
/// ```
@JS('NutrientViewer.ViewState')
@staticInterop
class NutrientViewStateConstructor {
  /// Creates a new ViewState instance.
  external factory NutrientViewStateConstructor(JSAny properties);
}

/// Legacy ViewState constructor using PSPDFKit namespace.
@JS('PSPDFKit.ViewState')
@staticInterop
class PSPDFKitViewStateConstructor {
  /// Creates a new ViewState instance using the legacy namespace.
  external factory PSPDFKitViewStateConstructor(JSAny properties);
}

extension NutrientViewStateExtension on NutrientViewState {
  // Navigation & Display
  /// Current page index (0-based)
  external int get currentPageIndex;

  /// Layout mode (single, double page, etc.)
  external String? get layoutMode;

  /// Scroll mode (continuous, per spread)
  external String? get scrollMode;

  /// Page rotation in degrees (0, 90, 180, 270)
  external int get pagesRotation;

  // Zoom & Viewport
  /// Current zoom level (number or zoom mode string)
  external JSAny get zoom;

  /// Zoom step increment for zoom in/out (default: 1.25)
  external num get zoomStep;

  /// Viewport padding configuration
  external JSAny? get viewportPadding;

  // Spacing
  /// Spacing between pages in pixels
  external int get pageSpacing;

  /// Spacing between page spreads (default: 20)
  external int get spreadSpacing;

  // Visibility Controls
  /// Show/hide toolbar
  external bool get showToolbar;

  /// Show/hide annotations
  external bool get showAnnotations;

  /// Show/hide annotation notes
  external bool get showAnnotationNotes;

  /// Show/hide comments
  external bool get showComments;

  /// Show/hide AI Assistant dialog
  external bool get showAIAssistant;

  // User Permissions
  /// Read-only mode (disables annotation creation/editing UI)
  external bool get readOnly;

  /// Allow PDF export
  external bool get allowExport;

  /// Allow printing
  external bool get allowPrinting;

  // UI Modes
  /// Current interaction mode (PAN, TEXT, etc.)
  external String? get interactionMode;

  /// Current sidebar mode (THUMBNAILS, ANNOTATIONS, etc.)
  external String? get sidebarMode;

  /// Form design mode (edit vs. interact with form fields)
  external bool get formDesignMode;

  /// Preview redaction mode (show redacted vs. marked state)
  external bool get previewRedactionMode;

  // Specialized Features
  /// Comment display style (FITTING, POPOVER, FLOATING)
  external String? get commentDisplay;

  /// Show signature validation status UI
  external String? get showSignatureValidationStatus;

  /// Keep selected tool after annotation creation
  external bool get keepSelectedTool;

  /// Disable snapping for measurement tools
  external bool get disablePointSnapping;

  /// Enable finger scrolling during ink drawing
  external bool get canScrollWhileDrawing;

  /// Control page spread prerendering
  external int? get prerenderedPageSpreads;

  // Methods
  /// Update view state with a single property.
  ///
  /// Note: For updating `currentPageIndex`, prefer using [merge] with a
  /// jsified map for more reliable type conversion:
  /// ```dart
  /// viewState.merge({'currentPageIndex': 2}.jsify()!);
  /// ```
  ///
  /// Direct usage (may have type conversion issues):
  /// ```dart
  /// viewState.set('currentPageIndex'.toJS, 2.toJS);
  /// ```
  external NutrientViewState set(JSAny key, JSAny value);

  /// Update multiple view state properties at once using Immutable.js merge.
  ///
  /// Example:
  /// ```dart
  /// viewState.merge({'currentPageIndex': 2, 'showToolbar': false}.jsify()!);
  /// ```
  external NutrientViewState merge(JSAny updates);

  /// Navigate to next page
  external NutrientViewState goToNextPage();

  /// Navigate to previous page
  external NutrientViewState goToPreviousPage();

  /// Zoom in by 25%
  external NutrientViewState zoomIn();

  /// Zoom out by 25%
  external NutrientViewState zoomOut();

  /// Rotate 90° counterclockwise
  external NutrientViewState rotateLeft();

  /// Rotate 90° clockwise
  external NutrientViewState rotateRight();
}

// ============================================================================
// Annotation Types
// ============================================================================

/// Base annotation interface
///
/// All annotation types extend this base interface.
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.Annotation.html
@JS()
@staticInterop
class NutrientAnnotation {}

extension NutrientAnnotationExtension on NutrientAnnotation {
  // Core Identification
  /// Unique identifier
  external String get id;

  /// Optional name field
  external String? get name;

  /// Page index (0-based)
  external int get pageIndex;

  // Visual Properties
  /// Bounding box defining position and size
  external NutrientRect get boundingBox;

  /// Opacity (0-1)
  external num get opacity;

  /// Blend mode
  external String get blendMode;

  // State & Permission Flags
  /// Prevent modification
  external bool get locked;

  /// Prevent content modification
  external bool get lockedContents;

  /// Read-only annotation
  external bool get readOnly;

  /// Hide annotation
  external bool get hidden;

  /// Prevent printing
  external bool get noPrint;

  /// Prevent rendering
  external bool get noView;

  // Metadata
  /// Creation timestamp
  external JSAny? get createdAt;

  /// Last update timestamp
  external JSAny? get updatedAt;

  /// Creator name
  external String? get creatorName;

  /// Subject/topic
  external String? get subject;

  /// Note text
  external String? get note;

  /// Custom application data
  external JSAny? get customData;

  // Collaboration Features
  /// Can be edited (based on JWT permissions)
  external bool get isEditable;

  /// Can be deleted (based on JWT permissions)
  external bool get isDeletable;

  /// Can set group
  external bool get canSetGroup;

  /// Group identifier
  external String? get group;

  // Methods
  /// Update annotation with new values
  external NutrientAnnotation set(JSAny updates);
}

/// Text annotation (note/comment)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.TextAnnotation.html
@JS()
@staticInterop
class NutrientTextAnnotation extends NutrientAnnotation {}

extension NutrientTextAnnotationExtension on NutrientTextAnnotation {
  /// Text content
  external String? get text;

  /// Icon name
  external String get icon;

  /// Annotation color
  external NutrientColor? get color;
}

/// Ink annotation (freehand drawing)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.InkAnnotation.html
@JS()
@staticInterop
class NutrientInkAnnotation extends NutrientAnnotation {}

extension NutrientInkAnnotationExtension on NutrientInkAnnotation {
  /// Array of line paths (each path is an array of DrawingPoints)
  external JSArray get lines;

  /// Line width
  external num get lineWidth;

  /// Stroke color
  external NutrientColor? get strokeColor;

  /// Is signature
  external bool get isSignature;
}

/// Highlight annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.HighlightAnnotation.html
@JS()
@staticInterop
class NutrientHighlightAnnotation extends NutrientAnnotation {}

extension NutrientHighlightAnnotationExtension on NutrientHighlightAnnotation {
  /// Array of rects to highlight
  external JSArray get rects;

  /// Highlight color
  external NutrientColor? get color;
}

/// Shape annotation base (for lines, rectangles, ellipses, etc.)
@JS()
@staticInterop
class NutrientShapeAnnotation extends NutrientAnnotation {}

extension NutrientShapeAnnotationExtension on NutrientShapeAnnotation {
  /// Stroke color
  external NutrientColor? get strokeColor;

  /// Fill color
  external NutrientColor? get fillColor;

  /// Stroke width
  external num get strokeWidth;

  /// Stroke dash array
  external JSArray? get strokeDashArray;
}

/// Line annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.LineAnnotation.html
@JS()
@staticInterop
class NutrientLineAnnotation extends NutrientShapeAnnotation {}

extension NutrientLineAnnotationExtension on NutrientLineAnnotation {
  /// Start point
  external NutrientPoint get startPoint;

  /// End point
  external NutrientPoint get endPoint;

  /// Start line ending style
  external String? get lineCap;

  /// End line ending style
  external String? get lineEnd;
}

/// Rectangle annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.RectangleAnnotation.html
@JS()
@staticInterop
class NutrientRectangleAnnotation extends NutrientShapeAnnotation {}

/// Ellipse annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.EllipseAnnotation.html
@JS()
@staticInterop
class NutrientEllipseAnnotation extends NutrientShapeAnnotation {}

/// Stamp annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.StampAnnotation.html
@JS()
@staticInterop
class NutrientStampAnnotation extends NutrientAnnotation {}

extension NutrientStampAnnotationExtension on NutrientStampAnnotation {
  /// Stamp title
  external String? get title;

  /// Stamp subtitle
  external String? get subtitle;

  /// Stamp color
  external NutrientColor? get color;

  /// Stamp type identifier
  external String? get stampType;
}

/// Image annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.ImageAnnotation.html
@JS()
@staticInterop
class NutrientImageAnnotation extends NutrientAnnotation {}

extension NutrientImageAnnotationExtension on NutrientImageAnnotation {
  /// Image attachment ID
  external String? get imageAttachmentId;

  /// Image description
  external String? get description;

  /// Image file name
  external String? get fileName;

  /// Image content type
  external String? get contentType;
}

// ============================================================================
// Form Field Types
// ============================================================================

/// Base form field interface
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.FormFields.FormField.html
@JS()
@staticInterop
class NutrientFormField {}

extension NutrientFormFieldExtension on NutrientFormField {
  /// Unique name of the form field (fully qualified name)
  external String get name;

  /// Label used to identify the form field in the UI
  external String? get label;

  /// Read only form fields cannot be filled out
  external bool get readOnly;

  /// Required form fields must be filled out to submit the form
  external bool get required;

  /// Unique identifier for the form field record
  external String? get id;

  /// Additional actions to execute when events are triggered
  external JSAny? get additionalActions;

  /// Holds an immutable list of WidgetAnnotation ids
  external JSAny? get annotationIds;
}

/// Form field value
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.FormFields.FormFieldValue.html
@JS()
@staticInterop
class NutrientFormFieldValue {}

extension NutrientFormFieldValueExtension on NutrientFormFieldValue {
  /// Field name
  external String get name;

  /// Field value
  external JSAny? get value;

  /// Is opted in (for choice fields)
  external bool? get optedIn;
}

// ============================================================================
// Search Types
// ============================================================================

/// Search result
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.SearchResult.html
@JS()
@staticInterop
class NutrientSearchResult {}

extension NutrientSearchResultExtension on NutrientSearchResult {
  /// Page index where result was found
  external int get pageIndex;

  /// Text snippets containing the search term
  external JSArray get textLines;

  /// Rectangles highlighting the search term
  external JSArray get rects;

  /// Preview text around the match
  external String? get previewText;
}

/// Search state
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.SearchState.html
@JS()
@staticInterop
class NutrientSearchState {}

extension NutrientSearchStateExtension on NutrientSearchState {
  /// Search query
  external String? get query;

  /// Search is in progress
  external bool get isLoading;

  /// Search results
  external JSArray? get results;

  /// Currently focused result index
  external int? get focusedResultIndex;

  /// Case sensitive search
  external bool get caseSensitive;

  /// Whole word search
  external bool get wholeWord;
}

// ============================================================================
// Bookmark Types
// ============================================================================

/// Bookmark
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Bookmark.html
///
/// To create a new bookmark, use [NutrientBookmarkConstructor]:
/// ```dart
/// final action = nutrientGoToAction({'pageIndex': 5}.jsify()!);
/// final bookmark = nutrientBookmark({'name': 'My Bookmark', 'action': action}.jsify()!);
/// await instance.create(bookmark).toDart;
/// ```
@JS()
@staticInterop
class NutrientBookmark {}

extension NutrientBookmarkExtension on NutrientBookmark {
  /// Bookmark page index (may be null if page is defined via action)
  external int? get pageIndex;

  /// Bookmark name
  external String? get name;

  /// Bookmark action (navigation target)
  external JSAny? get action;

  /// Bookmark ID
  external String? get id;

  /// PDF object ID
  external int? get pdfObjectId;

  /// Create a copy with updated properties (Immutable.js pattern)
  external NutrientBookmark set(String property, JSAny? value);
}

/// Bookmark constructor class for creating new bookmarks.
///
/// This class provides proper JavaScript constructor invocation with 'new'.
///
/// Usage:
/// ```dart
/// final action = NutrientGoToActionConstructor({'pageIndex': 5}.jsify()!);
/// final bookmark = NutrientBookmarkConstructor({
///   'name': 'My Bookmark',
///   'action': action,
/// }.jsify()!);
/// await instance.create(bookmark).toDart;
/// ```
@JS('NutrientViewer.Bookmark')
@staticInterop
class NutrientBookmarkConstructor {
  /// Creates a new Bookmark instance.
  external factory NutrientBookmarkConstructor(JSAny properties);
}

/// Legacy PSPDFKit.Bookmark constructor for older SDK versions
@JS('PSPDFKit.Bookmark')
@staticInterop
class PSPDFKitBookmarkConstructor {
  /// Creates a new Bookmark instance using the legacy namespace.
  external factory PSPDFKitBookmarkConstructor(JSAny properties);
}

// ============================================================================
// Document Outline Types
// ============================================================================

/// Outline element (table of contents entry)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.OutlineElement.html
@JS()
@staticInterop
class NutrientOutlineElement {}

extension NutrientOutlineElementExtension on NutrientOutlineElement {
  /// Title text
  external String get title;

  /// Action (navigation target)
  external JSAny? get action;

  /// Color
  external NutrientColor? get color;

  /// Is bold
  external bool get isBold;

  /// Is italic
  external bool get isItalic;

  /// Child elements
  external JSArray? get children;
}

// ============================================================================
// Comment Types
// ============================================================================

/// Comment on an annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Comment.html
@JS()
@staticInterop
class NutrientComment {}

extension NutrientCommentExtension on NutrientComment {
  /// Comment ID
  external String get id;

  /// Root annotation ID
  external String get rootId;

  /// Page index
  external int get pageIndex;

  /// Text content
  external JSAny? get text;

  /// Creator name
  external String? get creatorName;

  /// Creation timestamp
  external JSAny? get createdAt;

  /// Update timestamp
  external JSAny? get updatedAt;

  /// Custom data
  external JSAny? get customData;
}

// ============================================================================
// Configuration Types
// ============================================================================

/// Main configuration object for PSPDFKit.load()
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Configuration.html
@JS()
@staticInterop
class NutrientConfiguration {}

extension NutrientConfigurationExtension on NutrientConfiguration {
  /// Container element or selector
  external JSAny get container;

  /// Document source (URL, ArrayBuffer, or File)
  external JSAny get document;

  /// Base URL for assets
  external String? get baseUrl;

  /// License key
  external String? get licenseKey;

  /// Initial view state
  external NutrientViewState? get initialViewState;

  /// Toolbar items configuration
  external JSArray? get toolbarItems;

  /// Layout mode
  external String? get layoutMode;

  /// Scroll mode
  external String? get scrollMode;

  /// Theme (LIGHT, DARK, AUTO)
  external String? get theme;

  /// Enable history (undo/redo)
  external bool? get enableHistory;

  /// Auto-save mode
  external String? get autoSaveMode;

  /// Instant JSON configuration
  external JSAny? get instant;
}

// ============================================================================
// Page Info Types
// ============================================================================

/// Page information
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.PageInfo.html
@JS()
@staticInterop
class NutrientPageInfo {}

extension NutrientPageInfoExtension on NutrientPageInfo {
  /// Page width
  external num get width;

  /// Page height
  external num get height;

  /// Page rotation (0, 90, 180, 270)
  external int get rotation;

  /// Page index
  external int get pageIndex;

  /// Page label
  external String? get label;
}

// ============================================================================
// Signature Types
// ============================================================================

/// Signature information
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.SignatureInfo.html
@JS()
@staticInterop
class NutrientSignatureInfo {}

extension NutrientSignatureInfoExtension on NutrientSignatureInfo {
  /// Signature type
  external String get signatureType;

  /// Signer name
  external String? get signerName;

  /// Signing time
  external JSAny? get signingTime;

  /// Validation status
  external String? get validationStatus;

  /// Signature covers whole document
  external bool get coversWholeDocument;
}

/// Stored signature
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.InkSignature.html
@JS()
@staticInterop
class NutrientInkSignature {}

extension NutrientInkSignatureExtension on NutrientInkSignature {
  /// Signature ID
  external String? get id;

  /// Signature title
  external String? get title;

  /// Ink annotation representing the signature
  external NutrientInkAnnotation get inkAnnotation;
}

// ============================================================================
// Text Line Types
// ============================================================================

/// Text line in a document
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.TextLine.html
@JS()
@staticInterop
class NutrientTextLine {}

extension NutrientTextLineExtension on NutrientTextLine {
  /// Page index
  external int get pageIndex;

  /// Bounding box
  external NutrientRect get boundingBox;

  /// Text content
  external String get contents;
}

// ============================================================================
// Instant (Collaboration) Types
// ============================================================================

/// Instant client for collaboration
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Instant.InstantClient.html
@JS()
@staticInterop
class NutrientInstantClient {}

extension NutrientInstantClientExtension on NutrientInstantClient {
  /// Connected clients
  external JSArray get connectedClients;

  /// Sync annotations manually
  external JSPromise syncAnnotations();

  /// Start listening to layer changes
  external void startListening();

  /// Stop listening to layer changes
  external void stopListening();
}

/// Connected client in collaboration session
@JS()
@staticInterop
class NutrientConnectedClient {}

extension NutrientConnectedClientExtension on NutrientConnectedClient {
  /// Client ID
  external String get id;

  /// Client name
  external String? get name;

  /// Client color
  external NutrientColor? get color;

  /// Is current user
  external bool get isCurrentUser;
}

// ============================================================================
// Action Types
// ============================================================================

/// Base action class
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Actions.Action.html
@JS()
@staticInterop
class NutrientAction {}

extension NutrientActionExtension on NutrientAction {
  /// Action type
  external String get type;

  /// Action ID
  external String? get id;
}

/// Go to action - navigates to a page
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Actions.GoToAction.html
@JS()
@staticInterop
class NutrientGoToAction {}

extension NutrientGoToActionExtension on NutrientGoToAction {
  /// Target page index
  external int get pageIndex;

  /// Optional target rect
  external NutrientRect? get rect;
}

/// GoToAction constructor class for creating navigation actions.
///
/// This class provides proper JavaScript constructor invocation with 'new'.
///
/// Usage:
/// ```dart
/// final action = NutrientGoToActionConstructor({'pageIndex': 5}.jsify()!);
/// ```
@JS('NutrientViewer.Actions.GoToAction')
@staticInterop
class NutrientGoToActionConstructor {
  /// Creates a new GoToAction instance.
  external factory NutrientGoToActionConstructor(JSAny properties);
}

/// Legacy GoToAction constructor using PSPDFKit namespace
@JS('PSPDFKit.Actions.GoToAction')
@staticInterop
class PSPDFKitGoToActionConstructor {
  /// Creates a new GoToAction instance using the legacy namespace.
  external factory PSPDFKitGoToActionConstructor(JSAny properties);
}

/// URI action - opens a URL
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Actions.URIAction.html
@JS()
@staticInterop
class NutrientURIAction {}

extension NutrientURIActionExtension on NutrientURIAction {
  /// Target URI
  external String get uri;
}

/// Submit form action
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Actions.SubmitFormAction.html
@JS()
@staticInterop
class NutrientSubmitFormAction {}

extension NutrientSubmitFormActionExtension on NutrientSubmitFormAction {
  /// Submit URL
  external String get url;

  /// HTTP method (GET or POST)
  external String? get method;
}

/// Hide action - hides/shows annotations
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Actions.HideAction.html
@JS()
@staticInterop
class NutrientHideAction {}

extension NutrientHideActionExtension on NutrientHideAction {
  /// Annotation IDs to hide/show
  external JSArray get annotationIds;

  /// Whether to hide (true) or show (false)
  external bool get hide;
}

/// JavaScript action
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Actions.JavaScriptAction.html
@JS()
@staticInterop
class NutrientJavaScriptAction {}

extension NutrientJavaScriptActionExtension on NutrientJavaScriptAction {
  /// JavaScript code to execute
  external String get script;
}

/// Launch action - opens a file
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Actions.LaunchAction.html
@JS()
@staticInterop
class NutrientLaunchAction {}

extension NutrientLaunchActionExtension on NutrientLaunchAction {
  /// File path to launch
  external String get filePath;
}

/// Named action - executes predefined actions
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Actions.NamedAction.html
@JS()
@staticInterop
class NutrientNamedAction {}

extension NutrientNamedActionExtension on NutrientNamedAction {
  /// Action name (e.g., 'NextPage', 'PrevPage', 'FirstPage', 'LastPage')
  external String get action;
}

/// Reset form action
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Actions.ResetFormAction.html
@JS()
@staticInterop
class NutrientResetFormAction {}

extension NutrientResetFormActionExtension on NutrientResetFormAction {
  /// Field names to reset (null = all fields)
  external JSArray? get fields;
}

// ============================================================================
// Additional Annotation Types
// ============================================================================

/// Note annotation (sticky note)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.NoteAnnotation.html
@JS()
@staticInterop
class NutrientNoteAnnotation {}

extension NutrientNoteAnnotationExtension on NutrientNoteAnnotation {
  /// Annotation ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Bounding box
  external NutrientRect get boundingBox;

  /// Text content
  external String? get text;

  /// Icon name
  external String? get icon;
}

/// Link annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.LinkAnnotation.html
@JS()
@staticInterop
class NutrientLinkAnnotation {}

extension NutrientLinkAnnotationExtension on NutrientLinkAnnotation {
  /// Annotation ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Bounding box
  external NutrientRect get boundingBox;

  /// Link action
  external NutrientAction? get action;

  /// Link URI (for URI actions)
  external String? get uri;
}

/// Polygon annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.PolygonAnnotation.html
@JS()
@staticInterop
class NutrientPolygonAnnotation {}

extension NutrientPolygonAnnotationExtension on NutrientPolygonAnnotation {
  /// Annotation ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Bounding box
  external NutrientRect get boundingBox;

  /// Polygon points
  external JSArray get points;

  /// Stroke color
  external NutrientColor? get strokeColor;

  /// Fill color
  external NutrientColor? get fillColor;

  /// Line width
  external num? get lineWidth;
}

/// Polyline annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.PolylineAnnotation.html
@JS()
@staticInterop
class NutrientPolylineAnnotation {}

extension NutrientPolylineAnnotationExtension on NutrientPolylineAnnotation {
  /// Annotation ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Bounding box
  external NutrientRect get boundingBox;

  /// Polyline points
  external JSArray get points;

  /// Stroke color
  external NutrientColor? get strokeColor;

  /// Line width
  external num? get lineWidth;
}

/// Redaction annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.RedactionAnnotation.html
@JS()
@staticInterop
class NutrientRedactionAnnotation {}

extension NutrientRedactionAnnotationExtension on NutrientRedactionAnnotation {
  /// Annotation ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Bounding box
  external NutrientRect get boundingBox;

  /// Overlay text (shown after redaction is applied)
  external String? get overlayText;

  /// Fill color
  external NutrientColor? get fillColor;

  /// Outline color
  external NutrientColor? get outlineColor;
}

/// Squiggle annotation (underline with wavy line)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.SquiggleAnnotation.html
@JS()
@staticInterop
class NutrientSquiggleAnnotation {}

extension NutrientSquiggleAnnotationExtension on NutrientSquiggleAnnotation {
  /// Annotation ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Text rects
  external JSArray get rects;

  /// Color
  external NutrientColor? get color;
}

/// Strikeout annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.StrikeOutAnnotation.html
@JS()
@staticInterop
class NutrientStrikeOutAnnotation {}

extension NutrientStrikeOutAnnotationExtension on NutrientStrikeOutAnnotation {
  /// Annotation ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Text rects
  external JSArray get rects;

  /// Color
  external NutrientColor? get color;
}

/// Underline annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.UnderlineAnnotation.html
@JS()
@staticInterop
class NutrientUnderlineAnnotation {}

extension NutrientUnderlineAnnotationExtension on NutrientUnderlineAnnotation {
  /// Annotation ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Text rects
  external JSArray get rects;

  /// Color
  external NutrientColor? get color;
}

/// Widget annotation (form field visual representation)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.WidgetAnnotation.html
@JS()
@staticInterop
class NutrientWidgetAnnotation {}

extension NutrientWidgetAnnotationExtension on NutrientWidgetAnnotation {
  /// Annotation ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Bounding box
  external NutrientRect get boundingBox;

  /// Associated form field ID
  external String get formFieldName;

  /// Border style
  external String? get borderStyle;

  /// Border width
  external num? get borderWidth;

  /// Border color
  external NutrientColor? get borderColor;

  /// Background color
  external NutrientColor? get backgroundColor;
}

/// Media annotation (audio/video)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.MediaAnnotation.html
@JS()
@staticInterop
class NutrientMediaAnnotation {}

extension NutrientMediaAnnotationExtension on NutrientMediaAnnotation {
  /// Annotation ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Bounding box
  external NutrientRect get boundingBox;

  /// Media URI
  external String? get mediaUri;

  /// Media type (audio/video)
  external String? get mediaType;

  /// Content type (MIME type)
  external String? get contentType;
}

/// Comment marker annotation
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.CommentMarkerAnnotation.html
@JS()
@staticInterop
class NutrientCommentMarkerAnnotation {}

extension NutrientCommentMarkerAnnotationExtension
    on NutrientCommentMarkerAnnotation {
  /// Annotation ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Bounding box
  external NutrientRect get boundingBox;

  /// Marker text
  external String? get text;
}

// ============================================================================
// Form Field Types (Specialized)
// ============================================================================

/// Text form field
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.FormFields.TextFormField.html
@JS()
@staticInterop
class NutrientTextFormField {}

extension NutrientTextFormFieldExtension on NutrientTextFormField {
  /// Field name
  external String get name;

  /// Field value
  external String? get value;

  /// Is multiline
  external bool get isMultiLine;

  /// Is password field
  external bool get isPassword;

  /// Max length
  external int? get maxLength;
}

/// Checkbox form field
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.FormFields.CheckBoxFormField.html
@JS()
@staticInterop
class NutrientCheckBoxFormField {}

extension NutrientCheckBoxFormFieldExtension on NutrientCheckBoxFormField {
  /// Field name
  external String get name;

  /// Field value (checked state)
  external bool get value;

  /// Default value
  external bool get defaultValue;
}

/// Radio button form field
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.FormFields.RadioButtonFormField.html
@JS()
@staticInterop
class NutrientRadioButtonFormField {}

extension NutrientRadioButtonFormFieldExtension
    on NutrientRadioButtonFormField {
  /// Field name
  external String get name;

  /// Selected option value
  external String? get value;

  /// Available options
  external JSArray get options;
}

/// Combo box form field (dropdown)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.FormFields.ComboBoxFormField.html
@JS()
@staticInterop
class NutrientComboBoxFormField {}

extension NutrientComboBoxFormFieldExtension on NutrientComboBoxFormField {
  /// Field name
  external String get name;

  /// Selected value
  external String? get value;

  /// Available options
  external JSArray get options;

  /// Is editable
  external bool get isEditable;
}

/// List box form field
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.FormFields.ListBoxFormField.html
@JS()
@staticInterop
class NutrientListBoxFormField {}

extension NutrientListBoxFormFieldExtension on NutrientListBoxFormField {
  /// Field name
  external String get name;

  /// Selected values
  external JSArray get values;

  /// Available options
  external JSArray get options;

  /// Allow multiple selection
  external bool get isMultiSelect;
}

/// Signature form field
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.FormFields.SignatureFormField.html
@JS()
@staticInterop
class NutrientSignatureFormField {}

extension NutrientSignatureFormFieldExtension on NutrientSignatureFormField {
  /// Field name
  external String get name;

  /// Is signed
  external bool get isSigned;

  /// Signature info
  external NutrientSignatureInfo? get signatureInfo;
}

/// Button form field
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.FormFields.ButtonFormField.html
@JS()
@staticInterop
class NutrientButtonFormField {}

extension NutrientButtonFormFieldExtension on NutrientButtonFormField {
  /// Field name
  external String get name;

  /// Button label
  external String? get label;

  /// Action triggered on click
  external NutrientAction? get action;
}

// ============================================================================
// Toolbar & UI Types
// ============================================================================

/// Toolbar item configuration
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.ToolbarItem.html
@JS()
@staticInterop
class NutrientToolbarItem {}

extension NutrientToolbarItemExtension on NutrientToolbarItem {
  /// Item type
  external String get type;

  /// Item ID
  external String? get id;

  /// Item title
  external String? get title;

  /// Icon
  external String? get icon;

  /// Is disabled
  external bool? get disabled;

  /// Is selected
  external bool? get selected;
}

/// Custom overlay item
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.CustomOverlayItem.html
@JS()
@staticInterop
class NutrientCustomOverlayItem {}

extension NutrientCustomOverlayItemExtension on NutrientCustomOverlayItem {
  /// Item ID
  external String get id;

  /// Item title
  external String? get title;

  /// Item node (DOM element)
  external JSAny? get node;

  /// Position on page
  external NutrientPoint? get position;

  /// Page index
  external int get pageIndex;
}

// ============================================================================
// Font Types
// ============================================================================

/// Font definition
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Font.html
@JS()
@staticInterop
class NutrientFont {}

extension NutrientFontExtension on NutrientFont {
  /// Font name
  external String get name;

  /// Font family
  external String? get family;

  /// Font size
  external num? get size;

  /// Font weight
  external String? get weight;

  /// Font style (italic, normal)
  external String? get style;
}

// ============================================================================
// Inset Type
// ============================================================================

/// Inset (padding/margin)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Geometry.Inset.html
@JS()
@staticInterop
class NutrientInset {}

extension NutrientInsetExtension on NutrientInset {
  /// Top inset
  external num get top;

  /// Right inset
  external num get right;

  /// Bottom inset
  external num get bottom;

  /// Left inset
  external num get left;
}

// ============================================================================
// Document Permissions
// ============================================================================

/// Document permissions
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.DocumentPermissions.html
@JS()
@staticInterop
class NutrientDocumentPermissions {}

extension NutrientDocumentPermissionsExtension on NutrientDocumentPermissions {
  /// Can print
  external bool get canPrint;

  /// Can modify
  external bool get canModify;

  /// Can copy
  external bool get canCopy;

  /// Can annotate
  external bool get canAnnotate;

  /// Can fill forms
  external bool get canFillForms;

  /// Can extract content
  external bool get canExtractContent;

  /// Can assemble document
  external bool get canAssembleDocument;

  /// Can print high quality
  external bool get canPrintHighQuality;
}

// ============================================================================
// Document Comparison Types
// ============================================================================

/// Document comparison result
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.ComparisonOperation.html
@JS()
@staticInterop
class NutrientComparisonOperation {}

extension NutrientComparisonOperationExtension on NutrientComparisonOperation {
  /// Operation type (insert, delete, equal)
  external String get type;

  /// Text content
  external String get text;

  /// Rectangles where the change occurs
  external JSArray? get rects;

  /// Page index
  external int get pageIndex;
}

/// Text comparison state
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.TextComparisonState.html
@JS()
@staticInterop
class NutrientTextComparisonState {}

extension NutrientTextComparisonStateExtension on NutrientTextComparisonState {
  /// Is comparing
  external bool get isComparing;

  /// Document A page index
  external int? get documentAPageIndex;

  /// Document B page index
  external int? get documentBPageIndex;

  /// Comparison mode
  external String? get comparisonMode;
}

// ============================================================================
// Content Editing Types
// ============================================================================

/// Content editing session
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.ContentEditing.html
@JS()
@staticInterop
class NutrientContentEditingSession {}

extension NutrientContentEditingSessionExtension
    on NutrientContentEditingSession {
  /// End the content editing session
  external JSPromise end();

  /// Get editable content on page
  external JSPromise getEditableContent(int pageIndex);
}

// ============================================================================
// OCG Layers Types
// ============================================================================

/// Optional Content Group (layer)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Layer.html
@JS()
@staticInterop
class NutrientLayer {}

extension NutrientLayerExtension on NutrientLayer {
  /// Layer ID
  external String get id;

  /// Layer name
  external String get name;

  /// Is visible
  external bool get isVisible;

  /// Parent layer ID
  external String? get parentId;

  /// Intent (View or Design)
  external String? get intent;
}

/// Layer visibility state
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.LayersVisibilityState.html
@JS()
@staticInterop
class NutrientLayersVisibilityState {}

extension NutrientLayersVisibilityStateExtension
    on NutrientLayersVisibilityState {
  /// Visible layer IDs
  external JSArray get visibleLayerIds;

  /// Base state (ON, OFF, or Unchanged)
  external String get baseState;
}

// ============================================================================
// Attachment Types
// ============================================================================

/// File attachment
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Attachment.html
@JS()
@staticInterop
class NutrientAttachment {}

extension NutrientAttachmentExtension on NutrientAttachment {
  /// Attachment ID
  external String get id;

  /// File name
  external String get name;

  /// Description
  external String? get description;

  /// File size in bytes
  external int? get size;

  /// Content type (MIME type)
  external String? get contentType;
}

/// Embedded file
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.EmbeddedFile.html
@JS()
@staticInterop
class NutrientEmbeddedFile {}

extension NutrientEmbeddedFileExtension on NutrientEmbeddedFile {
  /// File name
  external String get name;

  /// Description
  external String? get description;

  /// File content as ArrayBuffer
  external JSAny get content;

  /// File size in bytes
  external int get size;

  /// Creation date
  external String? get creationDate;

  /// Modification date
  external String? get modificationDate;
}

// ============================================================================
// Electronic Signature Types
// ============================================================================

/// Electronic signature configuration
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.ElectronicSignatureConfiguration.html
@JS()
@staticInterop
class NutrientElectronicSignatureConfiguration {}

extension NutrientElectronicSignatureConfigurationExtension
    on NutrientElectronicSignatureConfiguration {
  /// Signature mode (draw, type, or image)
  external String get mode;

  /// Color presets
  external JSArray? get colorPresets;

  /// Signing fonts
  external JSArray? get signingFonts;
}

// ============================================================================
// Measurement Types
// ============================================================================

/// Measurement scale
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.MeasurementScale.html
@JS()
@staticInterop
class NutrientMeasurementScale {}

extension NutrientMeasurementScaleExtension on NutrientMeasurementScale {
  /// Unit from (measurement unit)
  external String get unitFrom;

  /// Unit to (display unit)
  external String get unitTo;

  /// Scale factor
  external num get scale;

  /// Scale description
  external String? get description;
}

/// Measurement precision
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.MeasurementPrecision.html
@JS()
@staticInterop
class NutrientMeasurementPrecision {}

extension NutrientMeasurementPrecisionExtension
    on NutrientMeasurementPrecision {
  /// Decimal places
  external int get decimalPlaces;

  /// Unit
  external String get unit;
}

/// Measurement value reference point
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.MeasurementValueConfiguration.html
@JS()
@staticInterop
class NutrientMeasurementValueConfiguration {}

extension NutrientMeasurementValueConfigurationExtension
    on NutrientMeasurementValueConfiguration {
  /// Scale
  external NutrientMeasurementScale? get scale;

  /// Precision
  external NutrientMeasurementPrecision? get precision;
}

// ============================================================================
// Print Configuration Types
// ============================================================================

/// Print configuration options
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.PrintConfiguration.html
@JS()
@staticInterop
class NutrientPrintConfiguration {}

extension NutrientPrintConfigurationExtension on NutrientPrintConfiguration {
  /// Print mode (export or native)
  external String? get mode;

  /// Page ranges to print
  external JSArray? get pageRanges;

  /// Include annotations
  external bool? get includeAnnotations;

  /// Include comments
  external bool? get includeComments;
}

// ============================================================================
// Mention & Collaboration Types
// ============================================================================

/// Mentionable user
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.MentionableUser.html
@JS()
@staticInterop
class NutrientMentionableUser {}

extension NutrientMentionableUserExtension on NutrientMentionableUser {
  /// User ID
  external String get id;

  /// User name/display name
  external String get name;

  /// User email
  external String? get email;

  /// Avatar URL
  external String? get avatarUrl;
}

// ============================================================================
// Form Option Types
// ============================================================================

/// Form field option (for combo boxes, list boxes, radio buttons)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.FormOption.html
@JS()
@staticInterop
class NutrientFormOption {}

extension NutrientFormOptionExtension on NutrientFormOption {
  /// Option label (displayed text)
  external String get label;

  /// Option value (internal value)
  external String get value;

  /// Is selected by default
  external bool? get isSelected;
}

// ============================================================================
// Annotation Preset Types
// ============================================================================

/// Annotation preset configuration
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.AnnotationPreset.html
@JS()
@staticInterop
class NutrientAnnotationPreset {}

extension NutrientAnnotationPresetExtension on NutrientAnnotationPreset {
  /// Preset ID
  external String get id;

  /// Preset name
  external String? get name;

  /// Preset configuration
  external JSAny get configuration;
}

// ============================================================================
// Custom Renderer Types
// ============================================================================

/// Custom annotation renderer
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.CustomRenderers.html
@JS()
@staticInterop
class NutrientCustomRenderers {}

extension NutrientCustomRenderersExtension on NutrientCustomRenderers {
  /// Annotation renderer function
  external JSFunction? get Annotation;

  /// Comment renderer function
  external JSFunction? get Comment;

  /// Thumbnail renderer function
  external JSFunction? get Thumbnail;
}

// ============================================================================
// Instant (Real-time Collaboration) Types
// ============================================================================

/// Instant document layer
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Instant.Layer.html
@JS()
@staticInterop
class NutrientInstantLayer {}

extension NutrientInstantLayerExtension on NutrientInstantLayer {
  /// Layer ID
  external String get id;

  /// Layer name
  external String? get name;

  /// Is editable
  external bool get isEditable;

  /// Creator user ID
  external String? get creatorUserId;
}

/// Instant synchronization status
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Instant.SyncStatus.html
@JS()
@staticInterop
class NutrientInstantSyncStatus {}

extension NutrientInstantSyncStatusExtension on NutrientInstantSyncStatus {
  /// Is syncing
  external bool get isSyncing;

  /// Has unsaved changes
  external bool get hasUnsavedChanges;

  /// Last sync timestamp
  external String? get lastSyncTimestamp;
}

// ============================================================================
// Document Operation Types
// ============================================================================

/// Document operation (for page manipulation)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.DocumentOperation.html
@JS()
@staticInterop
class NutrientDocumentOperation {}

extension NutrientDocumentOperationExtension on NutrientDocumentOperation {
  /// Operation type (rotate, duplicate, remove, move, etc.)
  external String get type;

  /// Page indexes
  external JSArray? get pageIndexes;

  /// Rotation angle (for rotate operation)
  external int? get rotateBy;

  /// Destination index (for move operation)
  external int? get beforePageIndex;

  /// Source document (for import operation)
  external JSAny? get document;
}

// ============================================================================
// Export Configuration Types
// ============================================================================

/// PDF export flags
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.ExportPDFFlags.html
@JS()
@staticInterop
class NutrientExportPDFFlags {}

extension NutrientExportPDFFlagsExtension on NutrientExportPDFFlags {
  /// Include annotations
  external bool? get includeAnnotations;

  /// Include comments
  external bool? get includeComments;

  /// Flatten annotations
  external bool? get flatten;

  /// Incremental (preserve structure)
  external bool? get incremental;

  /// Save mode
  external String? get saveMode;
}

// ============================================================================
// Instant JSON Types
// ============================================================================

/// Instant JSON export version
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.InstantJSON.html
@JS()
@staticInterop
class NutrientInstantJSON {}

extension NutrientInstantJSONExtension on NutrientInstantJSON {
  /// Format version
  external int get format;

  /// Annotations
  external JSArray get annotations;

  /// Form field values
  external JSArray? get formFieldValues;

  /// Bookmarks
  external JSArray? get bookmarks;
}

// ============================================================================
// Stamp Annotation Template Types
// ============================================================================

/// Stamp annotation template
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.StampAnnotationTemplate.html
@JS()
@staticInterop
class NutrientStampAnnotationTemplate {}

extension NutrientStampAnnotationTemplateExtension
    on NutrientStampAnnotationTemplate {
  /// Template ID
  external String get id;

  /// Template title
  external String get title;

  /// Stamp type
  external String? get stampType;

  /// Stamp image URL
  external String? get imageUrl;

  /// Stamp size
  external NutrientSize? get size;
}

// ============================================================================
// Text Selection Types
// ============================================================================

/// Text selection
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.TextSelection.html
@JS()
@staticInterop
class NutrientTextSelection {}

extension NutrientTextSelectionExtension on NutrientTextSelection {
  /// Selected text
  external String get text;

  /// Start page index
  external int get startPageIndex;

  /// End page index
  external int get endPageIndex;

  /// Bounding rectangles
  external JSArray get rects;

  /// Text lines
  external JSArray? get textLines;
}

// ============================================================================
// Highlight State Types
// ============================================================================

/// Highlight state for text
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.HighlightState.html
@JS()
@staticInterop
class NutrientHighlightState {}

extension NutrientHighlightStateExtension on NutrientHighlightState {
  /// Highlight ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Rectangles
  external JSArray get rects;

  /// Color
  external NutrientColor? get color;
}

// ============================================================================
// AI Document Services Types
// ============================================================================

/// AI document analysis result
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.AI.DocumentAnalysisResult.html
@JS()
@staticInterop
class NutrientAIDocumentAnalysisResult {}

extension NutrientAIDocumentAnalysisResultExtension
    on NutrientAIDocumentAnalysisResult {
  /// Analysis result text
  external String get result;

  /// Confidence score
  external num? get confidence;

  /// Categories identified
  external JSArray? get categories;
}

/// AI document comparison result
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.AI.DocumentComparisonResult.html
@JS()
@staticInterop
class NutrientAIDocumentComparisonResult {}

extension NutrientAIDocumentComparisonResultExtension
    on NutrientAIDocumentComparisonResult {
  /// Comparison summary
  external String get summary;

  /// Changes detected
  external JSArray get changes;

  /// Similarity score
  external num? get similarityScore;
}

/// AI document tagging result
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.AI.DocumentTaggingResult.html
@JS()
@staticInterop
class NutrientAIDocumentTaggingResult {}

extension NutrientAIDocumentTaggingResultExtension
    on NutrientAIDocumentTaggingResult {
  /// Suggested tags
  external JSArray get tags;

  /// Confidence scores for each tag
  external JSArray? get confidenceScores;
}

// ============================================================================
// History Types (Undo/Redo)
// ============================================================================

/// History entry
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.History.html
@JS()
@staticInterop
class NutrientHistoryEntry {}

extension NutrientHistoryEntryExtension on NutrientHistoryEntry {
  /// Entry ID
  external String get id;

  /// Entry type
  external String get type;

  /// Timestamp
  external String get timestamp;

  /// User who made the change
  external String? get userId;

  /// Description
  external String? get description;
}

// ============================================================================
// Watermark Types
// ============================================================================

/// Watermark configuration
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Watermark.html
@JS()
@staticInterop
class NutrientWatermark {}

extension NutrientWatermarkExtension on NutrientWatermark {
  /// Watermark text
  external String? get text;

  /// Watermark image URL
  external String? get imageUrl;

  /// Position
  external String? get position;

  /// Opacity (0-1)
  external num? get opacity;

  /// Rotation angle
  external num? get rotation;

  /// Font
  external NutrientFont? get font;

  /// Color
  external NutrientColor? get color;
}

// ============================================================================
// Document Descriptor Types
// ============================================================================

/// Document descriptor for loading documents
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.DocumentDescriptor.html
@JS()
@staticInterop
class NutrientDocumentDescriptor {}

extension NutrientDocumentDescriptorExtension on NutrientDocumentDescriptor {
  /// Document URL or ArrayBuffer
  external JSAny get document;

  /// Document ID
  external String? get documentId;

  /// Base URL for relative links
  external String? get baseUrl;

  /// JWT token for authentication
  external String? get jwt;
}

// ============================================================================
// Comparison Service Types
// ============================================================================

/// Text comparison instance
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.TextComparisonInstance.html
@JS()
@staticInterop
class NutrientTextComparisonInstance {}

extension NutrientTextComparisonInstanceExtension
    on NutrientTextComparisonInstance {
  /// Get comparison operations
  external JSPromise getOperations();

  /// Navigate to next change
  external JSPromise nextChange();

  /// Navigate to previous change
  external JSPromise previousChange();

  /// Stop comparison
  external JSPromise stop();
}

/// Document comparison result
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.DocumentComparisonResult.html
@JS()
@staticInterop
class NutrientDocumentComparisonResult {}

extension NutrientDocumentComparisonResultExtension
    on NutrientDocumentComparisonResult {
  /// Document A ID
  external String get documentAId;

  /// Document B ID
  external String get documentBId;

  /// Comparison operations
  external JSArray get operations;

  /// Comparison metadata
  external JSAny? get metadata;
}

/// AI comparison API
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.AIComparisonAPI.html
@JS()
@staticInterop
class NutrientAIComparisonAPI {}

extension NutrientAIComparisonAPIExtension on NutrientAIComparisonAPI {
  /// Compare documents using AI
  external JSPromise compareDocuments(JSAny options);

  /// Get comparison summary
  external JSPromise getSummary(String comparisonId);
}

/// AI document comparison service
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.AIDocumentComparisonService.html
@JS()
@staticInterop
class NutrientAIDocumentComparisonService {}

extension NutrientAIDocumentComparisonServiceExtension
    on NutrientAIDocumentComparisonService {
  /// Start AI-powered comparison
  external JSPromise startComparison(JSAny configuration);

  /// Get comparison results
  external JSPromise getResults();

  /// Stop comparison service
  external JSPromise stop();
}

// ============================================================================
// Choice Form Field (Base for ComboBox/ListBox)
// ============================================================================

/// Choice form field (base for combo box and list box)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.FormFields.ChoiceFormField.html
@JS()
@staticInterop
class NutrientChoiceFormField {}

extension NutrientChoiceFormFieldExtension on NutrientChoiceFormField {
  /// Field name
  external String get name;

  /// Selected values
  external JSArray get values;

  /// Available options
  external JSArray get options;

  /// Allow custom text input
  external bool? get allowEdit;

  /// Commit on selection change
  external bool? get commitOnSelChange;
}

// ============================================================================
// Go To Embedded Action
// ============================================================================

/// Go to embedded action (navigate to embedded document)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Actions.GoToEmbeddedAction.html
@JS()
@staticInterop
class NutrientGoToEmbeddedAction {}

extension NutrientGoToEmbeddedActionExtension on NutrientGoToEmbeddedAction {
  /// Target embedded file
  external String get targetFile;

  /// Target page index
  external int? get pageIndex;

  /// New window
  external bool? get newWindow;
}

/// Go to remote action (navigate to external document)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Actions.GoToRemoteAction.html
@JS()
@staticInterop
class NutrientGoToRemoteAction {}

extension NutrientGoToRemoteActionExtension on NutrientGoToRemoteAction {
  /// Remote file path
  external String get filePath;

  /// Target page index
  external int? get pageIndex;

  /// New window
  external bool? get newWindow;
}

// ============================================================================
// Free Text Annotation
// ============================================================================

/// Free text annotation (text box)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.FreeTextAnnotation.html
@JS()
@staticInterop
class NutrientFreeTextAnnotation {}

extension NutrientFreeTextAnnotationExtension on NutrientFreeTextAnnotation {
  /// Annotation ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Bounding box
  external NutrientRect get boundingBox;

  /// Text content
  external String? get text;

  /// Font
  external NutrientFont? get font;

  /// Font color
  external NutrientColor? get fontColor;

  /// Background color
  external NutrientColor? get backgroundColor;

  /// Border color
  external NutrientColor? get borderColor;

  /// Text alignment (left, center, right)
  external String? get textAlignment;

  /// Horizontal alignment (left, center, right)
  external String? get horizontalAlign;

  /// Vertical alignment (top, center, bottom)
  external String? get verticalAlign;
}

// ============================================================================
// Unknown Annotation (for unsupported types)
// ============================================================================

/// Unknown annotation type
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Annotations.UnknownAnnotation.html
@JS()
@staticInterop
class NutrientUnknownAnnotation {}

extension NutrientUnknownAnnotationExtension on NutrientUnknownAnnotation {
  /// Annotation ID
  external String get id;

  /// Page index
  external int get pageIndex;

  /// Additional properties
  external JSAny? get additionalProperties;
}

// ============================================================================
// Page Range Type
// ============================================================================

/// Page range specification
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.PageRange.html
@JS()
@staticInterop
class NutrientPageRange {}

extension NutrientPageRangeExtension on NutrientPageRange {
  /// Start page index
  external int get start;

  /// End page index
  external int get end;
}

// ============================================================================
// Ink Eraser Mode
// ============================================================================

/// Ink eraser configuration
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.InkEraserMode.html
@JS()
@staticInterop
class NutrientInkEraserMode {}

extension NutrientInkEraserModeExtension on NutrientInkEraserMode {
  /// Eraser mode type (point, stroke)
  external String get mode;

  /// Eraser size
  external num? get size;
}

// ============================================================================
// Annotation Border Style
// ============================================================================

/// Annotation border style
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.BorderStyle.html
@JS()
@staticInterop
class NutrientBorderStyle {}

extension NutrientBorderStyleExtension on NutrientBorderStyle {
  /// Border width
  external num get width;

  /// Border style (solid, dashed, beveled, inset, underline)
  external String get style;

  /// Dash array for dashed borders
  external JSArray? get dashArray;
}

// ============================================================================
// Line Ending Style
// ============================================================================

/// Line ending style (for line/polyline annotations)
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.LineEndingStyle.html
@JS()
@staticInterop
class NutrientLineEndingStyle {}

extension NutrientLineEndingStyleExtension on NutrientLineEndingStyle {
  /// Start line ending (None, OpenArrow, ClosedArrow, Square, Circle, etc.)
  external String? get start;

  /// End line ending
  external String? get end;
}

// ============================================================================
// Blend Mode
// ============================================================================

/// Blend mode for annotations
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.BlendMode.html
@JS()
@staticInterop
class NutrientBlendMode {}

extension NutrientBlendModeExtension on NutrientBlendMode {
  /// Blend mode name (normal, multiply, screen, overlay, etc.)
  external String get mode;
}
