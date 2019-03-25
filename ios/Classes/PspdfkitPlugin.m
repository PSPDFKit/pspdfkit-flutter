//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfkitPlugin.h"

@import PSPDFKit;
@import PSPDFKitUI;

@implementation PspdfkitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"pspdfkit"
                                     binaryMessenger:[registrar messenger]];
    PspdfkitPlugin* instance = [[PspdfkitPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"frameworkVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:PSPDFKit.versionNumber]);
    } else if ([@"setLicenseKey" isEqualToString:call.method]) {
        NSString *licenseKey = call.arguments[@"licenseKey"];
        [PSPDFKit setLicenseKey:licenseKey];
    } else if ([@"present" isEqualToString:call.method]) {
        NSString *documentPath = call.arguments[@"document"];
        NSAssert(documentPath != nil, @"Document path may not be nil.");
        NSAssert(documentPath.length != 0, @"Document path may not be empty.");
        NSDictionary *configurationDictionary = call.arguments[@"configuration"];

        PSPDFDocument *document = [self PSPDFDocument:documentPath];
        PSPDFConfiguration *psPdfConfiguration = [self PSPDFConfiguration:configurationDictionary forDocument:document];
        PSPDFViewController *pdfViewController = [[PSPDFViewController alloc] initWithDocument:document configuration:psPdfConfiguration];
        pdfViewController.appearanceModeManager.appearanceMode = [self PSPDFAppearanceMode:configurationDictionary];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pdfViewController];
        UIViewController *presentingViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        [presentingViewController presentViewController:navigationController animated:YES completion:nil];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

# pragma mark - Private methods

- (PSPDFDocument *)PSPDFDocument:(NSString *)string {
    NSURL *url;
    
    if ([string hasPrefix:@"/"]) {
        url = [NSURL fileURLWithPath:string];
    } else {
        url = [NSBundle.mainBundle URLForResource:string withExtension:nil];
    }

    NSString *fileExtension = url.pathExtension.lowercaseString;
    BOOL isImageFile = [fileExtension isEqualToString:@"png"] || [fileExtension isEqualToString:@"jpeg"] || [fileExtension isEqualToString:@"jpg"];
    if (isImageFile) {
        return [[PSPDFImageDocument alloc] initWithImageURL:url];
    } else {
        return [[PSPDFDocument alloc] initWithURL:url];
    }
}

- (PSPDFConfiguration *)PSPDFConfiguration:(NSDictionary *)dictionary forDocument:(PSPDFDocument *)document{
    PSPDFConfiguration *configuration;
    if ([document isKindOfClass:PSPDFImageDocument.class]) {
        configuration = PSPDFConfiguration.imageConfiguration;
    } else {
        configuration = PSPDFConfiguration.defaultConfiguration;
    }

    if ((id)dictionary == NSNull.null || !dictionary || dictionary.count == 0) {
        return configuration;
    }

    return [configuration configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder * _Nonnull builder) {
        if (dictionary[@"pageScrollDirection"]) {
            builder.scrollDirection = [dictionary[@"pageScrollDirection"] isEqualToString:@"pageScrollDirectionHorizontal"] ? PSPDFScrollDirectionHorizontal : PSPDFScrollDirectionVertical;
        }
        if (dictionary[@"pageScrollContinuous"]) {
            builder.pageTransition = dictionary[@"pageScrollContinuous"] ? PSPDFPageTransitionScrollContinuous : PSPDFPageTransitionScrollPerSpread;
        }
        if (dictionary[@"userInterfaceViewMode"]) {
            PSPDFUserInterfaceViewMode userInterfaceMode = PSPDFUserInterfaceViewModeAutomatic;
            NSString *value = dictionary[@"userInterfaceViewMode"];
            if ([value isEqualToString:@"automatic"]) {
                userInterfaceMode = PSPDFUserInterfaceViewModeAutomatic;
            } else if ([value isEqualToString:@"alwaysVisible"]) {
                userInterfaceMode = PSPDFUserInterfaceViewModeAlways;
            } else if ([value isEqualToString:@"alwaysHidden"]) {
                userInterfaceMode = PSPDFUserInterfaceViewModeNever;
            } else if ([value isEqualToString:@"automaticNoFirstLastPage"]) {
                userInterfaceMode = PSPDFUserInterfaceViewModeAutomaticNoFirstLastPage;
            }
            builder.userInterfaceViewMode = userInterfaceMode;
        }
        if (dictionary[@"inlineSearch"]) {
            builder.searchMode = dictionary[@"inlineSearch"] ? PSPDFSearchModeInline : PSPDFSearchModeModal;
        }
        if (dictionary[@"showThumbnailBar"]) {
            PSPDFThumbnailBarMode thumbnailBarMode = PSPDFThumbnailBarModeScrubberBar;
            NSString *value = dictionary[@"showThumbnailBar"];
            if ([value isEqualToString:@"default"]) {
                thumbnailBarMode = PSPDFThumbnailBarModeScrubberBar;
            } else if ([value isEqualToString:@"scrollable"]) {
                thumbnailBarMode = PSPDFThumbnailBarModeScrollable;
            } else if ([value isEqualToString:@"none"]) {
                thumbnailBarMode = PSPDFThumbnailBarModeNone;
            }
            builder.thumbnailBarMode = thumbnailBarMode;
        }
    }];
}

- (PSPDFAppearanceMode)PSPDFAppearanceMode:(NSDictionary *)dictionary {
    if ((id)dictionary == NSNull.null || !dictionary || dictionary.count == 0) {
        return PSPDFAppearanceModeDefault;
    }
    PSPDFAppearanceMode appearanceMode = PSPDFAppearanceModeDefault;
    if (dictionary[@"appearanceMode"]) {
        NSString *value = dictionary[@"appearanceMode"];
        if ([value isEqualToString:@"default"]) {
            appearanceMode = PSPDFAppearanceModeDefault;
        } else if ([value isEqualToString:@"night"]) {
            appearanceMode = PSPDFAppearanceModeNight;
        } else if ([value isEqualToString:@"sepia"]) {
            appearanceMode = PSPDFAppearanceModeSepia;
        }
    }
    return appearanceMode;
}

@end

