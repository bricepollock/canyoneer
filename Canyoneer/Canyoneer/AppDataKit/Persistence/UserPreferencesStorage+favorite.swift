//
//  Storage+user.swift
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

extension UserPreferencesStorage {
    fileprivate static let favoriteListKey = "canyon_favorite_list"
    public static let favorites = UserPreferencesStorage()
    
    static var favoritesNeedMigration: Bool {
        let legacyList = ((favorites.get(key: favoriteListKey) as [LegacyCanyon]?) ?? [])
        return legacyList.isEmpty == false
    }
    
    /// Migrate from prior mechanism of saving the whole canyon with a custom ID to saving only the ID of favorited canyons with the server (i.e. rope wiki) id
    static func migrateFavoritesIfNeeded(given allCanyons: [CanyonIndex]) {
        let legacyList = ((favorites.get(key: favoriteListKey) as [LegacyCanyon]?) ?? [])
        
        // If legacy exists, perform migration
        guard legacyList.isEmpty == false else {
            Global.logger.debug("No favorite migration needed")
            return
        }
                
        var legacyIDMap = [String: CanyonIndex]()
        allCanyons.forEach {
            let legacyID = "\($0.name)_\($0.coordinate.latitude)_\($0.coordinate.longitude)"
            legacyIDMap[legacyID] = $0
        }
        
        let migratedFavorites = legacyList.compactMap {
            let found = legacyIDMap[$0.id]
            if found == nil {
                Global.logger.error("Unable to find matching canyon for legacy canyon favorite: \($0.id)")
            }
            return found
        }
        
        // Overwrite legacy to adopt new type for key
        favorites.set(key: favoriteListKey, value: migratedFavorites.map { $0.id })
    }
    
    static var allFavoriteIDs: [String] {
        guard let list = favorites.get(key: favoriteListKey) as [String]? else {
            Global.logger.error("Unable to get favorites, either first load or they are in invalid format and need migration")
            return []
        }
        return list
    }
    
    static func isFavorite(canyon: Canyon) -> Bool {
        return allFavoriteIDs.firstIndex(where: { id in
            return id == canyon.id
        }) != nil
    }

    static func addFavorite(canyon: Canyon) {
        var list = allFavoriteIDs
        list.append(canyon.id)
        favorites.set(key: favoriteListKey, value: list)
    }
    
    static func removeFavorite(canyon: Canyon) {
        var list = allFavoriteIDs
        guard let index = list.firstIndex(where: { id in
            return id == canyon.id
        }) else {
            Global.logger.error("Cannot find canyon to remove for \(canyon.name)")
            return
        }
        list.remove(at: index)
        favorites.set(key: favoriteListKey, value: list)
    }
    
    static func clearFavorites() {
        let overwrite: [String] = []
        favorites.set(key: favoriteListKey, value: overwrite)
    }
}
