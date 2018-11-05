//
//  AdUnitTableViewController.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class AdUnitTableViewController: UIViewController {
    // Outlets from `Main.storyboard`
    @IBOutlet weak var tableView: UITableView!
    
    // Table data source.
    fileprivate var dataSource: AdUnitDataSource? = nil
    
    // MARK: - Initialization
    
    /**
     Initializes the view controller's data source. This must be performed before
     `viewDidLoad()` is called.
     - Parameter dataSource: Data source for the view controller.
     */
    func initialize(with dataSource: AdUnitDataSource) {
        self.dataSource = dataSource
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register reusable table cells and delegates
        AdUnitTableViewCell.register(with: tableView)
        AdUnitTableViewHeader.register(with: tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Ad Loading
    
    public func loadAd(with adUnit: AdUnit) {
        guard let vcClass = NSClassFromString(adUnit.viewControllerClassName) as? AdViewController.Type,
            let destination: UIViewController = vcClass.instantiateFromNib(adUnit: adUnit) as? UIViewController else {
            return
        }
        
        splitViewController?.showDetailViewController(destination, sender: self)
    }
    
    /**
     Reloads the data source's data and refreshes the table view with the updated
     contents.
     */
    public func reloadData() {
        dataSource?.reloadData()
        tableView.reloadData()
    }
}

extension AdUnitTableViewController: UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.items(for: section)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let adUnitCell: AdUnitTableViewCell = tableView.dequeueReusableCell(withIdentifier: AdUnitTableViewCell.reuseId, for: indexPath) as? AdUnitTableViewCell,
            let adUnit: AdUnit = dataSource?.item(at: indexPath) else {
            return UITableViewCell()
        }
        
        adUnitCell.refresh(adUnit: adUnit)
        adUnitCell.setNeedsLayout()
        return adUnitCell
    }
}

extension AdUnitTableViewController: UITableViewDelegate {
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let adUnit: AdUnit = dataSource?.item(at: indexPath) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        loadAd(with: adUnit)
        
        // Unselect the row.
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header: AdUnitTableViewHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: AdUnitTableViewHeader.reuseId) as? AdUnitTableViewHeader,
            let title = dataSource?.sections[section] else {
            return nil
        }
        
        header.refresh(title: title)
        return header
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}
