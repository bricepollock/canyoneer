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
    var service: MockRopeWikiService!
    var viewModel: FavoriteListViewModel!
    
    override func setUp() {
        super.setUp()
        UserPreferencesStorage.clearFavorites()
        
        service = MockRopeWikiService()
        viewModel = FavoriteListViewModel(
            weatherViewModel: WeatherViewModel(),
            mapService: MapService(),
            canyonService: service,
            favoriteService: FavoriteService()
        )
        
    }
    
    func testReturnsFavorites() async {
        // setup
        let canyon = Canyon.dummy()
        UserPreferencesStorage.addFavorite(canyon: canyon)
        
        // test
        await viewModel.refresh()
        XCTAssertEqual(viewModel.results.count, 1)
    }
    
    func testTitle() async {
        // setup
        let canyon = Canyon.dummy()
        service.mockCanyons = [canyon, Canyon.dummy(), Canyon.dummy(), Canyon.dummy()]
        
        // test
        await viewModel.refresh()
        XCTAssertEqual(viewModel.title, "Favorites")
    }
}
