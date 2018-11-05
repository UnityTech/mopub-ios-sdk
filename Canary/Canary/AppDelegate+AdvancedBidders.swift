//
//  AppDelegate+AdvancedBidders.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
import MoPub

extension AppDelegate {
    /**
     Generates a list of advanced bidders supported by the app.
     - Returns: A list of advanced bidders or `nil` if none are found.
     */
    func supportedAdvancedBidders() -> [MPAdvancedBidder.Type]? {
        var bidders: [MPAdvancedBidder.Type] = []
        
        // AdColony advanced bidder
        if let adColonyBidderType = NSClassFromString("AdColonyAdvancedBidder") as? MPAdvancedBidder.Type {
            bidders.append(adColonyBidderType)
        }
        
        // AppLovin advanced bidder
        if let appLovinBidderType = NSClassFromString("AppLovinAdvancedBidder") as? MPAdvancedBidder.Type {
            bidders.append(appLovinBidderType)
        }
        
        // Facebook advanced bidder
        if let facebookBidderType = NSClassFromString("FacebookAdvancedBidder") as? MPAdvancedBidder.Type {
            bidders.append(facebookBidderType)
        }
        
        // Tapjoy advanced bidder
        if let tapjoyBidderType = NSClassFromString("TapjoyAdvancedBidder") as? MPAdvancedBidder.Type {
            bidders.append(tapjoyBidderType)
        }
        
        return bidders.count > 0 ? bidders : nil
    }
}
