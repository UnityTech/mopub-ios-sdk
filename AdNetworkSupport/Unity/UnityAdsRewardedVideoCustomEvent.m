//
//  UnityAdsRewardedVideoCustomEvent.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "UnityAdsRewardedVideoCustomEvent.h"
#import "MPUnityRouter.h"
#import "MPRewardedVideoReward.h"
#import "MPRewardedVideoError.h"
#import "MPLogging.h"
#import "UnityAdsInstanceMediationSettings.h"

static NSString *const kMPUnityRewardedVideoGameId = @"gameId";
static NSString *const kUnityAdsOptionPlacementIdKey = @"placementId";
static NSString *const kUnityAdsOptionZoneIdKey = @"zoneId";

@interface UnityAdsRewardedVideoCustomEvent () <MPUnityRouterDelegate>

@property (nonatomic, copy) NSString *placementId;

@end

@implementation UnityAdsRewardedVideoCustomEvent

- (void)dealloc
{
    [[MPUnityRouter sharedRouter] clearDelegate:self];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    NSString *gameId = [info objectForKey:kMPUnityRewardedVideoGameId];
    self.placementId = [info objectForKey:kUnityAdsOptionPlacementIdKey];
    if (self.placementId == nil) {
        self.placementId = [info objectForKey:kUnityAdsOptionZoneIdKey];
    }
    if (self.placementId == nil) {
        // TODO: what error code is appropriate for the case where a placementId wasn't provided in the custom event data?
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:[NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil]];
    } else {
        [[MPUnityRouter sharedRouter] requestVideoAdWithGameId:gameId placementId:self.placementId delegate:self];
    }
}

- (BOOL)hasAdAvailable
{
    return [[MPUnityRouter sharedRouter] isAdAvailableForPlacementId:self.placementId];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        UnityAdsInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[UnityAdsInstanceMediationSettings class]];

        NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];
        [[MPUnityRouter sharedRouter] presentVideoAdFromViewController:viewController customerId:customerId placementId:self.placementId settings:settings delegate:self];
    } else {
        MPLogInfo(@"Failed to show Unity rewarded video: Unity now claims that there is no available video ad.");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (void)handleCustomEventInvalidated
{
    [[MPUnityRouter sharedRouter] clearDelegate:self];
}

- (void)handleAdPlayedForCustomEventNetwork
{
    // If we no longer have an ad available, report back up to the application that this ad expired.
    // We receive this message only when this ad has reported an ad has loaded and another ad unit
    // has played a video for the same ad network.
    if (![self hasAdAvailable]) {
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }}

#pragma mark - MPUnityRouterDelegate

- (void)unityAdsReady:(NSString *)placementId
{
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message
{
    // TODO: should map the UnityAdsError to MoPubRewardedVideoAdsSDKDomain, or use a new domain
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:[NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil]];
}

- (void) unityAdsDidStart:(NSString *)placementId
{
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void) unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state
{
    if (state == kUnityAdsFinishStateCompleted) {
        MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:kMPRewardedVideoRewardCurrencyTypeUnspecified amount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)];
        [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];
    }
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)unityAdsDidFailWithError:(NSError *)error
{
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

@end
