//
//  MPBannerAdManagerDelegateHandler.m
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPBannerAdManagerDelegateHandler.h"

@implementation MPBannerAdManagerDelegateHandler

#pragma mark - MPBannerAdManagerDelegate

- (void)invalidateContentView {
    // Do nothing.
}

- (void)managerDidLoadAd:(UIView *)ad {
    if (self.didLoadAd != nil) { self.didLoadAd(); }
}

- (void)managerDidFailToLoadAd {
    if (self.didFailToLoadAd != nil) { self.didFailToLoadAd(); }
}

- (void)userActionWillBegin {
    if (self.willBeginUserAction != nil) { self.willBeginUserAction(); }
}

- (void)userActionDidFinish {
    if (self.didEndUserAction != nil) { self.didEndUserAction(); }
}

- (void)userWillLeaveApplication {
    if (self.willLeaveApplication != nil) { self.willLeaveApplication(); }
}

@end
