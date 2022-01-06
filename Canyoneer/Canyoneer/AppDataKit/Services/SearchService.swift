//
//  SearchService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

struct SearchService {
    func requestSearch(for searchString: String) -> SearchResultList {
        return SearchResultList(
            searchString: searchString,
            result: [
                SearchResult(name: "Utah", type: .region, canyonDetails: nil, regionDetails: RopeWikiService.utah),
                SearchResult(name: "Moonflower", type: .canyon, canyonDetails: RopeWikiService.moonflower, regionDetails: nil)
            ]
        )
    }
}
