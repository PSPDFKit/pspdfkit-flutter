//
//  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfPlatformView.h"
#include <Foundation/Foundation.h>
#import "PspdfkitFlutterHelper.h"
#import "PspdfkitFlutterConverter.h"
#import "nutrient_flutter-Swift.h"

@import PSPDFKit;
@import PSPDFKitUI;

// Forward declaration for Swift class - actual implementation in PspdfkitApiImpl.swift
@class AutomaticConflictResolutionManager;

@interface PspdfPlatformView() <PSPDFViewControllerDelegate>
@property int64_t platformViewId;
@property (nonatomic) FlutterMethodChannel *channel;
@property (nonatomic) FlutterMethodChannel *broadcastChannel;
@property (nonatomic, weak) UIViewController *flutterViewController;
@property (nonatomic) PSPDFViewController *pdfViewController;
@property (nonatomic) PSPDFNavigationController *navigationController;
@property (nonatomic) FlutterPdfDocument *flutterPdfDocument;
@property (nonatomic) AnnotationManagerImpl *annotationManager;
@property (nonatomic) BookmarkManagerImpl *bookmarkManager;
@property (nonatomic) NSObject<FlutterBinaryMessenger> *binaryMessenger;
@property (nonatomic) PSPDFPageIndex initialPageIndex; // Store the initial page index from configuration
@property PspdfkitPlatformViewImpl *platformViewImpl;
@property (nonatomic, strong) AutomaticConflictResolutionManager *conflictResolutionManager; // For automatic file conflict resolution
@end

@implementation PspdfPlatformView

// Static registry for PSPDFViewController instances, keyed by view ID
static NSMutableDictionary<NSNumber *, PSPDFViewController *> *viewControllerRegistry;

#pragma mark - Static Registry Methods

+ (void)initialize {
    if (self == [PspdfPlatformView class]) {
        viewControllerRegistry = [NSMutableDictionary dictionary];
    }
}

+ (void)registerViewController:(int64_t)viewId controller:(PSPDFViewController *)controller {
    @synchronized (viewControllerRegistry) {
        viewControllerRegistry[@(viewId)] = controller;
        NSLog(@"Registered PSPDFViewController for view %lld", viewId);
    }
}

+ (void)unregisterViewController:(int64_t)viewId {
    @synchronized (viewControllerRegistry) {
        [viewControllerRegistry removeObjectForKey:@(viewId)];
        NSLog(@"Unregistered PSPDFViewController for view %lld", viewId);
    }
}

+ (PSPDFViewController *)getViewController:(int64_t)viewId {
    @synchronized (viewControllerRegistry) {
        return viewControllerRegistry[@(viewId)];
    }
}

#pragma mark - FlutterPlatformView

- (nonnull UIView *)view {
    return self.navigationController.view ?: [UIView new];
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    
    if ((self = [super init])) {
        _platformViewId = viewId;
        _channel = [FlutterMethodChannel methodChannelWithName:[NSString stringWithFormat:@"com.nutrient.widget.%lld", viewId] binaryMessenger:messenger];
        _broadcastChannel = [FlutterMethodChannel methodChannelWithName:@"com.nutrient.global" binaryMessenger:messenger];
        _binaryMessenger = messenger;
        _navigationController = [PSPDFNavigationController new];
        _navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _navigationController.view.frame = frame;
        _platformViewImpl = [[PspdfkitPlatformViewImpl alloc] init];
        // Get the list of custom toolbar items as an array of dictionaries
        NSArray<NSDictionary *> *customToolbarItems = args[@"customToolbarItems"];
      
        [_platformViewImpl registerWithBinaryMessenger:messenger viewId:[NSString stringWithFormat:@"%lld",viewId] customToolbarItems: customToolbarItems];
        
        // View controller containment
        _flutterViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        if (_flutterViewController != nil) {
            [_flutterViewController addChildViewController:_navigationController];
            [_navigationController didMoveToParentViewController:_flutterViewController];
        }

        NSString *documentPath = args[@"document"];
        if ([documentPath isKindOfClass:[NSString class]] == NO || [documentPath length] == 0) {
            _pdfViewController = [[PSPDFViewController alloc] init];
        } else {
           
            NSDictionary *configurationDictionary = [PspdfkitFlutterConverter processConfigurationOptionsDictionaryForPrefix:args[@"configuration"]];
            PSPDFDocument *document = [PspdfkitFlutterHelper documentFromPath:documentPath];
            
            NSArray *measurementValueConfigurations = configurationDictionary[@"measurementValueConfigurations"];
          
            [PspdfkitFlutterHelper unlockWithPasswordIfNeeded:document dictionary:configurationDictionary];

            BOOL isImageDocument = [PspdfkitFlutterHelper isImageDocument:documentPath];
            PSPDFConfiguration *configuration = [PspdfkitFlutterConverter configuration:configurationDictionary isImageDocument:isImageDocument];
            
            // Only update signature settings if signatureSavingStrategy is specified in the configuration
            if (configurationDictionary[@"signatureSavingStrategy"]) {
                PSPDFConfiguration *updatedConfig = [configuration configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder *builder) {
                    builder.signatureStore = [[PSPDFKeychainSignatureStore alloc] init];
                }];
                configuration = updatedConfig;
            }
            
            _pdfViewController = [[PSPDFViewController alloc] initWithDocument:document configuration:configuration];
            _pdfViewController.appearanceModeManager.appearanceMode = [PspdfkitFlutterConverter appearanceMode:configurationDictionary];
            // Store the initial page index from the configuration to set it later
            _initialPageIndex = [PspdfkitFlutterConverter pageIndex:configurationDictionary];
            _pdfViewController.delegate = self;
            
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(documentDidFinishRendering) name:PSPDFDocumentViewControllerDidConfigureSpreadViewNotification object:nil];

            if ((id)configurationDictionary != NSNull.null) {
                NSString *key = @"leftBarButtonItems";
                if (configurationDictionary[key]) {
                    [PspdfkitFlutterHelper setLeftBarButtonItems:configurationDictionary[key] forViewController:_pdfViewController];
                }
                key = @"rightBarButtonItems";
                if (configurationDictionary[key]) {
                    [PspdfkitFlutterHelper setRightBarButtonItems:configurationDictionary[key] forViewController:_pdfViewController];
                }
                key = @"invertColors";
                if (configurationDictionary[key]) {
                    _pdfViewController.appearanceModeManager.appearanceMode = [configurationDictionary[key] boolValue] ? PSPDFAppearanceModeNight : PSPDFAppearanceModeDefault;
                }
                key = @"toolbarTitle";
                if (configurationDictionary[key]) {
                    [PspdfkitFlutterHelper setToolbarTitle:configurationDictionary[key] forViewController:_pdfViewController];
                }
                
                NSArray *annotationToolbarGroupingitems = configurationDictionary[@"toolbarItemGrouping"];
                
                if (annotationToolbarGroupingitems){
                    PSPDFAnnotationToolbarConfiguration *configuration = [AnnotationToolbarItemsGrouping convertAnnotationToolbarConfigurationWithToolbarItems:annotationToolbarGroupingitems];
                    _pdfViewController.annotationToolbarController.annotationToolbar.configurations = @[configuration];
                }
            }
            // Set Measurement value configurations
            if (measurementValueConfigurations != nil) {
                for (NSDictionary *measurementValueConfigurationDictionary in measurementValueConfigurations) {
                    [PspdfkitMeasurementConvertor addMeasurementValueConfigurationWithDocument:_pdfViewController.document configuration: measurementValueConfigurationDictionary];
                }
            }

            // Configure file conflict resolution for embedded views
            NSString *fileConflictResolutionString = configurationDictionary[@"fileConflictResolution"];
            if (fileConflictResolutionString != nil) {
                NSNumber *resolutionNumber = [PspdfkitFlutterConverter fileConflictResolution:fileConflictResolutionString];
                if (resolutionNumber != nil) {
                    PSPDFFileConflictResolution resolution = (PSPDFFileConflictResolution)[resolutionNumber unsignedIntegerValue];
                    _conflictResolutionManager = [[AutomaticConflictResolutionManager alloc] initWithResolution:resolution];
                }
            }
        }

        if (_pdfViewController.configuration.userInterfaceViewMode == PSPDFUserInterfaceViewModeNever) {
            // In this mode PDFViewController doesn't hide the navigation bar on its own to avoid getting stuck.
            _navigationController.navigationBarHidden = YES;
        }
        [_navigationController setViewControllers:@[_pdfViewController] animated:NO];

        __weak id weakSelf = self;
        
        // Handle annotation menu configuration if present (shared for both branches)
        NSDictionary *configurationDictionary = [PspdfkitFlutterConverter processConfigurationOptionsDictionaryForPrefix:args[@"configuration"]];
        if (configurationDictionary && (id)configurationDictionary != NSNull.null && configurationDictionary[@"annotationMenuConfiguration"]) {
            // Pass the raw dictionary to the Swift implementation to handle parsing
            NSDictionary *annotationMenuDict = configurationDictionary[@"annotationMenuConfiguration"];
            if ([annotationMenuDict isKindOfClass:[NSDictionary class]]) {
                [_platformViewImpl setAnnotationMenuConfigurationFromDictionary:annotationMenuDict];
            }
        }
        
        [_platformViewImpl setViewControllerWithController:_pdfViewController];

        [_channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            [weakSelf handleMethodCall:call result:result];
        }];

        // Register the PSPDFViewController in the static registry for adapter access via FFI
        [PspdfPlatformView registerViewController:viewId controller:_pdfViewController];

        // Notify Dart that the PSPDFViewController is ready for adapter access
        [_channel invokeMethod:@"onViewControllerReady" arguments:nil];
        NSLog(@"Sent onViewControllerReady notification to Dart");
    }

    return self;
}

- (void)documentDidFinishRendering {
    // Remove observer after the initial notification
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:PSPDFDocumentViewControllerDidConfigureSpreadViewNotification
                                                object:nil];

    // Set the initial page index after the document has fully rendered
    if (_initialPageIndex > 0) {
        _pdfViewController.pageIndex = _initialPageIndex;
    }

    NSString *documentId = self.pdfViewController.document.UID;
    if (documentId != nil) {
        NSDictionary *arguments = @{
            @"documentId": documentId,
        };
        _flutterPdfDocument = [[FlutterPdfDocument alloc] initWithViewController:self.pdfViewController];
        [_flutterPdfDocument registerWithBinaryMessenger:_binaryMessenger];

        // Create and register AnnotationManager for this document
        NSError *annotationError = nil;
        _annotationManager = [AnnotationManagerImpl createAndInitializeWithDocument:self.pdfViewController.document binaryMessenger:_binaryMessenger error:&annotationError];
        if (annotationError) {
            [_channel invokeMethod:@"onDocumentError" arguments:@{
                @"error": annotationError.localizedDescription ?: @"Failed to initialize annotation manager",
                @"type": @"annotationManager"
            }];
        }

        // Create and register BookmarkManager for this document
        NSError *bookmarkError = nil;
        _bookmarkManager = [BookmarkManagerImpl createAndInitializeWithDocument:self.pdfViewController.document binaryMessenger:_binaryMessenger error:&bookmarkError];
        if (bookmarkError) {
            [_channel invokeMethod:@"onDocumentError" arguments:@{
                @"error": bookmarkError.localizedDescription ?: @"Failed to initialize bookmark manager",
                @"type": @"bookmarkManager"
            }];
        }

        [_platformViewImpl onDocumentLoadedWithDocumentId:documentId];
        [_channel invokeMethod:@"onDocumentLoaded" arguments:arguments];
    }
}

- (void) pdfViewController:(PSPDFViewController *)pdfController willBeginDisplayingPageView:(PSPDFPageView *)pageView forPageAtIndex:(NSInteger)pageIndex {
    NSDictionary *arguments = @{
        @"pageIndex": @(pageIndex),
        @"documentId": pdfController.document.UID,
    };
    [_channel invokeMethod:@"onPageChanged" arguments: arguments];
}

- (void)dealloc {
    [self cleanup];
}

- (void)cleanup {
    // Unregister the PSPDFViewController from the static registry
    [PspdfPlatformView unregisterViewController:self.platformViewId];

    [self.flutterPdfDocument unRegisterWithBinaryMessenger:_binaryMessenger];
    self.flutterPdfDocument = nil;

    // Cleanup AnnotationManager
    if (self.annotationManager != nil) {
        [self.annotationManager unregisterWithBinaryMessenger:_binaryMessenger];
        // TODO: Fix Objective-C bridging for unregisterDocument method
        // [AnnotationManagerImpl unregisterDocumentWithId:self.pdfViewController.document.UID];
        self.annotationManager = nil;
    }

    // Cleanup conflict resolution manager
    self.conflictResolutionManager = nil;

    [self.platformViewImpl unRegisterWithBinaryMessenger:_binaryMessenger];
    self.platformViewImpl = nil;
    self.pdfViewController.document = nil;
    [self.pdfViewController.view removeFromSuperview];
    [self.pdfViewController removeFromParentViewController];
    [self.navigationController.navigationBar removeFromSuperview];
    [self.navigationController.view removeFromSuperview];
    [self.navigationController removeFromParentViewController];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    [PspdfkitFlutterHelper processMethodCall:call result:result forViewController:self.pdfViewController];
}


# pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewControllerDidDismiss:(PSPDFViewController *)pdfController {
    // Don't hold on to the view controller object after dismissal.
    [self cleanup];
}

@end

#pragma mark - C FFI Functions for Adapter Bridge

/// Gets the PSPDFViewController registered for a given view ID.
/// This function is called from Dart via FFI to allow adapters to access
/// the native PSPDFViewController from the PspdfPlatformView registry.
///
/// @param viewId The platform view ID.
/// @return The PSPDFViewController pointer, or NULL if not registered.
void* nutrient_get_view_controller(int64_t viewId) {
    PSPDFViewController *controller = [PspdfPlatformView getViewController:viewId];
    return (__bridge void *)controller;
}
