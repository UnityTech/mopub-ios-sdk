//
//  LogingLevelMenuDataSource.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import MoPub

fileprivate enum LoggingLevelMenuOptions: String {
    case all = "All"
    case trace = "Trace"
    case debug = "Debug"
    case info = "Informational"
    case warn = "Warnings"
    case error = "Errors"
    case fatal = "Fatal"
    case off = "Off"
    
    var logLevel: MPLogLevel {
        switch self {
        case .all: return MPLogLevelAll
        case .trace: return MPLogLevelTrace
        case .debug: return MPLogLevelDebug
        case .info: return MPLogLevelInfo
        case .warn: return MPLogLevelWarn
        case .error: return MPLogLevelError
        case .fatal: return MPLogLevelFatal
        case .off: return MPLogLevelOff
        }
    }
}

class LogingLevelMenuDataSource {
    fileprivate let items: [LoggingLevelMenuOptions] = [.all, .trace, .debug, .info, .warn, .error, .fatal, .off]
}

extension LogingLevelMenuDataSource: MenuDisplayable {
    /**
     Number of menu items available
     */
    var count: Int {
        return items.count
    }
    
    /**
     Human-readable title for the menu grouping
     */
    var title: String {
        return "Console Log Level"
    }
    
    /**
     Provides the rendered cell for the menu item
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that will render the cell
     - Returns: A configured `UITableViewCell`
     */
    func cell(forItem index: Int, inTableView tableView: UITableView) -> UITableViewCell {
        let cell: BasicMenuTableViewCell = basicMenuCell(inTableView: tableView)
        let item: LoggingLevelMenuOptions = items[index]
        let currentLogLevel: MPLogLevel = MoPub.sharedInstance().logLevel
        
        cell.accessoryType = (currentLogLevel == item.logLevel ? .checkmark : .none)
        cell.title.text = item.rawValue
        
        return cell
    }
    
    /**
     Query if the menu item is selectable
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that rendered the item
     - Returns: `true` if selectable; `false` otherwise
     */
    func canSelect(itemAt index: Int, inTableView tableView: UITableView) -> Bool {
        return true
    }
    
    /**
     Performs an optional selection action for the menu item
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that rendered the item
     - Parameter viewController: Presenting view controller
     */
    func didSelect(itemAt index: Int, inTableView tableView: UITableView, presentFrom viewController: UIViewController) -> Swift.Void {
        let item: LoggingLevelMenuOptions = items[index]
        MoPub.sharedInstance().logLevel = item.logLevel
        
        tableView.reloadData()
    }
}
