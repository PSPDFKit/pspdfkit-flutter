//
//  Copyright © 2018-2022 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import <Flutter/Flutter.h>

@import PSPDFKit;
@import PSPDFKitUI;

NS_ASSUME_NONNULL_BEGIN

@interface PspdfkitFlutterHelper : NSObject

+ (void)processMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result forViewController:(PSPDFViewController *)pdfViewController;

// Document Helpers
+ (PSPDFDocument *)documentFromPath:(NSString *)path;
+ (void)unlockWithPasswordIfNeeded:(PSPDFDocument *)document dictionary:(NSDictionary *)dictionary;
+ (BOOL)isImageDocument:(NSString *)path;

// Toolbar Helpers
+ (void)setToolbarTitle:(NSString *)toolbarTitle forViewController:(PSPDFViewController *)pdfViewController;
+ (void)setLeftBarButtonItems:(nullable NSArray <NSString *> *)items forViewController:(PSPDFViewController *)pdfViewController;
+ (void)setRightBarButtonItems:(nullable NSArray <NSString *> *)items forViewController:(PSPDFViewController *)pdfViewController;

@end

NS_ASSUME_NONNULL_END
