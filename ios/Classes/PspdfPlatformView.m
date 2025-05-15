//
//  Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
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
#import "pspdfkit_flutter-Swift.h"

@import PSPDFKit;
@import PSPDFKitUI;

// Custom subclass to control swipe-to-delete based on allowAnnotationDeletion
@interface CustomAnnotationTableViewController : PSPDFAnnotationTableViewController
@property (nonatomic, assign) BOOL allowAnnotationDeletion;
@end

@implementation CustomAnnotationTableViewController

// Override to control swipe-to-delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.allowAnnotationDeletion; // Control editing based on the property
}

@end

@interface PspdfPlatformView() <PSPDFViewControllerDelegate, PSPDFAnnotationTableViewControllerDelegate>
@property int64_t platformViewId;
@property (nonatomic) FlutterMethodChannel *channel;
@property (nonatomic) FlutterMethodChannel *broadcastChannel;
@property (nonatomic, weak) UIViewController *flutterViewController;
@property (nonatomic) PSPDFViewController *pdfViewController;
@property (nonatomic) PSPDFNavigationController *navigationController;
@property (nonatomic) FlutterPdfDocument *flutterPdfDocument;
@property (nonatomic) NSObject<FlutterBinaryMessenger> *binaryMessenger;
@property (nonatomic, assign) BOOL allowAnnotationDeletion;
@property PspdfkitPlatformViewImpl *platformViewImpl;
@end

@implementation PspdfPlatformView

- (nonnull UIView *)view {
    return self.navigationController.view ?: [UIView new];
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    
    if ((self = [super init])) {
        _channel = [FlutterMethodChannel methodChannelWithName:[NSString stringWithFormat:@"com.pspdfkit.widget.%lld", viewId] binaryMessenger:messenger];
        _broadcastChannel = [FlutterMethodChannel methodChannelWithName:@"com.pspdfkit.global" binaryMessenger:messenger];
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
        if (_flutterViewController == nil) {
            NSLog(@"Warning: FlutterViewController is nil. This may lead to view container containment problems with PSPDFViewController since we no longer receive UIKit lifecycle events.");
        } else {
            [_flutterViewController addChildViewController:_navigationController];
            [_navigationController didMoveToParentViewController:_flutterViewController];
        }

        NSString *documentPath = args[@"document"];
        if ([documentPath isKindOfClass:[NSString class]] == NO || [documentPath length] == 0) {
            NSLog(@"Warning: 'document' argument is not a string. Showing an empty view in default configuration.");
            _pdfViewController = [[PSPDFViewController alloc] init];
        } else {
           
            NSDictionary *configurationDictionary = [PspdfkitFlutterConverter processConfigurationOptionsDictionaryForPrefix:args[@"configuration"]];
            PSPDFDocument *document = [PspdfkitFlutterHelper documentFromPath:documentPath];

            // Extract and assign allowAnnotationDeletion
            BOOL allowAnnotationDeletion = YES;
            if (configurationDictionary[@"allowAnnotationDeletion"] != nil) {
                allowAnnotationDeletion = [configurationDictionary[@"allowAnnotationDeletion"] boolValue];
            }
            self.allowAnnotationDeletion = allowAnnotationDeletion;
            NSLog(@"[PSPDFKit] allowAnnotationDeletion: %@", self.allowAnnotationDeletion ? @"YES" : @"NO");


            BOOL askForAnnotationUsername = YES;
            if (configurationDictionary[@"askForAnnotationUsername"] != nil) {
                askForAnnotationUsername = [configurationDictionary[@"askForAnnotationUsername"] boolValue];
            }

            if (askForAnnotationUsername == NO) {
                document.defaultAnnotationUsername = configurationDictionary[@"defaultAuthorName"];
            }
            
            NSArray *measurementValueConfigurations = configurationDictionary[@"measurementValueConfigurations"];
          
            [PspdfkitFlutterHelper unlockWithPasswordIfNeeded:document dictionary:configurationDictionary];

            BOOL isImageDocument = [PspdfkitFlutterHelper isImageDocument:documentPath];
            PSPDFConfiguration *configuration = [PspdfkitFlutterConverter configuration:configurationDictionary isImageDocument:isImageDocument];

            // Start listening to the annotation's change notification.
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(annotationChangedNotification:) name:PSPDFAnnotationChangedNotification object:nil];
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(annotationChangedNotification:) name:PSPDFAnnotationsAddedNotification object:nil];
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(annotationChangedNotification:) name:PSPDFAnnotationsRemovedNotification object:nil];
            
            // Only update signature settings if signatureSavingStrategy is specified in the configuration
            if (configurationDictionary[@"signatureSavingStrategy"]) {
                PSPDFConfiguration *updatedConfig = [configuration configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder *builder) {
                    builder.signatureStore = [[PSPDFKeychainSignatureStore alloc] init];
                }];
                configuration = updatedConfig;
            }
            
            // Update the configuration to set 'shouldAskForAnnotationUsername'
            PSPDFConfiguration *updatedConfiguration = [configuration configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder *builder) {
                builder.shouldAskForAnnotationUsername = askForAnnotationUsername;
                NSLog(@"[PSPDFKit] shouldAskForAnnotationUsername: %@", builder.shouldAskForAnnotationUsername ? @"YES" : @"NO");
                NSLog(@"[PSPDFKit] defaultAuthorName %@", configurationDictionary[@"defaultAuthorName"]);

                // Override PSPDFAnnotationTableViewController with our custom subclass
                [builder overrideClass:[PSPDFAnnotationTableViewController class] withClass:[CustomAnnotationTableViewController class]];
            }];

            _pdfViewController = [[PSPDFViewController alloc] initWithDocument:document configuration:updatedConfiguration];
            _pdfViewController.appearanceModeManager.appearanceMode = [PspdfkitFlutterConverter appearanceMode:configurationDictionary];
            _pdfViewController.pageIndex = [PspdfkitFlutterConverter pageIndex:configurationDictionary];
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
        }

        if (_pdfViewController.configuration.userInterfaceViewMode == PSPDFUserInterfaceViewModeNever) {
            // In this mode PDFViewController doesn’t hide the navigation bar on its own to avoid getting stuck.
            _navigationController.navigationBarHidden = YES;
        }
        [_navigationController setViewControllers:@[_pdfViewController] animated:NO];

        __weak id weakSelf = self;
        
        [_platformViewImpl setViewControllerWithController:_pdfViewController];
        
        [_channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            [weakSelf handleMethodCall:call result:result];
        }];
    }

    return self;
}

- (void)annotationChangedNotification:(NSNotification *)notification {
    NSDictionary *arguments = @{
        @"documentId": self.pdfViewController.document.UID,
    };
    [_channel invokeMethod:@"onAnnotationsChanged" arguments: arguments];
}

// Helper method to find the annotation controller
- (PSPDFAnnotationTableViewController *)findAnnotationControllerIn:(UIViewController *)controller {
    if ([controller isKindOfClass:[PSPDFAnnotationTableViewController class]]) {
        return (PSPDFAnnotationTableViewController *)controller;
    } else if ([controller isKindOfClass:[UINavigationController class]]) {
        return [self findAnnotationControllerIn:((UINavigationController *)controller).topViewController];
    } else if ([controller isKindOfClass:[PSPDFContainerViewController class]]) {
        for (UIViewController *childController in ((PSPDFContainerViewController *)controller).viewControllers) {
            PSPDFAnnotationTableViewController *foundController = [self findAnnotationControllerIn:childController];
            if (foundController) {
                return foundController;
            }
        }
    }
    return nil;
}

// Implement the delegate method
- (BOOL)pdfViewController:(PSPDFViewController *)pdfController
     shouldShowController:(UIViewController *)controller
                  options:(NSDictionary<NSString *, id> *)options
        animated:(BOOL)animated {
    PSPDFAnnotationTableViewController *annotationController = [self findAnnotationControllerIn:controller];
    if (annotationController) {
        if ([annotationController isKindOfClass:[CustomAnnotationTableViewController class]]) {
            CustomAnnotationTableViewController *customController = (CustomAnnotationTableViewController *)annotationController;
            customController.allowAnnotationDeletion = self.allowAnnotationDeletion;
            NSLog(@"[PSPDFKit] Setting allowAnnotationDeletion to %@", self.allowAnnotationDeletion ? @"YES" : @"NO");
        }
    }
    return YES;
}

- (void)documentDidFinishRendering {
    // Remove observer after the initial notification
    [NSNotificationCenter.defaultCenter removeObserver:self 
                                                  name:PSPDFDocumentViewControllerDidConfigureSpreadViewNotification
                                                object:nil];
    NSString *documentId = self.pdfViewController.document.UID;
    if (documentId != nil) {
        NSDictionary *arguments = @{
            @"documentId": documentId,
        };
        _flutterPdfDocument = [[FlutterPdfDocument alloc] initWithViewController:self.pdfViewController];
        [_flutterPdfDocument registerWithBinaryMessenger:_binaryMessenger];
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

// should suppress file conflict alerts https://pspdfkit.com/guides/ios/knowledge-base/suppressing-file-coordination-alerts/
// ...but seems to be not working
- (BOOL)resolutionManager:(PSPDFConflictResolutionManager *)manager shouldPerformAutomaticResolutionForForDocument:(PSPDFDocument *)document dataProvider:(id<PSPDFCoordinatedFileDataProviding>)dataProvider conflictType:(PSPDFFileConflictType)type 
               resolution:(inout PSPDFFileConflictResolution *)resolution {
    switch (type) {
        case PSPDFFileConflictTypeDeletion:
            // Unconditionally close the document — EVEN WHEN THERE ARE UNSAVED CHANGES!
            *resolution = PSPDFFileConflictResolutionClose;
            return YES;
        case PSPDFFileConflictTypeModification:
            // Unconditionally reload the document from disk — EVEN WHEN THERE ARE UNSAVED CHANGES!
            *resolution = PSPDFFileConflictResolutionReload;
            return YES;
    }
}

- (void)dealloc {
    [self cleanup];
}

- (void)cleanup {
    [self.flutterPdfDocument unRegisterWithBinaryMessenger:_binaryMessenger];
    self.flutterPdfDocument = nil;
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
