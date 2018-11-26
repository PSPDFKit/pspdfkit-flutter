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
        NSString *documentPath = call.arguments[@"document"];
        NSAssert(documentPath != nil, @"Document path may not be nil.");
        NSAssert(documentPath.length != 0, @"Document path may not be empty.");
        PSPDFDocument *document = [self PSPDFDocument:documentPath];
        PSPDFViewController *pdfViewController = [[PSPDFViewController alloc] initWithDocument:document];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pdfViewController];
        UIViewController *presentingViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        [presentingViewController presentViewController:navigationController animated:YES completion:nil];
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

