///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Callback for document info updates (page count, current page, title, readiness).
typedef DocumentInfoCallback = void Function({
  int? pageCount,
  int? currentPage,
  String? title,
  bool? isReady,
});

/// Callback for status/event messages from the adapter.
typedef StatusChangedCallback = void Function(String status);

/// Controller interface for the platform adapter example.
///
/// Each platform adapter extends its base adapter AND implements this interface:
/// - Android: `ExampleAndroidAdapter extends AndroidAdapter implements ExampleAdapterController`
/// - iOS: `ExampleIOSAdapter extends IOSAdapter implements ExampleAdapterController`
/// - Web: `ExampleWebAdapter extends NutrientWebAdapter implements ExampleAdapterController`
///
/// ```dart
/// final adapter = createExampleAdapter(
///   onStatusChanged: (status) => print(status),
///   onDocumentInfo: ({pageCount, currentPage, title, isReady}) {
///     print('Page count: $pageCount');
///   },
/// );
///
/// NutrientView(
///   documentPath: 'document.pdf',
///   adapter: adapter as NutrientPlatformAdapter,
/// )
/// ```
abstract class ExampleAdapterController {
  /// Callback for status/event messages.
  StatusChangedCallback? get onStatusChanged;

  /// Callback for document info updates.
  DocumentInfoCallback? get onDocumentInfo;

  /// Get the total number of pages in the document.
  Future<int> getPageCount();

  /// Get the current page index (0-based).
  Future<int> getCurrentPageIndex();

  /// Navigate to a specific page.
  Future<void> setPageIndex(int pageIndex);

  /// Get the document title.
  Future<String?> getDocumentTitle();
}
