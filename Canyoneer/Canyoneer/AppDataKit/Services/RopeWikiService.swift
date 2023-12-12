//
//  RopeWikiService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import MapKit

/// See https://github.com/CanyoneerApp/api for API documentation
protocol RopeWikiServiceInterface {
    /// Get all canyons from index
    func canyons() async -> [CanyonIndex]
    
    /// Get detail canyon information
    func canyon(for id: String) async throws -> Canyon
}

actor RopeWikiService: RopeWikiServiceInterface {
    private var previews = [String: CanyonIndex]()
    private var canyons = [String: Canyon]()
    
    private var isLoaded: Bool = false
    
    func canyons() async -> [CanyonIndex] {
        
        // preference in-memory cache
        let cachedPreviews = Array(previews.values)
        guard cachedPreviews.isEmpty else {
            return cachedPreviews
        }

        // update cache
        do {
            let index = try loadIndex()
            
            
            index.filter {
                // Don't show closed canyons
                !$0.isClosed
            }.forEach {
                // Populate cache
                self.previews[$0.id] = $0
            }
            isLoaded = true
            Global.logger.debug("Loaded \(index.count) canyons into memory")
            return index
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
        
        
        let data = try loadCanyonFromFile(from: id)
        let canyon = Canyon(data: data)
        canyons[id] = canyon
        return canyon
    }
    
    internal func loadIndex() throws -> [CanyonIndex] {
        do {
            return try self.loadIndexFromFile().map {
                CanyonIndex(data: $0)
            }
        } catch {
            Global.logger.error("Serialization Error: \(String(describing: error))")
            throw RequestError.serialization
        }
    }
    
    internal func loadIndexFromFile() throws -> [RopeWikiCanyonIndex] {
        let decoder = JSONDecoder()
        let bundle = Bundle(for: RopeWikiService.self)
        
        guard let path = bundle.path(forResource: "index", ofType: "json") else {
            Global.logger.error("Failed to find index file!")
            throw RequestError.serialization
        }

        let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        return try decoder.decode([RopeWikiCanyonIndex].self, from: jsonData)
    }
    
    internal func loadCanyonFromFile(from fileName: String) throws -> RopeWikiCanyon {
        let decoder = JSONDecoder()
        let bundle = Bundle(for: RopeWikiService.self)
        
        guard let path = bundle.path(forResource: fileName, ofType: "json", inDirectory: "CanyonDetails") else {
            Global.logger.error("Failed to find canyon details directory")
            throw RequestError.serialization
        }

        let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        return try decoder.decode(RopeWikiCanyon.self, from: jsonData)
    }
}
