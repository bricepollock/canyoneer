//
//  SearchService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import RxSwift
import CoreLocation

protocol SearchServiceInterface {
    init(canyonService: RopeWikiServiceInterface)
    func requestSearch(for searchString: String) -> Single<SearchResultList>
    func nearMeSearch(limit: Int) -> Single<SearchResultList>
}

struct SearchService: SearchServiceInterface {
    private static let maxSearchResults = 100
    
    private let ropeWikiService: RopeWikiServiceInterface
    private let locationService = LocationService()
    
    init(canyonService: RopeWikiServiceInterface = RopeWikiService()) {
        self.ropeWikiService = canyonService
    }
    
    func requestSearch(for searchString: String) -> Single<SearchResultList> {
        return self.ropeWikiService.canyons().map { canyons in
            var results = [SearchResult]()
            canyons.filter { canyon in
                return canyon.name.lowercased().contains(searchString.lowercased())
            }.sorted(by: { lhs, rhs in
                return lhs.quality > rhs.quality
            }).prefix(Self.maxSearchResults)
            .forEach { canyon in
                results.append(SearchResult(name: canyon.name, canyonDetails: canyon))
            }
            
            return SearchResultList(searchString: searchString, result: results)
        }
    }
    
    func nearMeSearch(limit: Int) -> Single<SearchResultList> {
        guard locationService.isLocationEnabled() else {
            return Single.error(RequestError.badRequest)
        }
        
        return self.ropeWikiService.canyons().flatMap { canyons in
            return Single.create { single in
                self.locationService.getCurrentLocation { currentLocation in
                    
                    let results = canyons.sorted { lhs, rhs in
                        let lhsDistance = lhs.coordinate.asCLObject.distance(to: currentLocation)
                        let rhsDistance = rhs.coordinate.asCLObject.distance(to: currentLocation)
                        return lhsDistance < rhsDistance
                    }
                        .prefix(limit)
                        .sorted(by: { lhs, rhs in
                            return lhs.quality > rhs.quality
                        })
                        .map { canyon in
                            return SearchResult(name: canyon.name, canyonDetails: canyon)
                        }
                    
                    
                    single(.success(SearchResultList(searchString: "Closest \(limit)", result: results)))
                }
                return Disposables.create()
            }

        }
    }
}
