//
//  PSCDisallowCopyApplicationPolicy.m
//  PSPDFCatalog
//
//  Copyright © 2014-2016 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCDisallowCopyApplicationPolicy.h"

@implementation PSCDisallowCopyApplicationPolicy

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFApplicationPolicy

- (BOOL)hasPermissionForEvent:(NSString *)event isUserAction:(BOOL)isUserAction {
    if ([event isEqualToString:PSPDFPolicyEventPasteboard]) {
        return NO;
    }
    return YES;
}

@end
