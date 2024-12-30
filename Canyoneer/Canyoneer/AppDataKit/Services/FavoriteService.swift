//
//  FavoriteService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import Combine

protocol FavoriteServing {
    /// Does a migration if needed and warms the cache
    /// - Note: Maybe should move the serial loading of canyons into memory to TaskGroup for the service.canyon call, but we warm the cache here so hopefully there is limited latency after the first load.
    func start() async
        
    func allFavorites() async -> [Canyon]
    
    func isFavorite(canyon: FavoritableCanyon) -> Bool
    func setFavorite(canyon: CanyonIndex, to isFavorite: Bool)
    
    /// Observe changes to favorites while app is foreground
    var favoriteStatusDidChange: PassthroughSubject<(canyon: CanyonIndex, isFavorite: Bool), Never> { get }
}

class FavoriteService: FavoriteServing {
    public let favoriteStatusDidChange: PassthroughSubject<(canyon: CanyonIndex, isFavorite: Bool), Never>
    private let canyonManager: CanyonDataManaging
    
    init(canyonManager: CanyonDataManaging) {
        self.canyonManager = canyonManager
        self.favoriteStatusDidChange = PassthroughSubject()
    }
    
    func start() async {
        await migrateIfNeeded()
        _ = await allFavorites()
    }
    
    func allFavorites() async -> [Canyon] {
        return await withTaskGroup(of: Canyon?.self, returning: [Canyon].self) { group in
            UserPreferencesStorage.allFavoriteIDs.forEach { id in
                _ = group.addTaskUnlessCancelled { [weak self] in
                    guard let self else { return nil }
                    do {
                        return try await canyonManager.canyon(for: id)
                    } catch {
                        Global.logger.error("Could not find favorite for: \(id)")
                        return nil
                    }
                }
            }
            
            var canyons = [Canyon]()
            for await taskCanyon in group {
                guard let taskCanyon else { continue }
                canyons.append(taskCanyon)
            }
            return canyons
        }
    }
    
    func isFavorite(canyon: FavoritableCanyon) -> Bool {
        return UserPreferencesStorage.isFavorite(canyon: canyon)
    }
    
    func setFavorite(canyon: CanyonIndex, to isFavorite: Bool) {
        if isFavorite {
            UserPreferencesStorage.addFavorite(canyon: canyon)
        } else {
            UserPreferencesStorage.removeFavorite(canyon: canyon)
        }
        favoriteStatusDidChange.send((canyon: canyon, isFavorite: isFavorite))
    }
    
    private func migrateIfNeeded() async {
        guard UserPreferencesStorage.favoritesNeedMigration else { return }
        let allCanyons = await canyonManager.canyons()
        UserPreferencesStorage.migrateFavoritesIfNeeded(given: allCanyons)
    }
}
