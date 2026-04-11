///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'dart:js_interop';
import 'nutrient_web_types.dart';

// ============================================================================
// Nutrient Web SDK JavaScript Interop Bindings
// ============================================================================
//
// These bindings provide type-safe access to the Nutrient Web SDK.
// For complete API documentation, see:
// - https://www.nutrient.io/api/web/NutrientViewer.html
// - https://www.nutrient.io/api/web/NutrientViewer.Instance.html
//
// These bindings use the "NutrientViewer" global namespace.
//
// Type definitions are available in nutrient_web_types.dart

/// Nutrient Web SDK global static object (NutrientViewer namespace)
///
/// Accesses the NutrientViewer global namespace (for @nutrient-sdk/viewer v1.0+).
///
/// The global namespace changed from 'PSPDFKit' to 'NutrientViewer' starting
/// with @nutrient-sdk/viewer v1.0.0.
@JS('NutrientViewer')
external NutrientWebStatic get nutrient;

/// Legacy PSPDFKit global for backwards compatibility
///
/// Use this if you're loading an older version of the SDK that still uses
/// the PSPDFKit namespace instead of NutrientViewer.
@JS('PSPDFKit')
external NutrientWebStatic get pspdfkit;

/// Nutrient Web SDK static class interface
///
/// Provides static methods for loading and managing Nutrient instances.
@JS()
@staticInterop
class NutrientWebStatic {}

extension NutrientWebStaticExtension on NutrientWebStatic {
  // ========================================================================
  // Static Properties
  // ========================================================================

  /// Get Nutrient Web SDK version string
  external String get version;

  /// Default annotation presets configuration
  external JSAny get defaultAnnotationPresets;

  /// Default annotations sidebar content
  external JSArray get defaultAnnotationsSidebarContent;

  /// Default document editor footer items
  external JSArray get defaultDocumentEditorFooterItems;

  /// Default document editor toolbar items
  external JSArray get defaultDocumentEditorToolbarItems;

  /// Default editable annotation types
  external JSArray get defaultEditableAnnotationTypes;

  /// Default electronic signature color presets
  external JSArray get defaultElectronicSignatureColorPresets;

  /// Default electronic signature creation modes
  external JSArray get defaultElectronicSignatureCreationModes;

  /// Default signing fonts
  external JSArray get defaultSigningFonts;

  /// Default stamp annotation templates
  external JSArray get defaultStampAnnotationTemplates;

  /// Default text comparison inner toolbar items
  external JSArray get defaultTextComparisonInnerToolbarItems;

  /// Default text comparison toolbar items
  external JSArray get defaultTextComparisonToolbarItems;

  /// Default toolbar items
  external JSArray get defaultToolbarItems;

  // ========================================================================
  // Static Methods
  // ========================================================================

  /// Load a Nutrient instance
  ///
  /// Returns a Promise that resolves to a NutrientWebInstance
  ///
  /// Example:
  /// ```dart
  /// final config = {
  ///   'container': containerElement,
  ///   'document': 'document.pdf',
  ///   'licenseKey': 'YOUR_LICENSE_KEY',
  /// }.jsify();
  /// final promise = nutrient.load(config);
  /// final instance = await promise.toDart as NutrientWebInstance;
  /// ```
  external JSPromise load(JSAny config);

  /// Unload a Nutrient instance
  ///
  /// Cleans up the instance and releases resources.
  external void unload(NutrientWebInstance instance);

  /// Preload the Nutrient Web Worker
  ///
  /// Optionally preload the Web Worker to improve initial load performance.
  external JSPromise preloadWorker(JSAny? config);

  /// Load text comparison instance
  ///
  /// Asynchronously loads a text comparison instance
  external JSPromise loadTextComparison(JSAny config);

  /// Generate Instant ID
  ///
  /// Creates unique identifiers for annotations, form fields, bookmarks, or comments
  external String generateInstantId();

  /// Convert to PDF
  ///
  /// Converts files to PDF format with optional conformance levels
  external JSPromise convertToPDF(JSAny options);

  /// Convert to Office
  ///
  /// Converts documents to DOCX, XLSX, or PPTX formats
  external JSPromise convertToOffice(JSAny options);

  /// Build document
  ///
  /// Performs processing via Nutrient Backend Build API for document operations
  external JSPromise build(JSAny options);

  /// Populate document template
  ///
  /// Populates template fields with provided data
  external JSPromise populateDocumentTemplate(JSAny options);

  /// View state from open parameters
  ///
  /// Retrieves view state from URL parameters
  external JSAny viewStateFromOpenParameters(String parameters);

  // Type guard methods
  /// Check if result is AI document analysis result
  external bool isAIDocumentAnalysisResult(JSAny result);

  /// Check if result is AI document comparison result
  external bool isAIDocumentComparisonResult(JSAny result);

  /// Check if result is AI document tagging result
  external bool isAIDocumentTaggingResult(JSAny result);

  /// Check if response is signature callback response raw
  external bool isSignatureCallbackResponseRaw(JSAny response);
}

/// Nutrient instance interface
///
/// Represents a loaded Nutrient instance. This is the main object for
/// interacting with the PDF viewer.
///
/// See: https://www.nutrient.io/api/web/PSPDFKit.Instance.html
@JS()
@staticInterop
class NutrientWebInstance {}

extension NutrientWebInstanceExtension on NutrientWebInstance {
  // ========================================================================
  // Properties
  // ========================================================================

  /// Current page index (0-based).
  ///
  /// **Note:** This property doesn't exist on the Instance class.
  /// Use `viewState.currentPageIndex` instead.
  ///
  /// Returns `null` since this property is not available on Instance.
  @Deprecated('Use viewState.currentPageIndex instead')
  external int? get currentPageIndex;

  /// Total number of pages in the document.
  ///
  /// Returns `null` if the property is not available on the current SDK version.
  /// The Nutrient Viewer SDK may expose this as `totalPageCount` or `pageCount`
  /// depending on version.
  external int? get totalPageCount;

  /// Alias for [totalPageCount] — some SDK versions use `pageCount`.
  external int? get pageCount;

  /// Current view state
  ///
  /// Returns an immutable ViewState object containing current page index,
  /// zoom level, scroll position, etc.
  external NutrientViewState get viewState;

  /// Document ID
  external String? get documentId;

  /// Content document (for Instant collaboration)
  external JSAny? get contentDocument;

  /// Content window (for Instant collaboration)
  external JSAny? get contentWindow;

  /// Form field values
  ///
  /// Returns an Immutable.List of form field values
  external JSArray? get formFieldValues;

  /// Annotations
  ///
  /// Returns an Immutable.List of annotations
  external JSArray? get annotations;

  /// Bookmarks
  ///
  /// Returns an Immutable.List of bookmarks
  external JSArray? get bookmarks;

  /// Text lines
  ///
  /// Returns an Immutable.List of text lines for the current page
  external JSArray? get textLines;

  // Additional Properties (from complete API)

  /// Annotation creator name
  external String? get annotationCreatorName;

  /// Annotation presets configuration
  external JSAny? get annotationPresets;

  /// Connected clients (for Instant collaboration)
  external JSArray? get connectedClients;

  /// Current annotation preset
  external String? get currentAnnotationPreset;

  /// Current zoom level
  external num get currentZoomLevel;

  /// Disable point snapping for measurements
  external bool get disablePointSnapping;

  /// Document editor footer items
  external JSArray? get documentEditorFooterItems;

  /// Document editor toolbar items
  external JSArray? get documentEditorToolbarItems;

  /// Editable annotation types
  external JSArray? get editableAnnotationTypes;

  /// Current locale
  external String get locale;

  /// Maximum zoom level
  external num get maximumZoomLevel;

  /// Minimum zoom level
  external num get minimumZoomLevel;

  /// Search state
  external NutrientSearchState? get searchState;

  /// Stamp annotation templates
  external JSArray? get stampAnnotationTemplates;

  /// Toolbar items
  external JSArray? get toolbarItems;

  /// Zoom step increment
  external num get zoomStep;

  // ========================================================================
  // View State & Navigation Methods
  // ========================================================================

  /// Set view state
  ///
  /// Updates the current view state (page, zoom, scroll position, etc.)
  ///
  /// Can accept a ViewState object or a function that receives current state
  ///
  /// Example:
  /// ```dart
  /// final newState = {
  ///   'currentPageIndex': 5,
  ///   'zoom': 'FIT_TO_WIDTH',
  /// }.jsify();
  /// instance.setViewState(newState);
  /// ```
  external void setViewState(JSAny viewStateOrFunction);

  /// Jump to rectangle
  ///
  /// Navigate to a specific rectangle on a page
  external void jumpToRect(int pageIndex, NutrientRect rect);

  /// Jump and zoom to rectangle
  ///
  /// Navigate and zoom to a specific rectangle on a page
  external void jumpAndZoomToRect(int pageIndex, NutrientRect rect);

  /// Get page info for index
  ///
  /// Get information about a specific page (dimensions, rotation, etc.)
  ///
  /// Returns null if page index is out of bounds
  external NutrientPageInfo? pageInfoForIndex(int pageIndex);

  // ========================================================================
  // Toolbar & UI Methods
  // ========================================================================

  /// Set toolbar items
  ///
  /// Customize the toolbar with specific items
  ///
  /// Example:
  /// ```dart
  /// final items = [
  ///   {'type': 'sidebar-thumbnails'},
  ///   {'type': 'pager'},
  ///   {'type': 'zoom-out'},
  ///   {'type': 'zoom-in'},
  /// ].jsify();
  /// await instance.setToolbarItems(items).toDart;
  /// ```
  external JSPromise setToolbarItems(JSAny items);

  /// Set custom overlay item
  ///
  /// Add a custom UI element to the viewer
  external JSPromise setCustomOverlayItem(JSAny item);

  /// Remove custom overlay item
  external JSPromise removeCustomOverlayItem(String itemId);

  // ========================================================================
  // Annotation Methods
  // ========================================================================

  /// Create annotation
  ///
  /// Add a new annotation to the document
  ///
  /// Example:
  /// ```dart
  /// final annotation = {
  ///   'pageIndex': 0,
  ///   'boundingBox': {'left': 100, 'top': 100, 'width': 200, 'height': 50},
  ///   'text': 'Note text',
  ///   'type': 'pspdfkit/text',
  /// }.jsify();
  /// await instance.create(annotation).toDart;
  /// ```
  external JSPromise create(JSAny annotation);

  /// Update annotation
  ///
  /// Modify an existing annotation
  external JSPromise update(JSAny annotation);

  /// Delete annotation
  ///
  /// Remove an annotation from the document
  external JSPromise delete(String annotationId);

  /// Get annotations for a page
  ///
  /// Returns an Immutable.List of annotations for the specified page
  external JSPromise getAnnotations(int pageIndex);

  /// Get selected annotations
  ///
  /// Returns an Immutable.List of currently selected annotations
  external JSPromise getSelectedAnnotations();

  /// Set selected annotations
  ///
  /// Select specific annotations by their IDs
  external JSPromise setSelectedAnnotations(JSArray annotationIds);

  /// Get overlapping annotations
  ///
  /// Find annotations that overlap with a given rectangle
  external JSPromise getOverlappingAnnotations(
      int pageIndex, NutrientRect rect);

  /// Set editing annotation
  ///
  /// Put an annotation into edit mode
  external JSPromise setEditingAnnotation(String? annotationId);

  /// Get markup annotation text
  ///
  /// Get the text content covered by a markup annotation
  external JSPromise getMarkupAnnotationText(String annotationId);

  /// Calculate fitting text annotation bounding box
  ///
  /// Calculate optimal size for a text annotation
  external JSPromise calculateFittingTextAnnotationBoundingBox(
      JSAny annotation);

  /// Group annotations
  ///
  /// Create a group from multiple annotations
  external JSPromise groupAnnotations(JSArray annotationIds);

  /// Delete annotations group
  ///
  /// Remove a group while keeping individual annotations
  external JSPromise deleteAnnotationsGroup(String groupId);

  /// Reset group
  ///
  /// Reset annotations in a group to their original state
  external JSPromise resetGroup(String groupId);

  /// Set group
  ///
  /// Assign annotations to a group
  external void setGroup(JSAny group);

  /// Get annotations groups
  ///
  /// Get all annotation groups
  ///
  /// Returns null if no groups exist
  external JSAny? getAnnotationsGroups();

  /// Export XFDF
  ///
  /// Export annotations and form fields as XFDF string
  external JSPromise exportXFDF(bool? ignorePageRotation);

  /// Import XFDF
  ///
  /// Import annotations and form fields from XFDF string
  external JSPromise importXFDF(String xfdf);

  // ========================================================================
  // Annotation Configuration Methods
  // ========================================================================

  /// Set annotation creator name
  ///
  /// Set the creator name for new annotations
  external void setAnnotationCreatorName(String name);

  /// Set annotation presets
  ///
  /// Configure default annotation settings
  external JSPromise setAnnotationPresets(JSAny presets);

  /// Set current annotation preset
  ///
  /// Select the active annotation preset
  external JSPromise setCurrentAnnotationPreset(String presetId);

  /// Set is editable annotation
  ///
  /// Set whether an annotation can be edited
  external JSPromise setIsEditableAnnotation(JSFunction callback);

  /// Set is editable comment
  ///
  /// Set whether a comment can be edited
  external JSPromise setIsEditableComment(JSFunction callback);

  /// Set on annotation resize start
  ///
  /// Callback when annotation resizing begins
  external void setOnAnnotationResizeStart(JSFunction? callback);

  /// Set stamp annotation templates
  ///
  /// Configure available stamp templates
  external JSPromise setStampAnnotationTemplates(JSArray templates);

  /// Set ink signatures
  ///
  /// Configure available ink signatures for signing
  external JSPromise setInkSignatures(JSArray signatures);

  /// Set stored signatures
  ///
  /// Configure stored digital signatures
  external JSPromise setStoredSignatures(JSArray signatures);

  /// Set annotation toolbar items
  ///
  /// Configure annotation toolbar
  external JSPromise setAnnotationToolbarItems(JSArray items);

  /// Set editable annotation types
  ///
  /// Specify which annotation types can be edited
  external JSPromise setEditableAnnotationTypes(JSArray types);

  // ========================================================================
  // Form Field Methods
  // ========================================================================

  /// Get form fields
  ///
  /// Returns an Immutable.List of all form fields
  external JSPromise getFormFields();

  /// Get form field values
  ///
  /// Returns a Record<string, null | string | string[]> synchronously.
  /// The keys are the fully qualified form field names.
  external JSAny getFormFieldValues();

  /// Set form field values
  ///
  /// Update form field values. Accepts a Record<string, null | string | string[]>.
  /// Returns a Promise that resolves when the values have been set.
  ///
  /// Example:
  /// ```dart
  /// final values = {'Name_Last': 'Smith', 'City': 'Vienna'}.jsify();
  /// await instance.setFormFieldValues(values!).toDart;
  /// ```
  external JSPromise setFormFieldValues(JSAny values);

  // ========================================================================
  // Document Methods
  // ========================================================================

  /// Save document
  ///
  /// Saves all changes to the document
  ///
  /// Returns a Promise that resolves when save is complete
  external JSPromise save();

  /// Check if document has unsaved changes
  ///
  /// Returns true if there are unsaved changes
  external bool hasUnsavedChanges();

  /// Ensure changes saved
  ///
  /// Ensures specific changes are saved and returns the saved changes
  external JSPromise ensureChangesSaved(JSAny changes);

  /// Export PDF
  ///
  /// Export the PDF with specific options (flags)
  external JSPromise exportPDF(JSAny? flags);

  /// Export PDF with operations
  ///
  /// Export PDF after applying document operations
  external JSPromise exportPDFWithOperations(JSArray operations);

  /// Export Instant JSON
  ///
  /// Export annotations and changes as Instant JSON
  external JSPromise exportInstantJSON(int? version);

  /// Export Office document
  ///
  /// Export to Word, PowerPoint, or other Office formats
  external JSPromise exportOffice(JSAny options);

  /// Apply operations
  ///
  /// Apply document operations (rotate, duplicate, remove pages, etc.)
  external JSPromise applyOperations(JSAny operations);

  /// Apply redactions
  ///
  /// Apply all redaction annotations permanently
  external JSPromise applyRedactions();

  /// Get page info
  ///
  /// Get information about a specific page (dimensions, rotation, etc.)
  external JSPromise getPageInfo(int pageIndex);

  /// Render page as image
  ///
  /// Render a page to an image (canvas, data URL, or blob)
  external JSPromise renderPageAsImageURL(JSAny options);

  /// Render page as ArrayBuffer
  ///
  /// Render a page to an image as ArrayBuffer
  external JSPromise renderPageAsArrayBuffer(JSAny options);

  /// Get document permissions
  ///
  /// Get the document's permission flags
  external JSPromise getDocumentPermissions();

  /// Get document outline
  ///
  /// Get the document's table of contents
  external JSPromise getDocumentOutline();

  /// Set document outline
  ///
  /// Update the document's table of contents
  external JSPromise setDocumentOutline(JSArray? outline);

  /// Get bookmarks
  ///
  /// Get all document bookmarks
  external JSPromise getBookmarks();

  /// Get comments
  ///
  /// Get all comments in the document
  external JSPromise getComments();

  // ========================================================================
  // Search Methods
  // ========================================================================

  /// Search text
  ///
  /// Search for text in the document
  ///
  /// Returns a Promise that resolves to an Immutable.List of search results
  external JSPromise search(String query, JSAny? options);

  /// Start search
  ///
  /// Start an incremental search
  external void startSearch(String query, JSAny? options);

  /// Stop search
  ///
  /// Stop the current search
  external void stopSearch();

  /// Set search state
  ///
  /// Update the search UI state
  external JSPromise setSearchState(NutrientSearchState searchState);

  /// Start UI search
  ///
  /// Open search UI with query
  external JSPromise startUISearch(String query);

  /// Create redactions by search
  ///
  /// Create redaction annotations for search results
  external JSPromise createRedactionsBySearch(String query, JSAny? options);

  // ========================================================================
  // Text Selection Methods
  // ========================================================================

  /// Get text from rectangles
  ///
  /// Extract text from specific rectangles on a page
  external JSPromise getTextFromRects(int pageIndex, JSArray rects);

  /// Get selected text
  ///
  /// Get the currently selected text
  external String? getSelectedText();

  /// Get text selection
  ///
  /// Get the current text selection object
  external JSPromise getTextSelection();

  /// Text lines for page index
  ///
  /// Get all text lines for a specific page
  external JSPromise textLinesForPageIndex(int pageIndex);

  // ========================================================================
  // Event Methods
  // ========================================================================

  /// Add event listener
  ///
  /// Listen to Nutrient Web SDK events.
  ///
  /// For a complete list of available events, see:
  /// https://www.nutrient.io/api/web/enums/NutrientViewer.EventName.html
  ///
  /// Common events by category:
  ///
  /// **Annotation Events:**
  /// - `annotations.create` - Annotation created
  /// - `annotations.update` - Annotation modified
  /// - `annotations.delete` - Annotation deleted
  /// - `annotations.load` - Annotations loaded
  /// - `annotations.focus` - Annotation focused
  /// - `annotations.blur` - Annotation lost focus
  /// - `annotations.press` - Annotation pressed
  /// - `annotationSelection.change` - Selection changed
  ///
  /// **View State Events:**
  /// - `viewState.change` - View state changed
  /// - `viewState.currentPageIndex.change` - Page changed
  /// - `viewState.zoom.change` - Zoom level changed
  ///
  /// **Document Events:**
  /// - `document.change` - Document changed
  /// - `document.saveStateChange` - Save state changed
  ///
  /// **Form Events:**
  /// - `formFields.load` - Form fields loaded
  /// - `formFields.create` - Form field created
  /// - `formFields.update` - Form field updated
  /// - `formFields.delete` - Form field deleted
  /// - `formFieldValues.update` - Form field value changed
  ///
  /// **Other Events:**
  /// - `bookmarks.create/update/delete` - Bookmark changes
  /// - `comments.create/update/delete` - Comment changes
  /// - `textSelection.change` - Text selection changed
  /// - `search.stateChange` - Search state changed
  /// - `history.undo/redo` - Undo/redo actions
  /// - `page.press` - Page pressed
  ///
  /// Example:
  /// ```dart
  /// instance.addEventListener('annotations.create', ((JSAny event) {
  ///   debugPrint('Annotation created');
  /// }).toJS);
  /// ```
  external void addEventListener(String event, JSFunction callback);

  /// Remove event listener
  ///
  /// Remove a previously registered event listener.
  ///
  /// **Important:** You must pass the exact same [JSFunction] reference
  /// that was used when calling [addEventListener].
  ///
  /// Example:
  /// ```dart
  /// // Store the handler reference
  /// final handler = ((JSAny event) {
  ///   debugPrint('Annotation created');
  /// }).toJS;
  ///
  /// // Add listener
  /// instance.addEventListener('annotations.create', handler);
  ///
  /// // Later, remove listener
  /// instance.removeEventListener('annotations.create', handler);
  /// ```
  external void removeEventListener(String event, JSFunction callback);

  // ========================================================================
  // Instant (Collaboration) Methods
  // ========================================================================

  /// Sync annotations
  ///
  /// Manually trigger annotation synchronization (for Instant)
  external JSPromise syncAnnotations();

  /// Get instant client
  ///
  /// Get the Instant client instance (for collaboration features)
  external NutrientInstantClient? getInstantClient();

  // ========================================================================
  // Coordinate Transformation Methods
  // ========================================================================

  /// Transform page coordinates to client (viewport) coordinates
  ///
  /// Convert PDF page coordinates to screen coordinates
  external NutrientPoint transformPageToClientSpace(
      NutrientPoint pagePoint, int pageIndex);

  /// Transform client (viewport) coordinates to page coordinates
  ///
  /// Convert screen coordinates to PDF page coordinates
  external NutrientPoint transformClientToPageSpace(
      NutrientPoint clientPoint, int pageIndex);

  /// Transform content page coordinates to client coordinates
  ///
  /// Convert coordinates in the content coordinate system to screen coordinates
  external NutrientPoint transformContentPageToClientSpace(
      NutrientPoint pagePoint, int pageIndex);

  /// Transform client coordinates to content page coordinates
  ///
  /// Convert screen coordinates to content coordinate system
  external NutrientPoint transformContentClientToPageSpace(
      NutrientPoint clientPoint, int pageIndex);

  /// Transform page coordinates to raw space
  ///
  /// Convert page coordinates to raw (unrotated) coordinate system
  external NutrientPoint transformPageToRawSpace(
      NutrientPoint pagePoint, int pageIndex);

  /// Transform raw space coordinates to page coordinates
  ///
  /// Convert raw (unrotated) coordinates to page coordinate system
  external NutrientPoint transformRawToPageSpace(
      NutrientPoint rawPoint, int pageIndex);

  // ========================================================================
  // UI Customization Methods
  // ========================================================================

  /// Set custom renderers
  ///
  /// Customize how annotations or UI elements are rendered
  external void setCustomRenderers(JSAny renderers);

  /// Set custom UI configuration
  ///
  /// Configure custom UI behaviors
  external JSPromise setCustomUIConfiguration(JSAny config);

  /// Toggle clipboard actions
  ///
  /// Enable/disable clipboard operations
  external void toggleClipboardActions(bool enabled);

  /// Set document editor toolbar items
  ///
  /// Configure document editor toolbar
  external JSPromise setDocumentEditorToolbarItems(JSArray items);

  /// Set document editor footer items
  ///
  /// Configure document editor footer
  external JSPromise setDocumentEditorFooterItems(JSArray items);

  // ========================================================================
  // Signature & Verification Methods
  // ========================================================================

  /// Get signatures info
  ///
  /// Get information about digital signatures in the document
  external JSPromise getSignaturesInfo();

  /// Get stored signatures
  ///
  /// Get available stored signatures
  external JSPromise getStoredSignatures();

  /// Get ink signatures
  ///
  /// Get available ink signatures
  external JSPromise getInkSignatures();

  /// Sign document
  ///
  /// Digitally sign the document
  external JSPromise signDocument(JSAny signatureData);

  /// Set signatures LTV
  ///
  /// Enable Long Term Validation for signatures
  external JSPromise setSignaturesLTV(JSAny options);

  // ========================================================================
  // Measurement Methods
  // ========================================================================

  /// Set measurement scale
  ///
  /// Configure scale for measurement annotations
  external JSPromise setMeasurementScale(JSAny scale);

  /// Set measurement precision
  ///
  /// Configure precision for measurement values
  external JSPromise setMeasurementPrecision(JSAny precision);

  /// Set measurement snapping
  ///
  /// Enable/disable snapping for measurement tools
  external JSPromise setMeasurementSnapping(bool enabled);

  // ========================================================================
  // Print Methods
  // ========================================================================

  /// Print document
  ///
  /// Open the browser print dialog
  external JSPromise print(JSAny? options);

  /// Abort print operation
  ///
  /// Cancel an ongoing print operation
  external void abortPrint();

  // ========================================================================
  // Comparison Methods
  // ========================================================================

  /// Compare documents
  ///
  /// Compare two documents and show differences
  external JSPromise compareDocuments(JSAny options);

  /// Start document comparison
  ///
  /// Start comparison mode with options
  external JSPromise startComparison(JSAny options);

  /// Stop document comparison
  ///
  /// Exit comparison mode
  external JSPromise stopComparison();

  /// Set document comparison mode
  ///
  /// Configure comparison display mode
  external JSPromise setDocumentComparisonMode(String mode);

  // ========================================================================
  // Measurement Methods
  // ========================================================================

  /// Start measurement mode
  ///
  /// Enable measurement tools
  external JSPromise startMeasurement(String tool);

  /// Stop measurement mode
  external JSPromise stopMeasurement();

  // ========================================================================
  // Undo/Redo Methods
  // ========================================================================

  /// Undo last action
  external JSPromise undo();

  /// Redo last undone action
  external JSPromise redo();

  /// Check if undo is available
  external bool get canUndo;

  /// Check if redo is available
  external bool get canRedo;

  // ========================================================================
  // Content Editing Methods
  // ========================================================================

  /// Begin content editing session
  ///
  /// Start editing PDF content (text, images, etc.)
  external JSPromise beginContentEditingSession();

  // ========================================================================
  // OCG Layers Methods
  // ========================================================================

  /// Get layers
  ///
  /// Get optional content groups (layers)
  external JSPromise getLayers();

  /// Get layers visibility state
  ///
  /// Get current visibility state of layers
  external JSPromise getLayersVisibilityState();

  /// Set layers visibility state
  ///
  /// Update layer visibility
  external JSPromise setLayersVisibilityState(JSAny state);

  // ========================================================================
  // Tab Order & Accessibility Methods
  // ========================================================================

  /// Get page tab order
  ///
  /// Get tab order for form fields and annotations
  external JSPromise getPageTabOrder(int pageIndex);

  /// Set page tab order
  ///
  /// Configure tab order for a page
  external JSPromise setPageTabOrder(int pageIndex, JSAny tabOrder);

  // ========================================================================
  // Attachment Methods
  // ========================================================================

  /// Create attachment
  ///
  /// Add a file attachment to the document
  external JSPromise createAttachment(JSAny attachment);

  /// Get attachment
  ///
  /// Retrieve a specific attachment
  external JSPromise getAttachment(String attachmentId);

  /// Get embedded files
  ///
  /// Get all embedded files in the document
  external JSPromise getEmbeddedFiles();

  // ========================================================================
  // Mention & Collaboration Methods
  // ========================================================================

  /// Set mentionable users
  ///
  /// Configure users that can be mentioned in comments
  external void setMentionableUsers(JSArray users);

  /// Set max mention suggestions
  ///
  /// Configure maximum mention suggestions shown
  external void setMaxMentionSuggestions(int max);

  // ========================================================================
  // Localization Methods
  // ========================================================================

  /// Set locale
  ///
  /// Change the UI language
  external JSPromise setLocale(String locale);

  // ========================================================================
  // Comment Callback Methods
  // ========================================================================

  /// Set on comment creation start
  ///
  /// Callback when comment creation begins
  external void setOnCommentCreationStart(JSFunction? callback);

  /// Set on widget annotation creation start
  ///
  /// Callback when widget annotation creation begins
  external void setOnWidgetAnnotationCreationStart(JSFunction? callback);
}
