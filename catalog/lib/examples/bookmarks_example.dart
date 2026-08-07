// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';

/// Bookmarks example: drive [BookmarkManagerInterface] from a live viewer.
///
/// Demonstrates the full CRUD surface on `controller.document.bookmarks`:
///
/// 1. [NutrientDocumentView] hosts the bundled `bookmarks.pdf`;
///    `onControllerReady` hands us a [NutrientController].
/// 2. `controller.document.bookmarks.getBookmarks()` populates the bottom
///    info bar's "Bookmarks" cell on load and after every mutation.
/// 3. `controller.events.pageChanged` keeps the current-page indicator and
///    the per-page "Bookmarked?" state in sync as the user navigates.
/// 4. The action row exercises `addBookmark` / `removeBookmark` /
///    `updateBookmark` / `hasBookmarkForPage` against the current page.
/// 5. The "List" button opens a sheet that taps the rename + delete paths
///    on individual bookmarks.
class BookmarksExamplePage extends StatefulWidget {
  const BookmarksExamplePage({super.key});

  @override
  State<BookmarksExamplePage> createState() => _BookmarksExamplePageState();
}

class _BookmarksExamplePageState extends State<BookmarksExamplePage> {
  Future<String>? _documentPath;
  NutrientController? _controller;
  StreamSubscription<NutrientEvent>? _eventsSub;

  List<Bookmark> _bookmarks = [];
  int _currentPage = 0;
  bool _hasBookmarkForCurrentPage = false;
  bool _isBusy = false;
  String? _lastAction;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentPath ??= CatalogDocuments.bookmarks(context);
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    super.dispose();
  }

  Future<void> _onControllerReady(NutrientController controller) async {
    // Cancel any prior subscription in case the view re-fires ready (e.g.
    // hot-reload re-attaching the platform view).
    await _eventsSub?.cancel();
    if (!mounted) return;
    _eventsSub = controller.events.listen(_handleEvent);
    // `canMutate` in `build` keys off `_controller != null`, so a setState
    // is required to flip the Add button to enabled — otherwise the
    // button stays disabled even after the controller arrives.
    setState(() => _controller = controller);
    // iOS / Web: the document is already loaded at this point.
    // Android: the controller fires ready ~400 ms before `pdfDocument` is
    // registered, so this throws; the `DocumentLoadedEvent` listener
    // recovers once the doc lands.
    _refreshBookmarks();
  }

  void _handleEvent(NutrientEvent event) {
    // `_eventsSub?.cancel()` in `dispose` is fire-and-forget, so an
    // event already queued on the broadcast stream can still land here
    // after the state is unmounted. Bail before any `setState`.
    if (!mounted) return;
    if (event is DocumentLoadedEvent) {
      _refreshBookmarks();
      return;
    }
    if (event is PageChangedEvent) {
      if (event.pageIndex == _currentPage) return;
      setState(() => _currentPage = event.pageIndex);
      _refreshHasBookmarkForCurrentPage();
    }
  }

  Future<void> _refreshBookmarks() async {
    final controller = _controller;
    if (controller == null) return;
    List<Bookmark> bookmarks;
    try {
      bookmarks = await controller.document.bookmarks.getBookmarks();
    } catch (_) {
      // Bindings round-trip failed — leave the page in a safe state for
      // the `DocumentLoadedEvent` listener (Android) to retry.
      return;
    }
    if (!mounted) return;
    setState(() => _bookmarks = bookmarks);
    _refreshHasBookmarkForCurrentPage();
  }

  Future<void> _refreshHasBookmarkForCurrentPage() async {
    final controller = _controller;
    if (controller == null) return;
    final forPage = _currentPage; // capture so a fast page-change doesn't race
    bool has;
    try {
      has = await controller.document.bookmarks.hasBookmarkForPage(forPage);
    } catch (_) {
      has = false;
    }
    if (!mounted || _currentPage != forPage) return;
    setState(() => _hasBookmarkForCurrentPage = has);
  }

  Future<void> _addBookmarkToCurrentPage() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    // Mark busy *before* the dialog so a fast second tap (e.g. Maestro
    // firing two presses on Save in quick succession, which on Android
    // would translate to two `BookmarkProvider.addBookmark` calls and
    // hence two duplicate bookmarks since the Android SDK doesn't
    // dedupe by page) is short-circuited by the guard above.
    setState(() => _isBusy = true);
    try {
      final name = await _promptName(
        title: 'Add bookmark',
        initial: 'Page ${_currentPage + 1}',
      );
      // An empty name produces an invisible row in the List sheet
      // (since the `?? 'Unnamed bookmark'` fallback only fires on
      // null) — bail out the same as Cancel.
      if (name == null || name.isEmpty || !mounted) return;
      final saved = await controller.document.bookmarks.addBookmark(
        BookmarkFactory.forPage(pageIndex: _currentPage, name: name),
      );
      _setLastAction('Added "${saved.name ?? name}"');
      await _refreshBookmarks();
    } catch (error) {
      _setLastAction('Add failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _removeBookmarksOnCurrentPage() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    final onThisPage = _bookmarks
        .where((b) => b.pageIndex == _currentPage)
        .toList();
    if (onThisPage.isEmpty) {
      _setLastAction('No bookmark on page ${_currentPage + 1}');
      return;
    }
    setState(() => _isBusy = true);
    try {
      int removed = 0;
      for (final b in onThisPage) {
        if (await controller.document.bookmarks.removeBookmark(b)) removed++;
      }
      _setLastAction('Removed $removed on page ${_currentPage + 1}');
      await _refreshBookmarks();
    } catch (error) {
      _setLastAction('Remove failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _renameBookmark(Bookmark bookmark) async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    final newName = await _promptName(
      title: 'Rename bookmark',
      initial: bookmark.name ?? '',
    );
    if (newName == null || newName.isEmpty || newName == bookmark.name) {
      return;
    }
    if (!mounted) return;
    setState(() => _isBusy = true);
    try {
      // `updateBookmark(bookmark.copyWith(name: newName))` is fragile on
      // platforms where the SDK doesn't surface a stable `pdfBookmarkId`
      // on freshly-created bookmarks: the platform's `removeBookmark`
      // would receive the *new* name as the identity hint and could
      // match the wrong sibling on the same page. Explicit
      // remove-original then add-renamed keeps the identity check on
      // the original bookmark.
      await controller.document.bookmarks.removeBookmark(bookmark);
      await controller.document.bookmarks.addBookmark(
        bookmark.copyWith(name: newName),
      );
      _setLastAction('Renamed to "$newName"');
      await _refreshBookmarks();
    } catch (error) {
      _setLastAction('Rename failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _deleteBookmark(Bookmark bookmark) async {
    final controller = _controller;
    if (controller == null || _isBusy) return;
    setState(() => _isBusy = true);
    try {
      final removed = await controller.document.bookmarks.removeBookmark(
        bookmark,
      );
      _setLastAction(
        removed
            ? 'Deleted "${bookmark.name ?? 'Unnamed'}"'
            : 'Delete returned false',
      );
      await _refreshBookmarks();
    } catch (error) {
      _setLastAction('Delete failed: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _setLastAction(String message) {
    if (!mounted) return;
    setState(() => _lastAction = message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> _promptName({
    required String title,
    required String initial,
  }) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) =>
          _BookmarkNameDialog(title: title, initial: initial),
    );
  }

  void _showBookmarksSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(BrandSpacing.lg),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmarks_outlined),
                      const SizedBox(width: BrandSpacing.sm),
                      Text(
                        'Bookmarks (${_bookmarks.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _bookmarks.isEmpty
                      ? const Center(
                          child: Text(
                            'No bookmarks yet.\nTap "Add" to bookmark a page.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _bookmarks.length,
                          itemBuilder: (_, index) {
                            final bookmark = _bookmarks[index];
                            final pageIndex = bookmark.pageIndex;
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  pageIndex != null ? '${pageIndex + 1}' : '?',
                                ),
                              ),
                              title: Text(bookmark.name ?? 'Unnamed bookmark'),
                              subtitle: pageIndex != null
                                  ? Text('Page ${pageIndex + 1}')
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    tooltip: 'Rename',
                                    onPressed: () {
                                      Navigator.of(sheetContext).pop();
                                      _renameBookmark(bookmark);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: 'Delete',
                                    onPressed: () {
                                      Navigator.of(sheetContext).pop();
                                      _deleteBookmark(bookmark);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canMutate = _controller != null && !_isBusy;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Bookmarks')),
      // The info bar lives in the bottom slot so it stays Flutter-owned and
      // Maestro-reachable once the native viewer takes a11y focus over the
      // body area.
      bottomNavigationBar: SafeArea(
        top: false,
        child: _InfoBar(
          currentPage: _currentPage,
          bookmarks: _bookmarks,
          hasBookmarkForCurrentPage: _hasBookmarkForCurrentPage,
          isBusy: _isBusy,
          lastAction: _lastAction,
          onAdd: canMutate ? _addBookmarkToCurrentPage : null,
          onRemove: canMutate && _hasBookmarkForCurrentPage
              ? _removeBookmarksOnCurrentPage
              : null,
          onShowList: _controller != null ? _showBookmarksSheet : null,
        ),
      ),
      body: FutureBuilder<String>(
        future: _documentPath,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return NutrientDocumentView(
            documentPath: snapshot.data!,
            onControllerReady: _onControllerReady,
          );
        },
      ),
    );
  }
}

class _InfoBar extends StatelessWidget {
  final int currentPage;
  final List<Bookmark> bookmarks;
  final bool hasBookmarkForCurrentPage;
  final bool isBusy;
  final String? lastAction;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onShowList;

  const _InfoBar({
    required this.currentPage,
    required this.bookmarks,
    required this.hasBookmarkForCurrentPage,
    required this.isBusy,
    required this.lastAction,
    required this.onAdd,
    required this.onRemove,
    required this.onShowList,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BrandSpacing.lg,
          vertical: BrandSpacing.sm,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Phones in portrait (typically < 600 dp): info cells overflow
            // when laid out side-by-side and three labelled buttons end up
            // wrapping the labels ("Add bo okmar k"). Below the breakpoint
            // we stack the info cells onto a Wrap and shrink the action
            // labels.
            final isCompact = constraints.maxWidth < 600;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCells(isCompact: isCompact),
                const SizedBox(height: BrandSpacing.sm),
                _buildActionRow(isCompact: isCompact),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCells({required bool isCompact}) {
    final cells = [
      _InfoCell(label: 'Page', value: '${currentPage + 1}'),
      _InfoCell(label: 'Total', value: '${bookmarks.length}'),
      _InfoCell(
        label: 'Bookmarked?',
        value: hasBookmarkForCurrentPage ? 'Yes' : 'No',
      ),
      _InfoCell(label: 'Status', value: lastAction ?? '—'),
    ];
    if (isCompact) {
      // Wrap onto multiple rows; the Status cell stretches to the row's
      // remaining width so long messages don't overflow.
      return Wrap(
        spacing: BrandSpacing.lg,
        runSpacing: BrandSpacing.sm,
        children: cells,
      );
    }
    return Row(
      children: [
        cells[0],
        const SizedBox(width: BrandSpacing.lg),
        cells[1],
        const SizedBox(width: BrandSpacing.lg),
        cells[2],
        const SizedBox(width: BrandSpacing.lg),
        Expanded(child: cells[3]),
      ],
    );
  }

  Widget _buildActionRow({required bool isCompact}) {
    final addIcon = isBusy
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.bookmark_add_outlined);
    // On compact screens drop the icons on the secondary buttons and use
    // shorter labels so all three fit on one row without wrapping.
    final addLabel = isCompact ? 'Add' : 'Add bookmark';
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: addIcon,
            label: Text(addLabel, overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(width: BrandSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.bookmark_remove_outlined),
            label: const Text('Remove', overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(width: BrandSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onShowList,
            icon: const Icon(Icons.bookmarks_outlined),
            label: Text(
              'List (${bookmarks.length})',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: BrandColors.codeCoral,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Small `StatefulWidget` so the `TextEditingController` is owned by its
/// own `State` and disposed cleanly when the dialog tears down. Doing
/// that from `_promptName` directly via `Future.whenComplete(dispose)`
/// trips `debugAssertNotDisposed` on the dialog's exit-transition
/// rebuilds.
class _BookmarkNameDialog extends StatefulWidget {
  final String title;
  final String initial;

  const _BookmarkNameDialog({required this.title, required this.initial});

  @override
  State<_BookmarkNameDialog> createState() => _BookmarkNameDialogState();
}

class _BookmarkNameDialogState extends State<_BookmarkNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Bookmark name'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
