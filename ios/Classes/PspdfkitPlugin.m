//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfkitPlugin.h"
#import "PspdfPlatformViewFactory.h"
#import "PspdfkitFlutterHelper.h"
#import "PspdfkitFlutterConverter.h"

@import PSPDFKit;
@import PSPDFKitUI;

@interface PspdfkitPlugin() <PSPDFViewControllerDelegate>
@property (nonatomic) PSPDFViewController *pdfViewController;
@end

@implementation PspdfkitPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    PspdfPlatformViewFactory *platformViewFactory = [[PspdfPlatformViewFactory alloc] initWithMessenger:[registrar messenger]];
    [registrar registerViewFactory:platformViewFactory withId:@"com.pspdfkit.widget"];

    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"com.pspdfkit.global" binaryMessenger:[registrar messenger]];
    PspdfkitPlugin* instance = [[PspdfkitPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"frameworkVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:PSPDFKitGlobal.versionNumber]);
    } else if ([@"setLicenseKey" isEqualToString:call.method]) {
        NSString *licenseKey = call.arguments[@"licenseKey"];
        [PSPDFKitGlobal setLicenseKey:licenseKey];
    } else if ([@"present" isEqualToString:call.method]) {
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

        self.pdfViewController = [[PSPDFViewController alloc] initWithDocument:document configuration:configuration];
        self.pdfViewController.appearanceModeManager.appearanceMode = [PspdfkitFlutterConverter appearanceMode:configurationDictionary];
        self.pdfViewController.pageIndex = [PspdfkitFlutterConverter pageIndex:configurationDictionary];
        self.pdfViewController.delegate = self;

        if ((id)configurationDictionary != NSNull.null) {
            [PspdfkitFlutterHelper setLeftBarButtonItems:configurationDictionary[@"leftBarButtonItems"] forViewController:self.pdfViewController];
            [PspdfkitFlutterHelper setRightBarButtonItems:configurationDictionary[@"rightBarButtonItems"] forViewController:self.pdfViewController];
            [PspdfkitFlutterHelper setToolbarTitle:configurationDictionary[@"toolbarTitle"] forViewController:self.pdfViewController];
        }

        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.pdfViewController];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        UIViewController *presentingViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        [presentingViewController presentViewController:navigationController animated:YES completion:nil];
        result(@(YES));
    } else if ([@"updateiOSAppearance" isEqualToString:call.method]) {
        // Detailed guide on appearance customization:
        // https://pspdfkit.com/guides/ios/current/customizing-the-interface/appearance-styling/
        
        UINavigationBar *navBarPopoverProxy = [UINavigationBar appearance];
        UIToolbar *toolbarPopoverProxy = [UIToolbar appearance];

        // Change the colors here as required.
        UIColor *barColor = UIColor.systemYellowColor;

        // On iOS 13 and later.
        if (@available(iOS 13, *)) {
            // For `UINavigationBar`.
            UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
            navigationBarAppearance.backgroundColor = barColor;
            navigationBarAppearance.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor blackColor]};

            // Use the same appearance for all navigation bar modes.
            navBarPopoverProxy.standardAppearance = navigationBarAppearance;
            navBarPopoverProxy.compactAppearance = navigationBarAppearance;
            navBarPopoverProxy.scrollEdgeAppearance = navigationBarAppearance;

            // For `UIToolbar`.
            UIToolbarAppearance *toolbarAppearance = [[UIToolbarAppearance alloc] init];
            toolbarAppearance.backgroundColor = barColor;

            // Apply the same appearance styling to all sizes of `UIToolbar`.
            toolbarPopoverProxy.standardAppearance = toolbarAppearance;
            toolbarPopoverProxy.compactAppearance = toolbarAppearance;
        } else {
            // On iOS 12 and earlier.
            navBarPopoverProxy.barTintColor = barColor;
            toolbarPopoverProxy.barTintColor = barColor;
        }

        // Change the colors here as required.
        navBarPopoverProxy.tintColor = UIColor.blackColor;
        toolbarPopoverProxy.tintColor = UIColor.blackColor;
    } else {
        [PspdfkitFlutterHelper processMethodCall:call result:result forViewController:self.pdfViewController];
    }
}

# pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewControllerDidDismiss:(PSPDFViewController *)pdfController {
    // Don't hold on to the view controller object after dismissal.
    self.pdfViewController = nil;
}

@end
