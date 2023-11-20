//
//  RopeWikiService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import RxSwift
import MapKit

protocol RopeWikiServiceInterface {
    func canyons() -> Single<[Canyon]>
    func canyon(for id: String) -> Single<Canyon?>
}

class RopeWikiService: RopeWikiServiceInterface {
    private let storage = InMemoryStorage.canyons
    
    // while each service entity should be able to act independently, this multi-caching is not supported by Storage
    // Therefore we have to ensure we are not reading mid-writing all these canyons to the storage.
    private static let cacheLock = NSLock()
    
    func canyons() -> Single<[Canyon]> {
        Self.cacheLock.lock()
        
        // preference in-memory cache
        let cachedCanyons = storage.all() as [Canyon]
        guard cachedCanyons.isEmpty else {
            Self.cacheLock.unlock()
            return Single.just(cachedCanyons)
        }

        // update cache
        return loadFromDisk().do(
            onSuccess: { canyons in
                canyons.forEach {
                    self.storage.set(key: $0.id, value: $0)
                }
                Self.cacheLock.unlock()
            }, onError: { error in
                assertionFailure(error.localizedDescription)
            }
        )
    }
    
    func canyon(for id: String) -> Single<Canyon?> {
        return canyons().map { canyons in
            let found = canyons.filter { canyon in
                return canyon.id == id
            }.first
            return found
        }
    }
    
    func loadFromDisk() -> Single<[Canyon]> {
        return Single.create { [weak self] single in
            guard let self else {
                return Disposables.create()
            }
            
            do {
                // We had to split into two files to get around githubs large file limit. We split the DB at "Uranus Canyon" which was more or less halfway.
                let first = try self.loadFromFile(from: "ropewiki_database_pt1")
                let second = try self.loadFromFile(from: "ropewiki_database_pt1")
                let totalList = first + second
                single(.success(totalList))
                return Disposables.create()
            } catch {
                Global.logger.error("Serialization Error: \(String(describing: error))")
                single(.failure(RequestError.serialization))
                return Disposables.create()
            }
        }
    }
    
    func loadFromFile(from fileName: String) throws -> [Canyon] {
        let decoder = JSONDecoder()
        let bundle = Bundle(for: RxUIButton.self)
        
        guard let path = bundle.path(forResource: fileName, ofType: "json") else {
            throw RequestError.serialization
        }

        let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let canyonDataList = try decoder.decode([CanyonDataPoint].self, from: jsonData)
        return canyonDataList.compactMap { data in
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
                technicalDifficulty: data.technicalDifficulty,
                risk: data.risk,
                timeGrade: data.timeRatingString,
                waterDifficulty: data.waterDifficulty,
                quality: data.quality,
                vehicleAccessibility: data.vehicleAccessibility,
                description: data.htmlDescription ?? "",
                geoWaypoints: waypoints,
                geoLines: lines
            )
        }
    }
}
