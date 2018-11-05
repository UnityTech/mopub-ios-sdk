//
//  MainTabBarController.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import MoPub

fileprivate enum Constants {
    /**
     Time in seconds to render notification animations.
     */
    static let notificationAnimationDuration: TimeInterval = 0.5
}

class MainTabBarController: UITabBarController {
    /**
     Button used for displaying status notifications.
     */
    private var notificationButton: UIButton = UIButton()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the notification label
        notificationButton.alpha = 0.0
        notificationButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 10, bottom: 5, right: 10)
        notificationButton.addTarget(self, action: #selector(self.dismissNotification), for: .touchUpInside)
        view.addSubview(notificationButton)
        
        // Constrain the notification label
        notificationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            notificationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notificationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            notificationButton.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        ])
        
        // Register for the consent broadcast notifications
        NotificationCenter.default.addObserver(self, selector: #selector(MainTabBarController.onConsentChangedNotification(notification:)), name: NSNotification.Name.mpConsentChanged, object: nil)
    }

    // MARK: - Notifications
    
    /**
     Displays a status notification onscreen just above the tab bar.
     - Parameter text: Status text to display
     - Parameter textColor: Text color
     - Parameter backgroundColor: Background color
     */
    func showNotification(withText text: String, textColor: UIColor = .white, backgroundColor: UIColor = .black) {
        notificationButton.backgroundColor = backgroundColor
        notificationButton.setTitle(text, for: .normal)
        notificationButton.setTitleColor(textColor, for: .normal)
        notificationButton.layoutIfNeeded()
        
        UIView.animate(withDuration: Constants.notificationAnimationDuration) {
            self.notificationButton.alpha = 1.0
        }
    }
    
    /**
     Dismisses the notification display.
     */
    @objc
    func dismissNotification() {
        UIView.animate(withDuration: Constants.notificationAnimationDuration) {
            self.notificationButton.alpha = 0.0
        }
    }
    
    // MARK: - Notification Listeners
    
    /**
     Listens for changes in consent status and PII collection status.
     - Parameter notification: Notification with payload in `userInfo`.
     */
    @objc
    func onConsentChangedNotification(notification: NSNotification) {
        // Extract the notification payload
        if let payload: [String: NSNumber] = notification.userInfo as? [String: NSNumber],
            let oldStatusNumber: NSNumber = payload[kMPConsentChangedInfoPreviousConsentStatusKey],
            let newStatusNumber: NSNumber = payload[kMPConsentChangedInfoNewConsentStatusKey],
            let canCollectPii: Bool = payload[kMPConsentChangedInfoCanCollectPersonalInfoKey]?.boolValue,
            let oldStatus: MPConsentStatus = MPConsentStatus(rawValue: oldStatusNumber.intValue),
            let newStatus: MPConsentStatus = MPConsentStatus(rawValue: newStatusNumber.intValue) {
            // Text to display
            var notificationText: String
            
            // There was a change in status; display the new status
            if oldStatus != newStatus {
                notificationText = "Consent changed to \(newStatus.description)"
            }
            // There was a change in the ability to collect PII
            else if canCollectPii {
                notificationText = "PII can be collected"
            }
            // Not allowed to collect PII
            else {
                notificationText = "PII is not allowed to be collected"
            }
            
            showNotification(withText: notificationText)
        }
    }
}
