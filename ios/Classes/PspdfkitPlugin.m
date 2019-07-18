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

@interface PspdfkitPlugin()
@property (nonatomic) PSPDFViewController *pdfViewController;
@end

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
        [self unlockWithPasswordIfNeeded:document dictionary:configurationDictionary];
        PSPDFConfiguration *psPdfConfiguration = [self configuration:configurationDictionary isImageDocument:[self isImageDocument:documentPath]];
        self.pdfViewController = [[PSPDFViewController alloc] initWithDocument:document configuration:psPdfConfiguration];
        self.pdfViewController.appearanceModeManager.appearanceMode = [self appearanceMode:configurationDictionary];
        self.pdfViewController.pageIndex = [self pageIndex:configurationDictionary];
        
        if ((id)configurationDictionary != NSNull.null) {
            [self setLeftBarButtonItems:configurationDictionary[@"leftBarButtonItems"]];
            [self setRightBarButtonItems:configurationDictionary[@"rightBarButtonItems"]];
            [self setToolbarTitle:configurationDictionary[@"toolbarTitle"]];
        }

        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.pdfViewController];
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
        builder.scrollDirection = [dictionary[@"pageScrollDirection"] isEqualToString:@"vertical"] ? PSPDFScrollDirectionVertical : PSPDFScrollDirectionHorizontal;
        builder.pageTransition = [dictionary[@"scrollContinuously"] boolValue] ? PSPDFPageTransitionScrollContinuous : PSPDFPageTransitionScrollPerSpread;
        builder.spreadFitting = [dictionary[@"fitPageToWidth"] boolValue] ? PSPDFConfigurationSpreadFittingFill : PSPDFConfigurationSpreadFittingAdaptive;
        builder.searchMode = [dictionary[@"inlineSearch"] boolValue] ? PSPDFSearchModeInline : PSPDFSearchModeModal;
        builder.userInterfaceViewMode = [self userInterfaceViewMode:dictionary];
        builder.thumbnailBarMode = [self thumbnailBarMode:dictionary];

        if (dictionary[@"showPageLabels"]) {
            builder.pageLabelEnabled = [dictionary[@"showPageLabels"] boolValue];
        }
        if (dictionary[@"showDocumentLabel"]) {
            builder.documentLabelEnabled = [dictionary[@"showDocumentLabel"] boolValue];
        }
        if (dictionary[@"allowToolbarTitleChange"]) {
            builder.allowToolbarTitleChange = [dictionary[@"allowToolbarTitleChange"] boolValue];
        }
        if (![dictionary[@"enableAnnotationEditing"] boolValue]) {
            builder.editableAnnotationTypes = nil;
        }
        if (dictionary[@"enableTextSelection"]) {
            builder.textSelectionEnabled = [dictionary[@"enableTextSelection"] boolValue];
        }
    }];
}


#pragma mark - Customize the Toolbar

- (void)setLeftBarButtonItems:(nullable NSArray <NSString *> *)items {
    if ((id)items == NSNull.null || !items || items.count == 0) {
        return;
    }
    NSMutableArray *leftItems = [NSMutableArray array];
    for (NSString *barButtonItemString in items) {
        UIBarButtonItem *barButtonItem = [self barButtonItemFromString:barButtonItemString forViewController:self.pdfViewController];
        if (barButtonItem && ![self.pdfViewController.navigationItem.rightBarButtonItems containsObject:barButtonItem]) {
            [leftItems addObject:barButtonItem];
        }
    }

    [self.pdfViewController.navigationItem setLeftBarButtonItems:[leftItems copy] animated:NO];
}

- (void)setRightBarButtonItems:(nullable NSArray <NSString *> *)items {
    if ((id)items == NSNull.null || !items || items.count == 0) {
        return;
    }
    NSMutableArray *rightItems = [NSMutableArray array];
    for (NSString *barButtonItemString in items) {
        UIBarButtonItem *barButtonItem = [self barButtonItemFromString:barButtonItemString forViewController:self.pdfViewController];
        if (barButtonItem && ![self.pdfViewController.navigationItem.leftBarButtonItems containsObject:barButtonItem]) {
            [rightItems addObject:barButtonItem];
        }
    }

    [self.pdfViewController.navigationItem setRightBarButtonItems:[rightItems copy] animated:NO];
}


# pragma mark - Helpers

- (PSPDFUserInterfaceViewMode)userInterfaceViewMode:(NSDictionary *)dictionary {
    PSPDFUserInterfaceViewMode userInterfaceMode = PSPDFConfiguration.defaultConfiguration.userInterfaceViewMode;
    if ((id)dictionary == NSNull.null || !dictionary || dictionary.count == 0) {
        return userInterfaceMode;
    }

    NSString *value = dictionary[@"userInterfaceViewMode"];
    if (value) {
        if ([value isEqualToString:@"automatic"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeAutomatic;
        } else if ([value isEqualToString:@"alwaysVisible"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeAlways;
        } else if ([value isEqualToString:@"alwaysHidden"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeNever;
        } else if ([value isEqualToString:@"automaticNoFirstLastPage"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeAutomaticNoFirstLastPage;
        }
    }
    return userInterfaceMode;
}

- (PSPDFThumbnailBarMode)thumbnailBarMode:(NSDictionary *)dictionary {
    PSPDFThumbnailBarMode thumbnailBarMode = PSPDFConfiguration.defaultConfiguration.thumbnailBarMode;
    if ((id)dictionary == NSNull.null || !dictionary || dictionary.count == 0) {
        return thumbnailBarMode;
    }

    NSString *value = dictionary[@"showThumbnailBar"];
    if (value) {
        if ([value isEqualToString:@"default"]) {
            thumbnailBarMode = PSPDFThumbnailBarModeScrubberBar;
        } else if ([value isEqualToString:@"scrollable"]) {
            thumbnailBarMode = PSPDFThumbnailBarModeScrollable;
        } else if ([value isEqualToString:@"none"]) {
            thumbnailBarMode = PSPDFThumbnailBarModeNone;
        }
    }
    return thumbnailBarMode;
}


- (PSPDFAppearanceMode)appearanceMode:(NSDictionary *)dictionary {
    if ((id)dictionary == NSNull.null || !dictionary || dictionary.count == 0) {
        return PSPDFAppearanceModeDefault;
    }
    PSPDFAppearanceMode appearanceMode = PSPDFAppearanceModeDefault;
    NSString *value = dictionary[@"appearanceMode"];
    if (value) {
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

- (void)setToolbarTitle:(NSString *)toolbarTitle {
    // Early return if the toolbar title is not explicitly set in the configuration dictionary.
    if (!toolbarTitle) {
        return;
    }

    // We allow setting a null title.
    self.pdfViewController.title = (id)toolbarTitle == NSNull.null ? nil : toolbarTitle;
}

- (BOOL)isImageDocument:(NSString*)path {
    NSString *fileExtension = path.pathExtension.lowercaseString;
    return [fileExtension isEqualToString:@"png"] || [fileExtension isEqualToString:@"jpeg"] || [fileExtension isEqualToString:@"jpg"];
}

- (void)unlockWithPasswordIfNeeded:(PSPDFDocument *)document dictionary:(NSDictionary *)dictionary {
    if ((id)dictionary == NSNull.null || !dictionary || dictionary.count == 0) {
        return;
    }
    NSString *password = dictionary[@"password"];
    if (password.length) {
        [document unlockWithPassword:password];
    }
}

- (UIBarButtonItem *)barButtonItemFromString:(NSString *)barButtonItem forViewController:(PSPDFViewController *)pdfController {
    if ([barButtonItem isEqualToString:@"closeButtonItem"]) {
        return pdfController.closeButtonItem;
    } else if ([barButtonItem isEqualToString:@"outlineButtonItem"]) {
        return pdfController.outlineButtonItem;
    } else if ([barButtonItem isEqualToString:@"searchButtonItem"]) {
        return pdfController.searchButtonItem;
    } else if ([barButtonItem isEqualToString:@"thumbnailsButtonItem"]) {
        return pdfController.thumbnailsButtonItem;
    } else if ([barButtonItem isEqualToString:@"documentEditorButtonItem"]) {
        return pdfController.documentEditorButtonItem;
    } else if ([barButtonItem isEqualToString:@"printButtonItem"]) {
        return pdfController.printButtonItem;
    } else if ([barButtonItem isEqualToString:@"openInButtonItem"]) {
        return pdfController.openInButtonItem;
    } else if ([barButtonItem isEqualToString:@"emailButtonItem"]) {
        return pdfController.emailButtonItem;
    } else if ([barButtonItem isEqualToString:@"messageButtonItem"]) {
        return pdfController.messageButtonItem;
    } else if ([barButtonItem isEqualToString:@"annotationButtonItem"]) {
        return pdfController.annotationButtonItem;
    } else if ([barButtonItem isEqualToString:@"bookmarkButtonItem"]) {
        return pdfController.bookmarkButtonItem;
    } else if ([barButtonItem isEqualToString:@"brightnessButtonItem"]) {
        return pdfController.brightnessButtonItem;
    } else if ([barButtonItem isEqualToString:@"activityButtonItem"]) {
        return pdfController.activityButtonItem;
    } else if ([barButtonItem isEqualToString:@"settingsButtonItem"]) {
        return pdfController.settingsButtonItem;
    } else {
        return nil;
    }
}

@end

