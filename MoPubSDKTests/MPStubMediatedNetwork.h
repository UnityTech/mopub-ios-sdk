//
//  MPStubMediatedNetwork.h
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPMediationSdkInitializable.h"

@interface MPStubMediatedNetwork : NSObject <MPMediationSdkInitializable>

- (void)initializeSdkWithParameters:(NSDictionary * _Nullable)parameters;

@end


@interface MPStubMediatedNetworkTwo : NSObject <MPMediationSdkInitializable>

- (void)initializeSdkWithParameters:(NSDictionary * _Nullable)parameters;

@end
