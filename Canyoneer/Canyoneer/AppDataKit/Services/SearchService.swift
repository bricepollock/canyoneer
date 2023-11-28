//
//  SearchService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import CoreLocation

protocol SearchServiceInterface {
    init(canyonService: RopeWikiServiceInterface)
    func requestSearch(for searchString: String) async -> SearchResultList
    func nearMeSearch(limit: Int) async throws -> SearchResultList
}

struct SearchService: SearchServiceInterface {
    private static let maxSearchResults = 100
    
    private let ropeWikiService: RopeWikiServiceInterface
    private let locationService = LocationService()
    
    init(canyonService: RopeWikiServiceInterface = RopeWikiService()) {
        self.ropeWikiService = canyonService
    }
    
    func requestSearch(for searchString: String) async -> SearchResultList {
        let canyons = await self.ropeWikiService.canyons()
        var results = [SearchResult]()
        canyons.filter { canyon in
            return canyon.name.lowercased().contains(searchString.lowercased())
        }.sorted(by: { lhs, rhs in
            return lhs.quality > rhs.quality
        })
        .prefix(Self.maxSearchResults)
        .forEach { canyon in
            results.append(SearchResult(name: canyon.name, canyonDetails: canyon))
        }
        
        return SearchResultList(searchString: searchString, result: results)
    }
    
    func nearMeSearch(limit: Int) async throws -> SearchResultList {
        guard locationService.isLocationEnabled() else {
            throw RequestError.badRequest
        }
        
        let canyons = await ropeWikiService.canyons()
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
            return SearchResult(name: canyon.name, canyonDetails: canyon)
        }
        
        
        return SearchResultList(searchString: "Closest \(limit)", result: results)
    }
}
