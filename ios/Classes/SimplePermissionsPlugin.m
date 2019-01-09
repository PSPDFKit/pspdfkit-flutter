#import "SimplePermissionsPlugin.h"
#import <pspdfkit_flutter/pspdfkit_flutter-Swift.h>

@implementation SimplePermissionsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSimplePermissionsPlugin registerWithRegistrar:registrar];
}
@end
