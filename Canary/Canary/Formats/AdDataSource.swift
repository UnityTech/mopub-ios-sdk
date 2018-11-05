//
//  AdDataSource.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

/**
 Possible information to display along with the ad
 */
enum AdInformation {
    case id
    case keywords
    case userDataKeywords
    case customData
}

/**
 Possible actions for an ad
 */
enum AdAction {
    case load
    case show
}

/**
 Possible ad events
 */
enum AdEvent {
    case didLoad
    case didFailToLoad
    case didFailToPlay
    case willAppear
    case didAppear
    case willDisappear
    case didDisappear
    case willPresentModal
    case didDismissModal
    case didExpire
    case clicked
    case willLeaveApp
    case shouldRewardUser
}

/**
 Type-alias for ad action closures.
 The format of the handler is: (sender of the action) -> Void
 */
typealias AdActionHandler = ((Any) -> Swift.Void)

/**
 Delegate for presenting the data source's ad.
 */
protocol AdDataSourcePresentationDelegate: class {
    /**
     View controller used to present models (either the ad itself or any click through destination).
     */
    var adPresentationViewController: UIViewController? { get }
    
    /**
     Table view used to present the contents of the data source.
     */
    var adPresentationTableView: UITableView { get }
}

/**
 Protocol to specifying an ad's rendering on screen.
 */
protocol AdDataSource {
    /**
     Delegate used for presenting the data source's ad. This must be specified as `weak`.
     */
    var delegate: AdDataSourcePresentationDelegate? { get set }
    
    /**
     The ad unit information sections available for the ad.
     */
    var information: [AdInformation] { get }
    
    /**
     The actions available for the ad.
     */
    var actions: [AdAction] { get }
    
    /**
     Closures associated with each available ad action.
     */
    var actionHandlers: [AdAction: AdActionHandler] { get }
    
    /**
     The status events available for the ad.
     */
    var events: [AdEvent] { get }
    
    /**
     Ad unit associated with the ad.
     */
    var adUnit: AdUnit! { get }
    
    /**
     Optional container view for the ad.
     */
    var adContainerView: UIView? { get }
    
    /**
     Retrieves the display status for the event.
     - Parameter event: Status event.
     - Returns: A tuple containing the status display title, optional message, and highlighted state.
     */
    func status(for event: AdEvent) -> (title: String, message: String?, isHighlighted: Bool)
    
    /**
     Sets the status for the event to highlighted. If the status is already highlighted,
     nothing is done.
     - Parameter event: Status event.
     - Parameter complete: Completion closure.
     */
    func setStatus(for event: AdEvent, complete:(() -> Swift.Void))
    
    /**
     Clears the highlighted state for all status events.
     - Parameter complete: Completion closure.
     */
    func clearStatus(complete:(() -> Swift.Void))
}
