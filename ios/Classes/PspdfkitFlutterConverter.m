//
//  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfkitFlutterConverter.h"

@implementation PspdfkitFlutterConverter

+ (NSString *)removePrefixForKey:(NSString *)key {
   // If the key length is less than 4, we return it without any modification.
   if (([key hasPrefix:@"iOS"] || [key hasPrefix:@"ios"]) && key.length > 4) {
      NSString *prefixRemoved = [key substringFromIndex:3]; // Discard the first 3 letters (iOS).
      NSString *firstLetterLowerCase = [[prefixRemoved substringToIndex:1] lowercaseString]; // Extract and lowercase the first letter.
      NSString *everythingExceptFirstLetter = [prefixRemoved substringFromIndex:1];  // Extract everything except the first letter.
      NSString *cleanedKey = [NSString stringWithFormat:@"%@%@", firstLetterLowerCase, everythingExceptFirstLetter]; // Join the two strings.
      return cleanedKey;
   } else {
      return key;
   }
}

+ (NSDictionary *)processConfigurationOptionsDictionaryForPrefix:(NSDictionary *)dictionary {
   if (dictionary == NULL || [dictionary isKindOfClass:[NSNull class]]) {
      return dictionary;
   }
   NSMutableDictionary *output = [NSMutableDictionary new];
   for (NSString *key in dictionary) {
      id value = [dictionary valueForKey:key];
      [output setValue:value forKey:[self removePrefixForKey:key]];
   }
   return [NSDictionary dictionaryWithDictionary:output];
}

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
        NSString *key = @"";

        // Document Interaction Options

        key = @"scrollDirection";
        if (dictionary[key]) {
            builder.scrollDirection = [dictionary[key] isEqualToString: @"vertical"] ? PSPDFScrollDirectionVertical : PSPDFScrollDirectionHorizontal;
        }

        key = @"pageTransition";
        if (dictionary[key]) {
            builder.pageTransition = [PspdfkitFlutterConverter pageTransition:dictionary forKey:key];
        }

        key = @"enableTextSelection";
        if (dictionary[key]) {
            builder.textSelectionEnabled = [dictionary[key] boolValue];
        }

        // Document Presentation Options

        key = @"pageMode";
        if (dictionary[key]) {
            builder.pageMode = [PspdfkitFlutterConverter pageMode:dictionary forKey:key];
        }

        key = @"spreadFitting";
        if (dictionary[key]) {
            builder.spreadFitting = [PspdfkitFlutterConverter spreadFitting:dictionary forKey:key];
        }

        key = @"showPageLabels";
        if (dictionary[key]) {
            builder.pageLabelEnabled = [dictionary[key] boolValue];
        }

        key = @"documentLabelEnabled";
        if (dictionary[key]) {
            builder.documentLabelEnabled = [dictionary[key] boolValue];
        }

        key = @"firstPageAlwaysSingle";
        if (dictionary[key]) {
            builder.firstPageAlwaysSingle = [dictionary[key] boolValue];
        }

        // User Interface Options

        key = @"inlineSearch";
        if (dictionary[key]) {
            builder.searchMode = [dictionary[key] boolValue] ? PSPDFSearchModeInline : PSPDFSearchModeModal;
        }

        key = @"showActionNavigationButtons";
        if (dictionary[key]) {
            builder.showBackActionButton = [dictionary[key] boolValue];
            builder.showForwardActionButton = [dictionary[key] boolValue];
            builder.showBackForwardActionButtonLabels = [dictionary[key] boolValue];
        }

        key = @"userInterfaceViewMode";
        if (dictionary[key]) {
            builder.userInterfaceViewMode = [PspdfkitFlutterConverter userInterfaceViewMode:dictionary forKey:key];
        }

        key = @"immersiveMode";
        if (dictionary[key]) {
            builder.userInterfaceViewMode = [dictionary[key] boolValue] ? PSPDFUserInterfaceViewModeNever : PSPDFUserInterfaceViewModeAutomatic;
        }

        key = @"settingsMenuItems";
        if (dictionary[key]) {
            builder.settingsOptions = [PspdfkitFlutterConverter settingsOptions:dictionary[key]];
        }

        key = @"allowToolbarTitleChange";
        if (dictionary[key]) {
            builder.allowToolbarTitleChange = [dictionary[key] boolValue];
        }

        // Thumbnail Options

        key = @"showThumbnailBar";
        if (dictionary[key]) {
            builder.thumbnailBarMode = [PspdfkitFlutterConverter thumbnailBarMode:dictionary forKey:key];
        }

        // Annotation, Forms and Bookmark Options

        key = @"enableAnnotationEditing";
        if (dictionary[key]) {
            NSSet *editableAnnotations = [NSSet setWithArray:@[PSPDFAnnotationStringLink, PSPDFAnnotationStringHighlight, PSPDFAnnotationStringStrikeOut, PSPDFAnnotationStringUnderline, PSPDFAnnotationStringSquiggly, PSPDFAnnotationStringNote, PSPDFAnnotationStringFreeText, PSPDFAnnotationStringInk, PSPDFAnnotationStringSquare, PSPDFAnnotationStringCircle, PSPDFAnnotationStringLine, PSPDFAnnotationStringPolygon, PSPDFAnnotationStringPolyLine, PSPDFAnnotationStringSignature, PSPDFAnnotationStringStamp, PSPDFAnnotationStringEraser, PSPDFAnnotationStringSound, PSPDFAnnotationStringImage, PSPDFAnnotationStringRedaction, PSPDFAnnotationStringWidget, PSPDFAnnotationStringFile, PSPDFAnnotationStringRichMedia, PSPDFAnnotationStringScreen, PSPDFAnnotationStringCaret, PSPDFAnnotationStringPopup, PSPDFAnnotationStringWatermark, PSPDFAnnotationStringTrapNet, PSPDFAnnotationString3D]];
            builder.editableAnnotationTypes = [dictionary[key] boolValue] ? editableAnnotations : nil;
        }

        // Deprecated Options

        key = @"pageScrollDirection";
        if (dictionary[key]) {
            builder.scrollDirection = [dictionary[key] isEqualToString: @"vertical"] ? PSPDFScrollDirectionVertical : PSPDFScrollDirectionHorizontal;
        }

        key = @"scrollContinuously";
        if (dictionary[key]) {
            builder.pageTransition = [dictionary[key] boolValue] ? PSPDFPageTransitionScrollContinuous : PSPDFPageTransitionScrollPerSpread;
        }

        key = @"pageLayoutMode";
        if (dictionary[key]) {
            builder.pageMode = [PspdfkitFlutterConverter pageMode:dictionary forKey:key];
        }

        key = @"fitPageToWidth";
        if (dictionary[key]) {
            builder.spreadFitting = [dictionary[key] boolValue] ? PSPDFConfigurationSpreadFittingFill : PSPDFConfigurationSpreadFittingAdaptive;
        }

        key = @"showDocumentLabel";
        if (dictionary[key]) {
            builder.documentLabelEnabled = [dictionary[@"showDocumentLabel"] boolValue];
        }

        key = @"isFirstPageAlwaysSingle";
        if (dictionary[key]) {
            builder.firstPageAlwaysSingle = [dictionary[key] boolValue];
        }

        key = @"showActionNavigationButtonLabels";
        if (dictionary[key]) {
            builder.showBackActionButton = [dictionary[key] boolValue];
            builder.showForwardActionButton = [dictionary[key] boolValue];
            builder.showBackForwardActionButtonLabels = [dictionary[key] boolValue];
        }

        key = @"disableAutosave";
        if (dictionary[key]){
            builder.autosaveEnabled = ![dictionary[key] boolValue];
        }
    }];
}

+ (PSPDFPageTransition)pageTransition:(NSDictionary *)dictionary forKey:(NSString *)key {
    PSPDFPageTransition transition = PSPDFConfiguration.defaultConfiguration.pageTransition;
    NSString *value = dictionary[key];
    if (value) {
        if ([value isEqualToString:@"scrollPerSpread"]) {
            transition = PSPDFPageTransitionScrollPerSpread;
        } else if ([value isEqualToString:@"scrollContinuous"]) {
            transition = PSPDFPageTransitionScrollContinuous;
        } else if ([value isEqualToString:@"curl"]) {
            transition = PSPDFPageTransitionCurl;
        }
    }
    return transition;
}

+ (PSPDFUserInterfaceViewMode)userInterfaceViewMode:(NSDictionary *)dictionary forKey:(NSString *)key {
    PSPDFUserInterfaceViewMode userInterfaceMode = PSPDFConfiguration.defaultConfiguration.userInterfaceViewMode;
    NSString *value = dictionary[key];
    if (value) {
        if ([value isEqualToString:@"automatic"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeAutomatic;
        } else if ([value isEqualToString:@"automaticBorderPages"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeAutomaticNoFirstLastPage;
        } else if ([value isEqualToString:@"automaticNoFirstLastPage"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeAutomaticNoFirstLastPage;
        } else if ([value isEqualToString:@"always"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeAlways;
        } else if ([value isEqualToString:@"alwaysVisible"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeAlways;
        } else if ([value isEqualToString:@"alwaysHidden"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeNever;
        } else if ([value isEqualToString:@"never"]) {
            userInterfaceMode = PSPDFUserInterfaceViewModeNever;
        }
    }
    return userInterfaceMode;
}

+ (PSPDFThumbnailBarMode)thumbnailBarMode:(NSDictionary *)dictionary forKey:(NSString *)key {
    PSPDFThumbnailBarMode thumbnailBarMode = PSPDFConfiguration.defaultConfiguration.thumbnailBarMode;
    NSString *value = dictionary[key];
    if (value) {
        if ([value isEqualToString:@"default"] || [value isEqualToString:@"floating"]) {
            thumbnailBarMode = PSPDFThumbnailBarModeFloatingScrubberBar;
        } else if ([value isEqualToString:@"scrollable"]) {
            thumbnailBarMode = PSPDFThumbnailBarModeScrollable;
        } else if ([value isEqualToString:@"none"]) {
            thumbnailBarMode = PSPDFThumbnailBarModeNone;
        } else if ([value isEqualToString:@"scrubberBar"] || [value isEqualToString:@"pinned"]) {
            thumbnailBarMode = PSPDFThumbnailBarModeScrubberBar;
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

+ (PSPDFPageMode)pageMode:(NSDictionary *)dictionary forKey:(NSString *)key {
    PSPDFPageMode pageMode = PSPDFConfiguration.defaultConfiguration.pageMode;
    NSString *value = dictionary[key];
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

+ (PSPDFConfigurationSpreadFitting)spreadFitting:(NSDictionary *)dictionary forKey:(NSString *)key {
    PSPDFConfigurationSpreadFitting spreadFitting = PSPDFConfiguration.defaultConfiguration.spreadFitting;
    NSString *value = dictionary[key];
    if (value) {
        if ([value isEqualToString:@"fit"]) {
            spreadFitting = PSPDFConfigurationSpreadFittingFit;
        } else if ([value isEqualToString:@"fill"]) {
            spreadFitting = PSPDFConfigurationSpreadFittingFill;
        } else if ([value isEqualToString:@"adaptive"]) {
            spreadFitting = PSPDFConfigurationSpreadFittingAdaptive;
        }
    }
    return spreadFitting;
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
        } else if ([option isEqualToString:@"appearance"] || [option isEqualToString:@"iOSAppearance"]) {
            finalOptions |= PSPDFSettingsOptionAppearance;
        } else if ([option isEqualToString:@"brightness"] || [option isEqualToString:@"iOSBrightness"]) {
            finalOptions |= PSPDFSettingsOptionBrightness;
        } else if ([option isEqualToString:@"pageMode"] || [option isEqualToString:@"iOSPageMode"]) {
            finalOptions |= PSPDFSettingsOptionPageMode;
        } else if ([option isEqualToString:@"spreadFitting"] || [option isEqualToString:@"iOSSpreadFitting"]) {
            finalOptions |= PSPDFSettingsOptionSpreadFitting;
        } else if ([option isEqualToString:@"androidTheme"] || [option isEqualToString:@"androidPageLayout"] || [option isEqualToString:@"androidScreenAwake"]) {
            // NO OP. Only supported on Android
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
        return PSPDFAnnotationTypeNone;
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
    } else if ([typeString isEqualToString:@"pspdfkit/all"]) {
        return PSPDFAnnotationTypeAll;
    } else if ([typeString isEqualToString:@"all"]) {
        return PSPDFAnnotationTypeAll;
    } else {
        return PSPDFAnnotationTypeNone;
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
