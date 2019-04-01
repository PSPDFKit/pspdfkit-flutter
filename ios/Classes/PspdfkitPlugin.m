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
        
        PSPDFDocument *document = [self document:documentPath];
        PSPDFConfiguration *psPdfConfiguration = [self configuration:configurationDictionary isImageDocument:[self isImageDocument:documentPath]];
        PSPDFViewController *pdfViewController = [[PSPDFViewController alloc] initWithDocument:document configuration:psPdfConfiguration];
        pdfViewController.appearanceModeManager.appearanceMode = [self appearanceMode:configurationDictionary];
        pdfViewController.pageIndex = [self pageIndex:configurationDictionary];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pdfViewController];
        UIViewController *presentingViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        [presentingViewController presentViewController:navigationController animated:YES completion:nil];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

# pragma mark - Private methods

- (PSPDFDocument *)document:(NSString *)path {
    NSURL *url;
    
    if ([path hasPrefix:@"/"]) {
        url = [NSURL fileURLWithPath:path];
    } else {
        url = [NSBundle.mainBundle URLForResource:path withExtension:nil];
    }
    
    if ([self isImageDocument:path]) {
        return [[PSPDFImageDocument alloc] initWithImageURL:url];
    } else {
        return [[PSPDFDocument alloc] initWithURL:url];
    }
}

- (PSPDFConfiguration *)configuration:(NSDictionary *)dictionary isImageDocument:(BOOL)isImageDocument {
    PSPDFConfiguration *configuration;
    if (isImageDocument) {
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
            builder.userInterfaceViewMode = [self userInterfaceViewMode:dictionary[@"userInterfaceViewMode"]];
        }
        if (dictionary[@"inlineSearch"]) {
            builder.searchMode = dictionary[@"inlineSearch"] ? PSPDFSearchModeInline : PSPDFSearchModeModal;
        }
        if (dictionary[@"showThumbnailBar"]) {
            builder.thumbnailBarMode = [self thumbnailBarMode:dictionary[@"showThumbnailBar"]];
        }
        if (dictionary[@"showPageLabels"]) {
            builder.pageLabelEnabled = [dictionary[@"showPageLabels"] boolValue];
        }
        if (![dictionary[@"enableAnnotationEditing"] boolValue]) {
            builder.editableAnnotationTypes = nil;
        }
        if (dictionary[@"enableTextSelection"]) {
            builder.textSelectionEnabled = [dictionary[@"enableTextSelection"] boolValue];
        }
    }];
}

# pragma mark - Helpers

- (PSPDFUserInterfaceViewMode)userInterfaceViewMode:(NSString *)stringValue {
    if ((id)stringValue == NSNull.null || !stringValue || stringValue.length == 0) {
        return PSPDFUserInterfaceViewModeAutomatic;
    } else {
        PSPDFUserInterfaceViewMode userInterfaceMode = PSPDFUserInterfaceViewModeAutomatic;
        if ([stringValue isEqualToString:@"automatic"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeAutomatic;
        } else if ([stringValue isEqualToString:@"alwaysVisible"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeAlways;
        } else if ([stringValue isEqualToString:@"alwaysHidden"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeNever;
        } else if ([stringValue isEqualToString:@"automaticNoFirstLastPage"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeAutomaticNoFirstLastPage;
        }
        return  userInterfaceMode;
    }
}

- (PSPDFThumbnailBarMode)thumbnailBarMode:(NSString *)stringValue {
    if ((id)stringValue == NSNull.null || !stringValue || stringValue.length == 0) {
        return PSPDFThumbnailBarModeScrubberBar;
    } else {
        PSPDFThumbnailBarMode thumbnailBarMode = PSPDFThumbnailBarModeScrubberBar;
        if ([stringValue isEqualToString:@"default"]) {
            thumbnailBarMode = PSPDFThumbnailBarModeScrubberBar;
        } else if ([stringValue isEqualToString:@"scrollable"]) {
            thumbnailBarMode = PSPDFThumbnailBarModeScrollable;
        } else if ([stringValue isEqualToString:@"none"]) {
            thumbnailBarMode = PSPDFThumbnailBarModeNone;
        }
        return thumbnailBarMode;
    }
}


- (PSPDFAppearanceMode)appearanceMode:(NSDictionary *)dictionary {
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

- (PSPDFPageIndex)pageIndex:(NSDictionary *)dictionary {
    if ((id)dictionary == NSNull.null || !dictionary || dictionary.count == 0) {
        return 0;
    }
    return (PSPDFPageIndex)[dictionary[@"startPage"] unsignedLongValue];
}

- (BOOL)isImageDocument:(NSString*)path {
    NSString *fileExtension = path.pathExtension.lowercaseString;
    return [fileExtension isEqualToString:@"png"] || [fileExtension isEqualToString:@"jpeg"] || [fileExtension isEqualToString:@"jpg"];
}

@end

