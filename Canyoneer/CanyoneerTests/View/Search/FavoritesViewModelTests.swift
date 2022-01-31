//
//  SearchViewModel+favorite.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer

class FavoritesViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UserPreferencesStorage.clearFavorites()
    }
    
    func testReturnsFavorites() {
        // setup
        let canyon = Canyon.dummy()
        let viewModel = FavoritesViewModel()
        UserPreferencesStorage.addFavorite(canyon: canyon)
        
        // Wait for results to come in
        let expectation = self.expectation(description: "results")
        var results: [SearchResult] = []
        let cancelable = viewModel.results.sink { searchResults in
            results = searchResults
            expectation.fulfill()
        }
        
        // Create the event stream
        viewModel.refresh()
        waitForExpectations(timeout: 1)
        
        // test
        XCTAssertEqual(results.count, 1)
        
        // clean up
        cancelable.cancel()
    }
    
    func testTitle() {
        // setup
        let canyon = Canyon.dummy()
        let service = MockRopeWikiService()
        service.mockCanyons = [canyon, Canyon.dummy(), Canyon.dummy(), Canyon.dummy()]
        let viewModel = FavoritesViewModel()
        
        // wait
        let expectation = self.expectation(description: "title")
        var result: String = ""
        let cancelable = viewModel.title.sink { title in
            result = title
            expectation.fulfill()
        }
        
        // Create the event stream
        viewModel.refresh()
        waitForExpectations(timeout: 1)
        
        // test
        XCTAssertEqual(result, "Favorites")
        
        // clean up
        cancelable.cancel()
    }
}
