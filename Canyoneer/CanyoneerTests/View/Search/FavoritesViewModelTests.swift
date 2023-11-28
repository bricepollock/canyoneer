//
//  SearchViewModel+favorite.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer

@MainActor
class FavoritesViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UserPreferencesStorage.clearFavorites()
    }
    
    func testReturnsFavorites() async {
        // setup
        let canyon = Canyon.dummy()
        let viewModel = FavoritesViewModel()
        UserPreferencesStorage.addFavorite(canyon: canyon)
        
        // test
        await viewModel.refresh()
        XCTAssertEqual(viewModel.currentResults.count, 1)
    }
    
    func testTitle() async {
        // setup
        let canyon = Canyon.dummy()
        let service = MockRopeWikiService()
        service.mockCanyons = [canyon, Canyon.dummy(), Canyon.dummy(), Canyon.dummy()]
        let viewModel = FavoritesViewModel()
        
        // test
        await viewModel.refresh()
        XCTAssertEqual(viewModel.title, "Favorites")
    }
}
