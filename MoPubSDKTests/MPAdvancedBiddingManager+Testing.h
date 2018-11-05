//
//  MPAdvancedBiddingManager+Testing.h
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdvancedBiddingManager.h"

@interface MPAdvancedBiddingManager (Testing)
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<MPAdvancedBidder>> * bidders;
@end
