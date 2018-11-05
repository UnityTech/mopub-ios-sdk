//
//  AppDelegate.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import MoPub

let kAppId = "112358"
let kAdUnitId = "0ac59b0996d947309c33f59d6676399f"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    /**
     Main application window.
     */
    var window: UIWindow?
    
    /**
     Main application's container controller.
     */
    var containerViewController: ContainerViewController!
    
    /**
     Saved ads split view controller.
     */
    var savedAdSplitViewController: UISplitViewController?

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Extract the UI elements for easier manipulation later.
        // Calls to `loadViewIfNeeded()` are needed to load any children view controllers
        // before `viewDidLoad()` occurs.
        containerViewController = (window?.rootViewController as! ContainerViewController)
        containerViewController.loadViewIfNeeded()
        savedAdSplitViewController = containerViewController.mainTabBarController?.viewControllers?[1] as? UISplitViewController
        
        // Additional configuration for internal target.
        #if INTERNAL
        Internal.sharedInstance.initialize(with: containerViewController)
        #endif

        // MoPub SDK initialization
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: kAdUnitId)
        sdkConfig.advancedBidders = supportedAdvancedBidders()
        sdkConfig.globalMediationSettings = []
        sdkConfig.mediatedNetworks = MoPub.sharedInstance().allCachedNetworks()
        
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {
            // Request user consent to collect personally identifiable information
            // used for targeted ads
            if let tabBarController = self.containerViewController.mainTabBarController {
                self.displayConsentDialog(from: tabBarController)
            }
            
            print("SDK completed initialization")
        }

        // Conversion tracking
        MPAdConversionTracker.shared().reportApplicationOpen(forApplicationID: kAppId)
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "mopub" && url.host == "load" {
            return openMoPubUrl(url: url, onto: savedAdSplitViewController, shouldSave: true)
        }
        return true
    }
    
    // MARK: - Deep Links

    /**
     Attempts to open a valid `mopub://` scheme deep link URL
     - Parameter url: MoPub deep link URL
     - Parameter splitViewController: Split view controller that will present the opened deep link
     - Parameter shouldSave: Flag indicating that the ad unit that was opened should be saved
     */
    func openMoPubUrl(url: URL, onto splitViewController: UISplitViewController?, shouldSave: Bool) -> Bool {
        // Validate that the URL contains the required query parameters:
        // 1. adUnitId (must be non-nil in value)
        // 2. format (must be a valid format string)
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems,
            queryItems.contains(where: { $0.name == AdUnitKey.Id }),
            let formatString: String = queryItems.filter({ $0.name == "format" }).first?.value,
            let format = AdFormat(rawValue: formatString) else {
            return false
        }
        
        // Generate an `AdUnit` from the query parameters and extracted ad format.
        let params: [String: String] = queryItems.reduce(into: [:], { (result, queryItem) in
            result[queryItem.name] = queryItem.value ?? ""
        })
        
        guard let adUnit: AdUnit = AdUnit(info: params, defaultViewControllerClassName: format.renderingViewController) else {
            return false
        }
        
        // Generate the destinate view controller and attempt to push the destination to the
        // Saved Ads navigation controller.
        guard let vcClass = NSClassFromString(adUnit.viewControllerClassName) as? AdViewController.Type,
            let destination: UIViewController = vcClass.instantiateFromNib(adUnit: adUnit) as? UIViewController else {
            return false
        }
        
        DispatchQueue.main.async {
            // If the ad unit should be saved, we will switch the tab to the saved ads
            // tab and then push the view controller on that navigation stack.
            if shouldSave {
                self.containerViewController.mainTabBarController?.selectedIndex = 1
                SavedAdsManager.sharedInstance.addSavedAd(adUnit: adUnit)
            }
            
            splitViewController?.showDetailViewController(destination, sender: splitViewController)
        }
        return true
    }
}
