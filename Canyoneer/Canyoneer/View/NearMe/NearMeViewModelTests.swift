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
    var favorite: MockFavoriteService!
    override func setUp() {
        super.setUp()
        favorite = MockFavoriteService()
    }
    
    func testNearMe() async {
        // setup
        let canyon = CanyonIndex(name: "Something else")
        let manager = MockCanyonDataManager()
        let service = MockSearchService(canyonManager: manager)
        let queryResults  = [canyon, CanyonIndex(), CanyonIndex(), CanyonIndex()].map {
            return QueryResult(name: $0.name, canyonDetails: $0)
        }
        service.queryResults = QueryResultList(searchString: "Any Title", results: queryResults)
        let viewModel = NearMeViewModel(
            filterViewModel: CanyonFilterViewModel(initialState: .default),
            weatherViewModel: WeatherViewModel(),
            canyonManager: manager,
            favoriteService: favorite,
            searchService: service
        )
        
        // test response
        await viewModel.refresh()
        XCTAssertEqual(viewModel.results.count, 4)
        XCTAssertEqual(viewModel.title, "Any Title")
    }
}
