//
//  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

@class PSPDFViewController;

@interface PspdfPlatformView : NSObject<FlutterPlatformView>
- (instancetype _Nonnull)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args messenger:(NSObject<FlutterBinaryMessenger> * _Nonnull)messenger;

/// Registry for PSPDFViewController instances, keyed by view ID.
/// This allows Dart adapters to access the native PSPDFViewController via FFI.

/// Registers a PSPDFViewController for a given view ID.
///
/// @param viewId The platform view ID.
/// @param controller The PSPDFViewController instance.
+ (void)registerViewController:(int64_t)viewId controller:(PSPDFViewController * _Nonnull)controller;

/// Unregisters the PSPDFViewController for a given view ID.
///
/// @param viewId The platform view ID.
+ (void)unregisterViewController:(int64_t)viewId;

/// Gets the PSPDFViewController for a given view ID.
/// This method is intended to be called from Dart via FFI.
///
/// @param viewId The platform view ID.
/// @return The PSPDFViewController instance, or nil if not registered.
+ (PSPDFViewController * _Nullable)getViewController:(int64_t)viewId;

@end
