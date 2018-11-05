//
//  SavedAdsManager.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

class SavedAdsManager {

    static let savedAdsKey = "com.mopub.adunitids"

    static let sharedInstance = SavedAdsManager()

    private var savedAds: [AdUnit] = Array()

    // If a new Ad is added or removed from savedAdsManager, isDirty will be marked as true, which means
    // persistent storage (UserDefault) and memory data (stored in savedAds array) have inconsistent data.
    // To get updated saved ads, caller needs to invoke method loadSavedAds() again.
    var isDirty: Bool

    private init() {
        isDirty = false
    }

    func addSavedAd(adUnit: AdUnit) {
        removeSavedAd(adUnit: adUnit)
        savedAds.append(adUnit)
        persistSavedAds()
        isDirty = true
    }

    func loadSavedAds() -> [AdUnit] {
        savedAds = [] 
        guard let encodedSavedAdsData = UserDefaults.standard.object(forKey: SavedAdsManager.savedAdsKey) as? Data else {
            return []
        }

        guard let savedAdsFromPersistentStore: [AdUnit] = try? JSONDecoder().decode(Array.self, from: encodedSavedAdsData) else {
            return []
        }
        savedAds += savedAdsFromPersistentStore
        isDirty = false
        return savedAds
    }

    func removeSavedAd(adUnit: AdUnit) {
        if let targetAdUnit = savedAdForId(adId: adUnit.id) {
            if let index = savedAds.index(of:targetAdUnit) {
                savedAds.remove(at: index)
            }
            isDirty = true
        }
    }

    private func persistSavedAds() {
        let jsonEncoder = JSONEncoder()
        let persistData = try? jsonEncoder.encode(savedAds)
        let defaults = UserDefaults.standard
        defaults.set(persistData, forKey: SavedAdsManager.savedAdsKey)
        defaults.synchronize()
    }

    private func savedAdForId(adId: String) -> AdUnit? {
        var savedAd: AdUnit?
        for ad in savedAds {
            if ad.id == adId {
                savedAd = ad
                break
            }
        }
        return savedAd
    }
}
