//
//  MPManualAdViewController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPManualAdViewController.h"
#import "MPSampleAppInstanceProvider.h"
#import "MPGlobal.h"
#import "MPAdInfo.h"

#import "MPRewardedVideoAdDetailViewController.h"
#import "MPAdPersistenceManager.h"
#import "MPRewardedVideo.h"
#import "MoPub.h"

@interface MPManualAdViewController () <MPRewardedVideoDelegate, UIPickerViewDataSource, UIPickerViewDelegate>


@property (nonatomic, strong) MPInterstitialAdController *firstInterstitial;
@property (nonatomic, strong) MPInterstitialAdController *rewarded;
@property (nonatomic, strong) MPInterstitialAdController *secondInterstitial;
@property (nonatomic, strong) MPInterstitialAdController *anotherInterstitial;

@property (nonatomic, strong) MPAdView *banner;
@property (nonatomic, strong) MPAdView *mRectBanner;
@property (nonatomic, strong) UITextField *activeField;

@property (weak, nonatomic) IBOutlet UIPickerView *rewardPickerView;
@property (nullable, nonatomic, copy) NSString *rewardedID;
@property (nullable, nonatomic, copy) NSString *selectedRewardIndex;

@property NSArray* rewardIds;

@end

@implementation MPManualAdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_7_0
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif

    self.rewardIds = @[ @"e89ae282acd749e0bdd8bbf6e0696758", @"a2e918c1c6bb479ca5fcaf3403f02135" ];
    
    self.title = @"Manual";
    self.rewardPickerView.dataSource = self;
    self.rewardPickerView.delegate = self;
    self.rewardedID = @"e89ae282acd749e0bdd8bbf6e0696758";
    self.firstInterstitialShowButton.enabled = YES;
    self.secondInterstitialShowButton.enabled = YES;
    self.selectedRewardIndex = 0;

    [[MoPub sharedInstance] initializeRewardedVideoWithGlobalMediationSettings:@[] delegate:self];
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.scrollView.contentSize = self.scrollView.bounds.size;
}

- (void)dealloc
{
    self.firstInterstitial.delegate = nil;
    self.rewarded.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)didTapFirstInterstitialLoadButton:(id)sender
{
    NSString* rewardId = @"e89ae282acd749e0bdd8bbf6e0696758";
    NSLog(@"RewardID=%@", rewardId);
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID: rewardId keywords:@"" location:nil customerId:@"testCustomerId" mediationSettings:@[]];
    
//    self.firstInterstitialLoadButton.enabled = NO;
//    self.firstInterstitialStatusLabel.text = @"";
//    [self.firstInterstitialActivityIndicator startAnimating];
//    self.firstInterstitialShowButton.hidden = YES;
//
//   // self.firstInterstitial = [[MPSampleAppInstanceProvider sharedProvider] buildMPInterstitialAdControllerWithAdUnitID:self.firstInterstitialTextField.text];
//   
//    self.firstInterstitial = [[MPSampleAppInstanceProvider sharedProvider] buildMPInterstitialAdControllerWithAdUnitID:@"d9740275876e4b348eda8bc983a7158a"];
//    self.firstInterstitial.delegate = self;
//    [self.firstInterstitial loadAd];
}

- (IBAction)didTapFirstInterstitialShowButton:(id)sender
{
    // [self.rewarded showFromViewController:self];
    if ([MPRewardedVideo hasAdAvailableForAdUnitID:@"e89ae282acd749e0bdd8bbf6e0696758"]) {
        NSArray * rewards = [MPRewardedVideo availableRewardsForAdUnitID: @"e89ae282acd749e0bdd8bbf6e0696758"];
        MPRewardedVideoReward * reward = rewards[0];
        [MPRewardedVideo presentRewardedVideoAdForAdUnitID:self.rewardedID fromViewController:self withReward:reward];
    }
}

- (IBAction)didTapSecondInterstitialLoadButton:(id)sender
{
    NSString* rewardId = @"a2e918c1c6bb479ca5fcaf3403f02135";
    NSLog(@"RewardID=%@", rewardId);
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID: rewardId keywords:@"" location:nil customerId:@"testCustomerId" mediationSettings:@[]];
    /*
    self.secondInterstitialLoadButton.enabled = NO;
    self.secondInterstitialStatusLabel.text = @"";
    [self.secondInterstitialActivityIndicator startAnimating];
    self.secondInterstitialShowButton.hidden = YES;

//    self.secondInterstitial = [[MPSampleAppInstanceProvider sharedProvider] buildMPInterstitialAdControllerWithAdUnitID:self.secondInterstitialTextField.text];
//    self.secondInterstitial.delegate = self;
    
    
    // create Instance Mediation Settings as needed here
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID: @"e89ae282acd749e0bdd8bbf6e0696758" keywords:@"" location:nil customerId:@"testCustomerId" mediationSettings:@[]];
    
   // [self.rewarded loadAd];
     */
}

- (IBAction)didTapSecondInterstitialShowButton:(id)sender
{
   // [self.rewarded showFromViewController:self];
    if ([MPRewardedVideo hasAdAvailableForAdUnitID:@"a2e918c1c6bb479ca5fcaf3403f02135"]) {
        NSArray * rewards = [MPRewardedVideo availableRewardsForAdUnitID: @"a2e918c1c6bb479ca5fcaf3403f02135"];
        MPRewardedVideoReward * reward = rewards[0];
        [MPRewardedVideo presentRewardedVideoAdForAdUnitID:@"a2e918c1c6bb479ca5fcaf3403f02135" fromViewController:self withReward:reward];
    }
}

- (IBAction)didTapBannerLoadButton:(id)sender
{
    [self updateForBannerAdLoad];
    
    [self.view endEditing:YES];
    [self.bannerActivityIndicator startAnimating];
    self.bannerStatusLabel.text = @"";
    self.banner.adUnitId = self.bannerTextField.text;
    [self.banner loadAd];
}

- (IBAction)didTapBannerMRectLoadButton:(id)sender
{
    [self updateForBannerMRectAdLoad];
    
    [self.view endEditing:YES];
    [self.bannerActivityIndicator startAnimating];
    self.bannerStatusLabel.text = @"";
    self.mRectBanner.adUnitId = self.bannerTextField.text;
    [self.mRectBanner loadAd];
}

- (void)updateForBannerAdLoad
{
    [self.banner removeFromSuperview];
    [self.mRectBanner removeFromSuperview];
    
    self.scrollView.contentSize = self.scrollView.bounds.size;
    
    self.bannerContainer.frame = CGRectMake(0, self.bannerContainer.frame.origin.y, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height);
    
    self.banner.delegate = nil;
    self.banner = [[MPSampleAppInstanceProvider sharedProvider] buildMPAdViewWithAdUnitID:@"" size:MOPUB_BANNER_SIZE];
    self.banner.delegate = self;
    [self.bannerContainer addSubview:self.banner];
}

- (void)updateForBannerMRectAdLoad
{
    [self.banner removeFromSuperview];
    [self.mRectBanner removeFromSuperview];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.bannerContainer.frame.origin.y + MOPUB_MEDIUM_RECT_SIZE.width);
    
    CGFloat sideBuffer = (self.view.bounds.size.width - MOPUB_MEDIUM_RECT_SIZE.width) / 2;
    self.bannerContainer.frame = CGRectMake(sideBuffer, self.bannerContainer.frame.origin.y, MOPUB_MEDIUM_RECT_SIZE.width, MOPUB_MEDIUM_RECT_SIZE.height);
    
    self.mRectBanner.delegate = nil;
    self.mRectBanner = [[MPSampleAppInstanceProvider sharedProvider] buildMPAdViewWithAdUnitID:@"" size:MOPUB_MEDIUM_RECT_SIZE];
    self.mRectBanner.delegate = self;
    [self.bannerContainer addSubview:self.mRectBanner];
}

#pragma mark - <MPInterstitialAdControllerDelegate>

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    if (interstitial == self.firstInterstitial) {
        [self.firstInterstitialActivityIndicator stopAnimating];
        self.firstInterstitialShowButton.hidden = NO;
        self.firstInterstitialLoadButton.enabled = YES;
    } else if (interstitial == self.secondInterstitial) {
        [self.secondInterstitialActivityIndicator stopAnimating];
        self.secondInterstitialShowButton.hidden = NO;
        self.secondInterstitialLoadButton.enabled = YES;
    }
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    if (interstitial == self.firstInterstitial) {
        [self.firstInterstitialActivityIndicator stopAnimating];
        self.firstInterstitialLoadButton.enabled = YES;
        self.firstInterstitialStatusLabel.text = @"Failed";
    } else if (interstitial == self.secondInterstitial) {
        [self.secondInterstitialActivityIndicator stopAnimating];
        self.secondInterstitialLoadButton.enabled = YES;
        self.secondInterstitialStatusLabel.text = @"Failed";
    }
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
    if (interstitial == self.firstInterstitial) {
        self.firstInterstitialStatusLabel.text = @"Expired";
        self.firstInterstitialShowButton.hidden = YES;
        self.firstInterstitialLoadButton.enabled = YES;
    } else if (interstitial == self.secondInterstitial) {
        self.secondInterstitialStatusLabel.text = @"Expired";
        self.secondInterstitialShowButton.hidden = YES;
        self.secondInterstitialLoadButton.enabled = YES;
    }
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial
{
    if (interstitial == self.firstInterstitial) {
        self.firstInterstitialShowButton.hidden = YES;
        self.firstInterstitialLoadButton.enabled = YES;
    } else if (interstitial == self.secondInterstitial) {
        self.secondInterstitialShowButton.hidden = YES;
        self.secondInterstitialLoadButton.enabled = YES;
    }
}

#pragma mark - <MPAdViewDelegate>

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    [self.bannerActivityIndicator stopAnimating];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    self.bannerStatusLabel.text = @"Failed";
    [self.bannerActivityIndicator stopAnimating];
}

- (void)didTapScrollView
{
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - Keyboard Scroll Management

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint activeFieldVisiblePoint = CGPointMake(self.activeField.frame.origin.x, self.activeField.frame.origin.y + self.activeField.frame.size.height + 10);
    if (!CGRectContainsPoint(aRect, activeFieldVisiblePoint) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeFieldVisiblePoint.y - aRect.size.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Rotation (pre-iOS 6.0)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.banner rotateToOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}








//
//- (IBAction)didTapShowButton:(id)sender
//{
//    if ([MPRewardedVideo hasAdAvailableForAdUnitID:self.info.ID]) {
//        NSArray * rewards = [MPRewardedVideo availableRewardsForAdUnitID:self.info.ID];
//        MPRewardedVideoReward * reward = rewards[self.selectedRewardIndex];
//        [MPRewardedVideo presentRewardedVideoAdForAdUnitID:self.info.ID fromViewController:self withReward:reward];
//    }
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField endEditing:YES];
//    
//    return YES;
//}
//

#pragma mark - <MPInterstitialAdControllerDelegate>

- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"AdUnit=%@ loaded.", adUnitID);
    [self disableLoadButtonAndEnableShowButton:adUnitID];
    
  //  self.rewardPickerView.userInteractionEnabled = true;
  //  [self.rewardPickerView reloadAllComponents];
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error
{
    NSLog(@"Rewarded video failed to load. (adUnitId=%@, error=%@)", adUnitID, error);
    [self enableLoadButtonAndDisableShowButton:adUnitID];
    [self setAdUnitStatusText:adUnitID: @"Failed to load."];
}

- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"Appearing (adUnit=%@)", adUnitID);
}

- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"Appeared (adUnit=%@)", adUnitID);
}

- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"Disappearing (adUnit=%@)", adUnitID);
}

- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"Disappeared (adUnit=%@)", adUnitID);
    [self enableLoadButtonAndDisableShowButton:adUnitID];
}

- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"Expired (adUnit=%@)", adUnitID);
    [self enableLoadButtonAndDisableShowButton:adUnitID];
    [self setAdUnitStatusText:adUnitID: @"Loaded"];
}

- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID
{
    NSLog(@"Tapped (adUnit=%@)", adUnitID);
}

- (void)rewardedVideoWillLeaveApplicationForAdUnitID:(NSString *)adUnitID
{
    
}

- (void)enableLoadButtonAndDisableShowButton:(NSString*) adUnitID {
    /*
    if ([adUnitID isEqualToString:@"a2e918c1c6bb479ca5fcaf3403f02135"]) {
        self.secondInterstitialLoadButton.enabled = YES;
        self.secondInterstitialActivityIndicator.hidden = YES;
        self.secondInterstitialShowButton.enabled = NO;
    } else {
        self.firstInterstitialLoadButton.enabled = YES;
        self.firstInterstitialActivityIndicator.hidden = YES;
        self.firstInterstitialShowButton.enabled = NO;
    }
     */
}

- (void)disableLoadButtonAndEnableShowButton:(NSString*) adUnitID {
    /*
    if ([adUnitID isEqualToString:@"a2e918c1c6bb479ca5fcaf3403f02135"]) {
        self.secondInterstitialLoadButton.enabled = NO;
        // self.secondInterstitialActivityIndicator.hidden = NO;
        self.secondInterstitialShowButton.enabled = YES;
    } else {
        self.firstInterstitialLoadButton.enabled = NO;
        // self.firstInterstitialActivityIndicator.hidden = NO;
        self.firstInterstitialShowButton.enabled = YES;
    }
     */
}

- (void) setAdUnitStatusText:(NSString*) adUnitID :(NSString*) text {
    if ([adUnitID isEqualToString:@"a2e918c1c6bb479ca5fcaf3403f02135"]) {
        self.secondInterstitialStatusLabel.text = text;
    } else {
        self.firstInterstitialStatusLabel.text = text;
    }
}

- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPRewardedVideoReward *)reward
{
}

//#pragma mark - UIPickerViewDataSource
//
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
//    return 1;
//}
//
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//    if (![MPRewardedVideo hasAdAvailableForAdUnitID:self.info.ID]) {
//        return 0;
//    }
//    
//    NSArray * rewards = [MPRewardedVideo availableRewardsForAdUnitID:self.info.ID];
//    return rewards.count;
//}
//
//#pragma mark - UIPickerViewDelegate
//
//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    NSArray * rewards = [MPRewardedVideo availableRewardsForAdUnitID:self.info.ID];
//    MPRewardedVideoReward * reward = rewards[row];
//    NSString * title = [NSString stringWithFormat:@"%@ %@", reward.amount, reward.currencyType];
//    NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
//    
//    return attributedTitle;
//}
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    self.selectedRewardIndex = row;
//}
//



@end
