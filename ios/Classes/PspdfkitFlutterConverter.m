//
//  Copyright © 2018-2021 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfkitFlutterConverter.h"

@implementation PspdfkitFlutterConverter

+ (PSPDFConfiguration *)configuration:(NSDictionary *)dictionary isImageDocument:(BOOL)isImageDocument {
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
        builder.userInterfaceViewMode = [PspdfkitFlutterConverter userInterfaceViewMode:dictionary];
        builder.thumbnailBarMode = [PspdfkitFlutterConverter thumbnailBarMode:dictionary];
        builder.pageMode = [PspdfkitFlutterConverter pageMode:dictionary];

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
            builder.settingsOptions = [PspdfkitFlutterConverter settingsOptions:dictionary[@"iOSSettingsMenuItems"]];
        }
    }];
}

+ (PSPDFUserInterfaceViewMode)userInterfaceViewMode:(NSDictionary *)dictionary {
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

+ (PSPDFThumbnailBarMode)thumbnailBarMode:(NSDictionary *)dictionary {
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

+ (PSPDFAppearanceMode)appearanceMode:(NSDictionary *)dictionary {
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

+ (PSPDFPageIndex)pageIndex:(NSDictionary *)dictionary {
    if ((id)dictionary == NSNull.null || !dictionary || dictionary.count == 0) {
        return 0;
    }
    return (PSPDFPageIndex)[dictionary[@"startPage"] unsignedLongValue];
}

+ (PSPDFPageMode)pageMode:(NSDictionary *)dictionary {
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

+ (PSPDFSettingsOptions)settingsOptions:(nullable NSArray <NSString *> *)options {
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

+ (PSPDFAnnotationType)annotationTypeFromString:(NSString *)typeString {
    if (!typeString) {
        return PSPDFAnnotationTypeAll;
    } else if ([typeString isEqualToString:@"pspdfkit/ink"]) {
        return PSPDFAnnotationTypeInk;
    } else if ([typeString isEqualToString:@"pspdfkit/link"]) {
        return PSPDFAnnotationTypeLink;
    } else if ([typeString isEqualToString:@"pspdfkit/markup/highlight"]) {
        return PSPDFAnnotationTypeHighlight;
    } else if ([typeString isEqualToString:@"pspdfkit/markup/squiggly"]) {
        return PSPDFAnnotationTypeSquiggly;
    } else if ([typeString isEqualToString:@"pspdfkit/markup/strikeout"]) {
        return PSPDFAnnotationTypeStrikeOut;
    } else if ([typeString isEqualToString:@"pspdfkit/markup/underline"]) {
        return PSPDFAnnotationTypeUnderline;
    } else if ([typeString isEqualToString:@"pspdfkit/note"]) {
        return PSPDFAnnotationTypeNote;
    } else if ([typeString isEqualToString:@"pspdfkit/shape/ellipse"]) {
        return PSPDFAnnotationTypeCircle;
    } else if ([typeString isEqualToString:@"pspdfkit/shape/line"]) {
        return PSPDFAnnotationTypeLine;
    } else if ([typeString isEqualToString:@"pspdfkit/shape/polygon"]) {
        return PSPDFAnnotationTypePolygon;
    } else if ([typeString isEqualToString:@"pspdfkit/shape/rectangle"]) {
        return PSPDFAnnotationTypeSquare;
    } else if ([typeString isEqualToString:@"pspdfkit/text"]) {
        return PSPDFAnnotationTypeFreeText;
    } else {
        return PSPDFAnnotationTypeAll;
    }
}

+ (PSPDFAnnotationChange)annotationChangeFromString:(NSString *)changeString {
  if ([changeString isEqualToString:@"flatten"]) {
    return PSPDFAnnotationChangeFlatten;
  } else if ([changeString isEqualToString:@"remove"]) {
    return PSPDFAnnotationChangeRemove;
  } else if ([changeString isEqualToString:@"embed"]) {
    return PSPDFAnnotationChangeEmbed;
  } else if ([changeString isEqualToString:@"print"]) {
    return PSPDFAnnotationChangePrint;
  } else {
    return PSPDFAnnotationChangeEmbed;
  }
}

+ (NSArray <NSDictionary *> *)instantJSONFromAnnotations:(NSArray <PSPDFAnnotation *> *) annotations {
    NSMutableArray <NSDictionary *> *annotationsJSON = [NSMutableArray new];
    for (PSPDFAnnotation *annotation in annotations) {
        NSDictionary <NSString *, NSString *> *uuidDict = @{@"uuid" : annotation.uuid};
        NSData *annotationData = [annotation generateInstantJSONWithError:NULL];
        if (annotationData) {
            NSMutableDictionary *annotationDictionary = [[NSJSONSerialization JSONObjectWithData:annotationData options:kNilOptions error:NULL] mutableCopy];
            [annotationDictionary addEntriesFromDictionary:uuidDict];
            if (annotationDictionary) {
                [annotationsJSON addObject:annotationDictionary];
            }
        } else {
            // We only generate Instant JSON data for attached annotations. When an annotation is deleted, we only set the annotation uuid.
            [annotationsJSON addObject:uuidDict];
        }
    }

    return [annotationsJSON copy];
}

@end
