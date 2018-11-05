//
//  MPMockChartboostRewardedVideoCustomEvent.m
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockChartboostRewardedVideoCustomEvent.h"
#import "MPRewardedVideoCustomEvent+Caching.h"

static BOOL gInitialized = NO;

@implementation MPMockChartboostRewardedVideoCustomEvent

+ (BOOL)isSdkInitialized {
    return gInitialized;
}

+ (void)reset {
    gInitialized = NO;
}

- (void)initializeSdkWithParameters:(NSDictionary *)parameters {
    gInitialized = YES;
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info {
    [self setCachedInitializationParameters:info];
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

@end
