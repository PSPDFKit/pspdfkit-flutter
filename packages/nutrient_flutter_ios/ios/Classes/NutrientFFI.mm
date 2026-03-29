#import "NutrientFFI.h"
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <Instant/Instant.h>


// Forward-declare ViewControllerContainerCompanion so this file can be compiled
// both by the native-assets hook (without the generated Swift bridging header)
// and by CocoaPods (which provides the full bridging header).
// When compiled by CocoaPods the generated header is also included via the
// umbrella precompiled header, so the declaration below is harmless.
@interface ViewControllerContainerCompanion : NSObject
+ (BOOL)attachViewControllerWithViewId:(int64_t)viewId viewController:(void *)viewController;
+ (void *)getViewControllerWithViewId:(int64_t)viewId;
@end

__attribute__((used))
bool nutrient_attach_view_controller(int64_t viewId, void *viewController) {
  return [ViewControllerContainerCompanion attachViewControllerWithViewId:viewId
                                                            viewController:viewController];
}

__attribute__((used))
void* nutrient_get_view_controller(int64_t viewId) {
  // First try the FFI-based ViewControllerContainer registry (NutrientViewIOS path).
  void *vc = [ViewControllerContainerCompanion getViewControllerWithViewId:viewId];
  if (vc != NULL) {
    return vc;
  }
  // Fall back to the Pigeon/method-channel registry (NutrientView / AdapterBridge path).
  // Use NSClassFromString to avoid a link-time dependency on PspdfPlatformView
  // (which lives in nutrient_flutter's pod and is not available during hook linking).
  Class pigeonViewClass = NSClassFromString(@"PspdfPlatformView");
  if (pigeonViewClass != nil) {
    SEL getVCSel = NSSelectorFromString(@"getViewController:");
    if ([pigeonViewClass respondsToSelector:getVCSel]) {
      id pigeonVC = ((id (*)(Class, SEL, int64_t))objc_msgSend)(pigeonViewClass, getVCSel, viewId);
      if (pigeonVC != nil) {
        return (__bridge void *)pigeonVC;
      }
    }
  }
  return NULL;
}

// Associated-object keys used to keep Instant objects alive for the lifetime of the VC.
static const char kInstantClientKey = 0;
static const char kInstantDescriptorKey = 0;

// ---------------------------------------------------------------------------
// Private helper — applies a JSON-derived NSDictionary to a PSPDFConfigurationBuilder.
// ---------------------------------------------------------------------------
static void nutrient_apply_config_dict(NSDictionary *dict, PSPDFConfigurationBuilder *builder) {
  if (!dict) return;

  // scrollDirection — PSPDFScrollDirectionHorizontal=0, Vertical=1
  NSNumber *scrollDir = dict[@"scrollDirection"];
  if (scrollDir) builder.scrollDirection = (PSPDFScrollDirection)scrollDir.unsignedIntegerValue;

  // pageMode — PSPDFPageModeSingle=0, Double=1, Automatic=2
  NSNumber *pageMode = dict[@"pageMode"];
  if (pageMode) builder.pageMode = (PSPDFPageMode)pageMode.unsignedIntegerValue;

  // pageTransition — ScrollPerSpread=0, ScrollContinuous=1, Curl=2
  NSNumber *pageTransition = dict[@"pageTransition"];
  if (pageTransition) builder.pageTransition = (PSPDFPageTransition)pageTransition.unsignedIntegerValue;

  // spreadFitting — Fit=0, Fill=1, Adaptive=2
  NSNumber *spreadFitting = dict[@"spreadFitting"];
  if (spreadFitting) builder.spreadFitting = (PSPDFConfigurationSpreadFitting)spreadFitting.integerValue;

  // bookmarkIndicatorMode — Off=0, AlwaysOn=1, OnWhenBookmarked=2
  NSNumber *bookmarkMode = dict[@"bookmarkIndicatorMode"];
  if (bookmarkMode) builder.bookmarkIndicatorMode = (PSPDFPageBookmarkIndicatorMode)bookmarkMode.unsignedIntegerValue;

  // Booleans
  NSNumber *firstPageAlwaysSingle = dict[@"firstPageAlwaysSingle"];
  if (firstPageAlwaysSingle) builder.firstPageAlwaysSingle = firstPageAlwaysSingle.boolValue;

  NSNumber *pageLabelEnabled = dict[@"pageLabelEnabled"];
  if (pageLabelEnabled) builder.pageLabelEnabled = pageLabelEnabled.boolValue;

  NSNumber *textSelectionEnabled = dict[@"textSelectionEnabled"];
  if (textSelectionEnabled) builder.textSelectionEnabled = textSelectionEnabled.boolValue;

  NSNumber *autosaveEnabled = dict[@"autosaveEnabled"];
  if (autosaveEnabled) builder.autosaveEnabled = autosaveEnabled.boolValue;

  NSNumber *bookmarkInteraction = dict[@"bookmarkIndicatorInteractionEnabled"];
  if (bookmarkInteraction) builder.bookmarkIndicatorInteractionEnabled = bookmarkInteraction.boolValue;

  // thumbnailBarMode — None=0, ScrubberBar=1, Scrollable=2, FloatingScrubberBar=3
  NSNumber *thumbnailBarMode = dict[@"thumbnailBarMode"];
  if (thumbnailBarMode) builder.thumbnailBarMode = (PSPDFThumbnailBarMode)thumbnailBarMode.unsignedIntegerValue;

  // userInterfaceViewMode — Always=0, Automatic=1, AutomaticNoFirstLastPage=2, Never=3
  NSNumber *userInterfaceViewMode = dict[@"userInterfaceViewMode"];
  if (userInterfaceViewMode) builder.userInterfaceViewMode = (PSPDFUserInterfaceViewMode)userInterfaceViewMode.unsignedIntegerValue;

  // searchMode — Modal=0, Inline=1
  NSNumber *searchMode = dict[@"searchMode"];
  if (searchMode) builder.searchMode = (PSPDFSearchMode)searchMode.unsignedIntegerValue;

  // documentLabelEnabled — PSPDFAdaptiveConditional: NO=0, YES=1, Adaptive=2
  NSNumber *documentLabelEnabled = dict[@"documentLabelEnabled"];
  if (documentLabelEnabled) builder.documentLabelEnabled = (PSPDFAdaptiveConditional)documentLabelEnabled.unsignedIntegerValue;

  // allowToolbarTitleChange
  NSNumber *allowToolbarTitleChange = dict[@"allowToolbarTitleChange"];
  if (allowToolbarTitleChange) builder.allowToolbarTitleChange = allowToolbarTitleChange.boolValue;

  // showBackActionButton / showForwardActionButton
  NSNumber *showBack = dict[@"showBackActionButton"];
  if (showBack) builder.showBackActionButton = showBack.boolValue;

  NSNumber *showForward = dict[@"showForwardActionButton"];
  if (showForward) builder.showForwardActionButton = showForward.boolValue;

  // isCreateAnnotationMenuEnabled
  NSNumber *createAnnotationMenuEnabled = dict[@"isCreateAnnotationMenuEnabled"];
  if (createAnnotationMenuEnabled) builder.createAnnotationMenuEnabled = createAnnotationMenuEnabled.boolValue;

  // Zoom scales
  NSNumber *maxZoom = dict[@"maximumZoomScale"];
  if (maxZoom) builder.maximumZoomScale = maxZoom.floatValue;

  NSNumber *minZoom = dict[@"minimumZoomScale"];
  if (minZoom) builder.minimumZoomScale = minZoom.floatValue;
}

// ---------------------------------------------------------------------------
// Private helper — shared client/descriptor/download/VC setup.
// ---------------------------------------------------------------------------
static void* nutrient_create_instant_vc_internal(
    const char* serverUrl,
    const char* jwt,
    PSPDFConfiguration* configuration
) {
  NSString *serverUrlStr = [NSString stringWithUTF8String:serverUrl];
  NSString *jwtStr       = [NSString stringWithUTF8String:jwt];
  NSURL    *url          = [NSURL URLWithString:serverUrlStr];
  if (url == nil) {
    fprintf(stderr, "[NutrientFFI] Invalid URL: %s\n", serverUrl);
    return NULL;
  }

  NSError *error = nil;
  PSPDFInstantClient *client = [[PSPDFInstantClient alloc] initWithServerURL:url error:&error];
  if (client == nil) {
    fprintf(stderr, "[NutrientFFI] PSPDFInstantClient init failed: %s\n",
            error.localizedDescription.UTF8String ?: "unknown");
    return NULL;
  }
  fprintf(stderr, "[NutrientFFI] PSPDFInstantClient created\n");

  id<PSPDFInstantDocumentDescriptor> descriptor =
      [client documentDescriptorForJWT:jwtStr error:&error];
  if (descriptor == nil) {
    fprintf(stderr, "[NutrientFFI] documentDescriptorForJWT failed: %s\n",
            error.localizedDescription.UTF8String ?: "unknown");
    return NULL;
  }
  fprintf(stderr, "[NutrientFFI] document descriptor obtained\n");

  NSError *downloadError = nil;
  BOOL startedDownload = [descriptor downloadUsingJWT:jwtStr error:&downloadError];
  if (!startedDownload) {
    fprintf(stderr, "[NutrientFFI] downloadUsingJWT failed: %s\n",
            downloadError.localizedDescription.UTF8String ?: "unknown");
  } else {
    fprintf(stderr, "[NutrientFFI] downloadUsingJWT started successfully\n");
  }

  PSPDFDocument *document = descriptor.editableDocument;
  fprintf(stderr, "[NutrientFFI] editableDocument = %s\n",
          document ? document.description.UTF8String : "(nil)");

  PSPDFInstantViewController *vc =
      [[PSPDFInstantViewController alloc] initWithDocument:document
                                             configuration:configuration];
  fprintf(stderr, "[NutrientFFI] PSPDFInstantViewController alloc'd\n");

  // Enable real-time sync in both directions:
  // - shouldListenForServerChangesWhenVisible: pulls remote changes when visible.
  // - delayForSyncingLocalChanges: 1 s delay after last edit before uploading.
  vc.shouldListenForServerChangesWhenVisible = YES;
  descriptor.delayForSyncingLocalChanges = 1.0;
  fprintf(stderr, "[NutrientFFI] sync configured: listen=%d, delayForSyncingLocalChanges=1.0\n",
          (int)vc.shouldListenForServerChangesWhenVisible);

  // Keep both the client AND the descriptor alive for the lifetime of the VC.
  // Without retaining the descriptor, its delayForSyncingLocalChanges setting
  // and sync state are lost when ARC releases it.
  objc_setAssociatedObject(vc, &kInstantClientKey,     client,     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(vc, &kInstantDescriptorKey, descriptor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  fprintf(stderr, "[NutrientFFI] PSPDFInstantViewController created, client+descriptor retained\n");

  return (__bridge_retained void *)vc;
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

__attribute__((used))
void* nutrient_create_instant_view_controller(const char* serverUrl, const char* jwt) {
  fprintf(stderr, "[NutrientFFI] nutrient_create_instant_view_controller called: %s\n", serverUrl);
  PSPDFConfiguration *configuration = [PSPDFInstantViewController defaultConfiguration];
  return nutrient_create_instant_vc_internal(serverUrl, jwt, configuration);
}

__attribute__((used))
void* nutrient_create_instant_view_controller_with_config(
    const char* serverUrl,
    const char* jwt,
    const char* configJson
) {
  fprintf(stderr, "[NutrientFFI] nutrient_create_instant_view_controller_with_config called: %s\n", serverUrl);

  PSPDFConfiguration *configuration;
  if (configJson != NULL) {
    NSString *jsonStr = [NSString stringWithUTF8String:configJson];
    NSData   *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = nil;
    if (jsonData) {
      NSError *jsonError = nil;
      dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
      if (!dict) {
        fprintf(stderr, "[NutrientFFI] JSON parse error: %s\n",
                jsonError.localizedDescription.UTF8String ?: "unknown");
      }
    }
    configuration = [[PSPDFInstantViewController defaultConfiguration]
        configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder *builder) {
          nutrient_apply_config_dict(dict, builder);
        }];
  } else {
    configuration = [PSPDFInstantViewController defaultConfiguration];
  }

  return nutrient_create_instant_vc_internal(serverUrl, jwt, configuration);
}

__attribute__((used))
void nutrient_instant_sync_annotations(void* viewController) {
  if (viewController == NULL) return;
  PSPDFInstantViewController *vc =
      (__bridge PSPDFInstantViewController *)viewController;
  fprintf(stderr, "[NutrientFFI] nutrient_instant_sync_annotations: syncChanges called\n");
  [vc syncChanges:nil];
}

__attribute__((used))
void nutrient_instant_set_listen_for_server_changes(void* viewController, bool listen) {
  if (viewController == NULL) return;
  PSPDFInstantViewController *vc =
      (__bridge PSPDFInstantViewController *)viewController;
  vc.shouldListenForServerChangesWhenVisible = listen;
}
