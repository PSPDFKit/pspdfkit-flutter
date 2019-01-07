#import "SimplePermissionsPlugin.h"
#import <simple_permissions/simple_permissions-Swift.h>

@implementation SimplePermissionsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSimplePermissionsPlugin registerWithRegistrar:registrar];
}
@end
