//
//  Copyright © 2018-2021 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfPlatformView.h"
#import "PspdfkitFlutterHelper.h"
#import "PspdfkitFlutterConverter.h"

@import PSPDFKit;
@import PSPDFKitUI;


@interface PspdfPlatformView() <PSPDFViewControllerDelegate>
@property int64_t platformViewId;
@property (nonatomic) FlutterMethodChannel *channel;
@property (nonatomic, weak) UIViewController *flutterViewController;
@property (nonatomic) PSPDFViewController *pdfViewController;
@property (nonatomic) PSPDFNavigationController *navigationController;
@end

@implementation PspdfPlatformView

- (nonnull UIView *)view {
    return self.navigationController.view ?: [UIView new];
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    NSString *name = [NSString stringWithFormat:@"com.pspdfkit.widget.%lld",viewId];
    _platformViewId = viewId;
    _channel = [FlutterMethodChannel methodChannelWithName:name binaryMessenger:messenger];

    _navigationController = [PSPDFNavigationController new];
    _navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    // View controller containment
    _flutterViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (_flutterViewController == nil) {
        NSLog(@"Warning: FlutterViewController is nil. This may lead to view container containment problems with PSPDFViewController since we no longer receive UIKit lifecycle events.");
    }

    [_flutterViewController addChildViewController:_navigationController];
    [_flutterViewController.view addSubview:_navigationController.view];
    [_navigationController didMoveToParentViewController:_flutterViewController];

    _pdfViewController = [[PSPDFViewController alloc] init];

    [_navigationController setViewControllers:@[_pdfViewController] animated:NO];

    self = [super init];

    __weak id weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        [weakSelf handleMethodCall:call result:result];
    }];

    return self;
}

- (void)dealloc {
    [self cleanup];
}

- (void)cleanup {
    self.pdfViewController.document = nil;
    [self.pdfViewController.view removeFromSuperview];
    [self.pdfViewController removeFromParentViewController];
    [self.navigationController.navigationBar removeFromSuperview];
    [self.navigationController.view removeFromSuperview];
    [self.navigationController removeFromParentViewController];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"initializePlatformView" isEqualToString:call.method]) {
        NSString *documentPath = call.arguments[@"document"];

        if (documentPath == nil || documentPath.length <= 0) {
            FlutterError *error = [FlutterError errorWithCode:@"" message:@"Document path may not be nil or empty." details:nil];
            result(error);
            return;
        }

        NSDictionary *configurationDictionary = call.arguments[@"configuration"];

        PSPDFDocument *document = [PspdfkitFlutterHelper documentFromPath:documentPath];
        
        
        if ( [configurationDictionary objectForKey:@"fullname"]!= [NSNull null]) {
            PSPDFUsernameHelper.defaultAnnotationUsername = [configurationDictionary objectForKey:@"fullname"];
            document.defaultAnnotationUsername = [configurationDictionary objectForKey:@"fullname"];
        }
        
        [PspdfkitFlutterHelper unlockWithPasswordIfNeeded:document dictionary:configurationDictionary];

        BOOL isImageDocument = [PspdfkitFlutterHelper isImageDocument:documentPath];
        PSPDFConfiguration *configuration = [PspdfkitFlutterConverter configuration:configurationDictionary isImageDocument:isImageDocument];

       
        
        
        __weak typeof(NSDictionary) *weakConfiguration = configurationDictionary;
        
        PSPDFRenderDrawBlock renderBlock = ^(CGContextRef context, PSPDFPageIndex pageIndex, CGRect cropBox, PSPDFRenderOptions *options) {
                       Boolean *watermarkEnabled = [[configurationDictionary valueForKey:@"watermarkEnabled"] boolValue];
                           if (watermarkEnabled) {
                               CGContextSaveGState(context);
                               NSString *text = [configurationDictionary valueForKey:@"fullname"];
                               NSString *opacity = [configurationDictionary valueForKey:@"watermarkOpacity"];
                               NSString *color = [configurationDictionary valueForKey:@"watermarkColor"];
                               NSString *fontSize = [configurationDictionary valueForKey:@"watermarkFontSize"];
            
            
                                
                               for (int i = 1; i <= 10; i++)
                               {
                                   
                                   text= [text stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"   ",text]];
                               }
                               
                                CGContextSaveGState(context);
            
                                
                               unsigned int c;
                               if ([color characterAtIndex:0] == '#') {
                                   [[NSScanner scannerWithString:[color substringFromIndex:1]] scanHexInt:&c];
                               } else {
                                   [[NSScanner scannerWithString:color] scanHexInt:&c];
                               }
                               UIColor *watermarkColor = [UIColor colorWithRed:((c & 0xff0000) >> 16) / 255.0
                                                                         green:((c & 0xff00) >> 8) / 255.0
                                                                          blue:(c & 0xff) / 255.0 alpha:1.0];
            
            
                               CGFloat watermarkColorAlpha = (CGFloat) [opacity floatValue] ;
                               NSStringDrawingContext *stringDrawingContext = [NSStringDrawingContext new];
                               stringDrawingContext.minimumScaleFactor = 0.1f;
                               //calcolo di quanta rotazione bisogna applicare per averlo diagonale alla pagina
                               CGFloat xDiff = cropBox.size.width;
                               CGFloat yDiff = cropBox.size.height;
                               CGFloat rads = atan2(yDiff, xDiff);
                               CGContextTranslateCTM(context, -80, -165);
                               CGContextRotateCTM(context, rads);
            
                               NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                               paragraphStyle.lineBreakMode = NSLineBreakByClipping;
                               cropBox.size.width = cropBox.size.width * 2;
                               [text drawWithRect:cropBox
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:[fontSize floatValue]],
                                               NSForegroundColorAttributeName: [watermarkColor colorWithAlphaComponent:watermarkColorAlpha],
                                               NSParagraphStyleAttributeName: paragraphStyle
                                       }
                                          context:stringDrawingContext];
                               CGContextRestoreGState(context);
                           }
                           /*NSString *protocolNumberOptions = [weakSelf valueForKey:@"protocolNumber"];
                           if ([protocolNumberOptions length] > 0) {
                               //salvo il context
                               CGContextSaveGState(context);
                               NSString *protocolText = [NSString stringWithFormat:@"Protocollo n. %@", protocolNumberOptions];
                               NSStringDrawingContext *stringDrawingContext = [NSStringDrawingContext new];
                               stringDrawingContext.minimumScaleFactor = 0.1f;
                               //sposto la label in alto
                               CGContextTranslateCTM(context, -120, 10);
                               NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                               style.alignment = kCTRightTextAlignment;
                               [protocolText drawWithRect:cropBox
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:14],
                                                       NSForegroundColorAttributeName: [UIColor.blackColor colorWithAlphaComponent:1.0f],
                                                       NSParagraphStyleAttributeName: style
                                               }
                                                  context:stringDrawingContext];
                               CGContextRestoreGState(context);
                           }*/
                       };

        
        
        //configuration.drawOnAllCurrentPages(renderDrawBlock)
        
        if ([configurationDictionary[@"watermarkEnabled"] boolValue]) [document updateRenderOptionsForType:PSPDFRenderTypeAll withBlock:^(PSPDFRenderOptions * options){
                               options.drawBlock = renderBlock;
                           }];
        
        self.pdfViewController = [[PSPDFViewController alloc] initWithDocument:document configuration:configuration];
        self.pdfViewController.appearanceModeManager.appearanceMode = [PspdfkitFlutterConverter appearanceMode:configurationDictionary];
        self.pdfViewController.pageIndex = [PspdfkitFlutterConverter pageIndex:configurationDictionary];
        self.pdfViewController.delegate = self;
        
        
        // only these two menus
        self.pdfViewController.documentInfoCoordinator.availableControllerOptions = @[PSPDFDocumentInfoOptionOutline, PSPDFDocumentInfoOptionAnnotations];

        if ((id)configurationDictionary != NSNull.null) {
            [PspdfkitFlutterHelper setLeftBarButtonItems:configurationDictionary[@"leftBarButtonItems"] forViewController:self.pdfViewController];
            [PspdfkitFlutterHelper setRightBarButtonItems:configurationDictionary[@"rightBarButtonItems"] forViewController:self.pdfViewController];
            [PspdfkitFlutterHelper setToolbarTitle:configurationDictionary[@"toolbarTitle"] forViewController:self.pdfViewController];
        }

        [self.navigationController setViewControllers:@[self.pdfViewController] animated:NO];
        result(@(YES));
    } else {
        [PspdfkitFlutterHelper processMethodCall:call result:result forViewController:self.pdfViewController];
    }
}

# pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewControllerDidDismiss:(PSPDFViewController *)pdfController {
    // Don't hold on to the view controller object after dismissal.
    [self cleanup];
}

@end
