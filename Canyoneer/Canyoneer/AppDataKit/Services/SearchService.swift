//
//  SearchService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

struct SearchService {
    private let ropeWikiService = RopeWikiService()
    func requestSearch(for searchString: String) -> SearchResultList {
        let regions = ropeWikiService.regions()
        let canyons = ropeWikiService.canyons()
        let flattenedRegions = flattenRegions(regions: regions)
        
        var results = [SearchResult]()
        canyons.filter { canyon in
            return canyon.name.lowercased().contains(searchString.lowercased())
        }.forEach { canyon in
            results.append(SearchResult(name: canyon.name, type: .canyon, canyonDetails: canyon, regionDetails: nil))
        }
        
        flattenedRegions.filter { region in
            return region.name.lowercased().contains(searchString.lowercased())
        }.forEach { region in
            results.append(SearchResult(name: region.name, type: .region, canyonDetails: nil, regionDetails: region))
        }
        return SearchResultList(searchString: searchString, result: results)
    }
    
    func flattenRegions(regions: [Region]) -> [Region] {
        return regions.flatMap { region in
            return self.flattenRegion(region: region)
        }
    }
    func flattenRegion(region: Region) -> [Region] {
        guard !region.children.isEmpty else {
            return [region]
        }
        return region.children.flatMap { region in
            return self.flattenRegion(region: region)
        }
    }
}
