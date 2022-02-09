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
    private let network = NetworkService()
    
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
                    let lines = geoFeatures.filter { $0.type == .line }
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
    
    /// - Parameter radius: radius around the coordinate to search in miles
    ///  Example: http://ropewiki.com/api.php?action=ask&format=json&query=%5B%5BCategory%3ACanyons%5D%5D%5B%5BHas%20coordinates%3A%3A%2B%5D%5D%5B%5BCategory%3ACanyons%5D%5D%5B%5BHas%20latitude%3A%3A%3E36.731%5D%5D%5B%5BHas%20longitude%3A%3A%3E-113.083%5D%5D%5B%5BHas%20latitude%3A%3A%3C37.637%5D%5D%5B%5BHas%20longitude%3A%3A%3C-110.675%5D%5D|%3FHas_coordinates|%3FHas_summary|%3FHas_banner_image_file|%3FHas_location_class|%3FHas_KML_file|%3FRequires_permits|%3FHas_info_regions|%3FHas_info_major_region|%3FHas_rank_rating|%3FHas_total_rating|%3FHas_total_counter|%3FHas_info_typical_time|%3FHas_length_of_hike|%3FHas_length|%3FHas_depth|%3FHas_info_rappels|%3FHas_longest_rappel|%3FHas_info|%3FHas_condition_summary|%3FHas_vehicle_type|%3FHas_shuttle_length|%3FHas_best_season_parsed|%3FHas_pageid|limit=100|order=descending,ascending|sort=Has%20rank%20rating,Has%20name|offset=0
    func canyons(at coordinate: Coordinate, with radius: Double = 100) -> Single<[Canyon]>{
        let degrees = radius/8/10
        let upperRightLat = coordinate.latitude + degrees
        let upperRightLong = coordinate.longitude - degrees
        let lowerLeftLat = coordinate.latitude - degrees
        let lowerLeftLong = coordinate.longitude + degrees
        
        let queryParams = "action=ask&format=json&query=[[Category:Canyons]][[Has coordinates::+]][[Category:Canyons]][[Has latitude::>\(lowerLeftLat)]][[Has longitude::>\(upperRightLong)]][[Has latitude::<\(upperRightLat)]][[Has longitude::<\(lowerLeftLong)]]|?Has_coordinates|?Has_summary|?Has_banner_image_file|?Has_location_class|?Has_KML_file|?Requires_permits|?Has_info_regions|?Has_info_major_region|?Has_rank_rating|?Has_total_rating|?Has_total_counter|?Has_info_typical_time|?Has_length_of_hike|?Has_length|?Has_depth|?Has_info_rappels|?Has_longest_rappel|?Has_info|?Has_condition_summary|?Has_vehicle_type|?Has_shuttle_length|?Has_best_season_parsed|?Has_pageid|limit=100|order=descending,ascending|sort=Has rank rating,Has name|offset=0"
        
        
        // Need to escape allowable characters : and + since those are allow characters for URL but need escape in the query for it to work
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.remove(charactersIn: ":+")
        guard let escapedParams = queryParams.addingPercentEncoding(withAllowedCharacters: characterSet) else {

            Global.logger.error("Unable to escape string for map request")
            return Single.error(RequestError.badRequest)
        }
        guard let url = URL(string: "http://ropewiki.com/api.php?" + escapedParams) else {
                    Global.logger.error("Unable to convert string into URL for map request")
                    return Single.error(RequestError.badRequest)
                }
        return self.network.request(url: url).flatMap { response in
            return Single<[Canyon]>.create { single in
                guard let json = response.json else {
                    single(.failure(RequestError.badResponse))
                    return Disposables.create()
                }
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                    let decoder: JSONDecoder = JSONDecoder()
                    let canyonResponse = try decoder.decode(RopewikiLoationResponse.self, from: data)
                    
                    let canyons = canyonResponse.query.results.compactMap { (key, value) -> Canyon? in
                        // each dictionary has a single key and the canyon response
                        
                        let name = key
                        let ropewikiCanyon = value
                        guard let lat = ropewikiCanyon.holder.coordinates.first?.latitude, let long = ropewikiCanyon.holder.coordinates.first?.longitude else {
                            Global.logger.error("Cannot get coordinate for canyon: \(name)")
                            return nil
                        }
                        
                        return Canyon(
                            id: name,
                            bestSeasons: RopewikiParser.parseTimeOfYear(string: ropewikiCanyon.holder.bestSeasons.first?.fulltext ?? ""),
                            coordinate: Coordinate(latitude: lat, longitude: long),
                            isRestricted: nil,
                            maxRapLength: Int(ropewikiCanyon.holder.longestRappel.first?.value ?? 0),
                            name: name,
                            numRaps: Int(ropewikiCanyon.holder.numberRappels.first?.dropLast() ?? ""),
                            requiresShuttle: (ropewikiCanyon.holder.shuttle.first?.value ?? 0) > 0,
                            requiresPermit: RopewikiParser.parseBooleanString(ropewikiCanyon.holder.requiresPermitsRaw.first ?? ""),
                            ropeWikiURL: URL(string: ropewikiCanyon.pageUrlString),
                            technicalDifficulty: nil,
                            risk: nil,
                            timeGrade: nil,
                            waterDifficulty: nil,
                            quality: Float(ropewikiCanyon.holder.quality?.first ?? 0),
                            vehicleAccessibility: Vehicle(rawValue: ropewikiCanyon.holder.vehicleRaw.first ?? ""),
                            description: "",
                            geoWaypoints: [],
                            geoLines: []
                        )
                    }
                    single(.success(canyons))
                } catch (let error) {
                    Global.logger.debug("Failed to deserialize response from route \(url.absoluteString)\n response: \(json)")
                    Global.logger.error(error)
                    single(.failure(error))
                }
                return Disposables.create()
            }
        }.do { canyons in
            Self.cacheLock.lock()
            // the id for the included cache are different than the id for the remote ropewiki canyons
            canyons.forEach {
                self.storage.set(key: $0.id, value: $0)
            }
            Self.cacheLock.unlock()
        }
    }
}
