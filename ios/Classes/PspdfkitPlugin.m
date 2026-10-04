//
//  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfkitPlugin.h"
#include <Foundation/Foundation.h>
#import "PspdfPlatformViewFactory.h"
#import "nutrient_flutter-Swift.h"

@import PSPDFKit;
@import PSPDFKitUI;
@import Instant;

@interface PspdfkitPlugin()
@property PspdfkitApiImpl *apiImpl;
@property HeadlessDocumentApiImpl *headlessDocumentApiImpl;
@end

@implementation PspdfkitPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    PspdfPlatformViewFactory *platformViewFactory = [[PspdfPlatformViewFactory alloc] initWithMessenger:[registrar messenger]];
    [registrar registerViewFactory:platformViewFactory withId:@"com.nutrient.widget"];

    PspdfkitPlugin* instance = [[PspdfkitPlugin alloc] init];
    // Retain the plugin instance for the engine's lifetime so
    // detachFromEngineForRegistrar: runs. This used to be provided by
    // addMethodCallDelegate:channel: for the (now removed) legacy
    // com.nutrient.global MethodChannel.
    [registrar publish:instance];

    // Register pigeon APIs.
    instance.apiImpl = [[PspdfkitApiImpl alloc] init];
    [instance.apiImpl registerWithBinaryMessenger:[registrar messenger]];

    // Register headless document API.
    instance.headlessDocumentApiImpl = [[HeadlessDocumentApiImpl alloc] initWithBinaryMessenger:[registrar messenger]];
    [instance.headlessDocumentApiImpl registerWithBinaryMessenger:[registrar messenger]];
}

- (void) detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    // Unregister the API implementations.
    [_apiImpl unRegister];
    _apiImpl = nil;

    [_headlessDocumentApiImpl unregisterWithBinaryMessenger:[registrar messenger]];
    _headlessDocumentApiImpl = nil;

    // Clean up all headless documents
    [HeadlessDocumentApiImpl clearAllDocuments];
}

- (void)dealloc {
    self.apiImpl = nil;
    self.headlessDocumentApiImpl = nil;
}

@end
