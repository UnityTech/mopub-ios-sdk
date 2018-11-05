//
//  PrivacyInfoViewController.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class PrivacyInfoViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var buttonToolbar: UIToolbar!
    
    // MARK: - Properties
    
    /**
     Data source for privacy information.
     */
    private let dataSource: PrivacyInfoDataSource = PrivacyInfoDataSource()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the toolbar to have a transparent background
        buttonToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        buttonToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    // MARK: - IBActions
    
    @IBAction func onCloseButtonPressed(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension PrivacyInfoViewController: UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count(section: dataSource.sections[section])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = dataSource.item(atIndexPath: indexPath) else {
            return UITableViewCell()
        }
        
        let section = dataSource.sections[indexPath.section]
        let reuseIdentifier: String = (section == .allowableDataCollection ? "InfoDisplayTableViewCell" : "LongInfoDisplayTableViewCell")
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.value
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.sections[section].rawValue
    }
}

extension PrivacyInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
