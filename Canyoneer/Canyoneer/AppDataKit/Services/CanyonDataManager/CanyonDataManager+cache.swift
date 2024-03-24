//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation

extension CanyonDataManager {   
    fileprivate static let databaseCanyonCacheLimit = 100
    
    /// Update the cache
    internal func populate(from canyonIndexList: [CanyonIndex]) {
        self.previews = [:]
        canyonIndexList.filter {
            // Don't show closed canyons
            !$0.isClosed
        }.forEach {
            // Populate cache
            self.previews[$0.id] = $0
        }
        isLoaded = true
        Global.logger.debug("Loaded \(canyonIndexList.count) canyons into memory")
    }
    
    func canyonFromCache(with id: String) -> Canyon? {
        canyonsCache[id]
    }
    
    /// Maintain a cache of  no more than `databaseCanyonCacheLimit` canyons to limit memory overhead
    func updateCanyonCache(with canyonsToCache: [Canyon]) {
        let canyonsToCache = canyonsToCache.prefix(Self.databaseCanyonCacheLimit)
        let existingCachedCanyons = canyonsCache.values
        
        let newCacheCount = existingCachedCanyons.count + canyonsToCache.count
        guard newCacheCount < Self.databaseCanyonCacheLimit else {
            let remainingCapacity = Self.databaseCanyonCacheLimit - canyonsToCache.count
            let purgedCacheCanyons = canyonsToCache + existingCachedCanyons.prefix(remainingCapacity)
            canyonsCache = [:]
            canyonsToCache.forEach {
                canyonsCache[$0.id] = $0
            }
            return
        }
        
        canyonsToCache.forEach {
            canyonsCache[$0.id] = $0
        }
    }
}
