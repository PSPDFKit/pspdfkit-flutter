#import "PspdfkitPlugin.h"

@import PSPDFKit;
@import PSPDFKitUI;

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
    } else if ([@"present" isEqualToString:call.method]) {
        if (call.arguments[@"document"] != nil) {
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *documentPath = [cachePath stringByAppendingPathComponent:call.arguments[@"document"]];
            
            PSPDFDocument *document = [self PSPDFDocument:documentPath];
            PSPDFViewController *pdfViewController = [[PSPDFViewController alloc] initWithDocument:document];
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pdfViewController];
            UIViewController *presentingViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            [presentingViewController presentViewController:navigationController animated:YES completion:nil];
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (PSPDFDocument *)PSPDFDocument:(NSString *)string {
    NSURL *url;
    
    if ([string hasPrefix:@"/"]) {
        url = [NSURL fileURLWithPath:string];
    } else {
        url = [NSBundle.mainBundle URLForResource:string withExtension:nil];
    }
    return [[PSPDFDocument alloc] initWithURL:url];
}

@end

