//
//  SearchViewController+nearMe.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
import RxTest
@testable import Canyoneer


class NearMeViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserPreferencesStorage.clearFavorites()
    }
    
    func testNearMe() {
        // setup
        var canyon = Canyon.dummy()
        canyon.name = "Something else"
        let service = MockSearchService(canyonService: MockRopeWikiService())
        let searchResults  = [canyon, Canyon.dummy(), Canyon.dummy(), Canyon.dummy()].map {
            return SearchResult(name: $0.name, canyonDetails: $0)
        }
        service.searchResults = SearchResultList(searchString: "Near Me", result: searchResults)
        let viewModel = NearMeViewModel(searchService: service)
        
        // wait
        let expection = self.expectation(description: "results")
        var results = [SearchResult]()
        let cancelable = viewModel.results.sink { searchResults in
            results = searchResults
            expection.fulfill()
        }
        
        // Create the event stream
        viewModel.refresh()
        waitForExpectations(timeout: 1)
        
        // test response
        XCTAssertEqual(results.count, 4)
        
        // clean up
        cancelable.cancel()
    }
    
    func testTitle() {
        // setup
        let canyon = Canyon.dummy()
        let canyonService = MockRopeWikiService()
        canyonService.mockCanyons = [canyon, Canyon.dummy(), Canyon.dummy(), Canyon.dummy()]
        let service = MockSearchService(canyonService: canyonService)
        let viewModel = NearMeViewModel(searchService: service)
        
        // wait
        let expectation = self.expectation(description: "title")
        var result = ""
        let cancelable = viewModel.title.sink { title in
            result = title
            expectation.fulfill()
        }
        
        // Create the event stream
        viewModel.refresh()
        waitForExpectations(timeout: 1)
        
        // test
        XCTAssertEqual(result, "Near Me (Top 100)")
        
        // clean up
        cancelable.cancel()
    }
}
