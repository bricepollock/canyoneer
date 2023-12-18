//
//  FavoriteService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation

class FavoriteService {
    private let service: CanyonAPIServing
    
    init(service: CanyonAPIServing) {
        self.service = service
    }
    
    /// Does a migration if needed and warms the cache
    /// - Note: Maybe should move the serial loading of canyons into memory to TaskGroup for the service.canyon call, but we warm the cache here so hopefully there is limited latency after the first load.
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
                        return try await service.canyon(for: id)
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
    
    func isFavorite(canyon: Canyon) -> Bool {
        return UserPreferencesStorage.isFavorite(canyon: canyon)
    }
    
    func setFavorite(canyon: Canyon, to isFavorite: Bool) {
        if isFavorite {
            UserPreferencesStorage.addFavorite(canyon: canyon)
        } else {
            UserPreferencesStorage.removeFavorite(canyon: canyon)
        }
    }
    
    private func migrateIfNeeded() async {
        guard UserPreferencesStorage.favoritesNeedMigration else { return }
        let allCanyons = await service.canyons()
        UserPreferencesStorage.migrateFavoritesIfNeeded(given: allCanyons)
    }
}
