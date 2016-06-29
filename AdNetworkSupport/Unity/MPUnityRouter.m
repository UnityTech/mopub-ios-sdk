//
//  MPUnityRouter.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "MoPub.h"
#import "MPUnityRouter.h"
#import "UnityAdsInstanceMediationSettings.h"
#import "MPInstanceProvider+Unity.h"
#import "MPRewardedVideoError.h"
#import "MPRewardedVideo.h"

@interface MPUnityRouter ()

@property (nonatomic, assign) BOOL isAdPlaying;

@end

@implementation MPUnityRouter

+ (MPUnityRouter *)sharedRouter
{
    return [[MPInstanceProvider sharedProvider] sharedMPUnityRouter];
}

- (void)requestVideoAdWithGameId:(NSString *)gameId placementId:(NSString *)placementId delegate:(id<MPUnityRouterDelegate>)delegate;
{
    if (!self.isAdPlaying) {
        self.delegate = delegate;

        static dispatch_once_t unityInitToken;
        dispatch_once(&unityInitToken, ^{
            UADSMediationMetaData *mediationMetaData = [[UADSMediationMetaData alloc] init];
            [mediationMetaData setName:@"MoPub"];
            [mediationMetaData setVersion:[[MoPub sharedInstance] version]];
            [mediationMetaData commit];
            [UnityAds initialize:gameId delegate:self];
        });

        // Need to check immediately as an ad may be cached.
        if ([self isAdAvailableForPlacementId:placementId]) {
            [self.delegate unityAdsReady:placementId];
        }
        // MoPub timeout will handle the case for an ad failing to load.
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate unityAdsDidFailWithError:error];
    }
}

- (BOOL)isAdAvailableForPlacementId:(NSString *)placementId
{
    return [UnityAds isReady:placementId] && [UnityAds getPlacementState:placementId] == kUnityAdsPlacementStateReady;
}

- (void)presentVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId placementId:(NSString *)placementId settings:(UnityAdsInstanceMediationSettings *)settings delegate:(id<MPUnityRouterDelegate>)delegate
{
    if (!self.isAdPlaying && [self isAdAvailableForPlacementId:placementId]) {
        self.isAdPlaying = YES;

        self.delegate = delegate;

        // TODO: does the 2.0 SDK offer some way for us to provide the customerId or settings.userIdentifier to it? Perhaps a key in UADSMediationMetaData?
//        if (customerId.length >0) {
//            [[UnityAds sharedInstance] show:@{kUnityAdsOptionGamerSIDKey : customerId}];
//        } else if (settings.userIdentifier.length > 0) {
//            [[UnityAds sharedInstance] show:@{kUnityAdsOptionGamerSIDKey : settings.userIdentifier}];
//        } else {
//            [[UnityAds sharedInstance] show];
//        }
        [UnityAds show:viewController placementId:placementId];
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
        [delegate unityAdsDidFailWithError:error];
    }
}

- (void)clearDelegate:(id<MPUnityRouterDelegate>)delegate
{
    if (self.delegate == delegate)
    {
        [self setDelegate:nil];
    }
}

#pragma mark - UnityAdsDelegate

- (void)unityAdsReady:(NSString *)placementId
{
    [self.delegate unityAdsReady:placementId];
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    [self.delegate unityAdsDidError:error withMessage:message];
}

- (void)unityAdsDidStart:(NSString *)placementId {
    [self.delegate unityAdsDidStart:placementId];
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    [self.delegate unityAdsDidFinish:placementId withFinishState:state];
    self.isAdPlaying = NO;
}

//- (void)unityAdsVideoCompleted:(NSString *)rewardItemKey skipped:(BOOL)skipped
//{
//    [self.delegate unityAdsVideoCompleted:rewardItemKey skipped:skipped];
//}
//
//- (void)unityAdsWillShow
//{
//    [self.delegate unityAdsWillShow];
//}
//
//- (void)unityAdsDidShow
//{
//    [self.delegate unityAdsDidShow];
//}
//
//- (void)unityAdsWillHide
//{
//    [self.delegate unityAdsWillHide];
//}
//
//- (void)unityAdsDidHide
//{
//    [self.delegate unityAdsDidHide];
//    self.isAdPlaying = NO;
//}
//
//- (void)unityAdsWillLeaveApplication
//{
//    [self.delegate unityAdsWillLeaveApplication];
//}
//
//- (void)unityAdsFetchCompleted
//{
//    [self.delegate unityAdsFetchCompleted];
//}
//
//- (void)unityAdsFetchFailed
//{
//    NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:nil];
//
//    [self.delegate unityAdsDidFailWithError:error];
//}

@end
