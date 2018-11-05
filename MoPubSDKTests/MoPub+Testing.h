//
//  MoPub+Testing.h
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MoPub.h"

NS_ASSUME_NONNULL_BEGIN

@interface MoPub (Testing)

// This method is called by `initializeSdkWithConfiguration:completion:` in a dispatch_once block,
// and is exposed here for unit testing.
- (void)setSdkWithConfiguration:(MPMoPubConfiguration *)configuration
                     completion:(void(^_Nullable)(void))completionBlock;

@end

NS_ASSUME_NONNULL_END
