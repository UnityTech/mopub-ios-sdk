//
//  AdFormat.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

/**
 Provides a mapping of ad format to a view controller that can render it.
 */
enum AdFormat: String {
    /**
     320x50 banner
     */
    case Banner = "Banner"
    
    /**
     Full screen interstitial
     */
    case Interstitial = "Interstitial"
    
    /**
     728x90 leaderboard banner
     */
    case Leaderboard = "Leaderboard"
    
    /**
     320x250 medium rectangle banner
     */
    case MRect = "MRect"
    
    /**
     Native ad
     */
    case Native = "Native"
    
    /**
     Native ads rendered in a collection view
     */
    case NativeCollectionPlacer = "NativeCollectionPlacer"
    
    /**
     Native ads rendered in a table view
     */
    case NativeTablePlacer = "NativeTablePlacer"
    
    /**
     Rewarded interstitial
     */
    case Rewarded = "Rewarded"
    
    /**
     Name of the view controller that is capable of rendering the format.
     - Remark: The view controller names come from the storyboard identifiers
     from `AdFormats.storyboard`.
     */
    var renderingViewController: String {
        switch self {
        case .Banner:                   return "BannerAdViewController"
        case .Interstitial:             return "InterstitialAdViewController"
        case .Leaderboard:              return "LeaderboardAdViewController"
        case .MRect:                    return "MediumRectangleAdViewController"
        case .Native:                   return "NativeAdViewController"
        case .NativeCollectionPlacer:   return "NativeAdCollectionViewController"
        case .NativeTablePlacer:        return "NativeAdTableViewController"
        case .Rewarded:                 return "RewardedAdViewController"
        }
    }
    
    /**
     Storyboard associated with the `renderingViewController` property.
     */
    static let renderingStoryboard: String = "AdFormats"
}
