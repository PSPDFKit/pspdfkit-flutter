import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
    dartOut: 'lib/src/api/pspdfkit_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/java/com/pspdfkit/flutter/pspdfkit/api/PspdfkitApi.g.kt',
    kotlinOptions: KotlinOptions(
        package: 'com.pspdfkit.flutter.pspdfkit.api',
        errorClassName: 'PspdfkitApiError'),
    swiftOut: 'ios/Classes/api/PspdfkitApi.g.swift',
    swiftOptions: SwiftOptions(
      errorClassName: 'PspdfkitApiError',
    ),
    copyrightHeader: 'pigeons/copyright.txt',
    dartPackageName: 'pspdfkit_flutter'))
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
abstract class PspdfkitApi {
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
}

@FlutterApi()
abstract class PspdfkitFlutterApiCallbacks {
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
abstract class PspdfkitWidgetControllerApi {
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

  @async
  bool addBookmark(String name, int pageIndex);
}

@FlutterApi()
abstract class PspdfkitWidgetCallbacks {
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
