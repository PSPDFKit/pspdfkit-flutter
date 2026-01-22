#import "NutrientFFI.h"
#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

#if __has_include(<nutrient_flutter/nutrient_flutter-Swift.h>)
#import <nutrient_flutter/nutrient_flutter-Swift.h>
#else
#import "nutrient_flutter-Swift.h"
#endif

bool nutrient_attach_view_controller(int64_t viewId, void *viewController) {
  return [ViewControllerContainerCompanion attachViewControllerWithViewId:viewId
                                                            viewController:viewController];
}
