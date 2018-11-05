//
//  TableViewCellRegisterable.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

/**
 Provides a standard way of registering a `UITableViewCell` with associated
 Nib with a `UITableView`.
 */
protocol TableViewCellRegisterable {
    /**
     Constant representing a default reuseable table cell ID.
     */
    static var reuseId: String { get }
    
    /**
     Registers this table cell with a given table using the `reuseId` constant.
     - Parameter tableView: A valid table to register this cell.
     */
    static func register(with tableView: UITableView) -> Void
}

extension TableViewCellRegisterable {
    static func register(with tableView: UITableView) -> Void {
        let nib = UINib(nibName: reuseId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseId)
    }
}
