//
//  PrivacyMenuDataSource.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit
import MoPub

fileprivate enum PrivacyMenuOptions: String {
    case information = "Information"
    case grantConsent = "Grant Consent"
    case revokeConsent = "Revoke Consent"
    case forceGDPRApplies = "Force GDPR Applicable"
}

class PrivacyMenuDataSource {
    fileprivate let items: [PrivacyMenuOptions] = [.information, .grantConsent, .revokeConsent, .forceGDPRApplies]
}

extension PrivacyMenuDataSource: MenuDisplayable {
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
        return "Privacy"
    }
    
    /**
     Provides the rendered cell for the menu item
     - Parameter index: Menu item index assumed to be in bounds
     - Parameter tableView: `UITableView` that will render the cell
     - Returns: A configured `UITableViewCell`
     */
    func cell(forItem index: Int, inTableView tableView: UITableView) -> UITableViewCell {
        let cell: BasicMenuTableViewCell = basicMenuCell(inTableView: tableView)
        let item: PrivacyMenuOptions = items[index]
        
        cell.accessoryType = (item == .information ? .disclosureIndicator : .none)
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
        switch items[index] {
        case .information:
            guard let privacyInfoViewController: PrivacyInfoViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PrivacyInfoViewController") as? PrivacyInfoViewController else {
                break
            }
            
            viewController.present(privacyInfoViewController, animated: true, completion: nil)
            break
        case .grantConsent:
            MoPub.sharedInstance().grantConsent()
            break
        case .revokeConsent:
            MoPub.sharedInstance().revokeConsent()
            break
        case .forceGDPRApplies:
            MoPub.sharedInstance().forceGDPRApplicable()
            break;
        }
    }
}
