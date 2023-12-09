//
//  RopeWikiService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import MapKit

protocol RopeWikiServiceInterface {
    func canyons() async -> [Canyon]
    func canyon(for id: String) async throws -> Canyon
}

actor RopeWikiService: RopeWikiServiceInterface {
    private let storage = InMemoryStorage.canyons
    
    func canyons() async -> [Canyon] {
        
        // preference in-memory cache
        let cachedCanyons = storage.all() as [Canyon]
        guard cachedCanyons.isEmpty else {
            return cachedCanyons
        }

        // update cache
        do {
            let canyons = try loadFromDisk()
            
            // Populate cache
            canyons.forEach {
                self.storage.set(key: $0.id, value: $0)
            }
            Global.logger.debug("Loaded \(canyons.count) canyons into memory")
            return canyons
        } catch {
            assertionFailure(error.localizedDescription)
            return []
        }
    }
    
    func canyon(for id: String) async throws -> Canyon {
        guard let found = await canyons().filter({ canyon in
            return canyon.id == id
        }).first else {
            throw GeneralError.notFound
        }
        return found
    }
    
    func loadFromDisk() throws -> [Canyon] {
        do {
            // We had to split into two files to get around githubs large file limit. We split the DB at "Uranus Canyon" which was more or less halfway.
            let first = try self.loadFromFile(from: "ropewiki_database_pt1")
            let second = try self.loadFromFile(from: "ropewiki_database_pt2")
            return  first + second
        } catch {
            Global.logger.error("Serialization Error: \(String(describing: error))")
            throw RequestError.serialization
        }
    }
    
    func loadFromFile(from fileName: String) throws -> [Canyon] {
        let decoder = JSONDecoder()
        let bundle = Bundle(for: RopeWikiService.self)
        
        guard let path = bundle.path(forResource: fileName, ofType: "json") else {
            throw RequestError.serialization
        }

        let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let canyonDataList = try decoder.decode([CanyonDataPoint].self, from: jsonData)
        return canyonDataList.compactMap { data -> Canyon? in
            guard let latitude = data.latitude, let longitude = data.longitude else {
                return nil
            }
            // We are just not going to show closed canyons
            guard !data.isClosed else { return nil }
            
            let features = data.geoJson?.features ?? []
            let geoFeatures: [CoordinateFeature] = features.compactMap {
                return CoordinateFeature(
                    name: $0.properties.name,
                    type: $0.geometry.type,
                    hexColor: $0.properties.color,
                    coordinates: $0.geometry.coordinates
                )
            }
            let waypoints = geoFeatures.filter { $0.type == .waypoint }
            let lines = GPXService.simplify(features: geoFeatures.filter { $0.type == .line })
            return Canyon(
                id: "\(data.name)_\(latitude)_\(longitude)",
                bestSeasons: data.bestSeasons,
                coordinate: Coordinate(latitude: latitude, longitude: longitude),
                
                isRestricted: data.isRestricted,
                maxRapLength: data.rappelMaxLength,
                name: data.name,
                numRaps: data.numRappels,
                requiresShuttle: data.requiresShuttle,
                requiresPermit: data.requiresPermits,
                ropeWikiURL: URL(string: data.urlString),
                technicalDifficulty: TechnicalGrade(data: data.technicalDifficulty),
                risk: data.risk,
                timeGrade: TimeGrade(data: data.timeRatingString),
                waterDifficulty: WaterGrade(data: data.waterDifficulty),
                quality: data.quality,
                vehicleAccessibility: data.vehicleAccessibility,
                description: data.htmlDescription ?? "",
                geoWaypoints: waypoints,
                geoLines: lines
            )
        }
    }
}
