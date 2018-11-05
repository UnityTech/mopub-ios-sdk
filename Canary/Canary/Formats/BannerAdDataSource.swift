//
//  BannerAdDataSource.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPub
import UIKit

class BannerAdDataSource: NSObject, AdDataSource {
    // MARK: - Ad Properties
    
    /**
     Delegate used for presenting the data source's ad. This must be specified as `weak`.
     */
    weak var delegate: AdDataSourcePresentationDelegate? = nil
    
    /**
     Banner ad view.
     */
    private var adView: MPAdView!
    
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
     Status event titles that correspond to the events found in `MPAdViewDelegate`
     */
    private lazy var title: [AdEvent: String] = {
        var titleStrings: [AdEvent: String] = [:]
        titleStrings[.didLoad] = "adViewDidLoadAd(_:)"
        titleStrings[.didFailToLoad] = "adViewDidFailToLoadAd(_:)"
        titleStrings[.willPresentModal] = "willPresentModalViewForAd(_:)"
        titleStrings[.didDismissModal] = "didDismissModalViewForAd(_:)"
        titleStrings[.clicked] = "willLeaveApplicationFromAd(_:)"
        
        return titleStrings
    }()
    
    // MARK: - Initialization
    
    /**
     Initializes the Banner ad data source.
     - Parameter adUnit: Banner ad unit.
     - Parameter size: Banner ad size.
     */
    init(adUnit: AdUnit, bannerSize size: CGSize) {
        super.init()
        self.adUnit = adUnit
        
        // Instantiate the banner.
        adView = {
            let view: MPAdView = MPAdView(adUnitId: adUnit.id, size: size)
            view.delegate = self
            view.backgroundColor = .lightGray
            
            return view
        }()
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
        return [.load]
    }()
    
    /**
     Closures associated with each available ad action.
     */
    lazy var actionHandlers: [AdAction: AdActionHandler] = {
        var handlers: [AdAction: AdActionHandler] = [:]
        handlers[.load] = { [weak self] _ in
            self?.loadAd()
        }
        
        return handlers
    }()
    
    /**
     The status events available for the ad.
     */
    lazy var events: [AdEvent] = {
        return [.didLoad, .didFailToLoad, .willPresentModal, .didDismissModal, .clicked]
    }()
    
    /**
     Ad unit associated with the ad.
     */
    private(set) var adUnit: AdUnit!
    
    /**
     Optional container view for the ad.
     */
    var adContainerView: UIView? {
        return adView
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
        adView.keywords = adUnit.keywords
        adView.userDataKeywords = adUnit.userDataKeywords
        adView.loadAd()
    }
}

extension BannerAdDataSource: MPAdViewDelegate {
    // MARK: - MPAdViewDelegate
    
    func viewControllerForPresentingModalView() -> UIViewController? {
        return delegate?.adPresentationViewController
    }
    
    func adViewDidLoadAd(_ view: MPAdView!) {
        setStatus(for: .didLoad) { [weak self] in
            if let strongSelf = self {
                strongSelf.loadFailureReason = nil
                strongSelf.delegate?.adPresentationTableView.reloadData()
            }
        }
    }
    
    func adViewDidFail(toLoadAd view: MPAdView!) {
        setStatus(for: .didFailToLoad) { [weak self] in
            if let strongSelf = self {
                // The banner load failure doesn't give back an error reason; assume clear response
                strongSelf.loadFailureReason = "No ad available"
                strongSelf.delegate?.adPresentationTableView.reloadData()
            }
        }
    }
    
    func willPresentModalView(forAd view: MPAdView!) {
        setStatus(for: .willPresentModal) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func didDismissModalView(forAd view: MPAdView!) {
        setStatus(for: .didDismissModal) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func willLeaveApplication(fromAd view: MPAdView!) {
        setStatus(for: .clicked) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
}
