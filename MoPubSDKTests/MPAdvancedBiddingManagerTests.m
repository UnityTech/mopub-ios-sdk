//
//  MPAdvancedBiddingManagerTests.m
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdvancedBiddingManager+Testing.h"
#import "MPStubAdvancedBidder.h"

static NSTimeInterval const kTestTimeout = 4;

@interface MPAdvancedBiddingManagerTests : XCTestCase

@end

@implementation MPAdvancedBiddingManagerTests

- (void)setUp {
    [super setUp];

    // Reset the state of the bidders.
    MPAdvancedBiddingManager.sharedManager.bidders = [NSMutableDictionary dictionary];
    MPAdvancedBiddingManager.sharedManager.advancedBiddingEnabled = YES;
}

- (void)testInitialization {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect advanced bidders to initialize"];

    [MPAdvancedBiddingManager.sharedManager initializeBidders:@[MPStubAdvancedBidder.class] complete:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    NSDictionary * bidders = MPAdvancedBiddingManager.sharedManager.bidders;
    XCTAssertNotNil(bidders[@"stub_bidder"]);
    XCTAssert(bidders.allKeys.count == 1);

    NSString * json = MPAdvancedBiddingManager.sharedManager.bidderTokensJson;
    XCTAssertNotNil(json);
}

- (void)testReinitialization {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect advanced bidders to initialize"];
    [MPAdvancedBiddingManager.sharedManager initializeBidders:@[MPStubAdvancedBidder.class] complete:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTestExpectation * expectationAgain = [self expectationWithDescription:@"Expect advanced bidders to initialize"];
    [MPAdvancedBiddingManager.sharedManager initializeBidders:@[MPStubAdvancedBidder.class] complete:^{
        [expectationAgain fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    NSDictionary * bidders = MPAdvancedBiddingManager.sharedManager.bidders;
    XCTAssertNotNil(bidders[@"stub_bidder"]);
    XCTAssert(bidders.allKeys.count == 1);

    NSString * json = MPAdvancedBiddingManager.sharedManager.bidderTokensJson;
    XCTAssertNotNil(json);
}

- (void)testNoInitialization {
    NSDictionary * bidders = MPAdvancedBiddingManager.sharedManager.bidders;
    XCTAssert(bidders.allKeys.count == 0);
    XCTAssertNil(MPAdvancedBiddingManager.sharedManager.bidderTokensJson);
}

- (void)testDisabledAdvancedBidding {
    MPAdvancedBiddingManager.sharedManager.advancedBiddingEnabled = NO;

    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect advanced bidders to initialize"];

    [MPAdvancedBiddingManager.sharedManager initializeBidders:@[MPStubAdvancedBidder.class] complete:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    NSDictionary * bidders = MPAdvancedBiddingManager.sharedManager.bidders;
    XCTAssertNotNil(bidders[@"stub_bidder"]);
    XCTAssert(bidders.allKeys.count == 1);

    // Expect no JSON since advanced bidding is disabled.
    XCTAssertNil(MPAdvancedBiddingManager.sharedManager.bidderTokensJson);
}

@end
