//
//  MPAdViewTests.m
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdServerKeys.h"
#import "MPAdView.h"
#import "MPAdView+Testing.h"
#import "MPAPIEndpoints.h"
#import "MPBannerAdManager+Testing.h"
#import "MPMockAdServerCommunicator.h"
#import "MPURL.h"
#import "NSURLComponents+Testing.h"

@interface MPAdViewTests : XCTestCase
@property (nonatomic, strong) MPAdView * adView;
@property (nonatomic, weak) MPMockAdServerCommunicator * mockAdServerCommunicator;
@end

@implementation MPAdViewTests

- (void)setUp {
    [super setUp];

    self.adView = [[MPAdView alloc] initWithAdUnitId:@"FAKE_AD_UNIT_ID" size:MOPUB_BANNER_SIZE];
    self.adView.adManager.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adView.adManager];
        self.mockAdServerCommunicator = mock;
        mock;
    });
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Viewability

- (void)testViewabilityQueryParameter {
    // Banner ads should send a viewability query parameter.
    [self.adView loadAd];

    XCTAssertNotNil(self.mockAdServerCommunicator);
    XCTAssertNotNil(self.mockAdServerCommunicator.lastUrlLoaded);

    MPURL * url = [self.mockAdServerCommunicator.lastUrlLoaded isKindOfClass:[MPURL class]] ? (MPURL *)self.mockAdServerCommunicator.lastUrlLoaded : nil;
    XCTAssertNotNil(url);

    NSString * viewabilityValue = [url stringForPOSTDataKey:kViewabilityStatusKey];
    XCTAssertNotNil(viewabilityValue);
    XCTAssertTrue([viewabilityValue isEqualToString:@"1"]);
}


@end
