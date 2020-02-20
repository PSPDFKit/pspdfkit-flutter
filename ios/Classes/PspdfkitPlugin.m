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
    } else if ([@"setFormFieldValue" isEqualToString:call.method]) {
        NSString *value = call.arguments[@"value"];
        NSString *fullyQualifiedName = call.arguments[@"fullyQualifiedName"];
        result([self setFormFieldValue:value forFieldWithFullyQualifiedName:fullyQualifiedName]);
    } else if ([@"getFormFieldValue" isEqualToString:call.method]) {
        NSString *fullyQualifiedName = call.arguments[@"fullyQualifiedName"];
        result([self getFormFieldValueForFieldWithFullyQualifiedName:fullyQualifiedName]);
    } else if ([@"applyInstantJson" isEqualToString:call.method]) {
        NSString *annotationsJson = call.arguments[@"annotationsJson"];
        if (annotationsJson.length == 0) {
            result([FlutterError errorWithCode:@"" message:@"annotationsJson may not be nil or empty." details:nil]);
            return;
        }
        PSPDFDocument *document = self.pdfViewController.document;
        if (!document || !document.isValid) {
            result([FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil]);
            return;
        }
        PSPDFDataContainerProvider *jsonContainer = [[PSPDFDataContainerProvider alloc] initWithData:[annotationsJson dataUsingEncoding:NSUTF8StringEncoding]];
        NSError *error;
        BOOL success = [document applyInstantJSONFromDataProvider:jsonContainer toDocumentProvider:document.documentProviders.firstObject lenient:NO error:&error];
        if (!success) {
            result([FlutterError errorWithCode:@"" message:@"Error while importing document Instant JSON." details:nil]);
        } else {
            [self.pdfViewController reloadData];
            result(@(YES));
        }
    } else if ([@"exportInstantJson" isEqualToString:call.method]) {
        PSPDFDocument *document = self.pdfViewController.document;
        if (!document || !document.isValid) {
            result([FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil]);
            return;
        }
        NSError *error;
        NSData *data = [document generateInstantJSONFromDocumentProvider:document.documentProviders.firstObject error:&error];
        NSString *annotationsJson = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if (annotationsJson == nil) {
            result([FlutterError errorWithCode:@"" message:@"Error while exporting document Instant JSON." details:error.localizedDescription]);
        } else {
            result(annotationsJson);
        }
    } else if ([@"present" isEqualToString:call.method]) {
        NSString *documentPath = call.arguments[@"document"];

        if (documentPath == nil || documentPath.length <= 0) {
            FlutterError *error = [FlutterError errorWithCode:@"" message:@"Document path may not be nil or empty." details:nil];
            result(error);
            return;
        }

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
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        UIViewController *presentingViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        [presentingViewController presentViewController:navigationController animated:YES completion:nil];
        result(@(YES));
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
        builder.pageMode = [self pageMode:dictionary];

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
        if (dictionary[@"showActionNavigationButtons"]) {
            builder.showBackActionButton = [dictionary[@"showActionNavigationButtons"] boolValue];
            builder.showForwardActionButton = [dictionary[@"showActionNavigationButtons"] boolValue];
        }
        if (dictionary[@"iOSShowActionNavigationButtonLabels"]) {
            builder.showBackForwardActionButtonLabels = [dictionary[@"iOSShowActionNavigationButtonLabels"] boolValue];
        }
        if (dictionary[@"isFirstPageAlwaysSingle"]) {
            builder.firstPageAlwaysSingle = [dictionary[@"isFirstPageAlwaysSingle"] boolValue];
        }
        if (dictionary[@"iOSSettingsMenuItems"]) {
            builder.settingsOptions = [self settingsOptions:dictionary[@"iOSSettingsMenuItems"]];
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

#pragma mark - Forms

- (id)setFormFieldValue:(NSString *)value forFieldWithFullyQualifiedName:(NSString *)fullyQualifiedName {
    PSPDFDocument *document = self.pdfViewController.document;

    if (!document || !document.isValid) {
        FlutterError *error = [FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil];
        return error;
    }

    if (fullyQualifiedName == nil || fullyQualifiedName.length == 0) {
        FlutterError *error = [FlutterError errorWithCode:@"" message:@"Fully qualified name may not be nil or empty." details:nil];
        return error;
    }

    BOOL success = NO;
    for (PSPDFFormElement *formElement in document.formParser.forms) {
        if ([formElement.fullyQualifiedFieldName isEqualToString:fullyQualifiedName]) {
            if ([formElement isKindOfClass:PSPDFButtonFormElement.class]) {
                if ([value isEqualToString:@"selected"]) {
                    [(PSPDFButtonFormElement *)formElement select];
                    success = YES;
                } else if ([value isEqualToString:@"deselected"]) {
                    [(PSPDFButtonFormElement *)formElement deselect];
                    success = YES;
                }
            } else if ([formElement isKindOfClass:PSPDFChoiceFormElement.class]) {
                ((PSPDFChoiceFormElement *)formElement).selectedIndices = [NSIndexSet indexSetWithIndex:value.integerValue];
                success = YES;
            } else if ([formElement isKindOfClass:PSPDFTextFieldFormElement.class]) {
                formElement.contents = value;
                success = YES;
            } else if ([formElement isKindOfClass:PSPDFSignatureFormElement.class]) {
                FlutterError *error = [FlutterError errorWithCode:@"" message:@"Signature form elements are not supported." details:nil];
                return error;
            } else {
                return @(NO);
            }
            break;
        }
    }

    if (!success) {
        FlutterError *error = [FlutterError errorWithCode:@"" message:[NSString stringWithFormat:@"Error while searching for a form element with name %@.", fullyQualifiedName] details:nil];
        return error;
    }

    return @(YES);
}

- (id)getFormFieldValueForFieldWithFullyQualifiedName:(NSString *)fullyQualifiedName {
    if (fullyQualifiedName == nil || fullyQualifiedName.length == 0) {
        FlutterError *error = [FlutterError errorWithCode:@"" message:@"Fully qualified name may not be nil or empty." details:nil];
        return error;
    }

    PSPDFDocument *document = self.pdfViewController.document;
    id formFieldValue = nil;
    for (PSPDFFormElement *formElement in document.formParser.forms) {
        if ([formElement.fullyQualifiedFieldName isEqualToString:fullyQualifiedName]) {
            formFieldValue = formElement.value;
            break;
        }
    }

    if (formFieldValue == nil) {
        FlutterError *error = [FlutterError errorWithCode:@"" message:[NSString stringWithFormat:@"Error while searching for a form element with name %@.", fullyQualifiedName] details:nil];
        return error;
    }

    return formFieldValue;
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

- (PSPDFPageMode)pageMode:(NSDictionary *)dictionary {
    PSPDFPageMode pageMode = PSPDFConfiguration.defaultConfiguration.pageMode;

    if ((id)dictionary == NSNull.null || !dictionary || dictionary.count == 0) {
        return pageMode;
    }

    NSString *value = dictionary[@"pageLayoutMode"];
    if (value) {
        if ([value isEqualToString:@"automatic"]) {
            pageMode = PSPDFPageModeAutomatic;
        } else if ([value isEqualToString:@"single"]) {
            pageMode = PSPDFPageModeSingle;
        } else if ([value isEqualToString:@"double"]) {
            pageMode = PSPDFPageModeDouble;
        }
    }
    return pageMode;
}

- (PSPDFSettingsOptions)settingsOptions:(nullable NSArray <NSString *> *)options {
    if ((id)options == NSNull.null || !options || options.count == 0) {
        return PSPDFSettingsOptionDefault;
    }

    PSPDFSettingsOptions finalOptions = 0;
    for (NSString *option in options) {
        if ([option isEqualToString:@"scrollDirection"]) {
            finalOptions |= PSPDFSettingsOptionScrollDirection;
        } else if ([option isEqualToString:@"pageTransition"]) {
            finalOptions |= PSPDFSettingsOptionPageTransition;
        } else if ([option isEqualToString:@"appearance"]) {
            finalOptions |= PSPDFSettingsOptionAppearance;
        } else if ([option isEqualToString:@"brightness"]) {
            finalOptions |= PSPDFSettingsOptionBrightness;
        } else if ([option isEqualToString:@"pageMode"]) {
            finalOptions |= PSPDFSettingsOptionPageMode;
        } else if ([option isEqualToString:@"spreadFitting"]) {
            finalOptions |= PSPDFSettingsOptionSpreadFitting;
        } else {
            NSLog(@"WARNING: '%@' is an invalid settings option. It will be ignored.", option);
        }
    }

    // If no options were passed, we use the default setting options.
    if (finalOptions == 0) {
        finalOptions = PSPDFSettingsOptionDefault;
    }

    return finalOptions;
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

@interface PspdfPlatformViewFactory()
@property (nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@end

@implementation PspdfPlatformViewFactory

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    self = [super init];
    if (self) {
        self.messenger = messenger;
    }
    return self;
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args {
    return [[PspdfPlatformView alloc] initWithFrame:frame viewIdentifier:viewId arguments:args messenger:self.messenger];
}

@end

@interface PspdfPlatformView()
@property int64_t platformViewId;
@property (nonatomic) FlutterMethodChannel *channel;
@property (nonatomic) PSPDFViewController *pdfViewController;
@property (nonatomic) UINavigationController *navigationController;
@end

@implementation PspdfPlatformView

- (nonnull UIView *)view {
    return self.navigationController.view ? self.navigationController.view : [UIView new];
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    NSString *name = [NSString stringWithFormat:@"com.pspdfkit.widget.%lld",viewId];
    _platformViewId = viewId;
    _channel = [FlutterMethodChannel methodChannelWithName:name binaryMessenger:messenger];

    _pdfViewController = [[PSPDFViewController alloc] init];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:_pdfViewController];
    _navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self = [super init];

    __weak id weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        [weakSelf handleMethodCall:call result:result];
    }];

    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"setDocumentURL" isEqualToString:call.method]) {
        [self setDocumentURLWith:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)setDocumentURLWith:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *path = (NSString *)call.arguments;
    if (path != nil) {
        NSURL *url = [NSURL fileURLWithPath:path];
        PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:url];
        self.pdfViewController.document = document;
    } else {
        self.pdfViewController.document = nil;
    }
}

@end
