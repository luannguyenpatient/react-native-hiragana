#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Hiragana, NSObject)

RCT_EXTERN_METHOD(convert:(NSString*)str
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
