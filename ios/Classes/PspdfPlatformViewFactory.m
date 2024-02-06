//
//  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfPlatformView.h"
#import "PspdfPlatformViewFactory.h"

@import PSPDFKit;
@import PSPDFKitUI;

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

// Required to pass the arguments to UiKitView.
- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

@end
