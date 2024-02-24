//  Created by Brice Pollock for Canyoneer on 12/17/23

import Foundation

protocol CanyonDataManaging {
    /// Get all canyons from index
    func canyons() async -> [CanyonIndex]
    
    /// Get detail canyon information
    func canyon(for id: String) async throws -> Canyon
}

protocol CanyonDataUpdating: CanyonDataManaging, CanyonDataWriter {}

actor CanyonDataManager: CanyonDataUpdating {
    internal var previews = [String: CanyonIndex]()
    internal var canyons = [String: Canyon]()
    
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
            return try await loadIndex()
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
        if let cached = canyons[id] {
            return cached
        }
        
        let data = try await loadCanyonFromFile(id: id)
        let canyon = Canyon(data: data)
        canyons[id] = canyon
        return canyon
    }
}
