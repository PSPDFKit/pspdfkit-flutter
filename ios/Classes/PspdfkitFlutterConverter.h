//
//  Copyright © 2020 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import <Foundation/Foundation.h>

@import PSPDFKit;
@import PSPDFKitUI;

NS_ASSUME_NONNULL_BEGIN

@interface PspdfkitFlutterConverter : NSObject

+ (PSPDFConfiguration *)configuration:(NSDictionary *)dictionary isImageDocument:(BOOL)isImageDocument;
+ (PSPDFUserInterfaceViewMode)userInterfaceViewMode:(NSDictionary *)dictionary;
+ (PSPDFThumbnailBarMode)thumbnailBarMode:(NSDictionary *)dictionary;
+ (PSPDFAppearanceMode)appearanceMode:(NSDictionary *)dictionary;
+ (PSPDFPageIndex)pageIndex:(NSDictionary *)dictionary;
+ (PSPDFPageMode)pageMode:(NSDictionary *)dictionary;
+ (PSPDFSettingsOptions)settingsOptions:(nullable NSArray <NSString *> *)options;
+ (PSPDFAnnotationType)annotationTypeFromString:(NSString *)typeString;
+ (PSPDFAnnotationChange)annotationChangeFromString:(NSString *)changeString;

+ (NSArray <NSDictionary *> *)instantJSONFromAnnotations:(NSArray <PSPDFAnnotation *> *) annotations;

@end

NS_ASSUME_NONNULL_END
