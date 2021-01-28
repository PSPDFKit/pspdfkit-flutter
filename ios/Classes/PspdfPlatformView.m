//
//  Copyright © 2018-2021 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfPlatformView.h"
#import "PspdfkitFlutterHelper.h"
#import "PspdfkitFlutterConverter.h"

@import PSPDFKit;
@import PSPDFKitUI;

// Custom annotation toolbar subclass that adds a Clear button that removes all visible annotations.
@interface CustomButtonAnnotationToolbar : PSPDFAnnotationToolbar

@property (nonatomic) PSPDFToolbarButton *clearAnnotationsButton;

@end

@interface PspdfPlatformView() <PSPDFViewControllerDelegate>
@property int64_t platformViewId;
@property (nonatomic) FlutterMethodChannel *channel;
@property (nonatomic, weak) UIViewController *flutterViewController;
@property (nonatomic) PSPDFViewController *pdfViewController;
@property (nonatomic) PSPDFNavigationController *navigationController;
@end

@implementation PspdfPlatformView

- (nonnull UIView *)view {
    return self.navigationController.view ?: [UIView new];
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    NSString *name = [NSString stringWithFormat:@"com.pspdfkit.widget.%lld",viewId];
    _platformViewId = viewId;
    _channel = [FlutterMethodChannel methodChannelWithName:name binaryMessenger:messenger];

    _navigationController = [PSPDFNavigationController new];
    _navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    // View controller containment
    _flutterViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (_flutterViewController == nil) {
        NSLog(@"Warning: FlutterViewController is nil. This may lead to view container containment problems with PSPDFViewController since we no longer receive UIKit lifecycle events.");
    }
    [_flutterViewController addChildViewController:_navigationController];
    [_flutterViewController.view addSubview:_navigationController.view];
    [_navigationController didMoveToParentViewController:_flutterViewController];

    _pdfViewController = [[PSPDFViewController alloc] init];
    [_navigationController setViewControllers:@[_pdfViewController] animated:NO];

    self = [super init];

    __weak id weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        [weakSelf handleMethodCall:call result:result];
    }];

    return self;
}

- (void)dealloc {
    [self cleanup];
}

- (void)cleanup {
    self.pdfViewController.document = nil;
    [self.pdfViewController.view removeFromSuperview];
    [self.pdfViewController removeFromParentViewController];
    [self.navigationController.navigationBar removeFromSuperview];
    [self.navigationController.view removeFromSuperview];
    [self.navigationController removeFromParentViewController];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"initializePlatformView" isEqualToString:call.method]) {
        NSString *documentPath = call.arguments[@"document"];

        if (documentPath == nil || documentPath.length <= 0) {
            FlutterError *error = [FlutterError errorWithCode:@"" message:@"Document path may not be nil or empty." details:nil];
            result(error);
            return;
        }

        NSDictionary *configurationDictionary = call.arguments[@"configuration"];

        PSPDFDocument *document = [PspdfkitFlutterHelper documentFromPath:documentPath];
        [PspdfkitFlutterHelper unlockWithPasswordIfNeeded:document dictionary:configurationDictionary];

        BOOL isImageDocument = [PspdfkitFlutterHelper isImageDocument:documentPath];
        PSPDFConfiguration *configuration = [PspdfkitFlutterConverter configuration:configurationDictionary isImageDocument:isImageDocument];
        
        configuration = [configuration configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder * _Nonnull builder) {
            [builder overrideClass:PSPDFAnnotationToolbar.class withClass:CustomButtonAnnotationToolbar.class];
        }];

        self.pdfViewController = [[PSPDFViewController alloc] initWithDocument:document configuration:configuration];
        self.pdfViewController.appearanceModeManager.appearanceMode = [PspdfkitFlutterConverter appearanceMode:configurationDictionary];
        self.pdfViewController.pageIndex = [PspdfkitFlutterConverter pageIndex:configurationDictionary];
        self.pdfViewController.delegate = self;

        if ((id)configurationDictionary != NSNull.null) {
            [PspdfkitFlutterHelper setLeftBarButtonItems:configurationDictionary[@"leftBarButtonItems"] forViewController:self.pdfViewController];
            [PspdfkitFlutterHelper setRightBarButtonItems:configurationDictionary[@"rightBarButtonItems"] forViewController:self.pdfViewController];
            [PspdfkitFlutterHelper setToolbarTitle:configurationDictionary[@"toolbarTitle"] forViewController:self.pdfViewController];
        }

        [self.navigationController setViewControllers:@[self.pdfViewController] animated:NO];
        result(@(YES));
    } else {
        [PspdfkitFlutterHelper processMethodCall:call result:result forViewController:self.pdfViewController];
    }
}

# pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewControllerDidDismiss:(PSPDFViewController *)pdfController {
    // Don't hold on to the view controller object after dismissal.
    [self cleanup];
}

@end

@implementation CustomButtonAnnotationToolbar

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)initWithAnnotationStateManager:(PSPDFAnnotationStateManager *)annotationStateManager {
  if ((self = [super initWithAnnotationStateManager:annotationStateManager])) {
    // The biggest challenge here isn't the Clear button, but rather correctly updating the Clear button's states.
    NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
    [dnc addObserver:self selector:@selector(annotationChangedNotification:) name:PSPDFAnnotationChangedNotification object:nil];
    [dnc addObserver:self selector:@selector(annotationChangedNotification:) name:PSPDFAnnotationsAddedNotification object:nil];
    [dnc addObserver:self selector:@selector(annotationChangedNotification:) name:PSPDFAnnotationsRemovedNotification object:nil];

    // We could also use the delegate, but this is cleaner.
    [dnc addObserver:self selector:@selector(willShowSpreadViewNotification:) name:PSPDFDocumentViewControllerWillBeginDisplayingSpreadViewNotification object:nil];

    // Add Clear button.
    UIImage *clearImage = [[PSPDFKitGlobal imageNamed:@"trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _clearAnnotationsButton = [PSPDFToolbarButton new];
    _clearAnnotationsButton.accessibilityLabel = @"Clear";
    [_clearAnnotationsButton setImage:clearImage];
    [_clearAnnotationsButton addTarget:self action:@selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self updateClearAnnotationButton];
    self.additionalButtons = @[_clearAnnotationsButton];

    // Hide the callout and the signature buttons from the annotation toolbar.
    NSMutableArray <PSPDFAnnotationToolbarConfiguration *> *toolbarConfigurations = [NSMutableArray<PSPDFAnnotationToolbarConfiguration *> new];;
    for(PSPDFAnnotationToolbarConfiguration *toolbarConfiguration in self.configurations) {
      NSMutableArray<PSPDFAnnotationGroup *> *filteredGroups = [NSMutableArray<PSPDFAnnotationGroup *> new];
      for (PSPDFAnnotationGroup *group in toolbarConfiguration.annotationGroups) {
        NSMutableArray<PSPDFAnnotationGroupItem *> *filteredItems = [NSMutableArray<PSPDFAnnotationGroupItem *> new];
        for(PSPDFAnnotationGroupItem *item in group.items) {
          BOOL isCallout = [item.variant isEqualToString:PSPDFAnnotationVariantStringFreeTextCallout];
          BOOL isSignature = [item.type isEqualToString:PSPDFAnnotationStringSignature];
          if (!isCallout && !isSignature) {
            [filteredItems addObject:item];
          }
        }
        if (filteredItems.count) {
          [filteredGroups addObject:[PSPDFAnnotationGroup groupWithItems:filteredItems]];
        }
      }
      [toolbarConfigurations addObject:[[PSPDFAnnotationToolbarConfiguration alloc] initWithAnnotationGroups:filteredGroups]];
    }

    self.configurations = [toolbarConfigurations copy];
  }
  return self;
}

- (void)dealloc {
  [NSNotificationCenter.defaultCenter removeObserver:self];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Clear Button Action

- (void)clearButtonPressed:(id)sender {
  // Iterate over all visible pages and remove everything but links and widgets (forms).
  PSPDFViewController *pdfController = self.annotationStateManager.pdfController;
  PSPDFDocument *document = pdfController.document;
  for (PSPDFPageView *pageView in pdfController.visiblePageViews) {
    NSArray<PSPDFAnnotation *> *annotations = [document annotationsForPageAtIndex:pageView.pageIndex type:PSPDFAnnotationTypeAll & ~(PSPDFAnnotationTypeLink | PSPDFAnnotationTypeWidget)];
    [document removeAnnotations:annotations options:nil];

    // Remove any annotation on the page as well (updates views).
    // Alternatively, you can call `reloadData` on the `pdfController` as well.
    for (PSPDFAnnotation *annotation in annotations) {
      [pageView removeAnnotation:annotation options:nil animated:YES];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notifications

// If we detect annotation changes, schedule a reload.
- (void)annotationChangedNotification:(NSNotification *)notification {
  // Reevaluate toolbar button
  if (self.window) {
    [self updateClearAnnotationButton];
  }
}

- (void)willShowSpreadViewNotification:(NSNotification *)notification {
  [self updateClearAnnotationButton];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFAnnotationStateManagerDelegate

- (void)annotationStateManager:(PSPDFAnnotationStateManager *)manager didChangeUndoState:(BOOL)undoEnabled redoState:(BOOL)redoEnabled {
  [super annotationStateManager:manager didChangeUndoState:undoEnabled redoState:redoEnabled];
  [self updateClearAnnotationButton];
}

///////////////////////////////////////////////////////////////////////////////////////////
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
