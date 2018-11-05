//
//  MenuDisplayable.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

protocol MenuDisplayable {
    /**
     Number of menu items available
     */
    var count: Int { get }
    
    /**
     Human-readable title for the menu grouping
     */
    var title: String { get }
    
    /**
     Provides the rendered cell for the menu item
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that will render the cell
     - Returns: A configured `UITableViewCell`
     */
    func cell(forItem index: Int, inTableView tableView: UITableView) -> UITableViewCell
    
    /**
     Query if the menu item is selectable
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that rendered the item
     - Returns: `true` if selectable; `false` otherwise
     */
    func canSelect(itemAt index: Int, inTableView tableView: UITableView) -> Bool
    
    /**
     Performs an optional selection action for the menu item
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that rendered the item
     - Parameter viewController: Presenting view controller
     */
    func didSelect(itemAt index: Int, inTableView tableView: UITableView, presentFrom viewController: UIViewController) -> Swift.Void
    
    // MARK: - Menu Cells
    
    /**
     Provides a reusable basic menu cell that can be further customized.
     - Parameter tableView: `UITableView` to retrieve the cell from
     - Returns: A `BasicMenuTableViewCell`
     */
    func basicMenuCell(inTableView tableView: UITableView) -> BasicMenuTableViewCell
}

extension MenuDisplayable {
    // MARK: - Default implementations
    func canSelect(itemAt index: Int, inTableView tableView: UITableView) -> Bool {
        return false
    }
    
    func didSelect(itemAt index: Int, inTableView tableView: UITableView, presentFrom viewController: UIViewController) -> Swift.Void {
        return
    }
    
    func basicMenuCell(inTableView tableView: UITableView) -> BasicMenuTableViewCell {
        let basicCellReuseIdentifier: String = "BasicMenuTableViewCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: basicCellReuseIdentifier) as? BasicMenuTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: basicCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: basicCellReuseIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: basicCellReuseIdentifier) as? BasicMenuTableViewCell
        }
        
        return cell!
    }
}
