//
//  AdUnitTableViewCell.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

/**
 Cell for displaying ad unit information.
 */
class AdUnitTableViewCell: UITableViewCell {
    // Outlets from `AdUnitTableViewCell.xib`
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var adUnitId: UILabel!
    
    /**
     Updates the contents of the cell with the new ad unit.
     - Parameter adUnit: Ad unit information to use for display.
     */
    func refresh(adUnit: AdUnit) -> Void {
        name.text = adUnit.name
        adUnitId.text = adUnit.id
    }
}

extension AdUnitTableViewCell: TableViewCellRegisterable {
    // MARK: - TableViewCellRegisterable
    static private(set) var reuseId: String = "AdUnitTableViewCell"
}
