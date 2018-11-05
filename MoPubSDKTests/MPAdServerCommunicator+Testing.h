//
//  MPAdServerCommunicator+Testing.h
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdServerCommunicator.h"

@interface MPAdServerCommunicator (Testing)

@property (nonatomic, assign, readwrite) BOOL loading;

// Expose private methods from `MPAdServerCommunicator`
- (void)didFinishLoadingWithData:(NSData *)data;

@end
