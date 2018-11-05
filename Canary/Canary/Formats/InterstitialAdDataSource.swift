//
//  InterstitialAdDataSource.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPub
import UIKit

class InterstitialAdDataSource: NSObject, AdDataSource {
    // MARK: - Ad Properties
    
    /**
     Delegate used for presenting the data source's ad. This must be specified as `weak`.
     */
    weak var delegate: AdDataSourcePresentationDelegate? = nil
    
    /**
     Interstitial ad
     */
    private var interstitialAd: MPInterstitialAdController!
    
    // MARK: - Status Properties
    
    /**
     Table of which events were triggered.
     */
    private var eventTriggered: [AdEvent: Bool] = [:]
    
    /**
     Reason for load failure.
     */
    private var loadFailureReason: String? = nil
    
    /**
     Status event titles that correspond to the events found in `MPInterstitialAdControllerDelegate`
     */
    private lazy var title: [AdEvent: String] = {
        var titleStrings: [AdEvent: String] = [:]
        titleStrings[.didLoad]       = "interstitialDidLoadAd(_:)"
        titleStrings[.didFailToLoad] = "interstitialDidFailToLoadAd(_:)"
        titleStrings[.willAppear]    = "interstitialWillAppear(_:)"
        titleStrings[.didAppear]     = "interstitialDidAppear(_:)"
        titleStrings[.willDisappear] = "interstitialWillDisappear(_:)"
        titleStrings[.didDisappear]  = "interstitialDidDisappear(_:)"
        titleStrings[.didExpire]     = "interstitialDidExpire(_:)"
        titleStrings[.clicked]       = "interstitialDidReceiveTapEvent(_:)"
        
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
        
        // Instantiate the interstitial ad.
        interstitialAd = MPInterstitialAdController(forAdUnitId: adUnit.id)
        interstitialAd.delegate = self
    }
    
    // MARK: - AdDataSource
    
    /**
     The ad unit information sections available for the ad.
     */
    lazy var information: [AdInformation] = {
        return [.id, .keywords, .userDataKeywords]
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
        
        handlers[.show] = { [weak self] _ in
            self?.showAd()
        }
        
        return handlers
    }()
    
    /**
     The status events available for the ad.
     */
    lazy var events: [AdEvent] = {
        return [.didLoad, .didFailToLoad, .willAppear, .didAppear, .willDisappear, .didDisappear, .didExpire, .clicked]
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
        let message = (event == .didFailToLoad ? loadFailureReason : nil)
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
        eventTriggered = [:]
        complete()
    }
    
    // MARK: - Ad Loading
    
    private func loadAd() {
        clearStatus { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
        
        // Populate the keywords and user data keywords before attempting
        // to load.
        interstitialAd.keywords = adUnit.keywords
        interstitialAd.userDataKeywords = adUnit.userDataKeywords
        interstitialAd.loadAd()
    }
    
    private func showAd() {
        guard interstitialAd.ready else {
            print("Attempted to show an interstitial ad when it is not ready")
            return
        }
        
        interstitialAd.show(from: delegate?.adPresentationViewController)
    }
}

extension InterstitialAdDataSource: MPInterstitialAdControllerDelegate {
    // MARK: - MPInterstitialAdControllerDelegate
    
    func interstitialDidLoadAd(_ interstitial: MPInterstitialAdController!) {
        setStatus(for: .didLoad) { [weak self] in
            if let strongSelf = self {
                strongSelf.loadFailureReason = nil
                strongSelf.delegate?.adPresentationTableView.reloadData()
            }
        }
    }
    
    func interstitialDidFail(toLoadAd interstitial: MPInterstitialAdController!) {
        setStatus(for: .didFailToLoad) { [weak self] in
            if let strongSelf = self {
                // The interstitial load failure doesn't give back an error reason; assume clear response
                strongSelf.loadFailureReason = "No ad available"
                strongSelf.delegate?.adPresentationTableView.reloadData()
            }
        }
    }
    
    func interstitialWillAppear(_ interstitial: MPInterstitialAdController!) {
        setStatus(for: .willAppear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func interstitialDidAppear(_ interstitial: MPInterstitialAdController!) {
        setStatus(for: .didAppear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func interstitialWillDisappear(_ interstitial: MPInterstitialAdController!) {
        setStatus(for: .willDisappear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func interstitialDidDisappear(_ interstitial: MPInterstitialAdController!) {
        setStatus(for: .didDisappear) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func interstitialDidExpire(_ interstitial: MPInterstitialAdController!) {
        setStatus(for: .didExpire) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func interstitialDidReceiveTapEvent(_ interstitial: MPInterstitialAdController!) {
        setStatus(for: .clicked) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
}
