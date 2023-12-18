//
//  CanyonAPIService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import MapKit

/// See https://github.com/CanyoneerApp/api for API documentation
protocol CanyonAPIServing {
    /// Get all canyons from index
    func canyons() async -> [CanyonIndex]
    
    /// Get detail canyon information
    func canyon(for id: String) async throws -> Canyon
}

actor CanyonAPIService: CanyonAPIServing {
    internal var previews = [String: CanyonIndex]()
    private var canyons = [String: Canyon]()
    
    private var isLoaded: Bool = false
    internal let storage = UserDefaults.standard
    
    func canyons() async -> [CanyonIndex] {
        
        // preference in-memory cache
        let cachedPreviews = Array(previews.values)
        guard cachedPreviews.isEmpty else {
            return cachedPreviews
        }

        // populate from cache
        do {
            return try loadIndex()
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
        
        
        let data = try loadCanyonFromFile(id: id)
        let canyon = Canyon(data: data)
        canyons[id] = canyon
        return canyon
    }
    
    /// Update the cache
    internal func populate(from canyonIndexList: [CanyonIndex]) {
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
}
