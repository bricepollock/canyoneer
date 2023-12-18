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
    var service: MockCanyonAPIService!
    var viewModel: FavoriteListViewModel!
    
    override func setUp() {
        super.setUp()
        UserPreferencesStorage.clearFavorites()
        
        service = MockCanyonAPIService()
        viewModel = FavoriteListViewModel(
            weatherViewModel: WeatherViewModel(),
            mapService: MapService(),
            canyonService: service,
            favoriteService: FavoriteService()
        )
        
    }
    
    func testRefresh() async {
        // setup
        let canyon = Canyon()
        UserPreferencesStorage.addFavorite(canyon: canyon)
        
        // test
        await viewModel.refresh()
        XCTAssertEqual(viewModel.results.count, 1)
        XCTAssertEqual(viewModel.title, "Favorites")
    }
}
