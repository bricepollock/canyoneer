//  Created by Brice Pollock for Canyoneer on 12/17/23

import Foundation

protocol CanyonDataManaging {
    /// Get all canyons from index
    func canyons() async -> [CanyonIndex]
    
    /// Get detail canyon information
    func canyon(for id: String) async throws -> Canyon
    
    /// Get a list of detailed canyons
    func canyons(for canyonIdList: [String]) async throws -> [Canyon]
}

protocol CanyonDataUpdating: CanyonDataManaging, CanyonDataWriter {}

actor CanyonDataManager: CanyonDataUpdating {
    internal var previews = [String: CanyonIndex]()
    internal var canyonsCache = [String: Canyon]()
    
    internal var isLoaded: Bool = false
    internal let storage = UserDefaults.standard
    internal let fileManager = FileManager.default
    
    internal let canyonService: CanyonAPIServing
    
    init(canyonService: CanyonAPIServing = CanyonAPIService()) {
        self.canyonService = canyonService
    }
    
    func canyons() async -> [CanyonIndex] {        
        // preference in-memory cache
        let cachedPreviews = Array(previews.values)
        guard cachedPreviews.isEmpty else {
            return cachedPreviews
        }

        // populate from cache
        do {
            let allCanyons = try await loadIndex()
            allCanyons.forEach {
                previews[$0.id] = $0
            }
            return allCanyons
        } catch {
            assertionFailure(error.localizedDescription)
            return []
        }
    }
    
    func preview(for id: String) async throws -> CanyonIndex {
        let preview: CanyonIndex?
        if isLoaded {
            preview = previews[id]
        } else {
            preview = await canyons().filter({ canyon in
                return canyon.id == id
            }).first
        }

        guard let preview else {
            throw GeneralError.notFound
        }
        return preview
    }
    
    func canyon(for id: String) async throws -> Canyon {
        if let cached = canyonFromCache(with: id) {
            return cached
        }
        
        let data = try await loadCanyonFromFile(id: id)
        let canyon = Canyon(data: data)
        updateCanyonCache(with: [canyon])
        return canyon
    }
    
    /// - Warning: Does not guarentee order
    func canyons(for canyonIdList: [String]) async throws -> [Canyon] {
        var uncachedCanyonIDs = [String]()
        var cachedCanyons = [Canyon]()
        
        // First grab any canyons from the cache
        // Hope is if we only moved the map a little most will be found
        canyonIdList.forEach {
            if let cached = canyonFromCache(with: $0) {
                cachedCanyons.append(cached)
            } else {
                uncachedCanyonIDs.append($0)
            }
        }
        
        // Get all canyon topos from disk
        let diskCanyons = try await withThrowingTaskGroup(of: Canyon.self) { group in
            uncachedCanyonIDs.forEach { canyonID in
                _ = group.addTaskUnlessCancelled { [weak self] in
                    guard let self else {
                        throw GeneralError.unknownFailure
                    }
                    do {
                        return try await self.canyon(for: canyonID)
                    } catch {
                        let errorMessage: String = "Failed to get canyon for \(canyonID): \(error)"
                        Global.logger.error("\(errorMessage)")
                        throw error
                    }
                }
            }
            
            var responses = [Canyon]()
            for try await canyon in group {
                responses.append(canyon)
            }
            return responses
        }
        updateCanyonCache(with: diskCanyons)
        return cachedCanyons + diskCanyons
    }
}
