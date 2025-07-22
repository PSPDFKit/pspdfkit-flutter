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
#import "nutrient_flutter-Swift.h"

@import PSPDFKit;
@import PSPDFKitUI;

@interface PspdfPlatformView() <PSPDFViewControllerDelegate>
@property int64_t platformViewId;
@property (nonatomic) FlutterMethodChannel *channel;
@property (nonatomic) FlutterMethodChannel *broadcastChannel;
@property (nonatomic, weak) UIViewController *flutterViewController;
@property (nonatomic) PSPDFViewController *pdfViewController;
@property (nonatomic) PSPDFNavigationController *navigationController;
@property (nonatomic) FlutterPdfDocument *flutterPdfDocument;
@property (nonatomic) NSObject<FlutterBinaryMessenger> *binaryMessenger;
@property PspdfkitPlatformViewImpl *platformViewImpl;
@end

@implementation PspdfPlatformView

- (nonnull UIView *)view {
    return self.navigationController.view ?: [UIView new];
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    
    if ((self = [super init])) {
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
