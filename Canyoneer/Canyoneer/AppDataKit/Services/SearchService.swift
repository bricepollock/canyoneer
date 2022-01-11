//
//  SearchService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import RxSwift
import CoreLocation

struct SearchService {
    private static let maxNearMe = 50
    
    private let ropeWikiService = RopeWikiService()
    private let locationService = LocationService()
    func requestSearch(for searchString: String) -> Single<SearchResultList> {
        return self.ropeWikiService.canyons().map { canyons in
            var results = [SearchResult]()
            canyons.filter { canyon in
                return canyon.name.lowercased().contains(searchString.lowercased())
            }.sorted(by: { lhs, rhs in
                return lhs.quality > rhs.quality
            })
            .forEach { canyon in
                results.append(SearchResult(name: canyon.name, type: .canyon, canyonDetails: canyon, regionDetails: nil))
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
                        .prefix(Self.maxNearMe)
                        .sorted(by: { lhs, rhs in
                            return lhs.quality > rhs.quality
                        })
                        .map { canyon in
                            return SearchResult(name: canyon.name, type: .canyon, canyonDetails: canyon, regionDetails: nil)
                        }
                    
                    
                    single(.success(SearchResultList(searchString: "Closest \(Self.maxNearMe)", result: results)))
                }
                return Disposables.create()
            }

        }
    }
    
//    func flattenRegions(regions: [Region]) -> [Region] {
//        return regions.flatMap { region in
//            return self.flattenRegion(region: region)
//        }
//    }
//    func flattenRegion(region: Region) -> [Region] {
//        guard !region.children.isEmpty else {
//            return [region]
//        }
//        return region.children.flatMap { region in
//            return self.flattenRegion(region: region)
//        }
//    }
}
