//
//  SavedAdsDataSource.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

/**
 Saved ad units data source
 */
class SavedAdsDataSource: AdUnitDataSource {
    // MARK: - Overrides
    
    /**
     Initializes the data source with an optional plist file.
     - Parameter plistName: Name of a plist file (without the extension) to initialize the
     data source.
     - Parameter bundle: Bundle where the plist file lives.
     */
    required init(plistName: String = "", bundle: Bundle = Bundle.main) {
        super.init(plistName: plistName, bundle: bundle)
        self.adUnits = ["Saved Ads": SavedAdsManager.sharedInstance.loadSavedAds()]
    }
    
    /**
     Reloads the data source.
     */
    override func reloadData() {
        self.adUnits = ["Saved Ads": SavedAdsManager.sharedInstance.loadSavedAds()]
    }
}
