#import "NutrientFFI.h"
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <Instant/Instant.h>
// Not pulled in by Instant.h; used by the signature interceptor below.
#import <PSPDFKit/PSPDFSignatureFormElement.h>
#import <PSPDFKitUI/PSPDFAnnotationStateManager.h>
#import <PSPDFKitUI/PSPDFConfiguration.h>
#import <PSPDFKitUI/PSPDFSignatureSelectorViewController.h>
#import <PSPDFKitUI/PSPDFViewControllerDelegate.h>
#import <PSPDFKitUI/PSPDFViewState.h>


// Forward-declare ViewControllerContainerCompanion so this file can be compiled
// both by the native-assets hook (without the generated Swift bridging header)
// and by CocoaPods (which provides the full bridging header).
// When compiled by CocoaPods the generated header is also included via the
// umbrella precompiled header, so the declaration below is harmless.
@interface ViewControllerContainerCompanion : NSObject
+ (BOOL)attachViewControllerWithViewId:(int64_t)viewId viewController:(void *)viewController;
+ (void *)getViewControllerWithViewId:(int64_t)viewId;
@end

// Forward-declare NutrientConflictResolutionCompanion (ConflictResolutionCompanion.swift)
// for the same reason as ViewControllerContainerCompanion above — this file must
// keep compiling under the native-assets hook, which builds without the
// generated Swift bridging header.
@interface NutrientConflictResolutionCompanion : NSObject
+ (void)registerWithResolutionRawValue:(NSUInteger)resolutionRawValue for:(UIViewController *)viewController;
+ (void)unregisterFor:(UIViewController *)viewController;
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
// Private helper — applies an AI-assistant sub-dictionary (keys: serverUrl,
// jwt, sessionId, userId) to a PSPDFConfigurationBuilder via KVC.
//
// AIAssistantConfiguration is `NS_REFINED_FOR_SWIFT` and the
// `aiAssistantConfiguration` property on PSPDFConfigurationBuilder is only
// visible to Swift. We instantiate the Obj-C runtime class by name and assign
// via KVC so this file stays Obj-C++ and doesn't require linking a Swift
// helper (which fails to resolve in the Flutter native-assets dylib build).
// ---------------------------------------------------------------------------
static void nutrient_apply_ai_config_dict(NSDictionary *aiAssistant,
                                          PSPDFConfigurationBuilder *builder) {
  if (![aiAssistant isKindOfClass:[NSDictionary class]]) return;

  NSString *serverUrl = aiAssistant[@"serverUrl"];
  NSString *jwt       = aiAssistant[@"jwt"];
  NSString *sessionId = aiAssistant[@"sessionId"];
  NSString *userId    = aiAssistant[@"userId"];

  if (serverUrl.length == 0 || jwt.length == 0 || sessionId.length == 0) return;

  NSURL *url = [NSURL URLWithString:serverUrl];
  Class cfgClass = NSClassFromString(@PSPDF_PREFIX "AIAssistantConfiguration");
  // PSPDFBaseConfiguration exposes `+configurationWithBuilder:` taking a block
  // that receives the mutable builder — that is the canonical construction path.
  SEL factorySel = NSSelectorFromString(@"configurationWithBuilder:");
  if (url == nil || cfgClass == nil || ![cfgClass respondsToSelector:factorySel]) return;

  void (^configBlock)(id) = ^(id b) {
    [b setValue:url       forKey:@"serverURL"];
    [b setValue:jwt       forKey:@"jwt"];
    [b setValue:sessionId forKey:@"sessionID"];
    if (userId.length > 0) {
      [b setValue:userId forKey:@"userID"];
    }
  };
  id (*msgSend)(Class, SEL, void (^)(id)) = (id (*)(Class, SEL, void (^)(id)))objc_msgSend;
  id aiCfg = msgSend(cfgClass, factorySel, configBlock);
  if (aiCfg != nil) {
    [builder setValue:aiCfg forKey:@"aiAssistantConfiguration"];
    fprintf(stderr, "[NutrientFFI] AI Assistant configuration applied to builder\n");
  }
}

// ---------------------------------------------------------------------------
// Private helper — converts a "#RRGGBB" / "#AARRGGBB" hex string (produced by
// SignatureColorPreset.toMap() in the platform-interface package) to a
// UIColor. Returns nil for malformed input so callers can fall back to a
// PSPDFKit default rather than a bogus color.
// ---------------------------------------------------------------------------
static UIColor *nutrient_color_from_hex(NSString *hex) {
  if (![hex isKindOfClass:[NSString class]] || ![hex hasPrefix:@"#"]) return nil;

  NSString *hexDigits = [hex substringFromIndex:1];
  unsigned int hexValue = 0;
  if (![[NSScanner scannerWithString:hexDigits] scanHexInt:&hexValue]) return nil;

  CGFloat r, g, b, a;
  if (hexDigits.length == 6) {
    r = ((hexValue & 0xFF0000) >> 16) / 255.0;
    g = ((hexValue & 0x00FF00) >> 8)  / 255.0;
    b = (hexValue & 0x0000FF)         / 255.0;
    a = 1.0;
  } else if (hexDigits.length == 8) {
    a = ((hexValue & 0xFF000000) >> 24) / 255.0;
    r = ((hexValue & 0x00FF0000) >> 16) / 255.0;
    g = ((hexValue & 0x0000FF00) >> 8)  / 255.0;
    b = (hexValue & 0x000000FF)         / 255.0;
  } else {
    return nil;
  }
  return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

// ---------------------------------------------------------------------------
// Private helper — applies a signature-creation sub-dictionary (keys:
// creationModes, colorOptions, iosSignatureAspectRatio, fonts — matches
// SignatureCreationConfiguration.toMap() in the platform-interface package)
// to a PSPDFConfigurationBuilder by building a
// PSPDFSignatureCreationConfiguration and assigning it to
// `signatureCreationConfiguration`. Mirrors the legacy
// `SignatureHelper.configureSignatureCreation(_:withOptions:)` mapping
// (nutrient_flutter/ios/Classes/SignatureHelper.swift), ported to Obj-C++ so
// this file doesn't need a Swift dependency.
//
// `androidSignatureOrientation` is intentionally not read here — it has no
// iOS equivalent and IOSConfigurationBuilder never includes it in the JSON
// it forwards.
//
// `configurationUpdatedWithBuilder:`'s block parameter is resolved by class
// name and mutated via KVC (rather than declared as the concrete
// PSPDFSignatureCreationConfigurationBuilder type), matching
// nutrient_apply_ai_config_dict above — this keeps the call resilient to
// exactly how the SDK's real headers type that parameter without this file
// needing to hard-code it.
// ---------------------------------------------------------------------------
static void nutrient_apply_signature_creation_config_dict(
    NSDictionary *dict, PSPDFConfigurationBuilder *builder) {
  if (![dict isKindOfClass:[NSDictionary class]]) return;

  Class cfgClass = NSClassFromString(@PSPDF_PREFIX "SignatureCreationConfiguration");
  SEL defaultConfigSel = NSSelectorFromString(@"defaultConfiguration");
  if (cfgClass == nil || ![cfgClass respondsToSelector:defaultConfigSel]) return;
  id (*classMsgSend)(Class, SEL) = (id (*)(Class, SEL))objc_msgSend;
  id defaultConfig = classMsgSend(cfgClass, defaultConfigSel);
  if (defaultConfig == nil) return;

  SEL updateSel = NSSelectorFromString(@"configurationUpdatedWithBuilder:");
  if (![defaultConfig respondsToSelector:updateSel]) return;

  void (^configBlock)(id) = ^(id signatureBuilder) {
    // creationModes — array of "draw" | "image" | "type" strings.
    // `availableModes` is KVC-set as an array of NSNumbers, so we use the raw
    // PSPDFSignatureCreationMode ordinals (draw=0, image=1, type=2) directly:
    // the SDK doesn't expose the `PSPDFSignatureCreationMode*` enum constants
    // to this Objective-C translation unit (the type is refined for Swift), and
    // the ordinals are the stable enum contract (see PSPDFSignatureCreationMode
    // in the generated FFI bindings).
    NSArray *creationModes = dict[@"creationModes"];
    if ([creationModes isKindOfClass:[NSArray class]]) {
      NSMutableArray<NSNumber *> *modes = [NSMutableArray array];
      for (id modeName in creationModes) {
        if (![modeName isKindOfClass:[NSString class]]) continue;
        if ([modeName isEqualToString:@"draw"]) {
          [modes addObject:@(0)];
        } else if ([modeName isEqualToString:@"image"]) {
          [modes addObject:@(1)];
        } else if ([modeName isEqualToString:@"type"]) {
          [modes addObject:@(2)];
        }
      }
      if (modes.count > 0) {
        [signatureBuilder setValue:modes forKey:@"availableModes"];
      }
    }

    // colorOptions — {"option1": {"color": "#RRGGBB", ...}, "option2": {...}, "option3": {...}}
    NSDictionary *colorOptions = dict[@"colorOptions"];
    if ([colorOptions isKindOfClass:[NSDictionary class]]) {
      NSMutableArray<UIColor *> *colors = [NSMutableArray array];
      for (NSString *optionKey in @[@"option1", @"option2", @"option3"]) {
        NSDictionary *option = colorOptions[optionKey];
        if (![option isKindOfClass:[NSDictionary class]]) continue;
        UIColor *color = nutrient_color_from_hex(option[@"color"]);
        if (color != nil) [colors addObject:color];
      }
      // PSPDFSignatureCreationConfigurationBuilder.colors must not be empty
      // and must not contain duplicates — only apply when we parsed at least
      // one valid color, otherwise leave the SDK default in place.
      if (colors.count > 0) {
        [signatureBuilder setValue:colors forKey:@"colors"];
      }
    }

    // iosSignatureAspectRatio — a double (width:height ratio of the signing area).
    NSNumber *aspectRatio = dict[@"iosSignatureAspectRatio"];
    if ([aspectRatio isKindOfClass:[NSNumber class]]) {
      [signatureBuilder setValue:aspectRatio forKey:@"signingAreaAspectRatio"];
    }

    // fonts — array of font names (UIFont fontWithName:size:); invalid names
    // are skipped rather than failing the whole array, matching the legacy
    // Swift helper. The array is only applied when at least one name
    // resolved to a real UIFont — PSPDFSignatureCreationConfigurationBuilder.fonts
    // must not be empty.
    NSArray *fontNames = dict[@"fonts"];
    if ([fontNames isKindOfClass:[NSArray class]]) {
      NSMutableArray<UIFont *> *fonts = [NSMutableArray array];
      for (id fontName in fontNames) {
        if (![fontName isKindOfClass:[NSString class]]) continue;
        // Size is irrelevant — PSPDFSignatureCreationConfigurationBuilder.fonts
        // ignores the point size of the provided UIFont instances.
        UIFont *font = [UIFont fontWithName:fontName size:32.0];
        if (font != nil) [fonts addObject:font];
      }
      if (fonts.count > 0) {
        [signatureBuilder setValue:fonts forKey:@"fonts"];
      }
    }
  };

  id (*msgSend)(id, SEL, void (^)(id)) = (id (*)(id, SEL, void (^)(id)))objc_msgSend;
  id signatureConfig = msgSend(defaultConfig, updateSel, configBlock);
  if (signatureConfig != nil) {
    [builder setValue:signatureConfig forKey:@"signatureCreationConfiguration"];
  }
}

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

  // AI Assistant — delegate to the shared helper.
  NSDictionary *aiAssistant = dict[@"aiAssistantConfiguration"];
  if ([aiAssistant isKindOfClass:[NSDictionary class]]) {
    nutrient_apply_ai_config_dict(aiAssistant, builder);
  }

  // signatureSavingStrategy — AlwaysSave=0, NeverSave=1, SaveIfSelected=2
  // (raw ordinals of PSPDFSignatureSavingStrategy; see the table in
  // IOSConfigurationBuilder's class doc-comment).
  NSNumber *signatureSavingStrategy = dict[@"signatureSavingStrategy"];
  if ([signatureSavingStrategy isKindOfClass:[NSNumber class]]) {
    PSPDFSignatureSavingStrategy strategy =
        (PSPDFSignatureSavingStrategy)signatureSavingStrategy.unsignedIntegerValue;
    builder.signatureSavingStrategy = strategy;
    // A signatureStore is required for alwaysSave / saveIfSelected to
    // actually persist anything (see the property doc-comment on
    // PSPDFConfigurationBuilder.signatureStore). Install the on-device
    // keychain store only when the strategy calls for saving — NOT
    // unconditionally whenever the key is present, which is what the legacy
    // PspdfPlatformView.m path did (installed PSPDFKeychainSignatureStore any
    // time signatureSavingStrategy was set at all, even for neverSave).
    if (strategy != PSPDFSignatureSavingStrategyNeverSave) {
      builder.signatureStore = [[PSPDFKeychainSignatureStore alloc] init];
    }
  }

  // signatureCreationConfiguration — delegate to the shared helper (builds
  // UIColor/UIFont instances the generated Dart FFI bindings can't).
  NSDictionary *signatureCreationConfiguration = dict[@"signatureCreationConfiguration"];
  if ([signatureCreationConfiguration isKindOfClass:[NSDictionary class]]) {
    nutrient_apply_signature_creation_config_dict(signatureCreationConfiguration, builder);
  }
}

// ---------------------------------------------------------------------------
// Private helper — shared client/descriptor/download/VC setup.
// ---------------------------------------------------------------------------
static void* nutrient_create_instant_vc_internal(
    const char* serverUrl,
    const char* jwt,
    PSPDFConfiguration* configuration,
    BOOL enableInstantComments
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
    // If the document is already downloaded from a previous session, we need to
    // reauthenticate with the new JWT so the sync connection can talk to the server.
    // Without this, subsequent opens will have a local document but no working sync.
    if (downloadError != nil &&
        [downloadError.domain isEqualToString:PSPDFInstantErrorDomain] &&
        downloadError.code == PSPDFInstantErrorAlreadyDownloaded) {
      fprintf(stderr, "[NutrientFFI] Document already downloaded — reauthenticating with new JWT\n");
      [descriptor reauthenticateWithJWT:jwtStr];
      fprintf(stderr, "[NutrientFFI] reauthenticateWithJWT called (async — check notifications for result)\n");
    } else {
      fprintf(stderr, "[NutrientFFI] downloadUsingJWT failed: %s\n",
              downloadError.localizedDescription.UTF8String ?: "unknown");
    }
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

  if (enableInstantComments) {
    // Apply after init so it survives the Instant subclass swap performed
    // inside `PSPDFInstantViewController.commonInit`. The default
    // `PSPDFConfigurationBuilder` doesn't whitelist `instantCommentMarker`,
    // so calling `insertObject:` on the pre-init builder is silently dropped
    // and the comment menu items stay hidden. The Instant subclass installed
    // by `instant_adjustClass` does include it, so the same insert sticks
    // after init.
    [vc updateConfigurationWithoutReloadingWithBuilder:^(PSPDFConfigurationBuilder *builder) {
      NSMutableSet *editable = [builder.editableAnnotationTypes mutableCopy] ?: [NSMutableSet set];
      [editable addObject:PSPDFAnnotationStringInstantCommentMarker];
      builder.editableAnnotationTypes = editable;
    }];
  }

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

  // Surface the AI Assistant button on the nav bar when the builder has an
  // aiAssistantConfiguration. `aiAssistantButtonItem` is read-only on
  // PSPDFViewController and the SDK doesn't add it to leftBarButtonItems
  // automatically — matches what the legacy Pigeon path does when
  // iOSLeftBarButtonItems contains 'aiAssistantButtonItem'.
  // Same Swift-only-property issue: read via KVC. Nil means the user didn't
  // pass aiAssistantConfiguration in their NutrientViewConfiguration.
  id aiCfg = nil;
  @try {
    aiCfg = [configuration valueForKey:@"aiAssistantConfiguration"];
  } @catch (NSException *e) {
    // KVC raised because the key doesn't exist on this build; ignore.
  }
  if (aiCfg != nil) {
    UIBarButtonItem *aiBtn = vc.aiAssistantButtonItem;
    NSMutableArray<UIBarButtonItem *> *items =
        [vc.navigationItem.leftBarButtonItems mutableCopy] ?: [NSMutableArray array];
    if (![items containsObject:aiBtn]) {
      [items addObject:aiBtn];
    }
    vc.navigationItem.leftBarButtonItems = items;
    fprintf(stderr, "[NutrientFFI] AI Assistant button added to leftBarButtonItems\n");
  }

  return (__bridge_retained void *)vc;
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

__attribute__((used))
void* nutrient_create_instant_view_controller(const char* serverUrl, const char* jwt) {
  fprintf(stderr, "[NutrientFFI] nutrient_create_instant_view_controller called: %s\n", serverUrl);
  PSPDFConfiguration *configuration = [PSPDFInstantViewController defaultConfiguration];
  return nutrient_create_instant_vc_internal(serverUrl, jwt, configuration, NO);
}

__attribute__((used))
void* nutrient_create_instant_view_controller_with_config(
    const char* serverUrl,
    const char* jwt,
    const char* configJson
) {
  fprintf(stderr, "[NutrientFFI] nutrient_create_instant_view_controller_with_config called: %s\n", serverUrl);

  PSPDFConfiguration *configuration;
  BOOL enableInstantComments = NO;
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
    NSNumber *enableInstantCommentsNum = [dict isKindOfClass:[NSDictionary class]]
        ? dict[@"enableInstantComments"]
        : nil;
    enableInstantComments = [enableInstantCommentsNum isKindOfClass:[NSNumber class]]
        ? enableInstantCommentsNum.boolValue
        : NO;
    configuration = [[PSPDFInstantViewController defaultConfiguration]
        configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder *builder) {
          nutrient_apply_config_dict(dict, builder);
        }];
  } else {
    configuration = [PSPDFInstantViewController defaultConfiguration];
  }

  return nutrient_create_instant_vc_internal(serverUrl, jwt, configuration, enableInstantComments);
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

__attribute__((used))
void nutrient_instant_set_delay_for_syncing_local_changes(void* viewController, double delay) {
  if (viewController == NULL) return;
  PSPDFInstantViewController *vc =
      (__bridge PSPDFInstantViewController *)viewController;
  // delayForSyncingLocalChanges lives on PSPDFInstantDocumentDescriptor, not on
  // PSPDFInstantViewController itself — retrieve the descriptor we retained
  // alongside the VC in nutrient_create_instant_vc_internal (kInstantDescriptorKey).
  id<PSPDFInstantDocumentDescriptor> descriptor =
      objc_getAssociatedObject(vc, &kInstantDescriptorKey);
  if (descriptor == nil) {
    fprintf(stderr, "[NutrientFFI] nutrient_instant_set_delay_for_syncing_local_changes: "
                     "no PSPDFInstantDocumentDescriptor associated with this view controller\n");
    return;
  }
  descriptor.delayForSyncingLocalChanges = delay;
}

// ---------------------------------------------------------------------------
// Page-tap helper — installs a UITapGestureRecognizer on a PSPDFPageView
// that calls a C function pointer when a tap lands on empty page area.
// ---------------------------------------------------------------------------

@interface _NutrientPageTapTarget : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, assign) nutrient_page_tap_callback callback;
@property (nonatomic, assign) int64_t pageIndex;
@property (nonatomic, weak)   UIView *pageView;
- (void)handleTap:(UITapGestureRecognizer *)recognizer;
@end

@implementation _NutrientPageTapTarget
- (void)handleTap:(UITapGestureRecognizer *)recognizer {
  if (recognizer.state != UIGestureRecognizerStateEnded) return;
  if (self.callback == NULL) return;
  UIView *view = recognizer.view ?: self.pageView;
  if (view == nil) return;
  CGPoint p = [recognizer locationInView:view];
  self.callback((__bridge void *)view, p.x, p.y, self.pageIndex);
}

// Allow our empty-page tap recognizer to fire ALONGSIDE PSPDFKit's own
// recognizers. Without this, UIKit treats our recognizer and PSPDFKit's
// single-tap select-annotation recognizer as mutually exclusive — and since
// ours is added last, it wins and *suppresses* annotation selection, so a
// single tap on an annotation no longer selects it (the user has to
// long-press instead). Returning YES lets PSPDFKit's select-annotation tap
// recognize at the same time, restoring single-tap-to-select while we still
// observe the tap for empty-page PageClickedEvent reporting.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:
        (UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}
@end

// Associated-object key for the tap target, so we don't install twice and
// so the target stays alive for the page view's lifetime.
static const char kPageTapTargetKey = 0;

__attribute__((used))
void nutrient_install_page_tap(void* pageViewPtr, int64_t pageIndex, nutrient_page_tap_callback callback) {
  if (pageViewPtr == NULL || callback == NULL) return;
  UIView *pageView = (__bridge UIView *)pageViewPtr;

  // Idempotent: if we already installed a target on this page view, just
  // refresh its callback / pageIndex.
  _NutrientPageTapTarget *existing =
      objc_getAssociatedObject(pageView, &kPageTapTargetKey);
  if (existing != nil) {
    existing.callback = callback;
    existing.pageIndex = pageIndex;
    existing.pageView = pageView;
    return;
  }

  _NutrientPageTapTarget *target = [[_NutrientPageTapTarget alloc] init];
  target.callback = callback;
  target.pageIndex = pageIndex;
  target.pageView = pageView;

  UITapGestureRecognizer *recognizer =
      [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(handleTap:)];
  // Our target is the recognizer's delegate so it can opt into simultaneous
  // recognition with PSPDFKit's gestures (see
  // gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:).
  // Without this, our recognizer suppresses PSPDFKit's single-tap
  // select-annotation recognizer and selection only works via long-press.
  recognizer.delegate = target;
  // We must NOT swallow taps that PSPDFKit's existing recognizers want —
  // annotation tap, text long-press, HUD-toggle, etc. — so let them all
  // through. Our recognizer fires alongside; consumers can disambiguate
  // empty-page vs annotation taps via the cross-platform event payload
  // (PageClickedEvent has annotationJson==null for empty-page taps; we
  // also fire PageClickedEvent with annotationJson set from
  // didSelectAnnotations for annotation taps).
  //
  // We deliberately do NOT call `requireGestureRecognizerToFail:` against
  // PSPDFKit's recognizers: PSPDFKit's HUD-toggle recognizer SUCCEEDS on
  // every empty-page tap, so requiring it to fail would mean our handler
  // never runs for the very case we care about.
  recognizer.cancelsTouchesInView = NO;
  recognizer.delaysTouchesBegan = NO;
  recognizer.delaysTouchesEnded = NO;

  [pageView addGestureRecognizer:recognizer];
  objc_setAssociatedObject(pageView, &kPageTapTargetKey, target,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// ---------------------------------------------------------------------------
// AI Assistant helpers — standalone-document (plain PSPDFViewController) path.
//
// The Instant path applies AI config inside nutrient_create_instant_vc_internal
// via nutrient_apply_config_dict. The plain-view path builds its
// PSPDFConfiguration inside a Dart ObjC block (NutrientViewIOS._createConfiguration),
// which cannot reach the private nutrient_apply_ai_config_dict static. These
// two exported functions let the Dart layer drive both steps — configuration
// and button injection — through the same FFI channel.
// ---------------------------------------------------------------------------

/// Parses a JSON UTF-8 string containing an AI-assistant config object
/// (keys: serverUrl, jwt, sessionId, userId) and applies it to the given
/// PSPDFConfigurationBuilder via KVC. Safe to call with a NULL pointer or
/// an empty / invalid JSON string — all failure paths are no-ops.
///
/// @param configurationBuilder  A __bridge PSPDFConfigurationBuilder* obtained
///                              from the ObjC block passed to
///                              PSPDFConfiguration.configurationWithBuilder:.
/// @param jsonUtf8              Null-terminated UTF-8 JSON string with the
///                              AI-assistant sub-dict (NOT the full config dict).
__attribute__((used))
void nutrient_apply_ai_assistant_configuration(void *configurationBuilder,
                                               const char *jsonUtf8) {
  if (configurationBuilder == NULL || jsonUtf8 == NULL) return;

  NSString *jsonStr = [NSString stringWithUTF8String:jsonUtf8];
  NSData   *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
  if (jsonData == nil) return;

  NSError      *error = nil;
  NSDictionary *dict  = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:0
                                                          error:&error];
  if (![dict isKindOfClass:[NSDictionary class]]) {
    fprintf(stderr, "[NutrientFFI] nutrient_apply_ai_assistant_configuration: "
            "JSON parse error: %s\n",
            error.localizedDescription.UTF8String ?: "unknown");
    return;
  }

  PSPDFConfigurationBuilder *builder = (__bridge PSPDFConfigurationBuilder *)configurationBuilder;
  nutrient_apply_ai_config_dict(dict, builder);
}

// ---------------------------------------------------------------------------
// Signature-creation helper — standalone-document (plain PSPDFViewController)
// path. Mirrors nutrient_apply_ai_assistant_configuration immediately above:
// the plain-view path builds its PSPDFConfiguration inside a Dart ObjC block
// (NutrientViewIOS._createConfiguration), which cannot reach the private
// nutrient_apply_signature_creation_config_dict static directly, so this
// exported wrapper parses the JSON and delegates to it.
// ---------------------------------------------------------------------------

/// Parses a JSON UTF-8 string containing a signature-creation config object
/// (keys: creationModes, colorOptions, iosSignatureAspectRatio, fonts — see
/// SignatureCreationConfiguration.toMap() in the platform-interface package)
/// and applies it to the given PSPDFConfigurationBuilder. Safe to call with a
/// NULL pointer or an empty/invalid JSON string — all failure paths are
/// no-ops.
///
/// @param configurationBuilder  A __bridge PSPDFConfigurationBuilder* obtained
///                              from the ObjC block passed to
///                              PSPDFConfiguration.configurationWithBuilder:.
/// @param jsonUtf8              Null-terminated UTF-8 JSON string of the
///                              signature-creation sub-dict (NOT the full
///                              config dict).
__attribute__((used))
void nutrient_apply_signature_creation_configuration(void *configurationBuilder,
                                                      const char *jsonUtf8) {
  if (configurationBuilder == NULL || jsonUtf8 == NULL) return;

  NSString *jsonStr = [NSString stringWithUTF8String:jsonUtf8];
  NSData   *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
  if (jsonData == nil) return;

  NSError      *error = nil;
  NSDictionary *dict  = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:0
                                                          error:&error];
  if (![dict isKindOfClass:[NSDictionary class]]) {
    fprintf(stderr, "[NutrientFFI] nutrient_apply_signature_creation_configuration: "
            "JSON parse error: %s\n",
            error.localizedDescription.UTF8String ?: "unknown");
    return;
  }

  PSPDFConfigurationBuilder *builder = (__bridge PSPDFConfigurationBuilder *)configurationBuilder;
  nutrient_apply_signature_creation_config_dict(dict, builder);
}

/// Appends `aiAssistantButtonItem` to the left bar button items of the given
/// PSPDFViewController's navigation item. Mirrors the equivalent snippet in
/// nutrient_create_instant_vc_internal for the standalone-document path.
///
/// Must be called on the main thread after the VC has been created. Safe to
/// call when aiAssistantConfiguration was not set — in that case KVC returns
/// nil and this function is a no-op.
///
/// @param viewController  A __bridge PSPDFViewController* (NOT retained by
///                        this function — the caller owns the lifecycle).
__attribute__((used))
void nutrient_add_ai_assistant_button(void *viewController) {
  if (viewController == NULL) return;

  PSPDFViewController *vc = (__bridge PSPDFViewController *)viewController;

  // Guard: only add the button when an aiAssistantConfiguration was actually
  // applied — same check as the Instant path (lines ~269-274 above).
  id aiCfg = nil;
  @try {
    aiCfg = [vc.configuration valueForKey:@"aiAssistantConfiguration"];
  } @catch (NSException *e) {
    // KVC raised because the key doesn't exist on this SDK build; ignore.
  }
  if (aiCfg == nil) return;

  UIBarButtonItem *aiBtn = vc.aiAssistantButtonItem;
  NSMutableArray<UIBarButtonItem *> *items =
      [vc.navigationItem.leftBarButtonItems mutableCopy] ?: [NSMutableArray array];
  if (![items containsObject:aiBtn]) {
    [items addObject:aiBtn];
  }
  vc.navigationItem.leftBarButtonItems = items;
  fprintf(stderr, "[NutrientFFI] AI Assistant button added to leftBarButtonItems (standalone path)\n");
}

// ---------------------------------------------------------------------------
// Custom main-toolbar items — adds Dart-backed buttons to the VC's nav bar.
//
// UIBarButtonItem can't be created from the generated objective_c bindings
// (the binding is a wrap-only stub with no initWith… initializer), so the
// button must be built here and its tap routed back to Dart via a C callback.
// ---------------------------------------------------------------------------

@interface _NutrientToolbarItemTarget : NSObject
@property (nonatomic, assign) int64_t index;
@property (nonatomic, assign) nutrient_toolbar_tap_callback callback;
- (void)handleTap;
@end

@implementation _NutrientToolbarItemTarget
- (void)handleTap {
  if (self.callback == NULL) return;
  self.callback(self.index);
}
@end

// Associated-object keys: the array of buttons WE added (on the VC, so we can
// remove them on the next call) and each button's retained target (UIBarButtonItem
// holds its target weakly, so the button must keep the target alive itself).
static const char kToolbarAddedItemsKey = 0;
static const char kToolbarTargetKey = 0;

__attribute__((used))
void nutrient_set_main_toolbar_items(void *viewControllerPtr,
                                     const char *itemsJson,
                                     nutrient_toolbar_tap_callback callback) {
  if (viewControllerPtr == NULL) return;
  UIViewController *vc = (__bridge UIViewController *)viewControllerPtr;

  // Start from the current right items, minus the buttons we added last time.
  NSMutableArray<UIBarButtonItem *> *rightItems =
      [vc.navigationItem.rightBarButtonItems mutableCopy] ?: [NSMutableArray array];
  NSArray<UIBarButtonItem *> *previous =
      objc_getAssociatedObject(vc, &kToolbarAddedItemsKey);
  if (previous != nil) {
    [rightItems removeObjectsInArray:previous];
  }

  NSMutableArray<UIBarButtonItem *> *added = [NSMutableArray array];

  if (itemsJson != NULL) {
    NSString *jsonStr = [NSString stringWithUTF8String:itemsJson];
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    id parsed = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] : nil;
    if ([parsed isKindOfClass:[NSArray class]]) {
      NSArray *items = (NSArray *)parsed;
      for (NSUInteger i = 0; i < items.count; i++) {
        id entry = items[i];
        if (![entry isKindOfClass:[NSDictionary class]]) continue;
        NSString *title = [entry[@"title"] isKindOfClass:[NSString class]]
                              ? entry[@"title"]
                              : @"";
        BOOL disabled = [entry[@"disabled"] boolValue];

        _NutrientToolbarItemTarget *target = [[_NutrientToolbarItemTarget alloc] init];
        target.index = (int64_t)i;
        target.callback = callback;

        UIBarButtonItem *btn =
            [[UIBarButtonItem alloc] initWithTitle:title
                                             style:UIBarButtonItemStylePlain
                                            target:target
                                            action:@selector(handleTap)];
        btn.enabled = !disabled;
        // Keep the target alive for the button's lifetime (target is weak).
        objc_setAssociatedObject(btn, &kToolbarTargetKey, target,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [added addObject:btn];
      }
    }
  }

  [rightItems addObjectsFromArray:added];
  vc.navigationItem.rightBarButtonItems = rightItems;
  objc_setAssociatedObject(vc, &kToolbarAddedItemsKey, added,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// ---------------------------------------------------------------------------
// File-conflict resolution — forwards to the Swift
// NutrientConflictResolutionCompanion (ConflictResolutionCompanion.swift),
// forward-declared near the top of this file alongside
// ViewControllerContainerCompanion (same reasoning: this file must keep
// compiling under the native-assets hook, which builds without the generated
// Swift bridging header).
// ---------------------------------------------------------------------------

__attribute__((used))
void nutrient_register_file_conflict_resolution(void *viewControllerPtr,
                                                 int64_t resolutionRawValue) {
  if (viewControllerPtr == NULL || resolutionRawValue < 0) return;
  UIViewController *vc = (__bridge UIViewController *)viewControllerPtr;
  [NutrientConflictResolutionCompanion registerWithResolutionRawValue:(NSUInteger)resolutionRawValue
                                                                    for:vc];
}

__attribute__((used))
void nutrient_unregister_file_conflict_resolution(void *viewControllerPtr) {
  if (viewControllerPtr == NULL) return;
  UIViewController *vc = (__bridge UIViewController *)viewControllerPtr;
  [NutrientConflictResolutionCompanion unregisterFor:vc];
}

// ---------------------------------------------------------------------------
// Signature interceptor — drives NutrientController.setSignatureInterceptor.
//
// iOS has two places to step into the signature flow, and Dart can implement
// neither directly. The placement hook takes a completion handler, but the
// signing UI can only be adjusted before it opens through
// pdfViewController:shouldShowController:options:animated:, which returns BOOL,
// and a non-void delegate method called off the Dart isolate aborts. So this
// wraps the view controller's delegate: it answers those methods, holds the
// signing UI or the signature while Dart decides, and forwards every other
// delegate call to the wrapped delegate unchanged.
//
// Only public API is used. The signing UI is the saved-signature selector or
// the creation sheet; whichever opens first is held, and the creation sheet a
// held selector's "+" opens is covered by the same answer. Signing starts in
// one of two ways, and each tells differently when it is over:
//   - From the toolbar, in the signature annotation state; leaving that state
//     (another tool, a second tap) ends or cancels it.
//   - From a tapped signature field, which is selected first and does not
//     enter that state; deselecting the field ends it.
// The form field is that selected field, remembered from the selection
// callbacks; the page is the field's, or the visible one, which is the page
// the SDK signs on. The new SDK types are resolved by name, like the
// configuration helpers above, so this compiles against an SDK without them
// and simply never sees the placement call there.
// ---------------------------------------------------------------------------

static NSString *const kNutrientSignaturePlacementSelector = @"pdfViewController:placeSignature:completionHandler:";

@interface _NutrientHeldSignatureRequest : NSObject
@property (nonatomic, weak) PSPDFViewController *pdfController;
@property (nonatomic) UIViewController *controller;
@property (nonatomic, nullable, copy) NSDictionary *options;
@property (nonatomic) BOOL animated;
// How this signing started, which decides when it is over; see above.
@property (nonatomic) BOOL fromSignatureState;
@property (nonatomic, weak, nullable) PSPDFSignatureFormElement *field;
@end
@implementation _NutrientHeldSignatureRequest
@end

@interface _NutrientHeldSignaturePlacement : NSObject
@property (nonatomic, weak) PSPDFViewController *pdfController;
@property (nonatomic) id proposal;
@property (nonatomic, copy) void (^completion)(id _Nullable placement);
@end
@implementation _NutrientHeldSignaturePlacement
@end

// Held requests and signatures, keyed by the ids handed to Dart. Main thread only.
static NSMutableDictionary<NSNumber *, id> *NutrientHeldSignatures(void) {
  static NSMutableDictionary *held;
  static dispatch_once_t once;
  dispatch_once(&once, ^{ held = [NSMutableDictionary dictionary]; });
  return held;
}

static int64_t NutrientNextSignatureId(void) {
  static int64_t next = 0;
  return ++next;
}

// A form element's fully qualified field name as a C string the callback
// owns, or NULL. (On iOS the form element's key is `fullyQualifiedFieldName`;
// `fullyQualifiedName` belongs to the form field.)
static char *NutrientCopyFormFieldName(id formElement) {
  if (![formElement respondsToSelector:NSSelectorFromString(@"fullyQualifiedFieldName")]) return NULL;
  NSString *name = [formElement valueForKey:@"fullyQualifiedFieldName"];
  return [name isKindOfClass:NSString.class] ? strdup(name.UTF8String) : NULL;
}

// `object.key` as a double, or [fallback] when [object] has no such key.
static double NutrientDoubleForKey(id object, NSString *key, double fallback) {
  if (![object respondsToSelector:NSSelectorFromString(key)]) return fallback;
  id value = [object valueForKey:key];
  return [value respondsToSelector:@selector(doubleValue)] ? [value doubleValue] : fallback;
}

static BOOL NutrientIsInSignatureState(PSPDFViewController *pdfController) {
  return [pdfController.annotationStateManager.state isEqualToString:PSPDFAnnotationStringSignature];
}

static BOOL NutrientIsCreationSheet(UIViewController *controller) {
  Class creation = NSClassFromString(@PSPDF_PREFIX "SignatureCreationViewController");
  return creation != Nil && [controller isKindOfClass:creation];
}

// Whether [controller] is UI that starts a signature: the creation sheet, or
// the selector the SDK shows instead when signatures are saved.
static BOOL NutrientIsSigningUI(UIViewController *controller) {
  return NutrientIsCreationSheet(controller) ||
         [controller isKindOfClass:PSPDFSignatureSelectorViewController.class];
}

// Sets [lineWidth] and [alpha] as a creation sheet's default stroke width and
// opacity. Assigning a configuration applies its defaults to the sheet too.
static void NutrientApplySignatureStyle(UIViewController *controller, double lineWidth, double alpha) {
  if (!NutrientIsCreationSheet(controller)) return;
  SEL updateSel = NSSelectorFromString(@"configurationUpdatedWithBuilder:");
  id configuration = [controller valueForKey:@"configuration"];
  if (![configuration respondsToSelector:updateSel]) return;
  void (^styleBlock)(id) = ^(id builder) {
    [builder setValue:@(lineWidth) forKey:@"defaultLineWidth"];
    [builder setValue:@(alpha) forKey:@"defaultAlpha"];
  };
  id updated = ((id (*)(id, SEL, id))objc_msgSend)(configuration, updateSel, styleBlock);
  if (updated != nil) [controller setValue:updated forKey:@"configuration"];
}

// Drops every request still held for [pdfController] without presenting it.
static void NutrientDropHeldSignatureRequests(PSPDFViewController *pdfController) {
  NSMutableDictionary *held = NutrientHeldSignatures();
  for (NSNumber *requestId in held.allKeys) {
    id entry = held[requestId];
    if ([entry isKindOfClass:_NutrientHeldSignatureRequest.class] &&
        ((_NutrientHeldSignatureRequest *)entry).pdfController == pdfController) {
      [held removeObjectForKey:requestId];
    }
  }
}

// Ends a held request's signing as if the user had cancelled it. From the
// toolbar that means leaving the signature state. A tapped field never entered
// it, and its signing UI was never shown: dropping the request releases that
// UI, and with it the signing.
static void NutrientCancelSigning(_NutrientHeldSignatureRequest *request) {
  PSPDFViewController *pdfController = request.pdfController;
  if (request.fromSignatureState && NutrientIsInSignatureState(pdfController)) {
    pdfController.annotationStateManager.state = nil;
  }
}

// Marks a signing UI that Dart let through, so presenting it again passes.
static const char kNutrientSignatureApprovedKey = 0;

@interface _NutrientSignatureDelegateWrapper : NSObject <PSPDFViewControllerDelegate>
// Weak, like the view controller's own delegate reference: the wrapper must
// not extend the wrapped delegate's lifetime.
@property (nonatomic, weak, nullable) id<PSPDFViewControllerDelegate> wrapped;
@property (nonatomic, assign) nutrient_signature_request_callback onRequest;
@property (nonatomic, assign) nutrient_signature_placement_callback onPlacement;
// The signature field currently selected, if any: tapping one selects it
// before its signing UI opens.
@property (nonatomic, weak, nullable) PSPDFSignatureFormElement *selectedSignatureField;
// A selector Dart let through, and the style it answered with, for the
// creation sheet its "+" opens. The SDK presents that sheet from the
// selector's dismissal completion, which still holds the selector, so this
// weak reference is set exactly while that sheet can arrive.
@property (nonatomic, weak, nullable) UIViewController *approvedSelector;
@property (nonatomic) BOOL approvedAppliesStyle;
@property (nonatomic) double approvedLineWidth;
@property (nonatomic) double approvedAlpha;
@end

@implementation _NutrientSignatureDelegateWrapper

- (BOOL)respondsToSelector:(SEL)selector {
  if (selector == @selector(pdfViewController:shouldShowController:options:animated:) ||
      selector == @selector(pdfViewController:didSelectAnnotations:onPageView:) ||
      selector == @selector(pdfViewController:didDeselectAnnotations:onPageView:)) {
    return YES;
  }
  if (selector == NSSelectorFromString(kNutrientSignaturePlacementSelector)) return self.onPlacement != NULL || [self.wrapped respondsToSelector:selector];
  return [super respondsToSelector:selector] || [self.wrapped respondsToSelector:selector];
}

- (id)forwardingTargetForSelector:(SEL)selector {
  return [self.wrapped respondsToSelector:selector] ? self.wrapped : [super forwardingTargetForSelector:selector];
}

- (void)pdfViewController:(PSPDFViewController *)pdfController didSelectAnnotations:(NSArray<PSPDFAnnotation *> *)annotations onPageView:(PSPDFPageView *)pageView {
  for (PSPDFAnnotation *annotation in annotations) {
    if ([annotation isKindOfClass:PSPDFSignatureFormElement.class]) {
      self.selectedSignatureField = (PSPDFSignatureFormElement *)annotation;
      break;
    }
  }
  if ([self.wrapped respondsToSelector:_cmd]) {
    [self.wrapped pdfViewController:pdfController didSelectAnnotations:annotations onPageView:pageView];
  }
}

- (void)pdfViewController:(PSPDFViewController *)pdfController didDeselectAnnotations:(NSArray<PSPDFAnnotation *> *)annotations onPageView:(PSPDFPageView *)pageView {
  PSPDFSignatureFormElement *field = self.selectedSignatureField;
  if (field != nil && [annotations containsObject:field]) self.selectedSignatureField = nil;
  if ([self.wrapped respondsToSelector:_cmd]) {
    [self.wrapped pdfViewController:pdfController didDeselectAnnotations:annotations onPageView:pageView];
  }
}

- (BOOL)pdfViewController:(PSPDFViewController *)pdfController shouldShowController:(UIViewController *)controller options:(nullable NSDictionary<NSString *, id> *)options animated:(BOOL)animated {
  if (NutrientIsSigningUI(controller) && self.onRequest != NULL) {
    if (objc_getAssociatedObject(controller, &kNutrientSignatureApprovedKey) != nil) {
      // The held UI Dart let through, being presented now.
      objc_setAssociatedObject(controller, &kNutrientSignatureApprovedKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else if (NutrientIsCreationSheet(controller) && self.approvedSelector != nil) {
      // The creation sheet a let-through selector's "+" opens: same answer.
      if (self.approvedAppliesStyle) NutrientApplySignatureStyle(controller, self.approvedLineWidth, self.approvedAlpha);
      self.approvedSelector = nil;
    } else {
      // A new request replaces any still held, as the interface promises.
      NutrientDropHeldSignatureRequests(pdfController);
      self.approvedSelector = nil;
      PSPDFSignatureFormElement *field = self.selectedSignatureField;
      _NutrientHeldSignatureRequest *request = [_NutrientHeldSignatureRequest new];
      request.pdfController = pdfController;
      request.controller = controller;
      request.options = options;
      request.animated = animated;
      request.fromSignatureState = NutrientIsInSignatureState(pdfController);
      // A field only counts when this signing started from it.
      request.field = request.fromSignatureState ? nil : field;
      int64_t requestId = NutrientNextSignatureId();
      NutrientHeldSignatures()[@(requestId)] = request;

      int64_t pageIndex = request.field != nil ? (int64_t)request.field.absolutePageIndex
                                               : (int64_t)pdfController.viewState.pageIndex;
      // The style the creation sheet would open with: the sheet's own, or,
      // for the selector, the configuration a sheet is created from.
      id configuration = NutrientIsCreationSheet(controller)
          ? [controller valueForKey:@"configuration"]
          : pdfController.configuration.signatureCreationConfiguration;
      self.onRequest(requestId, pageIndex, NutrientCopyFormFieldName(request.field),
                     NutrientDoubleForKey(configuration, @"defaultLineWidth", 3),
                     NutrientDoubleForKey(configuration, @"defaultAlpha", 1));
      return NO;
    }
  }
  if ([self.wrapped respondsToSelector:_cmd]) {
    return [self.wrapped pdfViewController:pdfController shouldShowController:controller options:options animated:animated];
  }
  return YES;
}

// Typed as `id` so this also compiles against an SDK that does not declare
// the method; where it does, the protocol's concrete types differ in name only.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmismatched-parameter-types"
- (void)pdfViewController:(PSPDFViewController *)pdfController placeSignature:(id)proposal completionHandler:(void (^)(id _Nullable placement))completionHandler {
  self.approvedSelector = nil;
  if (self.onPlacement == NULL) {
    ((void (*)(id, SEL, id, id, id))objc_msgSend)(self.wrapped, _cmd, pdfController, proposal, completionHandler);
    return;
  }
  _NutrientHeldSignaturePlacement *held = [_NutrientHeldSignaturePlacement new];
  held.pdfController = pdfController;
  held.proposal = proposal;
  held.completion = completionHandler;
  int64_t requestId = NutrientNextSignatureId();
  NutrientHeldSignatures()[@(requestId)] = held;

  id placement = [proposal valueForKey:@"placement"];
  NSUInteger pageIndex = [[placement valueForKey:@"pageIndex"] unsignedIntegerValue];
  CGRect box = [[placement valueForKey:@"boundingBox"] CGRectValue];
  CGSize pageSize = [pdfController.document pageInfoForPageAtIndex:pageIndex].size;
  self.onPlacement(requestId, (int64_t)pageIndex,
                   box.origin.x, box.origin.y, box.size.width, box.size.height,
                   pageSize.width, pageSize.height,
                   NutrientCopyFormFieldName([proposal valueForKey:@"formElement"]));
}
#pragma clang diagnostic pop

@end

static const char kNutrientSignatureWrapperKey = 0;

// Whether a held request's signing is still going on; see the section comment.
static BOOL NutrientIsStillSigning(_NutrientHeldSignatureRequest *request) {
  PSPDFViewController *pdfController = request.pdfController;
  if (pdfController == nil || pdfController.view.window == nil) return NO;
  if (request.fromSignatureState) return NutrientIsInSignatureState(pdfController);
  if (request.field == nil) return YES;
  _NutrientSignatureDelegateWrapper *wrapper = objc_getAssociatedObject(pdfController, &kNutrientSignatureWrapperKey);
  return wrapper.selectedSignatureField == request.field;
}

// Lets go of everything still held for [pdfController]: a held signing UI is
// cancelled, since its view is going away, and a held signature is added where
// the SDK proposed.
static void NutrientReleaseHeldSignatures(PSPDFViewController *pdfController) {
  NSMutableDictionary *held = NutrientHeldSignatures();
  for (NSNumber *requestId in held.allKeys) {
    id entry = held[requestId];
    if ([entry isKindOfClass:_NutrientHeldSignatureRequest.class] && ((_NutrientHeldSignatureRequest *)entry).pdfController == pdfController) {
      [held removeObjectForKey:requestId];
      NutrientCancelSigning(entry);
    } else if ([entry isKindOfClass:_NutrientHeldSignaturePlacement.class] && ((_NutrientHeldSignaturePlacement *)entry).pdfController == pdfController) {
      [held removeObjectForKey:requestId];
      _NutrientHeldSignaturePlacement *placement = entry;
      placement.completion([placement.proposal valueForKey:@"placement"]);
    }
  }
}

__attribute__((used))
void nutrient_set_signature_interceptor(void *viewControllerPtr,
                                        nutrient_signature_request_callback onRequest,
                                        nutrient_signature_placement_callback onPlacement) {
  if (viewControllerPtr == NULL) return;
  PSPDFViewController *pdfController = (__bridge PSPDFViewController *)viewControllerPtr;
  _NutrientSignatureDelegateWrapper *wrapper = objc_getAssociatedObject(pdfController, &kNutrientSignatureWrapperKey);
  // A delegate assigned since the last call replaced the wrapper; start over.
  if (wrapper != nil && pdfController.delegate != wrapper) wrapper = nil;

  if (onRequest == NULL && onPlacement == NULL) {
    NutrientReleaseHeldSignatures(pdfController);
    if (wrapper != nil) pdfController.delegate = wrapper.wrapped;
    objc_setAssociatedObject(pdfController, &kNutrientSignatureWrapperKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return;
  }
  if (wrapper == nil) {
    wrapper = [_NutrientSignatureDelegateWrapper new];
    wrapper.wrapped = pdfController.delegate;
    // The delegate property is weak; the view controller keeps the wrapper.
    objc_setAssociatedObject(pdfController, &kNutrientSignatureWrapperKey, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  wrapper.onRequest = onRequest;
  wrapper.onPlacement = onPlacement;
  // Reassigned even when unchanged, so the view controller re-reads which
  // delegate methods are implemented.
  pdfController.delegate = nil;
  pdfController.delegate = wrapper;
}

__attribute__((used))
void nutrient_resolve_signature_request(int64_t requestId, bool proceed, bool applyStyle,
                                        double lineWidth, double alpha) {
  dispatch_async(dispatch_get_main_queue(), ^{
    _NutrientHeldSignatureRequest *request = NutrientHeldSignatures()[@(requestId)];
    if (![request isKindOfClass:_NutrientHeldSignatureRequest.class]) return;
    [NutrientHeldSignatures() removeObjectForKey:@(requestId)];
    // Another tool, a second tap or a deselected field ended it meanwhile.
    if (!NutrientIsStillSigning(request)) return;
    if (!proceed) {
      NutrientCancelSigning(request);
      return;
    }
    PSPDFViewController *pdfController = request.pdfController;
    UIViewController *controller = request.controller;
    if (applyStyle) NutrientApplySignatureStyle(controller, lineWidth, alpha);
    if ([controller isKindOfClass:PSPDFSignatureSelectorViewController.class]) {
      _NutrientSignatureDelegateWrapper *wrapper = objc_getAssociatedObject(pdfController, &kNutrientSignatureWrapperKey);
      wrapper.approvedSelector = controller;
      wrapper.approvedAppliesStyle = applyStyle;
      wrapper.approvedLineWidth = lineWidth;
      wrapper.approvedAlpha = alpha;
    }
    objc_setAssociatedObject(controller, &kNutrientSignatureApprovedKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [pdfController presentViewController:controller options:request.options animated:request.animated sender:nil completion:NULL];
  });
}

__attribute__((used))
void nutrient_resolve_signature_placement(int64_t requestId, int32_t action, int64_t pageIndex,
                                          double x, double y, double width, double height) {
  dispatch_async(dispatch_get_main_queue(), ^{
    _NutrientHeldSignaturePlacement *held = NutrientHeldSignatures()[@(requestId)];
    if (![held isKindOfClass:_NutrientHeldSignaturePlacement.class]) return;
    [NutrientHeldSignatures() removeObjectForKey:@(requestId)];

    id placement = [held.proposal valueForKey:@"placement"];
    if (action == nutrient_signature_placement_drop) {
      placement = nil;
    } else if (action == nutrient_signature_placement_custom) {
      Class placementClass = NSClassFromString(@PSPDF_PREFIX "AnnotationPlacement");
      SEL init = NSSelectorFromString(@"initWithPageIndex:boundingBox:");
      if (placementClass != Nil && [placementClass instancesRespondToSelector:init]) {
        placement = ((id (*)(id, SEL, NSUInteger, CGRect))objc_msgSend)(
            [placementClass alloc], init, (NSUInteger)pageIndex, CGRectMake(x, y, width, height));
      }
    }
    held.completion(placement);
  });
}
