//
//  SearchViewController+nearMe.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer

@MainActor
class NearMeViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserPreferencesStorage.clearFavorites()
    }
    
    func testNearMe() async {
        // setup
        var canyon = Canyon.dummy()
        canyon.name = "Something else"
        let service = MockSearchService(canyonService: MockRopeWikiService())
        let queryResults  = [canyon, Canyon.dummy(), Canyon.dummy(), Canyon.dummy()].map {
            return QueryResult(name: $0.name, canyonDetails: $0)
        }
        service.queryResults = QueryResultList(searchString: "Any Title", results: queryResults)
        let viewModel = NearMeViewModel(
            filerViewModel: CanyonFilterViewModel(initialState: .default),
            weatherViewModel: WeatherViewModel(),
            canyonService: MockRopeWikiService(),
            favoriteService: FavoriteService(),
            searchService: service
        )
        
        // test response
        await viewModel.refresh()
        XCTAssertEqual(viewModel.results.count, 4)
        XCTAssertEqual(viewModel.title, "Any Title")
    }
}
