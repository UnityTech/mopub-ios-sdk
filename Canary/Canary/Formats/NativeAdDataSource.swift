//
//  NativeAdDataSource.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPub
import UIKit

class NativeAdDataSource: BaseNativeAdDataSource, AdDataSource {
    // MARK: - Ad Properties
    
    /**
     Delegate used for presenting the data source's ad. This must be specified as `weak`.
     */
    weak var delegate: AdDataSourcePresentationDelegate? = nil
    
    /**
     Native ad.
     */
    private var nativeAd: MPNativeAd? = nil
    
    /**
     Native ad container.
     */
    private var nativeAdContainer: UIView!
    
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
     Status event titles that correspond to the events found in `MPNativeAdDelegate`
     */
    private lazy var title: [AdEvent: String] = {
        var titleStrings: [AdEvent: String] = [:]
        titleStrings[.didLoad]          = "nativeAdDidLoad(_:)"
        titleStrings[.didFailToLoad]    = "nativeAdDidFailToLoad(_:_:)"
        titleStrings[.willPresentModal] = "willPresentModal(_:)"
        titleStrings[.didDismissModal]  = "didDismissModal(_:)"
        titleStrings[.willLeaveApp]     = "willLeaveApplication(_:)"
        
        return titleStrings
    }()
    
    // MARK: - Initialization
    
    /**
     Initializes the Native ad data source.
     - Parameter adUnit: Native ad unit.
     */
    init(adUnit: AdUnit) {
        super.init()
        self.adUnit = adUnit
        
        nativeAdContainer = UIView()
        nativeAdContainer.backgroundColor = .lightGray
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
        return [.didLoad, .didFailToLoad, .willPresentModal, .didDismissModal, .willLeaveApp]
    }()
    
    /**
     Ad unit associated with the ad.
     */
    private(set) var adUnit: AdUnit!
    
    /**
     Optional container view for the ad.
     */
    var adContainerView: UIView? {
        return nativeAdContainer
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
    
    /**
     Computed native ad targetting settings.
     */
    var targetting: MPNativeAdRequestTargeting {
        let target: MPNativeAdRequestTargeting = MPNativeAdRequestTargeting()
        target.desiredAssets = Set(arrayLiteral: kAdTitleKey, kAdTextKey, kAdCTATextKey, kAdIconImageKey, kAdMainImageKey, kAdStarRatingKey, kAdIconImageViewKey, kAdMainMediaViewKey)
        target.keywords = adUnit.keywords
        target.userDataKeywords = adUnit.userDataKeywords
        
        return target
    }
    
    private func addToAdContainer(view: UIView) {
        guard let tableView = delegate?.adPresentationTableView else {
            return
        }
        
        // Remove all the subviews from the container
        for subview in nativeAdContainer.subviews {
            subview.removeFromSuperview()
        }
        
        // Resize the ad container frame to match the expanded size of the ad view
        // within the table view.
        nativeAdContainer.frame = {
            let size: CGSize = view.sizeFitting(view: tableView)
            let frame: CGRect = CGRect(origin: .zero, size: size)
            return frame
        }()
        
        // Add the view to the container and constrain it.
        view.frame = nativeAdContainer.bounds
        nativeAdContainer.addSubview(view)
        
        // Configure the contraints of the ad view.
        // The `translatesAutoresizingMaskIntoConstraints` must be set to `false`
        // since the native ad view is programmatically created and we want it
        // to interact with autolayout functionality.
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            view.topAnchor.constraint(equalTo: nativeAdContainer.topAnchor),
            view.bottomAnchor.constraint(equalTo: nativeAdContainer.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: nativeAdContainer.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: nativeAdContainer.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func loadAd() {
        clearStatus { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
        
        // Generate the native ad request
        let adRequest: MPNativeAdRequest = MPNativeAdRequest(adUnitIdentifier: adUnit.id, rendererConfigurations: rendererConfigurations)
        adRequest.targeting = targetting
        adRequest.start { [weak self] (request, nativeAd, error) in
            if let strongSelf = self {
                // Error loading the native ad
                guard error == nil else {
                    strongSelf.loadFailureReason = error?.localizedDescription
                    strongSelf.setStatus(for: .didFailToLoad) { [weak self] in
                        self?.delegate?.adPresentationTableView.reloadData()
                    }
                    return
                }
                
                // Setup the native ad for display
                strongSelf.nativeAd = nativeAd
                strongSelf.nativeAd?.delegate = strongSelf
                if let nativeAd = nativeAd, let nativeAdView = try? nativeAd.retrieveAdView() {
                    strongSelf.addToAdContainer(view: nativeAdView)
                }
                
                strongSelf.setStatus(for: .didLoad) { [weak self] in
                    self?.delegate?.adPresentationTableView.reloadData()
                }
            } // strongSelf
        } // start
    }
}

extension NativeAdDataSource: MPNativeAdDelegate {
    // MARK: - MPNativeAdDelegate
    
    func willPresentModal(for nativeAd: MPNativeAd!) {
        setStatus(for: .willPresentModal) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func didDismissModal(for nativeAd: MPNativeAd!) {
        setStatus(for: .didDismissModal) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func willLeaveApplication(from nativeAd: MPNativeAd!) {
        setStatus(for: .willLeaveApp) { [weak self] in
            self?.delegate?.adPresentationTableView.reloadData()
        }
    }
    
    func viewControllerForPresentingModalView() -> UIViewController! {
        return delegate?.adPresentationViewController
    }
}
