//
//  MockSearchService.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
@testable import Canyoneer

class MockSearchService: SearchServiceInterface {
    required init(canyonService: RopeWikiServiceInterface) {
        // no-op
    }
    
    public var searchResults: SearchResultList?
    func requestSearch(for searchString: String) async -> SearchResultList {
        return searchResults ?? SearchResultList(searchString: "", result: [])
    }
    
    func nearMeSearch(limit: Int) async throws -> SearchResultList {
        guard let searchResults else {
            throw RequestError.badRequest
        }
        
        return searchResults
    }
}
