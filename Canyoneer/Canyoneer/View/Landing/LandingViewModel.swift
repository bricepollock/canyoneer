//
//  LandingViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

struct LandingViewModel {
    private let service = RopeWikiService()
    private let searchService = SearchService()
    
    // MARK: Outputs
    public func regions() -> [Region] {
        return service.regions()
    }
    
    // MARK: Inputs
    func requestSearch(for searchString: String) -> SearchResultList {
        return searchService.requestSearch(for: searchString)
    }
}
