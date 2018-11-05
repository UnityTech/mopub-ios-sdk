//
//  RewardedAdDataSource.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPub
import UIKit

class RewardedAdDataSource: NSObject, AdDataSource {
    // MARK: - Ad Properties
    
    /**
     Delegate used for presenting the data source's ad. This must be specified as `weak`.
     */
    weak var delegate: AdDataSourcePresentationDelegate? = nil
    
    // MARK: - Status Properties
    
    /**
     Currently selected reward by the user.
     */
    private var selectedReward: MPRewardedVideoReward? = nil
    
    /**
     Rewarded that was granted to the user.
     */
    private var grantedReward: MPRewardedVideoReward? = nil
    
    /**
     Table of which events were triggered.
     */
    private var eventTriggered: [AdEvent: Bool] = [:]
    
    /**
     Reason for load failure.
     */
    private var loadFailureReason: String? = nil
    
    /**
     Reason for playback failure.
     */
    private var playFailureReason: String? = nil
    
    /**
     Status event titles that correspond to the events found in `MPRewardedVideoDelegate`
     */
    private lazy var title: [AdEvent: String] = {
        var titleStrings: [AdEvent: String] = [:]
        titleStrings[.didLoad]          = "rewardedVideoAdDidLoad(_:)"
        titleStrings[.didFailToLoad]    = "rewardedVideoAdDidFailToLoad(_:_:)"
        titleStrings[.didFailToPlay]    = "rewardedVideoAdDidFailToPlay(_:_:)"
        titleStrings[.willAppear]       = "rewardedVideoAdWillAppear(_:)"
        titleStrings[.didAppear]        = "rewardedVideoAdDidAppear(_:)"
        titleStrings[.willDisappear]    = "rewardedVideoAdWillDisappear(_:)"
        titleStrings[.didDisappear]     = "rewardedVideoAdDidDisappear(_:)"
        titleStrings[.didExpire]        = "rewardedVideoAdDidExpire(_:)"
        titleStrings[.clicked]          = "rewardedVideoAdDidReceiveTapEvent(_:)"
        titleStrings[.willLeaveApp]     = "rewardedVideoAdWillLeaveApplication(_:)"
        titleStrings[.shouldRewardUser] = "rewardedVideoAdShouldReward(_:_:)"
        
        return titleStrings
    }()
    
    // MARK: - Initialization
    
    /**
     Initializes the Interstitial ad data source.
     - Parameter adUnit: Interstitial ad unit.
     */
    init(adUnit: AdUnit) {
        super.init()
        self.adUnit = adUnit
        
        // Register for rewarded video events
        MPRewardedVideo.setDelegate(self, forAdUnitId: adUnit.id)
    }
    
    deinit {
        MPRewardedVideo.removeDelegate(forAdUnitId: adUnit.id)
    }
    
    // MARK: - AdDataSource
    
    /**
     The ad unit information sections available for the ad.
     */
    lazy var information: [AdInformation] = {
        return [.id, .keywords, .userDataKeywords, .customData]
    }()
    
    /**
     The actions available for the ad.
     */
    lazy var actions: [AdAction] = {
        return [.load, .show]
    }()
    
    /**
     Closures associated with each available ad action.
     */
    lazy var actionHandlers: [AdAction: AdActionHandler] = {
        var handlers: [AdAction: AdActionHandler] = [:]
        handlers[.load] = { [weak self] _ in
            self?.loadAd()
        }
        
        handlers[.show] = { [weak self] (sender) in
            self?.showAd(sender: sender)
        }
        
        return handlers
    }()
    
    /**
     The status events available for the ad.
     */
    lazy var events: [AdEvent] = {
        return [.didLoad, .didFailToLoad, .didFailToPlay, .willAppear, .didAppear, .willDisappear, .didDisappear, .didExpire, .clicked, .willLeaveApp, .shouldRewardUser]
    }()
    
    /**
     Ad unit associated with the ad.
     */
    private(set) var adUnit: AdUnit!
    
    /**
     Optional container view for the ad.
     */
    var adContainerView: UIView? {
        return nil
    }
    
    /**
     Retrieves the display status for the event.
     - Parameter event: Status event.
     - Returns: A tuple containing the status display title, optional message, and highlighted state.
     */
    func status(for event: AdEvent) -> (title: String, message: String?, isHighlighted: Bool) {
        var message: String? = nil
        if event == .didFailToLoad {
            message = loadFailureReason
        }
        else if event == .didFailToPlay {
            message = playFailureReason
        }
        else if event == .shouldRewardUser, let amount = grantedReward?.amount, let currency = grantedReward?.currencyType {
            message = "\(amount) \(currency)"
        }
        
        let isHighlighted = (eventTriggered[event] ?? false)
        return (title: title[event] ?? "", message: message, isHighlighted: isHighlighted)
    }
    
    /**
     Sets the status for the event to highlighted. If the status is already highlighted,
     nothing is done.
     - Parameter event: Status event.
     - Parameter complete: Completion closure.
     */
    func setStatus(for event: AdEvent, complete:(() -> Swift.Void)) {
        eventTriggered[event] = true
        complete()
    }
    
    /**
     Clears the highlighted state for all status events.
     - Parameter complete: Completion closure.
     */
    func clearStatus(complete:(() -> Swift.Void)) {
        loadFailureReason = nil
        playFailureReason = nil
        eventTriggered = [:]
        complete()
    }
    
    // MARK: - Reward Selection
    
    /**
     Presents the reward selection as an action sheet. It will preselect the first item.
     - Parameter sender: `UIButton` element that initiated the reward selection
     - Parameter complete: Completion closure that's invoked when the select button has been pressed
     */
    private func presentRewardSelection(from sender: Any, complete: @escaping (() -> Swift.Void)) {
        // No rewards to present.
        guard let availableRewards = MPRewardedVideo.availableRewards(forAdUnitID: adUnit.id) as? [MPRewardedVideoReward],
            availableRewards.count > 0 else {
            return
        }
        
        // It's really a supported behavior to have a `UIPickerView` as a subview
        // of `UIAlertController`. To make it work, the width of the alert view
        // (as specified by `preferredContentSize`) should be the same as the
        // picker view.
        
        // Create the alert.
        let alert: UIAlertController = UIAlertController(title: "Choose Reward", message: nil, preferredStyle: .actionSheet)
        alert.isModalInPopover = true
        alert.preferredContentSize = CGSize(width: 320, height: 250)
        
        // Create the selection button.
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { _ in
            complete()
        }))
        
        // Reward picker view
        let pickerView: UIPickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        // Configure popover appearance.
        if let popoverController = alert.popoverPresentationController,
            let showButton: UIButton = sender as? UIButton {
            popoverController.sourceView = showButton
            popoverController.sourceRect = showButton.bounds
            popoverController.permittedArrowDirections = [.up, .down]
        }
        
        alert.view.addSubview(pickerView)
        
        // The bottom constraint of the picker view is -44 from the bottom anchor of the
        // alert view so that it doesn't cover the selection button. If the selection
        // button is covered, it cannot be tapped.
        let constraints: [NSLayoutConstraint] = [
            pickerView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 0),
            pickerView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: 0),
            pickerView.topAnchor.constraint(equalTo: alert.view.topAnchor),
            pickerView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -44),
        ]
        NSLayoutConstraint.activate(constraints)
        
        // Select the first reward by default.
        pickerView.selectRow(0, inComponent: 0, animated: false)
        self.pickerView(pickerView, didSelectRow: 0, inComponent: 0)
        
        // Present the alert
        delegate?.adPresentationViewController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Ad Loading
    
    private func loadAd() {
        clearStatus { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
        
        // Clear out previous reward.
        selectedReward = nil
        grantedReward = nil
        
        // Load the rewarded ad.
        MPRewardedVideo.loadAd(withAdUnitID: adUnit.id, keywords: adUnit.keywords, userDataKeywords: adUnit.userDataKeywords, location: nil, mediationSettings: nil)
    }
    
    private func showAd(sender: Any) {
        guard MPRewardedVideo.hasAdAvailable(forAdUnitID: adUnit.id) else {
            print("Attempted to show a rewarded ad when it is not ready")
            return
        }
        
        // Prompt the user to select a reward
        presentRewardSelection(from: sender) { [weak self] in
            if let strongSelf = self {
                // Validate a reward was selected
                guard strongSelf.selectedReward != nil else {
                    print("No reward was selected")
                    return
                }
                
                // Present the ad.
                MPRewardedVideo.presentAd(forAdUnitID: strongSelf.adUnit.id, from: strongSelf.delegate?.adPresentationViewController, with: strongSelf.selectedReward, customData: strongSelf.adUnit.customData)
            }
        }
    }
}

extension RewardedAdDataSource: UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: - UIPickerViewDataSource
    
    // There will always be a single column of currencies
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MPRewardedVideo.availableRewards(forAdUnitID: adUnit.id).count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let reward: MPRewardedVideoReward = MPRewardedVideo.availableRewards(forAdUnitID: adUnit.id)[row] as? MPRewardedVideoReward,
            let amount = reward.amount,
            let currency = reward.currencyType else {
            return nil
        }
        
        return "\(amount) \(currency)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let reward: MPRewardedVideoReward = MPRewardedVideo.availableRewards(forAdUnitID: adUnit.id)[row] as? MPRewardedVideoReward else {
            return
        }
        
        selectedReward = reward
    }
}

extension RewardedAdDataSource: MPRewardedVideoDelegate {
    // MARK: - MPRewardedVideoDelegate
    
    func rewardedVideoAdDidLoad(forAdUnitID adUnitID: String!) {
        setStatus(for: .didLoad) { [weak self] in
            if let strongSelf = self {
                strongSelf.loadFailureReason = nil
                strongSelf.playFailureReason = nil
                strongSelf.delegate?.adPresentationTableView.reloadData()
            }
        }
    }
    
    func rewardedVideoAdDidFailToLoad(forAdUnitID adUnitID: String!, error: Error!) {
        setStatus(for: .didFailToLoad) { [weak self] in
            if let strongSelf = self {
                strongSelf.loadFailureReason = error.localizedDescription
                strongSelf.delegate?.adPresentationTableView.reloadData()
            }
        }
    }
    
    func rewardedVideoAdDidFailToPlay(forAdUnitID adUnitID: String!, error: Error!) {
        setStatus(for: .didFailToPlay) { [weak self] in
            if let strongSelf = self {
                strongSelf.playFailureReason = error.localizedDescription
                strongSelf.delegate?.adPresentationTableView.reloadData()
            }
        }
    }
    
    func rewardedVideoAdWillAppear(forAdUnitID adUnitID: String!) {
        setStatus(for: .willAppear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdDidAppear(forAdUnitID adUnitID: String!) {
        setStatus(for: .didAppear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdWillDisappear(forAdUnitID adUnitID: String!) {
        setStatus(for: .willDisappear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdDidDisappear(forAdUnitID adUnitID: String!) {
        setStatus(for: .didDisappear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdDidExpire(forAdUnitID adUnitID: String!) {
        setStatus(for: .didExpire) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdDidReceiveTapEvent(forAdUnitID adUnitID: String!) {
        setStatus(for: .clicked) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdWillLeaveApplication(forAdUnitID adUnitID: String!) {
        setStatus(for: .willLeaveApp) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func rewardedVideoAdShouldReward(forAdUnitID adUnitID: String!, reward: MPRewardedVideoReward!) {
        setStatus(for: .shouldRewardUser) { [weak self] in
            if let strongSelf = self {
                strongSelf.grantedReward = reward
                strongSelf.delegate?.adPresentationTableView.reloadData()
            }
        }
    }
}
