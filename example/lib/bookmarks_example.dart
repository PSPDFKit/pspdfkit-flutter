///
///  Copyright © 2024-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'utils/platform_utils.dart';

/// Example demonstrating the Bookmark API functionality.
///
/// This example shows how to:
/// - Get all bookmarks from a document
/// - Add bookmarks to specific pages
/// - Remove bookmarks
/// - Update bookmark names
/// - Check if a page has bookmarks
/// - Navigate to bookmarked pages
/// - Display bookmark indicators on pages (iOS only)
class BookmarksExample extends StatefulWidget {
  final String documentPath;

  const BookmarksExample({super.key, required this.documentPath});

  @override
  State<BookmarksExample> createState() => _BookmarksExampleState();
}

class _BookmarksExampleState extends State<BookmarksExample> {
  PdfDocument? _document;
  List<Bookmark> _bookmarks = [];
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: PlatformUtils.isAndroid(),
      resizeToAvoidBottomInset: PlatformUtils.isIOS(),
      appBar: AppBar(
        title: const Text('Bookmarks Example'),
        actions: [
          // Refresh bookmarks
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Bookmarks',
            onPressed: _document == null ? null : _loadBookmarks,
          ),
          // Show bookmarks list
          IconButton(
            icon: Badge(
              label: Text('${_bookmarks.length}'),
              isLabelVisible: _bookmarks.isNotEmpty,
              child: const Icon(Icons.bookmark),
            ),
            tooltip: 'View Bookmarks',
            onPressed: _document == null ? null : _showBookmarksList,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // PDF Viewer
            Expanded(
              child: Container(
                padding: PlatformUtils.isAndroid()
                    ? const EdgeInsets.only(top: kToolbarHeight)
                    : null,
                child: NutrientView(
                  documentPath: widget.documentPath,
                  configuration: PdfConfiguration(
                    // iOS only: Show bookmark indicator when page is bookmarked
                    iOSBookmarkIndicatorMode:
                        IOSBookmarkIndicatorMode.onWhenBookmarked,
                    // iOS only: Allow tapping indicator to toggle bookmark
                    iOSBookmarkIndicatorInteractionEnabled: true,
                  ),
                  onDocumentLoaded: _onDocumentLoaded,
                  onPageChanged: _onPageChanged,
                ),
              ),
            ),
            // Bookmark actions bar
            if (_document != null) _buildBookmarkActionsBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkActionsBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current page info
          Text(
            'Page ${_currentPage + 1}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Add bookmark to current page
              _ActionButton(
                icon: Icons.bookmark_add,
                label: 'Add',
                onPressed: _isLoading ? null : _addBookmarkToCurrentPage,
              ),
              // Remove bookmark from current page
              _ActionButton(
                icon: Icons.bookmark_remove,
                label: 'Remove',
                onPressed: _isLoading ? null : _removeBookmarkFromCurrentPage,
              ),
              // Check if page has bookmark
              _ActionButton(
                icon: Icons.bookmark_border,
                label: 'Check',
                onPressed: _isLoading ? null : _checkBookmarkForCurrentPage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onDocumentLoaded(PdfDocument document) async {
    setState(() {
      _document = document;
    });
    await _loadBookmarks();
    _showSnackBar('Document loaded. ${_bookmarks.length} bookmarks found.');
  }

  void _onPageChanged(int pageIndex) {
    setState(() {
      _currentPage = pageIndex;
    });
  }

  Future<void> _loadBookmarks() async {
    if (_document == null) return;

    setState(() => _isLoading = true);
    try {
      final bookmarks = await _document!.getBookmarks();
      setState(() {
        _bookmarks = bookmarks;
      });
    } catch (e) {
      _showSnackBar('Error loading bookmarks: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addBookmarkToCurrentPage() async {
    if (_document == null) return;

    // Show dialog to get bookmark name
    final name = await _showBookmarkNameDialog(
      title: 'Add Bookmark',
      initialName: 'Page ${_currentPage + 1}',
    );

    if (name == null) return;

    setState(() => _isLoading = true);
    try {
      final bookmark = BookmarkFactory.forPage(
        pageIndex: _currentPage,
        name: name,
      );
      final created = await _document!.addBookmark(bookmark);
      await _loadBookmarks();
      _showSnackBar(
          'Bookmark "${created.name}" added to page ${_currentPage + 1}');
    } catch (e) {
      _showSnackBar('Error adding bookmark: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeBookmarkFromCurrentPage() async {
    if (_document == null) return;

    setState(() => _isLoading = true);
    try {
      final pageBookmarks = await _document!.getBookmarksForPage(_currentPage);

      if (pageBookmarks.isEmpty) {
        _showSnackBar('No bookmarks on page ${_currentPage + 1}');
        return;
      }

      // If multiple bookmarks, let user choose
      Bookmark? bookmarkToRemove;
      if (pageBookmarks.length == 1) {
        bookmarkToRemove = pageBookmarks.first;
      } else {
        bookmarkToRemove = await _showBookmarkSelectionDialog(
          title: 'Select Bookmark to Remove',
          bookmarks: pageBookmarks,
        );
      }

      if (bookmarkToRemove == null) return;

      final removed = await _document!.removeBookmark(bookmarkToRemove);
      if (removed) {
        await _loadBookmarks();
        _showSnackBar('Bookmark "${bookmarkToRemove.name}" removed');
      } else {
        _showSnackBar('Failed to remove bookmark');
      }
    } catch (e) {
      _showSnackBar('Error removing bookmark: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkBookmarkForCurrentPage() async {
    if (_document == null) return;

    try {
      final hasBookmark = await _document!.hasBookmarkForPage(_currentPage);
      final pageBookmarks = await _document!.getBookmarksForPage(_currentPage);

      if (hasBookmark) {
        final names = pageBookmarks.map((b) => b.name ?? 'Unnamed').join(', ');
        _showSnackBar(
            'Page ${_currentPage + 1} has ${pageBookmarks.length} bookmark(s): $names');
      } else {
        _showSnackBar('Page ${_currentPage + 1} has no bookmarks');
      }
    } catch (e) {
      _showSnackBar('Error checking bookmark: $e');
    }
  }

  void _showBookmarksList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.bookmark),
                  const SizedBox(width: 8),
                  Text(
                    'Bookmarks (${_bookmarks.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Bookmarks list
            Expanded(
              child: _bookmarks.isEmpty
                  ? const Center(
                      child:
                          Text('No bookmarks yet.\nTap "Add" to create one.'),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _bookmarks.length,
                      itemBuilder: (context, index) {
                        final bookmark = _bookmarks[index];
                        final pageIndex = bookmark.pageIndex;
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${(pageIndex ?? 0) + 1}'),
                          ),
                          title: Text(bookmark.name ?? 'Unnamed Bookmark'),
                          subtitle: pageIndex != null
                              ? Text('Page ${pageIndex + 1}')
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit bookmark
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editBookmark(bookmark),
                              ),
                              // Delete bookmark
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteBookmark(bookmark),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            if (pageIndex != null) {
                              _navigateToPage(pageIndex);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editBookmark(Bookmark bookmark) async {
    final newName = await _showBookmarkNameDialog(
      title: 'Edit Bookmark',
      initialName: bookmark.name ?? '',
    );

    if (newName == null || newName == bookmark.name) return;

    Navigator.pop(context); // Close bottom sheet

    setState(() => _isLoading = true);
    try {
      final updated = bookmark.copyWith(name: newName);
      await _document!.updateBookmark(updated);
      await _loadBookmarks();
      _showSnackBar('Bookmark updated to "$newName"');
    } catch (e) {
      _showSnackBar('Error updating bookmark: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBookmark(Bookmark bookmark) async {
    Navigator.pop(context); // Close bottom sheet

    setState(() => _isLoading = true);
    try {
      final removed = await _document!.removeBookmark(bookmark);
      if (removed) {
        await _loadBookmarks();
        _showSnackBar('Bookmark "${bookmark.name}" deleted');
      }
    } catch (e) {
      _showSnackBar('Error deleting bookmark: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToPage(int pageIndex) {
    // Note: Page navigation would typically be done through the controller
    // For this example, we just show a message
    _showSnackBar('Navigate to page ${pageIndex + 1}');
  }

  Future<String?> _showBookmarkNameDialog({
    required String title,
    String initialName = '',
  }) async {
    final controller = TextEditingController(text: initialName);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Bookmark Name',
            hintText: 'Enter a name for this bookmark',
          ),
          autofocus: true,
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<Bookmark?> _showBookmarkSelectionDialog({
    required String title,
    required List<Bookmark> bookmarks,
  }) async {
    return showDialog<Bookmark>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return ListTile(
                title: Text(bookmark.name ?? 'Unnamed'),
                onTap: () => Navigator.pop(context, bookmark),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

/// A simple action button widget for the bookmark actions bar.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
