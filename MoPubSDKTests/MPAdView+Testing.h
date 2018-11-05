//
//  MPAdView+Testing.h
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdView.h"
#import "MPBannerAdManager.h"

@interface MPAdView (Testing)
@property (nonatomic, strong) MPBannerAdManager *adManager;
@end
