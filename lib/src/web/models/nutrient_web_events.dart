/// Enum representing the available event listeners for the PSPDFKit Web SDK.
enum NutrientWebEvent {
  // ViewState Events
  viewStateChange,
  viewStateCurrentPageIndexChange,
  viewStateZoomChange,

  // AnnotationPreset Events
  annotationPresetsUpdate,

  // Annotation Events
  annotationsLoad,
  annotationsChange,
  annotationsCreate,
  annotationsTransform,
  annotationsUpdate,
  annotationsDelete,
  annotationsPress,
  annotationsWillSave,
  annotationsDidSave,
  annotationsFocus,
  annotationsBlur,
  annotationsWillChange,

  // Bookmark Events
  bookmarksLoad,
  bookmarksChange,
  bookmarksCreate,
  bookmarksUpdate,
  bookmarksDelete,
  bookmarksWillSave,
  bookmarksDidSave,

  // Comment Events
  commentsLoad,
  commentsChange,
  commentsCreate,
  commentsUpdate,
  commentsDelete,
  commentsWillSave,
  commentsDidSave,

  // Document Events
  documentChange,
  documentSaveStateChange,

  // Form Field Value Events
  formFieldValuesUpdate,
  formFieldValuesWillSave,
  formFieldValuesDidSave,

  // Form Field Events
  formFieldsLoad,
  formFieldsChange,
  formFieldsCreate,
  formFieldsUpdate,
  formFieldsDelete,
  formFieldsWillSave,
  formFieldsDidSave,

  // Form Events
  formsWillSubmit,
  formsDidSubmit,

  // Ink Signature Events
  inkSignaturesCreate,
  inkSignaturesUpdate,
  inkSignaturesDelete,
  inkSignaturesChange,

  // Stored Signature Events
  storedSignaturesCreate,
  storedSignaturesUpdate,
  storedSignaturesDelete,
  storedSignaturesChange,

  // Instant Events
  instantConnectedClientsChange,

  // Selection Events
  textSelectionChange,
  annotationSelectionChange,

  // Press Events
  pagePress,
  textLinePress,

  // Search Events
  searchStateChange,
  searchTermChange,

  // History Events
  historyUndo,
  historyRedo,
  historyChange,
  historyWillChange,
  historyClear,

  // Crop Events
  cropAreaChangeStart,
  cropAreaChangeStop,

  // Document Comparison UI Events
  documentComparisonUIStart,
  documentComparisonUIEnd,
}

extension NutrientWebEventExtension on NutrientWebEvent {
  String get name {
    // Return the exact event name string as specified in PSPDFKit web documentation
    switch (this) {
      // ViewState Events
      case NutrientWebEvent.viewStateChange:
        return 'viewState.change';
      case NutrientWebEvent.viewStateCurrentPageIndexChange:
        return 'viewState.currentPageIndex.change';
      case NutrientWebEvent.viewStateZoomChange:
        return 'viewState.zoom.change';

      // Annotation Events
      case NutrientWebEvent.annotationPresetsUpdate:
        return 'annotationPresets.update';
      case NutrientWebEvent.annotationsLoad:
        return 'annotations.load';
      case NutrientWebEvent.annotationsChange:
        return 'annotations.change';
      case NutrientWebEvent.annotationsCreate:
        return 'annotations.create';
      case NutrientWebEvent.annotationsTransform:
        return 'annotations.transform';
      case NutrientWebEvent.annotationsUpdate:
        return 'annotations.update';
      case NutrientWebEvent.annotationsDelete:
        return 'annotations.delete';
      case NutrientWebEvent.annotationsPress:
        return 'annotations.press';
      case NutrientWebEvent.annotationsWillSave:
        return 'annotations.willSave';
      case NutrientWebEvent.annotationsDidSave:
        return 'annotations.didSave';
      case NutrientWebEvent.annotationsFocus:
        return 'annotations.focus';
      case NutrientWebEvent.annotationsBlur:
        return 'annotations.blur';
      case NutrientWebEvent.annotationsWillChange:
        return 'annotations.willChange';

      // Bookmark Events
      case NutrientWebEvent.bookmarksChange:
        return 'bookmarks.change';
      case NutrientWebEvent.bookmarksWillSave:
        return 'bookmarks.willSave';
      case NutrientWebEvent.bookmarksDidSave:
        return 'bookmarks.didSave';
      case NutrientWebEvent.bookmarksLoad:
        return 'bookmarks.load';
      case NutrientWebEvent.bookmarksCreate:
        return 'bookmarks.create';
      case NutrientWebEvent.bookmarksUpdate:
        return 'bookmarks.update';
      case NutrientWebEvent.bookmarksDelete:
        return 'bookmarks.delete';

      // Comment Events
      case NutrientWebEvent.commentsChange:
        return 'comments.change';
      case NutrientWebEvent.commentsWillSave:
        return 'comments.willSave';
      case NutrientWebEvent.commentsDidSave:
        return 'comments.didSave';
      case NutrientWebEvent.commentsLoad:
        return 'comments.load';
      case NutrientWebEvent.commentsCreate:
        return 'comments.create';
      case NutrientWebEvent.commentsUpdate:
        return 'comments.update';
      case NutrientWebEvent.commentsDelete:
        return 'comments.delete';

      // Document Events
      case NutrientWebEvent.documentChange:
        return 'document.change';
      case NutrientWebEvent.documentSaveStateChange:
        return 'document.saveStateChange';

      // Form Field Events
      case NutrientWebEvent.formFieldValuesUpdate:
        return 'formFieldValues.update';
      case NutrientWebEvent.formFieldValuesWillSave:
        return 'formFieldValues.willSave';
      case NutrientWebEvent.formFieldValuesDidSave:
        return 'formFieldValues.didSave';
      case NutrientWebEvent.formFieldsLoad:
        return 'formFields.load';
      case NutrientWebEvent.formFieldsChange:
        return 'formFields.change';
      case NutrientWebEvent.formFieldsCreate:
        return 'formFields.create';
      case NutrientWebEvent.formFieldsUpdate:
        return 'formFields.update';
      case NutrientWebEvent.formFieldsDelete:
        return 'formFields.delete';
      case NutrientWebEvent.formFieldsWillSave:
        return 'formFields.willSave';
      case NutrientWebEvent.formFieldsDidSave:
        return 'formFields.didSave';

      // Form Events
      case NutrientWebEvent.formsWillSubmit:
        return 'forms.willSubmit';
      case NutrientWebEvent.formsDidSubmit:
        return 'forms.didSubmit';

      // Signature Events
      case NutrientWebEvent.inkSignaturesCreate:
        return 'inkSignatures.create';
      case NutrientWebEvent.inkSignaturesUpdate:
        return 'inkSignatures.update';
      case NutrientWebEvent.inkSignaturesDelete:
        return 'inkSignatures.delete';
      case NutrientWebEvent.inkSignaturesChange:
        return 'inkSignatures.change';
      case NutrientWebEvent.storedSignaturesCreate:
        return 'storedSignatures.create';
      case NutrientWebEvent.storedSignaturesUpdate:
        return 'storedSignatures.update';
      case NutrientWebEvent.storedSignaturesDelete:
        return 'storedSignatures.delete';
      case NutrientWebEvent.storedSignaturesChange:
        return 'storedSignatures.change';

      // Instant Events
      case NutrientWebEvent.instantConnectedClientsChange:
        return 'instant.connectedClients.change';

      // Selection Events
      case NutrientWebEvent.textSelectionChange:
        return 'textSelection.change';
      case NutrientWebEvent.annotationSelectionChange:
        return 'annotationSelection.change';

      // Press Events
      case NutrientWebEvent.pagePress:
        return 'page.press';
      case NutrientWebEvent.textLinePress:
        return 'textLine.press';

      // Search Events
      case NutrientWebEvent.searchStateChange:
        return 'search.stateChange';
      case NutrientWebEvent.searchTermChange:
        return 'search.termChange';

      // History Events
      case NutrientWebEvent.historyUndo:
        return 'history.undo';
      case NutrientWebEvent.historyRedo:
        return 'history.redo';
      case NutrientWebEvent.historyChange:
        return 'history.change';
      case NutrientWebEvent.historyWillChange:
        return 'history.willChange';
      case NutrientWebEvent.historyClear:
        return 'history.clear';

      // Crop Events
      case NutrientWebEvent.cropAreaChangeStart:
        return 'cropArea.changeStart';
      case NutrientWebEvent.cropAreaChangeStop:
        return 'cropArea.changeStop';

      // Document Comparison UI Events
      case NutrientWebEvent.documentComparisonUIStart:
        return 'documentComparisonUI.start';
      case NutrientWebEvent.documentComparisonUIEnd:
        return 'documentComparisonUI.end';
    }
  }
}
