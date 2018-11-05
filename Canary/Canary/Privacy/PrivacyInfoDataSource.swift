//
//  PrivacyInfoDataSource.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
import MoPub

/**
 Privacy information section
 */
enum PrivacyInfoSection: String {
    case allowableDataCollection = "Allowable Data Collection"
    case consented = "Consented Versions"
    case current = "Current Versions"
}

/**
 Consent and privacy related keys associated with human readable strings.
 The key is named after the property that is being read for the value.
 */
fileprivate enum PrivacyInfo: String {
    case canCollectPersonalInfo  = "Can Collect PII?"
    case currentConsentStatus    = "Consent Status"
    case isGDPRApplicable        = "Is GDPR Applicable?"
    case shouldShowConsentDialog = "Should Show Consent Dialog?"
    case isWhitelisted           = "Is Whitelisted?"
    
    case currentConsentPrivacyPolicyUrl     = "Current Privacy Policy Url"
    case currentConsentVendorListUrl        = "Current Vendor List Url"
    case currentConsentIabVendorListFormat  = "Current IAB Vendor List Format"
    case currentConsentPrivacyPolicyVersion = "Current Privacy Policy Version"
    case currentConsentVendorListVersion    = "Current Vendor List Version"
    
    case previouslyConsentedIabVendorListFormat  = "Consented IAB Vendor List Format"
    case previouslyConsentedPrivacyPolicyVersion = "Consented Privacy Policy Version"
    case previouslyConsentedVendorListVersion    = "Consented Vendor List Version"
}

class PrivacyInfoDataSource {
    /**
     Section ordering
     */
    let sections: [PrivacyInfoSection] = [.allowableDataCollection, .current, .consented]
    
    /**
     Internal dictionary of arrays containing the data mappings.
     */
    fileprivate let dataSource: [PrivacyInfoSection: [PrivacyInfo]]
    
    // MARK: - Initialization
    
    init() {
        // Initialize the data source
        dataSource = [
            .allowableDataCollection: [.isGDPRApplicable,
                                       .currentConsentStatus,
                                       .canCollectPersonalInfo,
                                       .shouldShowConsentDialog,
                                       .isWhitelisted],
            .consented: [.previouslyConsentedVendorListVersion,
                         .previouslyConsentedPrivacyPolicyVersion,
                         .previouslyConsentedIabVendorListFormat],
            .current: [.currentConsentVendorListUrl,
                       .currentConsentVendorListVersion,
                       .currentConsentPrivacyPolicyUrl,
                       .currentConsentPrivacyPolicyVersion,
                       .currentConsentIabVendorListFormat]
        ]
    }
    
    // MARK: - Data Retrieval
    
    /**
     Number of items for the section
     - Parameter section: Section to query
     - Returns: Number of items in the section; otherwise `0`
     */
    func count(section: PrivacyInfoSection) -> Int {
        return dataSource[section]?.count ?? 0
    }
    
    /**
     Retrieves the name-value item pair for the given index path.
     - Parameter indexPath: Index path corresponding to the section and position within the section of the
     item to retrieve.
     - Returns: A name-value tuple if successful; `nil` otherwise.
     */
    func item(atIndexPath indexPath: IndexPath) -> (name: String, value: String)? {
        guard let infoItem: PrivacyInfo = dataSource[sections[indexPath.section]]?[indexPath.row] else {
            return nil
        }
        
        let value: String = valueForKey(infoItem)
        return (name: infoItem.rawValue, value: value)
    }
    
    /**
     Retrieves the current value for the given key.
     - Parameter key: Privacy info key
     - Returns: The value as a `String`.
     */
    fileprivate func valueForKey(_ key: PrivacyInfo) -> String {
        let mopub = MoPub.sharedInstance()
        
        switch key {
        case .canCollectPersonalInfo: return String(mopub.canCollectPersonalInfo)
        case .currentConsentIabVendorListFormat: return mopub.currentConsentIabVendorListFormat ?? ""
        case .currentConsentPrivacyPolicyUrl: return mopub.currentConsentPrivacyPolicyUrl()?.absoluteString ?? ""
        case .currentConsentPrivacyPolicyVersion: return mopub.currentConsentPrivacyPolicyVersion ?? ""
        case .currentConsentStatus: return mopub.currentConsentStatus.description
        case .currentConsentVendorListUrl: return mopub.currentConsentVendorListUrl()?.absoluteString ?? ""
        case .currentConsentVendorListVersion: return mopub.currentConsentVendorListVersion ?? ""
        case .isGDPRApplicable: return mopub.isGDPRApplicable.description
        case .previouslyConsentedIabVendorListFormat: return mopub.previouslyConsentedIabVendorListFormat ?? ""
        case .previouslyConsentedPrivacyPolicyVersion: return mopub.previouslyConsentedPrivacyPolicyVersion ?? ""
        case .previouslyConsentedVendorListVersion: return mopub.previouslyConsentedVendorListVersion ?? ""
        case .shouldShowConsentDialog: return String(mopub.shouldShowConsentDialog)
        case .isWhitelisted: return String(MPConsentManager.shared().isWhitelisted)
        }
    }
}

