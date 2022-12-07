//
//  Storage+user.swift
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

extension UserPreferencesStorage {
    
    fileprivate static let favoriteListKey = "canyon_favorite_list"
    public static let favorites = UserPreferencesStorage()
    
    static var allFavorites: [Canyon] {
        let list = Self.favorites.get(key: Self.favoriteListKey) as [Canyon]?
        return list ?? []
    }
    
    static func isFavorite(canyon: Canyon) -> Bool {
        return Self.allFavorites.firstIndex(where: { listCanyon in
            return listCanyon.id == canyon.id
        }) != nil
    }

    static func addFavorite(canyon: Canyon) {
        var list = self.allFavorites
        list.append(canyon)
        Self.favorites.set(key: Self.favoriteListKey, value: list)
    }
    
    static func removeFavorite(canyon: Canyon) {
        var list = self.allFavorites
        guard let index = list.firstIndex(where: { listCanyon in
            return listCanyon.id == canyon.id
        }) else {
            Global.logger.error("Cannot find canyon to remove for \(canyon.name)")
            return
        }
        list.remove(at: index)
        Self.favorites.set(key: Self.favoriteListKey, value: list)
    }
    
    static func clearFavorites() {
        Self.favorites.set(key: Self.favoriteListKey, value: [Canyon]())
    }
}
