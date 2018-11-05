//
//  MPConsentManager+Testing.h
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPConsentManager.h"

extern NSString * _Nonnull const kIfaForConsentStorageKey;

@interface MPConsentManager (Testing)
- (BOOL)setCurrentStatus:(MPConsentStatus)currentStatus
                  reason:(NSString * _Nullable)reasonForChange
         shouldBroadcast:(BOOL)shouldBroadcast;
- (BOOL)updateConsentStateWithParameters:(NSDictionary * _Nonnull)newState;
- (NSURL * _Nullable)urlWithFormat:(NSString * _Nullable)urlFormat isoLanguageCode:(NSString * _Nullable)isoLanguageCode;
- (void)setIsGDPRApplicable:(MPBool)isGDPRApplicable;
@property (nonatomic, readonly) MPBool rawIsGDPRApplicable;

// Reset consent manager state for testing
- (void)setUpConsentManagerForTesting;
@end
