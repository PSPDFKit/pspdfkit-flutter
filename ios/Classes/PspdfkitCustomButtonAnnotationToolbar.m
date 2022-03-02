#import "PspdfkitCustomButtonAnnotationToolbar.h"

@implementation PspdfkitCustomButtonAnnotationToolbar

#pragma mark - Lifecycle

- (instancetype)initWithAnnotationStateManager:(PSPDFAnnotationStateManager *)annotationStateManager {
    if ((self = [super initWithAnnotationStateManager:annotationStateManager])) {
        // The biggest challenge here isn't the clear button, but correctly updating the clear button if we actually can clear something or not.
        NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
        [dnc addObserver:self selector:@selector(annotationChangedNotification:) name:PSPDFAnnotationChangedNotification object:nil];
        [dnc addObserver:self selector:@selector(annotationChangedNotification:) name:PSPDFAnnotationsAddedNotification object:nil];
        [dnc addObserver:self selector:@selector(annotationChangedNotification:) name:PSPDFAnnotationsRemovedNotification object:nil];

        // We could also use the delegate, but this is cleaner.
        [dnc addObserver:self selector:@selector(willShowSpreadViewNotification:) name:PSPDFDocumentViewControllerWillBeginDisplayingSpreadViewNotification object:nil];

        // Add clear button
        UIImage *clearImage = [[PSPDFKitGlobal imageNamed:@"trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _clearAnnotationsButton = [PSPDFToolbarButton new];
        _clearAnnotationsButton.accessibilityLabel = @"Clear";
        [_clearAnnotationsButton setImage:clearImage];
        [_clearAnnotationsButton addTarget:self action:@selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        [self updateClearAnnotationButton];
        self.additionalButtons = @[_clearAnnotationsButton];
    }
    return self;
}

#pragma mark - Clear Button Action

- (void)clearButtonPressed:(id)sender {
    // Iterate over all visible pages and remove all but links and widgets (forms).
    PSPDFViewController *pdfController = self.annotationStateManager.pdfController;
    PSPDFDocument *document = pdfController.document;
    for (PSPDFPageView *pageView in pdfController.visiblePageViews) {
        NSArray<PSPDFAnnotation *> *annotations = [document annotationsForPageAtIndex:pageView.pageIndex type:PSPDFAnnotationTypeAll & ~(PSPDFAnnotationTypeLink | PSPDFAnnotationTypeWidget)];
        [document removeAnnotations:annotations options:nil];

        // Remove any annotation on the page as well (updates views)
        // Alternatively, you can call `reloadData` on the pdfController as well.
        for (PSPDFAnnotation *annotation in annotations) {
            [pageView removeAnnotation:annotation options:nil animated:YES];
        }
    }
}

#pragma mark - Notifications

// If we detect annotation changes, schedule a reload.
- (void)annotationChangedNotification:(NSNotification *)notification {
    // Re-evaluate toolbar button
    if (self.window) {
        [self updateClearAnnotationButton];
    }
}

- (void)willShowSpreadViewNotification:(NSNotification *)notification {
    [self updateClearAnnotationButton];
}

#pragma mark - PSPDFAnnotationStateManagerDelegate

- (void)annotationStateManager:(PSPDFAnnotationStateManager *)manager didChangeUndoState:(BOOL)undoEnabled redoState:(BOOL)redoEnabled {
    [super annotationStateManager:manager didChangeUndoState:undoEnabled redoState:redoEnabled];
    [self updateClearAnnotationButton];
}

#pragma mark - Private

- (void)updateClearAnnotationButton {
    __block BOOL annotationsFound = NO;
    PSPDFViewController *pdfController = self.annotationStateManager.pdfController;
    [pdfController.visiblePageIndexes enumerateIndexesUsingBlock:^(NSUInteger pageIndex, BOOL *stop) {
        NSArray<PSPDFAnnotation *> *annotations = [pdfController.document annotationsForPageAtIndex:pageIndex type:PSPDFAnnotationTypeAll & ~(PSPDFAnnotationTypeLink | PSPDFAnnotationTypeWidget)];
        if (annotations.count > 0) {
            annotationsFound = YES;
            *stop = YES;
        }
    }];
    self.clearAnnotationsButton.enabled = annotationsFound;
}

@end