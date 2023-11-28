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
        let searchResults  = [canyon, Canyon.dummy(), Canyon.dummy(), Canyon.dummy()].map {
            return SearchResult(name: $0.name, canyonDetails: $0)
        }
        service.searchResults = SearchResultList(searchString: "Near Me", result: searchResults)
        let viewModel = NearMeViewModel(searchService: service)
        
        // test response
        await viewModel.refresh()
        XCTAssertEqual(viewModel.currentResults.count, 4)
    }
    
    func testTitle() async {
        // setup
        let canyon = Canyon.dummy()
        let canyonService = MockRopeWikiService()
        canyonService.mockCanyons = [canyon, Canyon.dummy(), Canyon.dummy(), Canyon.dummy()]
        let service = MockSearchService(canyonService: canyonService)
        let viewModel = NearMeViewModel(searchService: service)
        
        // test
        await viewModel.refresh()
        XCTAssertEqual(viewModel.title, "Near Me (Top 100)")
    }
}
