//
//  MPInterstitialAdManagerTests.m
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfigurationFactory.h"
#import "MPAdTargeting.h"
#import "MPInterstitialAdManager+Testing.h"
#import "MPInterstitialAdManagerDelegateHandler.h"
#import "MPInterstitialCustomEventAdapter.h"
#import "MPInterstitialCustomEventAdapter+Testing.h"
#import "MPMockAdServerCommunicator.h"
#import "MPMockInterstitialCustomEvent.h"

static const NSTimeInterval kDefaultTimeout = 10;

@interface MPInterstitialAdManagerTests : XCTestCase

@end

@implementation MPInterstitialAdManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEmptyConfigurationArray {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    MPInterstitialAdManagerDelegateHandler * handler = [MPInterstitialAdManagerDelegateHandler new];
    handler.didFailToLoadAd = ^(NSError * error) {
        [expectation fulfill];
    };

    MPInterstitialAdManager * manager = [[MPInterstitialAdManager alloc] initWithDelegate:handler];
    [manager communicatorDidReceiveAdConfigurations:@[]];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testNilConfigurationArray {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    MPInterstitialAdManagerDelegateHandler * handler = [MPInterstitialAdManagerDelegateHandler new];
    handler.didFailToLoadAd = ^(NSError * error) {
        [expectation fulfill];
    };

    MPInterstitialAdManager * manager = [[MPInterstitialAdManager alloc] initWithDelegate:handler];
    [manager communicatorDidReceiveAdConfigurations:nil];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testMultipleResponsesFirstSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    MPInterstitialAdManagerDelegateHandler * handler = [MPInterstitialAdManagerDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^(NSError * error) {
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * interstitialThatShouldLoad = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"MPMockInterstitialCustomEvent"];
    MPAdConfiguration * interstitialLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"MPMockInterstitialCustomEvent"];
    MPAdConfiguration * interstitialLoadFail = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[interstitialThatShouldLoad, interstitialLoadThatShouldNotLoad, interstitialLoadFail];

    MPInterstitialAdManager * manager = [[MPInterstitialAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 1);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 1);
}

- (void)testMultipleResponsesMiddleSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    MPInterstitialAdManagerDelegateHandler * handler = [MPInterstitialAdManagerDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^(NSError * error) {
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * interstitialThatShouldLoad = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"MPMockInterstitialCustomEvent"];
    MPAdConfiguration * interstitialLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"MPMockInterstitialCustomEvent"];
    MPAdConfiguration * interstitialLoadFail = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[interstitialLoadFail, interstitialThatShouldLoad, interstitialLoadThatShouldNotLoad];

    MPInterstitialAdManager * manager = [[MPInterstitialAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
}

- (void)testMultipleResponsesLastSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    MPInterstitialAdManagerDelegateHandler * handler = [MPInterstitialAdManagerDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^(NSError * error) {
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * interstitialThatShouldLoad = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"MPMockInterstitialCustomEvent"];
    MPAdConfiguration * interstitialLoadFail1 = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * interstitialLoadFail2 = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[interstitialLoadFail1, interstitialLoadFail2, interstitialThatShouldLoad];

    MPInterstitialAdManager * manager = [[MPInterstitialAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 3);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 3);
}

- (void)testMultipleResponsesFailOverToNextPage {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    MPInterstitialAdManagerDelegateHandler * handler = [MPInterstitialAdManagerDelegateHandler new];
    handler.didFailToLoadAd = ^(NSError * error) {
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * interstitialLoadFail1 = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * interstitialLoadFail2 = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[interstitialLoadFail1, interstitialLoadFail2];

    MPInterstitialAdManager * manager = [[MPInterstitialAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // 2 failed attempts from first page
    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
    XCTAssert([communicator.lastUrlLoaded.absoluteString isEqualToString:@"http://ads.mopub.com/m/failURL"]);
}

- (void)testMultipleResponsesFailOverToNextPageClear {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    MPInterstitialAdManagerDelegateHandler * handler = [MPInterstitialAdManagerDelegateHandler new];
    handler.didFailToLoadAd = ^(NSError * error) {
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * interstitialLoadFail1 = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * interstitialLoadFail2 = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[interstitialLoadFail1, interstitialLoadFail2];

    MPInterstitialAdManager * manager = [[MPInterstitialAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    communicator.mockConfigurationsResponse = @[[MPAdConfigurationFactory clearResponse]];

    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // 2 failed attempts from first page
    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
    XCTAssert([communicator.lastUrlLoaded.absoluteString isEqualToString:@"http://ads.mopub.com/m/failURL"]);
}

#pragma mark - Local Extras

- (void)testLocalExtrasInCustomEvent {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for interstitial load"];

    MPInterstitialAdManagerDelegateHandler * handler = [MPInterstitialAdManagerDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^(NSError * error) {
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * interstitialThatShouldLoad = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"MPMockInterstitialCustomEvent"];
    NSArray * configurations = @[interstitialThatShouldLoad];

    MPInterstitialAdManager * manager = [[MPInterstitialAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    communicator.mockConfigurationsResponse = configurations;
    manager.communicator = communicator;

    MPAdTargeting * targeting = [[MPAdTargeting alloc] init];
    targeting.localExtras = @{ @"testing": @"YES" };
    [manager loadInterstitialWithAdUnitID:@"TEST_ADUNIT_ID" targeting:targeting];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    MPInterstitialCustomEventAdapter * adapter = (MPInterstitialCustomEventAdapter *)manager.adapter;
    MPMockInterstitialCustomEvent * customEvent = (MPMockInterstitialCustomEvent *)adapter.interstitialCustomEvent;
    XCTAssertNotNil(customEvent);

    NSDictionary * localExtras = customEvent.localExtras;
    XCTAssertNotNil(localExtras);
    XCTAssert([localExtras[@"testing"] isEqualToString:@"YES"]);
    XCTAssertTrue(customEvent.isLocalExtrasAvailableAtRequest);
}

@end
