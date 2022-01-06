//
//  LandingViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

struct LandingViewModel {
    // MARK: Outputs
    public func regions() -> [Region] {
        return [
            Self.california,
            Self.utah
        ]
    }
    
    // MARK: Inputs
    func requestSearch(for searchString: String) -> SearchResultList {
        return SearchResultList(
            searchString: searchString,
            result: [
                SearchResult(name: "Utah", type: .region, canyonDetails: nil, regionDetails: Self.utah),
                SearchResult(name: "Moonflower", type: .canyon, canyonDetails: Self.moonflower, regionDetails: nil)
            ]
        )
    }
}
