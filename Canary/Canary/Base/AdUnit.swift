//
//  AdUnit.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

/**
 Keys to access fields in the dictionary
 */
public struct AdUnitKey {
    static let Id: String = "adUnitId"
    static let Name: String = "name"
    static let Keywords: String = "keywords"
    static let UserDataKeywords: String = "userDataKeywords"
    static let CustomData: String = "custom_data"
    static let OverrideClass: String = "override_class"
}

/**
 Represents a displayable ad unit.
 */
public class AdUnit : NSObject, Codable {
    /**
     Ad unit ID as specified in the MoPub dashboard.
     */
    public var id: String
    
    /**
     A human readable name for the ad unit.
     */
    public var name: String

    /**
     An optional comma-delimited string of non-personally identifiable keywords associated with the ad unit.
     */
    public var keywords: String?

    /**
     An optional comma-delimited string of keywords associated with the ad unit.
     */
    public var userDataKeywords: String?
    
    /**
     An optional custom data string to pass along with rewarded ad requests.
     */
    public var customData: String?
    
    /**
     View controller that should be used to render the ad unit. This name is meant to
     initialize a `UIViewController` class from the storyboard.
     */
    public var viewControllerClassName: String
    
    /**
     Initializes an ad unit from a dictionary and a default rendering view controller.
     */
    public init?(info: [String: String], defaultViewControllerClassName: String) {
        guard let adUnitId = info[AdUnitKey.Id],
              let adUnitName = info[AdUnitKey.Name] else {
            return nil
        }

        id = adUnitId
        name = adUnitName
        keywords = info[AdUnitKey.Keywords]
        userDataKeywords = info[AdUnitKey.UserDataKeywords]
        customData = info[AdUnitKey.CustomData]

        if let overrideViewControllerClassName = info[AdUnitKey.OverrideClass] {
            viewControllerClassName = overrideViewControllerClassName
        }
        else {
            viewControllerClassName = defaultViewControllerClassName
        }
    }
}
