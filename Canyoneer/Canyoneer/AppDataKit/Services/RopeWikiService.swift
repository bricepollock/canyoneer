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
        return loadFromFile().do { canyons in
            canyons.forEach {
                self.storage.set(key: $0.id, value: $0)
            }
            Self.cacheLock.unlock()
        }
    }
    
    func canyon(for id: String) -> Single<Canyon?> {
        return canyons().map { canyons in
            let found = canyons.filter { canyon in
                return canyon.id == id
            }.first
            return found
        }
    }
    
    func regions() -> [Region] {
        return []
    }
    
    func loadFromFile() -> Single<[Canyon]> {
        let decoder = JSONDecoder()
        let fileName = "ropewiki_database"
        let bundle = Bundle(for: RxUIButton.self)
        
        return Single.create { single in
            do {
                guard let path = bundle.path(forResource: fileName, ofType: "json") else {
                    throw RequestError.serialization
                }

                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let canyonDataList = try decoder.decode([CanyonDataPoint].self, from: jsonData)
                let canyons: [Canyon] = canyonDataList.compactMap { data in
                    guard let latitude = data.latitude, let longitude = data.longitude else {
                        return nil
                    }
                    let features = data.geoJson?.features.map({ $0.geometry }) ?? []
                    let waypoints = features.filter { $0.type == .waypoint }.map { $0.coordinates }.first ?? []
                    let lines = features.filter { $0.type == .line }.map { $0.coordinates }
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
                single(.success(canyons))
                return Disposables.create()
            } catch {
                Global.logger.error("Serialization Error: \(String(describing: error))")
                single(.failure(RequestError.serialization))
                return Disposables.create()
            }
        }
    }
}
