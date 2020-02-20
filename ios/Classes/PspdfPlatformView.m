//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfPlatformView.h"

@import PSPDFKit;
@import PSPDFKitUI;

@interface PspdfPlatformView()
@property int64_t platformViewId;
@property (nonatomic) FlutterMethodChannel *channel;
@property (nonatomic) PSPDFViewController *pdfViewController;
@property (nonatomic) UINavigationController *navigationController;
@end

@implementation PspdfPlatformView

- (nonnull UIView *)view {
    return self.navigationController.view ?: [UIView new];
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    NSString *name = [NSString stringWithFormat:@"com.pspdfkit.widget.%lld",viewId];
    _platformViewId = viewId;
    _channel = [FlutterMethodChannel methodChannelWithName:name binaryMessenger:messenger];

    _navigationController = [UINavigationController new];
    _navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    // View controller containment
    UIViewController *flutterViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (flutterViewController == nil) {
        NSLog(@"Warning: FlutterViewController is nil. This may lead to view container containment problems with PSPDFViewController since we no longer receive UIKit lifecycle events.");
    }
    [flutterViewController addChildViewController:_navigationController];
    [flutterViewController.view addSubview:_navigationController.view];
    [_navigationController didMoveToParentViewController:flutterViewController];

    _pdfViewController = [[PSPDFViewController alloc] init];
    [_navigationController setViewControllers:@[_pdfViewController] animated:NO];
    _pdfViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];

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

- (void)backButtonPressed {
    [_channel invokeMethod:@"popPlatformView" arguments:nil];
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
