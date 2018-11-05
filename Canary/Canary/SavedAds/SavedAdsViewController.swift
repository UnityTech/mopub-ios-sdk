//
//  SavedAdsViewController.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class SavedAdsViewController: AdUnitTableViewController {
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        // Initialize the data source before invoking the base class's
        // `viewDidLoad()` method.
        let dataSource: SavedAdsDataSource = SavedAdsDataSource()
        super.initialize(with: dataSource)
        
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // If persistent storage (UserDefault) and memory data (stored in savedAds array) have inconsistent data,
        // reload tableView data.
        if SavedAdsManager.sharedInstance.isDirty {
            reloadData()
        }
    }
}
