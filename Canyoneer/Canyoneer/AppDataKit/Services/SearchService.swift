//
//  SearchService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import CoreLocation

protocol SearchServiceInterface {
    init(canyonManager: CanyonDataManaging)
    func requestSearch(for searchString: String) async -> QueryResultList
    func nearMeSearch(limit: Int) async throws -> QueryResultList
}

struct SearchService: SearchServiceInterface {
    private static let maxQueryResults = 100
    
    private let canyonManager: CanyonDataManaging
    private let locationService = LocationService()
    
    init(canyonManager: CanyonDataManaging) {
        self.canyonManager = canyonManager
    }
    
    func requestSearch(for searchString: String) async -> QueryResultList {
        let canyons = await self.canyonManager.canyons()
        let results = canyons.filter { canyon in
            return canyon.name.lowercased().contains(searchString.lowercased())
        }.sorted(by: { lhs, rhs in
            return lhs.quality > rhs.quality
        })
        .prefix(Self.maxQueryResults)
        .map { canyon in
            QueryResult(name: canyon.name, canyonDetails: canyon)
        }
        
        return QueryResultList(searchString: searchString, results: results)
    }
    
    func nearMeSearch(limit: Int) async throws -> QueryResultList {
        guard locationService.isLocationEnabled() else {
            throw RequestError.badRequest
        }
        
        let canyons = await canyonManager.canyons()
        let currentLocation = try await locationService.getCurrentLocation()
            
        let results = canyons.sorted { lhs, rhs in
            let lhsDistance = lhs.coordinate.distance(to: currentLocation)
            let rhsDistance = rhs.coordinate.distance(to: currentLocation)
            return lhsDistance < rhsDistance
        }
        .prefix(limit)
        .sorted(by: { lhs, rhs in
            return lhs.quality > rhs.quality
        })
        .map { canyon in
            return QueryResult(name: canyon.name, canyonDetails: canyon)
        }
        
        
        return QueryResultList(searchString: "Closest \(results.count)", results: results)
    }
}
