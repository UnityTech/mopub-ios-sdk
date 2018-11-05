//
//  MPMoPubRewardedPlayableCustomEvent+Testing.m
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMoPubRewardedPlayableCustomEvent+Testing.h"

@implementation MPMoPubRewardedPlayableCustomEvent (Testing)
@dynamic interstitial;
@dynamic timerView;

- (instancetype)initWithInterstitial:(MPMRAIDInterstitialViewController *)interstitial {
    if (self = [super init]) {
        self.interstitial = interstitial;
    }

    return self;
}

- (BOOL)isCountdownActive {
    return self.timerView.isActive;
}

@end
