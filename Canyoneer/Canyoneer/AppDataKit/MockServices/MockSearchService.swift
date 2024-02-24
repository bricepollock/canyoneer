//
//  MockSearchService.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
@testable import Canyoneer

class MockSearchService: SearchServiceInterface {
    required init(canyonManager: CanyonDataManaging) {
        // no-op
    }
    
    public var queryResults: QueryResultList?
    func requestSearch(for searchString: String) async -> QueryResultList {
        return queryResults ?? QueryResultList(searchString: "", results: [])
    }
    
    func nearMeSearch(limit: Int) async throws -> QueryResultList {
        guard let queryResults else {
            throw RequestError.badRequest
        }
        
        return queryResults
    }
}
