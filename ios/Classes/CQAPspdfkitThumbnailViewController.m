#import "PspdfkitCustomButtonAnnotationToolbar.h"

@implementation CQAPspdfkitThumbnailViewController

#pragma mark - Lifecycle

- (instancetype)initWithAnnotationStateManager:(PSPDFAnnotationStateManager *)annotationStateManager {
    if ((self = [super initWithAnnotationStateManager:annotationStateManager])) {
        self.filterOptions = @[PSPDFThumbnailViewFilterAnnotations];
    }
    return self;
}

@end
