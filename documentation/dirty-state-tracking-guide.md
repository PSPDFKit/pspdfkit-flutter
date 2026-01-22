# Dirty State Tracking

Track unsaved changes in PDF documents to prompt users before discarding modifications.

## Quick Start

Use the cross-platform `hasUnsavedChanges()` method for simple dirty state checking:

```dart
final hasChanges = await document.hasUnsavedChanges();
if (hasChanges) {
  final shouldSave = await showSaveDialog();
  if (shouldSave) {
    await document.save();
  }
}
```

## Cross-Platform API

| Method | Description |
|--------|-------------|
| `hasUnsavedChanges()` | Returns `true` if the document has any unsaved changes |

**Platform behavior:**

- **iOS**: Checks `document.hasDirtyAnnotations`
- **Android**: Checks annotation, form, and bookmark providers
- **Web**: Checks `instance.hasUnsavedChanges()`

## Platform-Specific APIs

### iOS

| Method | Description |
|--------|-------------|
| `iOSHasDirtyAnnotations()` | Check if document has dirty annotations |
| `iOSGetAnnotationIsDirty(pageIndex, annotationId)` | Check if specific annotation is dirty |
| `iOSSetAnnotationIsDirty(pageIndex, annotationId, isDirty)` | Set annotation dirty state |
| `iOSClearNeedsSaveFlag()` | Clear the needs-save flag for all annotations |

```dart
if (Platform.isIOS) {
  // Check document-level dirty state
  final hasDirty = await document.iOSHasDirtyAnnotations();

  // Check individual annotation
  final isDirty = await document.iOSGetAnnotationIsDirty(0, annotationId);

  // Mark annotation as clean
  await document.iOSSetAnnotationIsDirty(0, annotationId, false);

  // Clear needs-save flag after programmatic changes
  await document.iOSClearNeedsSaveFlag();
}
```

### Android

| Method | Description |
|--------|-------------|
| `androidHasUnsavedAnnotationChanges()` | Check annotation provider for changes |
| `androidHasUnsavedFormChanges()` | Check form provider for changes |
| `androidHasUnsavedBookmarkChanges()` | Check bookmark provider for changes |
| `androidGetBookmarkIsDirty(bookmarkId)` | Check if specific bookmark is dirty |
| `androidClearBookmarkDirtyState(bookmarkId)` | Clear bookmark dirty state |
| `androidGetFormFieldIsDirty(fieldName)` | Check if specific form field is dirty |

```dart
if (Platform.isAndroid) {
  // Check each provider
  final annotationsChanged = await document.androidHasUnsavedAnnotationChanges();
  final formsChanged = await document.androidHasUnsavedFormChanges();
  final bookmarksChanged = await document.androidHasUnsavedBookmarkChanges();

  // Check individual items
  final isDirty = await document.androidGetFormFieldIsDirty('fieldName');

  // Clear bookmark dirty state (only bookmarks can be cleared on Android)
  await document.androidClearBookmarkDirtyState(bookmarkId);
}
```

### Web

| Method | Description |
|--------|-------------|
| `webHasUnsavedChanges()` | Check if web instance has unsaved changes |

```dart
if (kIsWeb) {
  final hasChanges = await document.webHasUnsavedChanges();
}
```

## Feature Matrix

| Feature | Android | iOS | Web |
|---------|:-------:|:---:|:---:|
| `hasUnsavedChanges()` | ✅ | ✅ | ✅ |
| Document-level dirty check | ✅ | ✅ | ✅ |
| Per-annotation dirty check | ❌ | ✅ | ❌ |
| Set annotation dirty state | ❌ | ✅ | ❌ |
| Clear needs-save flag | Bookmarks only | ✅ | ❌ |
| Form changes check | ✅ | ❌ | ❌ |
| Per-form-field dirty check | ✅ | ❌ | ❌ |
| Bookmark changes check | ✅ | ❌ | ❌ |
| Per-bookmark dirty check | ✅ | ❌ | ❌ |

## Common Patterns

### Prevent Accidental Data Loss

```dart
PopScope(
  canPop: !_hasUnsavedChanges,
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;
    final shouldDiscard = await _showDiscardDialog();
    if (shouldDiscard && mounted) {
      Navigator.of(context).pop();
    }
  },
  child: // your widget
)
```

### Programmatic Changes Without Save Prompt (iOS)

```dart
// Add annotation programmatically
await document.addAnnotation(annotation);

// Clear needs-save flag so user isn't prompted
if (Platform.isIOS) {
  await document.iOSClearNeedsSaveFlag();
}
```

