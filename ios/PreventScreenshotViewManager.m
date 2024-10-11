#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(PreventScreenshotViewManager, RCTViewManager)


RCT_EXPORT_VIEW_PROPERTY(image, NSString)
RCT_EXPORT_VIEW_PROPERTY(resizeMode, NSString)


@end
