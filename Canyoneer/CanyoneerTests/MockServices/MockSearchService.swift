//
//  MockSearchService.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import RxSwift
@testable import Canyoneer

class MockSearchService: SearchServiceInterface {
    required init(canyonService: RopeWikiServiceInterface) {
        // no-op
    }
    
    public var searchResults: SearchResultList?
    func requestSearch(for searchString: String) -> Single<SearchResultList> {
        guard let searchResults = searchResults else {
            return Single.error(RequestError.badRequest)
        }

        return Single.just(searchResults)
    }
    
    func nearMeSearch(limit: Int) -> Single<SearchResultList> {
        guard let searchResults = searchResults else {
            return Single.error(RequestError.badRequest)
        }
        
        return Single.just(searchResults)
    }
}
