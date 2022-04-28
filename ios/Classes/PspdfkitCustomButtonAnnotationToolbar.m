#import "PspdfkitCustomButtonAnnotationToolbar.h"

@implementation PspdfkitCustomButtonAnnotationToolbar

#pragma mark - Lifecycle

- (instancetype)initWithAnnotationStateManager:(PSPDFAnnotationStateManager *)annotationStateManager {
    if ((self = [super initWithAnnotationStateManager:annotationStateManager])) {
        self.tintColor =  UIColor.whiteColor;
        self.editableAnnotationTypes = [NSSet setWithArray:@[PSPDFAnnotationStringHighlight, PSPDFAnnotationStringInk, PSPDFAnnotationStringEraser/*, PSPDFAnnotationStringFreeText*/]];
        self.configurations = @[[[PSPDFAnnotationToolbarConfiguration alloc] initWithAnnotationGroups:@[
            /*[PSPDFAnnotationGroup groupWithItems:@[
                [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringFreeText variant:NULL configurationBlock: [PSPDFAnnotationGroupItem freeTextConfigurationBlock]]
            ]],*/
            [PSPDFAnnotationGroup groupWithItems:@[
                [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringHighlight]
            ]],
            [PSPDFAnnotationGroup groupWithItems:@[
                [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringInk variant:PSPDFAnnotationVariantStringInkHighlighter configurationBlock:[PSPDFAnnotationGroupItem inkConfigurationBlock]]
            ]],
            [PSPDFAnnotationGroup groupWithItems:@[
                [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringInk variant:PSPDFAnnotationVariantStringInkPen configurationBlock:[PSPDFAnnotationGroupItem inkConfigurationBlock]]
            ]],
            [PSPDFAnnotationGroup groupWithItems:@[
                [PSPDFAnnotationGroupItem itemWithType:PSPDFAnnotationStringEraser]    
            ]],
            
        ]]];
        self.supportedToolbarPositions = PSPDFFlexibleToolbarPositionVertical;
    }

    return self;
}

@end