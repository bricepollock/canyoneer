//
//  Storage+user.swift
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

extension UserPreferencesStorage {
    fileprivate static let favoriteListKey = "canyon_favorite_list"
    public static let favorites = UserPreferencesStorage()
    
    static var allFavorites: [Canyon] {
        // Get legacy if exists
        let pastList = ((favorites.get(key: favoriteListKey) as [LegacyCanyon]?) ?? []).map { Canyon(legacy: $0) }
        
        // Get current
        let currentList = ((favorites.get(key: favoriteListKey) as [RopeWikiCanyon]?) ?? []).map { Canyon(data: $0) }
        
        // Merge (probably one or the other but never a merge)
        let merge = pastList + currentList
        
        // Overwrite legacy to adopt new file-type for key if needed
        if pastList.isEmpty == false {
            favorites.set(key: favoriteListKey, value: merge.map { $0.asCodable })
        }
        return merge
    }
    
    static func isFavorite(canyon: Canyon) -> Bool {
        return allFavorites.firstIndex(where: { listCanyon in
            return listCanyon.id == canyon.id
        }) != nil
    }

    static func addFavorite(canyon: Canyon) {
        var list = allFavorites
        list.append(canyon)
        
        let dataList: [RopeWikiCanyon] = list.map { $0.asCodable }
        favorites.set(key: favoriteListKey, value: dataList)
    }
    
    static func removeFavorite(canyon: Canyon) {
        var list = allFavorites
        guard let index = list.firstIndex(where: { listCanyon in
            return listCanyon.id == canyon.id
        }) else {
            Global.logger.error("Cannot find canyon to remove for \(canyon.name)")
            return
        }
        list.remove(at: index)
        
        let dataList: [RopeWikiCanyon] = list.map { $0.asCodable }
        favorites.set(key: favoriteListKey, value: dataList)
    }
    
    static func clearFavorites() {
        let overwrite: [RopeWikiCanyon] = []
        favorites.set(key: favoriteListKey, value: overwrite)
    }
}
