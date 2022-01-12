//
//  RopeWikiService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import RxSwift
import MapKit

class RopeWikiService {
    private var cachedCanyons: [Canyon] = []
    
    func canyons() -> Single<[Canyon]> {
        // preference in-memory cache
        guard cachedCanyons.isEmpty else {
            return Single.just(cachedCanyons)
        }

        // update cache
        return loadFromFile().do { canyons in
            self.cachedCanyons = canyons
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
                        timeGrade: data.timeRatingString,
                        waterDifficulty: data.waterDifficulty,
                        quality: data.quality,
                        vehicleAccessibility: data.vehicleAccessibility
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
//
//    private func canyons(with regions: [Region]) -> [Canyon] {
//        return regions.flatMap { region in
//            return self.canyons(for: region)
//        }
//    }
//
//    private func canyons(for region: Region) -> [Canyon] {
//        guard region.canyons.isEmpty else {
//            return region.canyons
//        }
//        return self.canyons(with: region.children)
//    }
}
