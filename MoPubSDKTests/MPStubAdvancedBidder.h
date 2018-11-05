//
//  MPStubAdvancedBidder.h
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPAdvancedBidder.h"

@interface MPStubAdvancedBidder : NSObject <MPAdvancedBidder>
@property (nonatomic, copy, readonly) NSString * _Nonnull creativeNetworkName;
@property (nonatomic, copy, readonly) NSString * _Nonnull token;
@end
