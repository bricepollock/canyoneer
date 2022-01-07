//
//  LandingViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import RxSwift

struct LandingViewModel {
    private let service = RopeWikiService()
    private let searchService = SearchService()
    
    // MARK: Outputs
    public func regions() -> [Region] {
        return service.regions()
    }
    
    public func canyons() -> Single<[Canyon]> {
        return service.canyons()
    }
    
    // MARK: Inputs
    func requestSearch(for searchString: String) -> Single<SearchResultList> {
        return searchService.requestSearch(for: searchString)
    }
    
    func nearMeSearch() -> Single<SearchResultList> {
        return searchService.nearMeSearch(limit: 50)
    }
}
