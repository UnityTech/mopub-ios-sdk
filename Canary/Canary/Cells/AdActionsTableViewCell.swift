//
//  AdActionsTableViewCell.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class AdActionsTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var showAdButton: RoundedButton!
    @IBOutlet weak var loadAdButton: RoundedButton!
    
    // MARK: - Properties
    fileprivate var willLoadAd: AdActionHandler? = nil
    fileprivate var willShowAd: AdActionHandler? = nil
    
    // MARK: - IBActions
    @IBAction func onLoad(_ sender: Any) {
        willLoadAd?(sender)
    }
    
    @IBAction func onShow(_ sender: Any) {
        willShowAd?(sender)
    }
    
    // MARK: - Refreshing
    func refresh(loadAdHandler: AdActionHandler? = nil, showAdHandler: AdActionHandler? = nil) {
        willLoadAd = loadAdHandler
        willShowAd = showAdHandler
        
        // Showing an ad is optional. Hide it if there is no show handler.
        showAdButton.isHidden = (showAdHandler == nil)
    }
}

extension AdActionsTableViewCell: TableViewCellRegisterable {
    // MARK: - TableViewCellRegisterable
    static private(set) var reuseId: String = "AdActionsTableViewCell"
}
