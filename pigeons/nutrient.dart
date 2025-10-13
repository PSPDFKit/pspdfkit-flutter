import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
    dartOut: 'lib/src/api/nutrient_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/java/com/pspdfkit/flutter/pspdfkit/api/NutrientApi.g.kt',
    kotlinOptions: KotlinOptions(
        package: 'com.pspdfkit.flutter.pspdfkit.api',
        errorClassName: 'NutrientApiError'),
    swiftOut: 'ios/Classes/api/NutrientApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'NutrientApiError',
    ),
    copyrightHeader: 'pigeons/copyright.txt',
    dartPackageName: 'nutrient_flutter'))
enum AndroidPermissionStatus {
  notDetermined,
  denied,
  authorized,
  deniedNeverAsk
}

/// Represents the native annotation type.
enum AnnotationType {
  all,
  none,
  undefined,
  link,
  highlight,
  strikeout,
  underline,
  squiggly,
  freeText,
  ink,
  square,
  circle,
  line,
  note,
  stamp,
  caret,
  media,
  screen,
  widget,
  file,
  sound,
  polygon,
  polyline,
  popup,
  watermark,
  trapNet,
  type3d,
  redact,
  image,
}

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

enum AnnotationToolVariant {
  inkPen,
  inkMagic,
  inkHighlighter,
  freeText,
  freeTextCallOut,
  stamp,
  image,
  highlight,
  underline,
}

enum AnnotationProcessingMode {
  flatten,
  remove,
  embed,
  print,
}

class PdfRect {
  PdfRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;
}

class PageInfo {
  PageInfo({
    required this.pageIndex,
    required this.height,
    required this.width,
    required this.rotation,
    this.label = '',
  });

  /// The index of the page. This is a zero-based index.
  final int pageIndex;

  /// The height of the page in points.
  final double height;

  /// The width of the page in points.
  final double width;

  /// The rotation of the page in degrees.
  final int rotation;

  /// The label of the page.
  final String label;
}

class DocumentSaveOptions {
  /// The password is used to encrypt the document. On Web, it's used as the user password.
  final String? userPassword;

  /// The owner password is used to encrypt the document and set permissions. It's only used on Web.
  final String? ownerPassword;

  /// Flatten annotations and form fields into the page content.
  final bool? flatten;

  /// Whether to save the document incrementally.
  final bool? incremental;

  /// The permissions to set on the document. See [DocumentPermissions] for more information.
  final List<DocumentPermissions?>? permissions;

  /// The PDF version to save the document as.
  final PdfVersion? pdfVersion;

  /// Whether to exclude annotations from the exported document.
  final bool? excludeAnnotations;

  /// Whether to exclude annotations that have the noPrint flag set to true from the exported document (Standalone only)
  final bool? saveForPrinting;

  /// Whether to include comments in the exported document (Server-Backed only).
  final bool? includeComments;

  /// Whether tp allow you to export a PDF in PDF/A format.
  final Object? outputFormat;

  /// Whether to optimize the document for the web.
  final bool? optimize;

  DocumentSaveOptions(
      {this.userPassword,
      this.ownerPassword,
      this.flatten,
      this.incremental,
      this.permissions,
      this.pdfVersion,
      this.excludeAnnotations,
      this.saveForPrinting,
      this.includeComments,
      this.outputFormat,
      this.optimize});
}

enum DocumentPermissions {
  /// Allow printing of document.
  printing,

  /// Modify the contents of the document.
  modification,

  /// Copy text and images from the document.
  extract,

  /// Add or modify text annotations, fill in interactive form fields.
  annotationsAndForms,

  /// Fill in existing interactive form fields (including signature fields).
  fillForms,

  /// Extract text and images from the document.
  extractAccessibility,

  /// Assemble the document (insert, rotate, or delete pages and create document outline items or thumbnail images).
  assemble,

  /// Print high quality.
  printHighQuality;
}

/// The PDF version of a document.
enum PdfVersion {
  pdf_1_0,
  pdf_1_1,
  pdf_1_2,
  pdf_1_3,
  pdf_1_4,
  pdf_1_5,
  pdf_1_6,
  pdf_1_7,
}

enum PdfFormFieldTypes {
  // Text field
  text,

  // Checkbox
  checkbox,

  // Radio button
  radioButton,

  // Combo box
  comboBox,

  // List box
  listBox,

  // Signature field
  signature,

  // Button
  button,

  // Unknown field type
  unknown
}

class PdfFormOption {
  /// The value of the option.
  final String value;

  /// The label of the option.
  final String label;

  PdfFormOption({required this.value, required this.label});
}

class FormFieldData {
  final String name;
  final String? alternativeFieldName;
  final String? fullyQualifiedName;
  final PdfFormFieldTypes type;
  final Object? annotations;
  final bool? isReadOnly;
  final bool? isRequired;
  final bool? isExported;
  final bool? isDirty;
  final List<PdfFormOption?>? options;

  FormFieldData({
    required this.name,
    this.alternativeFieldName,
    this.fullyQualifiedName,
    required this.type,
    this.annotations,
    this.isReadOnly,
    this.isRequired,
    this.isExported,
    this.isDirty,
    this.options,
  });
}

/// The API for interacting with a PDF document.
@HostApi()
abstract class NutrientApi {
  @async
  String? getFrameworkVersion();

  @async
  void setLicenseKey(String? licenseKey);

  @async
  void setLicenseKeys(
      String? androidLicenseKey, String? iOSLicenseKey, String? webLicenseKey);

  @async
  bool? present(String document, {Map<String, Object>? configuration});

  @async
  bool? presentInstant(String serverUrl, String jwt,
      {Map<String, Object>? configuration});

  @async
  bool? setFormFieldValue(String value, String fullyQualifiedName);

  @async
  String? getFormFieldValue(String fullyQualifiedName);

  @async
  bool? applyInstantJson(String annotationsJson);

  @async
  String? exportInstantJson();

  @async
  bool? addAnnotation(String annotation, String? attachment);

  @async
  bool? removeAnnotation(String annotation);

  @async
  Object? getAnnotations(int pageIndex, String type);

  @async
  Object? getAllUnsavedAnnotations();

  @async
  void updateAnnotation(String annotation);

  @async
  bool? processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  );

  @async
  bool? importXfdf(String xfdfString);

  @async
  bool? exportXfdf(String xfdfPath);

  @async
  bool? save();

  @async
  bool? setDelayForSyncingLocalChanges(double delay);

  @async
  bool? setListenToServerChanges(bool listen);

  @async
  bool? syncAnnotations();

  @async
  bool? checkAndroidWriteExternalStoragePermission();

  @async
  AndroidPermissionStatus requestAndroidWriteExternalStoragePermission();

  @async
  void openAndroidSettings();

  @async
  bool? setAnnotationPresetConfigurations(Map<String, Object?> configurations);

  @async
  String getTemporaryDirectory();

  @async
  void setAuthorName(String name);

  @async
  String getAuthorName();

  /// Generate PDF from Images, Template, and Patterns.
  ///[pages]: [NewPage]s to be added to the PDF.
  ///[outputPath]: The path to the output file.
  /// Returns the path to the generated PDF path or null if the input is invalid or if the PDF generation fails.
  @async
  String? generatePdf(List<Map<String, Object>> pages, String outputPath);

  /// Generates a PDF from HTML string.
  ///
  /// [html]: The HTML string to be converted to PDF.
  /// [outPutFile]: The path to the output file.
  /// Returns the path to the generated PDF file or null if the input is invalid or if the PDF generation fails.
  @async
  String? generatePdfFromHtmlString(
      String html, String outPutFile, Map<String, Object>? options);

  // /// Generates a PDF from HTML URI.
  // /// [htmlUri]: The URI to the HTML file to be converted to PDF. The URI can be for a local file or a remote file.
  // /// [outPutFile]: The path to the output file.
  // /// Returns the path to the generated PDF file or null if the input is invalid or if the PDF generation fails.
  @async
  String? generatePdfFromHtmlUri(
      String htmlUri, String outPutFile, Map<String, Object>? options);

  /// Configure Nutrient Analytics events.
  void enableAnalyticsEvents(bool enable);

  /// Sets the annotation menu configuration for the global presenter.
  /// This configuration applies to all annotation menus in presented documents.
  ///
  /// @param configuration The annotation menu configuration to apply.
  /// @return True if the configuration was set successfully, false otherwise.
  @async
  bool? setAnnotationMenuConfiguration(
      AnnotationMenuConfigurationData configuration);
}

@FlutterApi()
abstract class NutrientApiCallbacks {
  /// onPAuse callback for FlutterPdfActivity
  void onPdfActivityOnPause();

  void onPdfFragmentAdded();

  void onDocumentLoaded(String documentId);

  /// ViewControllerWillDismiss callback for PDFViewController
  void onPdfViewControllerWillDismiss();

  /// ViewControllerDidDismiss callback for PDFViewController
  void onPdfViewControllerDidDismiss();

  /// Called when instant synchronization starts.
  void onInstantSyncStarted(String documentId);

  /// Called when instant synchronization ends.
  void onInstantSyncFinished(String documentId);

  /// Called when instant synchronization fails.
  void onInstantSyncFailed(String documentId, String error);

  /// Called when instant authentication is done.
  void onInstantAuthenticationFinished(String documentId, String validJWT);

  /// Called when instant authentication fails.
  void onInstantAuthenticationFailed(String documentId, String error);

  /// Only available on iOS.
  /// Called when instant document download is done.
  void onInstantDownloadFinished(String documentId);

  /// Only available on iOS.
  /// Called when instant document download fails.
  void onInstantDownloadFailed(String documentId, String error);
}

@HostApi()
abstract class NutrientViewControllerApi {
  /// Sets the value of a form field by specifying its fully qualified field name.
  /// This method is deprecated. Use [PdfDocument.setFormFieldValue] instead.
  @async
  bool? setFormFieldValue(String value, String fullyQualifiedName);

  /// Gets the form field value by specifying its fully qualified name.
  @async
  String? getFormFieldValue(String fullyQualifiedName);

  /// Applies Instant document JSON to the presented document.
  @async
  bool? applyInstantJson(String annotationsJson);

  /// Exports Instant document JSON from the presented document.
  @async
  String? exportInstantJson();

  /// Adds the given annotation to the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  @async
  bool? addAnnotation(String annotation);

  /// Removes the given annotation from the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  @async
  bool? removeAnnotation(String annotation);

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  @async
  Object getAnnotations(int pageIndex, String type);

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  @async
  Object getAllUnsavedAnnotations();

  /// Processes annotations of the given type with the provided processing
  /// mode and stores the PDF at the given destination path.
  @async
  bool processAnnotations(
    AnnotationType type,
    AnnotationProcessingMode processingMode,
    String destinationPath,
  );

  /// Imports annotations from the XFDF file at the given path.
  @async
  bool importXfdf(String xfdfString);

  /// Exports annotations to the XFDF file at the given path.
  @async
  bool exportXfdf(String xfdfPath);

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  @async
  bool save();

  /// Sets the annotation preset configurations for the given annotation tools.
  /// @param configurations A map of annotation tools and their corresponding configurations.
  /// @param modifyAssociatedAnnotations Whether to modify the annotations associated with the old configuration. Only used for Android.
  /// @return True if the configurations were set successfully, false otherwise.
  @async
  bool? setAnnotationConfigurations(
    Map<String, Map<String, Object>> configurations,
  );

  /// Gets the visible rect of the given page.
  /// pageIndex The index of the page. This is a zero-based index.
  /// Returns a [Future] that completes with the visible rect of the given page.
  @async
  PdfRect getVisibleRect(int pageIndex);

  /// Zooms to the given rect on the given page.
  /// pageIndex The index of the page. This is a zero-based index.
  /// rect The rect to zoom to.
  /// Returns a [Future] that completes when the zoom operation is done.
  @async
  bool zoomToRect(
      int pageIndex, PdfRect rect, bool? animated, double? duration);

  /// Gets the zoom scale of the given page.
  /// pageIndex The index of the page. This is a zero-based index.
  /// Returns a [Future] that completes with the zoom scale of the given page.
  @async
  double getZoomScale(int pageIndex);

  void addEventListener(NutrientEvent event);

  void removeEventListener(NutrientEvent event);

  /// Enters annotation creation mode.
  ///
  /// If [annotationTool] is provided, that specific tool will be activated.
  /// If no tool is provided, the default annotation tool will be used.
  ///
  /// Returns a [Future] that completes with a boolean indicating whether
  /// entering annotation creation mode was successful.
  @async
  bool? enterAnnotationCreationMode(AnnotationTool? annotationTool);

  /// Exits annotation creation mode.
  ///
  /// Returns a [Future] that completes with a boolean indicating whether
  /// exiting annotation creation mode was successful.
  @async
  bool? exitAnnotationCreationMode();

  /// Sets the annotation menu configuration for the current view controller.
  /// This configuration applies only to annotation menus in the current document view.
  ///
  /// @param configuration The annotation menu configuration to apply.
  /// @return True if the configuration was set successfully, false otherwise.
  @async
  bool? setAnnotationMenuConfiguration(
      AnnotationMenuConfigurationData configuration);
}

@HostApi()
abstract class PdfDocumentApi {
  /// Returns the page info for the given page index.
  /// pageIndex The index of the page. This is a zero-based index.
  @async
  PageInfo getPageInfo(int pageIndex);

  /// Exports the document as a PDF.
  /// options:[DocumentSaveOptions] The options to use when exporting the document.
  /// Returns a [Uint8List] containing the exported PDF data.
  @async
  Uint8List exportPdf(DocumentSaveOptions? options);

  // Returns the form field with the given name.
  @async
  Map<String, Object?> getFormField(String fieldName);

  /// Returns a list of all form fields in the document.
  @async
  List<Map<String, Object?>> getFormFields();

  /// Sets the value of a form field by specifying its fully qualified field name.
  @async
  bool? setFormFieldValue(String value, String fullyQualifiedName);

  /// Gets the form field value by specifying its fully qualified name.
  @async
  String? getFormFieldValue(String fullyQualifiedName);

  /// Applies Instant document JSON to the presented document.
  @async
  bool? applyInstantJson(String annotationsJson);

  /// Exports Instant document JSON from the presented document.
  @async
  String? exportInstantJson();

  /// Adds the given annotation to the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  @async
  bool? addAnnotation(
    String jsonAnnotation,
    Object? attachment,
  );

  /// Updates the given annotation in the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  ///
  /// @deprecated Use setAnnotationProperties() or specific property setters instead.
  /// This method has a critical bug that causes data loss for annotations with attachments.
  /// It will be removed in version 7.0.0.
  ///
  /// Migration:
  /// - For single property updates: Use specific setters like setAnnotationColor()
  /// - For multiple property updates: Use setAnnotationProperties()
  @async
  bool? updateAnnotation(String jsonAnnotation);

  /// Removes the given annotation from the presented document.
  /// `jsonAnnotation` can either be a JSON string or a valid JSON Dictionary (iOS) / HashMap (Android).
  @async
  bool? removeAnnotation(String jsonAnnotation);

  /// Returns a list of JSON dictionaries for all the annotations of the given `type` on the given `pageIndex`.
  @async
  Object getAnnotations(int pageIndex, String type);

  /// Returns a list of JSON dictionaries for all the unsaved annotations in the presented document.
  @async
  Object getAllUnsavedAnnotations();

  /// Imports annotations from the XFDF file at the given path.
  @async
  bool importXfdf(String xfdfString);

  /// Exports annotations to the XFDF file at the given path.
  @async
  bool exportXfdf(String xfdfPath);

  /// Saves the document back to its original location if it has been changed.
  /// If there were no changes to the document, the document file will not be modified.
  @async
  bool save(String? outputPath, DocumentSaveOptions? options);

  /// Get the total number of pages in the document.
  @async
  int getPageCount();
}

@FlutterApi()
abstract class NutrientViewCallbacks {
  void onDocumentLoaded(String documentId);

  void onDocumentError(String documentId, String error);

  void onPageChanged(String documentId, int pageIndex);

  void onPageClick(
      String documentId, int pageIndex, PointF? point, Object? annotation);

  void onDocumentSaved(String documentId, String? path);
}

@FlutterApi()
abstract class NutrientEventsCallbacks {
  void onEvent(NutrientEvent event, Object? data);
}

class PointF {
  final double x;
  final double y;

  PointF({required this.x, required this.y});
}

enum NutrientEvent {
  /// Event triggered when annotations are created.
  annotationsCreated,

  /// Event triggered when annotations are pressed.
  annotationsDeselected,

  /// Event triggered when annotations are updated.
  annotationsUpdated,

  /// Event triggered when annotations are deleted.
  annotationsDeleted,

  /// Event triggered when annotations are focused.
  annotationsSelected,

  /// Event triggered when form field values are updated.
  formFieldValuesUpdated,

  /// Event triggered when form fields are loaded.
  formFieldSelected,

  /// Event triggered when form fields are about to be saved.
  formFieldDeselected,

  /// Event triggered when text selection changes.
  textSelectionChanged,
}

@FlutterApi()
abstract class AnalyticsEventsCallback {
  void onEvent(String event, Map<String, Object?>? attributes);
}

/// Callbacks for custom toolbar item interactions
@FlutterApi()
abstract class CustomToolbarCallbacks {
  /// Called when a custom toolbar item is tapped
  void onCustomToolbarItemTapped(String identifier);
}

/// Enumeration of default annotation menu actions that can be removed or disabled.
///
/// **Platform Support:**
/// - All actions can be removed or disabled on both iOS and Android
/// - Some system actions (copy/paste) may be harder to remove on iOS due to system restrictions
enum AnnotationMenuAction {
  /// Delete action - removes the annotation
  /// - iOS: Part of UIMenu system actions
  /// - Android: R.id.pspdf__annotation_editing_toolbar_item_delete
  delete,

  /// Copy action - copies the annotation
  /// - iOS: System copy action (may be harder to remove)
  /// - Android: R.id.pspdf__annotation_editing_toolbar_item_copy
  copy,

  /// Cut action - cuts the annotation to clipboard
  /// - iOS: System cut action
  /// - Android: R.id.pspdf__annotation_editing_toolbar_item_cut
  cut,

  /// Color action - opens annotation color picker/inspector
  /// - iOS: Style picker in UIMenu
  /// - Android: R.id.pspdf__annotation_editing_toolbar_item_picker
  color,

  /// Note action - opens annotation note editor
  /// - iOS: Note action in UIMenu
  /// - Android: R.id.pspdf__annotation_editing_toolbar_item_annotation_note
  note,

  /// Undo action - undoes the last action
  /// - iOS: Undo in UIMenu
  /// - Android: R.id.pspdf__annotation_editing_toolbar_item_undo
  undo,

  /// Redo action - redoes the previously undone action
  /// - iOS: Redo in UIMenu
  /// - Android: R.id.pspdf__annotation_editing_toolbar_item_redo
  redo,
}

/// Configuration data for annotation contextual menu
///
/// This class defines how annotation menus should be configured
/// when displayed to users. It supports removing actions, disabling actions,
/// and controlling visual presentation options.
///
/// **Usage Patterns**:
/// - **Static Configuration**: Set once via [NutrientViewController.setAnnotationMenuConfiguration]
///
/// **Platform Compatibility**:
/// - [itemsToRemove]: Supported on Android, iOS, and Web
/// - [itemsToDisable]: Supported on Android, iOS, and Web
/// - [showStylePicker]: Supported on Android and iOS
/// - [groupMarkupItems]: iOS only (ignored on other platforms)
/// - [maxVisibleItems]: Platform-dependent behavior
class AnnotationMenuConfigurationData {
  /// List of default annotation menu actions to remove completely from the menu.
  ///
  /// These actions will not appear in the contextual menu at all.
  /// Use this when you want to completely hide certain functionality.
  ///
  /// **Example**: Remove delete action for read-only annotations
  /// ```dart
  /// itemsToRemove: [AnnotationMenuAction.delete]
  /// ```
  final List<AnnotationMenuAction> itemsToRemove;

  /// List of default annotation menu actions to disable (show as grayed out).
  ///
  /// These actions will appear in the menu but will be non-interactive.
  /// Use this when you want to show functionality exists but is temporarily unavailable.
  ///
  /// **Example**: Disable copy action for certain annotation types
  /// ```dart
  /// itemsToDisable: [AnnotationMenuAction.copy]
  /// ```
  final List<AnnotationMenuAction> itemsToDisable;

  /// Whether to show the platform's default style picker in the annotation menu.
  ///
  /// When true, users can access color, thickness, and other style options
  /// directly from the annotation menu.
  ///
  /// **Platform Behavior**:
  /// - **iOS**: Shows style picker as part of UIMenu
  /// - **Android**: Shows annotation inspector/style picker
  /// - **Web**: Shows color picker and basic style options
  final bool showStylePicker;

  /// Whether to group markup annotation actions together in the menu.
  ///
  /// When true, related markup actions (highlight, underline, etc.) are
  /// visually grouped in the menu for better organization.
  ///
  /// **Platform Support**: iOS only (ignored on Android and Web)
  final bool groupMarkupItems;

  /// Maximum number of actions to show directly in the menu before creating overflow.
  ///
  /// When the number of available actions exceeds this limit, the platform
  /// may create a submenu or overflow menu to accommodate additional actions.
  ///
  /// **Platform Behavior**:
  /// - **iOS**: Respects platform UI guidelines for menu length
  /// - **Android**: Limited by toolbar space and screen size
  /// - **Web**: Creates scrollable or paginated menu as needed
  ///
  /// **Note**: If null, the platform default behavior is used.
  final int? maxVisibleItems;

  AnnotationMenuConfigurationData({
    required this.itemsToRemove,
    required this.itemsToDisable,
    required this.showStylePicker,
    required this.groupMarkupItems,
    this.maxVisibleItems,
  });
}

/// Data class for annotation properties that provides type-safe access
/// to annotation attributes while preserving attachments and custom data.
///
/// This class is used with the AnnotationManager API to safely update
/// annotation properties without losing data during the update process.
///
/// **Usage Pattern**:
/// ```dart
/// // Get current properties
/// final properties = await annotationManager.getAnnotationProperties(pageIndex, annotationId);
///
/// // Create modified version
/// final updated = properties?.withColor(Colors.red).withOpacity(0.7);
///
/// // Save changes
/// if (updated != null) {
///   await annotationManager.saveAnnotationProperties(updated);
/// }
/// ```
///
/// **Data Preservation**: Unlike the deprecated `updateAnnotation` method,
/// this approach preserves attachments, custom data, and other properties
/// that are not being explicitly modified.
class AnnotationProperties {
  /// Unique identifier for the annotation
  final String annotationId;

  /// Zero-based page index where the annotation is located
  final int pageIndex;

  /// Stroke color as ARGB integer (e.g., 0xFFFF0000 for red)
  final int? strokeColor;

  /// Fill color as ARGB integer (e.g., 0xFF0000FF for blue)
  final int? fillColor;

  /// Opacity value between 0.0 (transparent) and 1.0 (opaque)
  final double? opacity;

  /// Line width for stroke-based annotations (in points)
  final double? lineWidth;

  /// List of annotation flags (e.g., ['readOnly', 'print'])
  final List<String>? flags;

  /// Custom data associated with the annotation
  /// This preserves any application-specific metadata
  final Map<String, Object?>? customData;

  /// Text content of the annotation (for text-based annotations)
  final String? contents;

  /// Subject/title of the annotation
  final String? subject;

  /// Creator/author of the annotation
  final String? creator;

  /// Bounding box as [x, y, width, height] in PDF coordinates
  final List<double>? bbox;

  /// Note text associated with the annotation
  final String? note;

  // Type-specific properties

  /// Ink lines for ink annotations as [[[x, y, pressure], ...], ...]
  /// Each line is an array of points, each point is [x, y, pressure]
  final List<List<List<double>>>? inkLines;

  /// Font name for text annotations
  final String? fontName;

  /// Font size for text annotations (in points)
  final double? fontSize;

  /// Icon name for note annotations (e.g., 'Comment', 'Key', 'Note')
  final String? iconName;

  AnnotationProperties({
    required this.annotationId,
    required this.pageIndex,
    this.strokeColor,
    this.fillColor,
    this.opacity,
    this.lineWidth,
    this.flags,
    this.customData,
    this.contents,
    this.subject,
    this.creator,
    this.bbox,
    this.note,
    this.inkLines,
    this.fontName,
    this.fontSize,
    this.iconName,
  });
}

/// Manages annotations for a PDF document with proper data preservation.
///
/// This API replaces the deprecated annotation methods in PdfDocumentApi
/// and provides a safe way to update annotations without losing attachments
/// or custom data.
///
/// **Channel Management**: Each document instance creates its own AnnotationManager
/// with a unique channel ID prefixed by the document ID (e.g., "doc123_annotation_manager").
/// This allows multiple documents to have independent annotation managers.
///
/// **Key Features**:
/// - Preserves attachments when updating annotation properties
/// - Maintains custom data during updates
/// - Only updates properties that are explicitly set (non-null)
/// - Provides batch update capabilities
/// - Supports search and filtering operations
@HostApi()
abstract class AnnotationManagerApi {
  /// Initialize the annotation manager for a specific document.
  /// This should be called once when creating the manager instance.
  ///
  /// @param documentId The unique identifier of the document
  void initialize(String documentId);

  /// Get the current properties of an annotation.
  /// Returns null if the annotation doesn't exist.
  ///
  /// @param pageIndex Zero-based page index
  /// @param annotationId Unique identifier of the annotation
  /// @return Current annotation properties or null if not found
  @async
  AnnotationProperties? getAnnotationProperties(
      int pageIndex, String annotationId);

  /// Save modified annotation properties.
  /// Only non-null properties in modifiedProperties will be updated.
  /// All other properties (including attachments and custom data) are preserved.
  ///
  /// @param modifiedProperties Properties to update (only non-null values are applied)
  /// @return true if successfully saved, false otherwise
  @async
  bool saveAnnotationProperties(AnnotationProperties modifiedProperties);

  /// Get all annotations on a specific page.
  ///
  /// @param pageIndex Zero-based page index
  /// @param annotationType Type of annotations to retrieve (e.g., "all", "ink", "note")
  /// @return List of annotations as JSON-compatible maps
  @async
  Object getAnnotations(int pageIndex, String annotationType);

  /// Add a new annotation to the document.
  ///
  /// @param jsonAnnotation JSON representation of the annotation
  /// @param jsonAttachment Optional JSON representation of attachment (for file/image annotations)
  /// @return Unique identifier of the created annotation
  @async
  String addAnnotation(String jsonAnnotation, String? jsonAttachment);

  /// Remove an annotation from the document.
  ///
  /// @param pageIndex Zero-based page index
  /// @param annotationId Unique identifier of the annotation
  /// @return true if successfully removed, false otherwise
  @async
  bool removeAnnotation(int pageIndex, String annotationId);

  /// Search for annotations containing specific text.
  ///
  /// @param query Search term
  /// @param pageIndex Optional page index to limit search scope
  /// @return List of matching annotations
  @async
  Object searchAnnotations(String query, int? pageIndex);

  /// Export annotations as XFDF format.
  ///
  /// @param pageIndex Optional page index to export specific page annotations
  /// @return XFDF string representation
  @async
  String exportXFDF(int? pageIndex);

  /// Import annotations from XFDF format.
  ///
  /// @param xfdfString XFDF string to import
  /// @return true if successfully imported, false otherwise
  @async
  bool importXFDF(String xfdfString);

  /// Get all annotations that have unsaved changes.
  ///
  /// @return List of annotations with pending changes
  @async
  Object getUnsavedAnnotations();
}
