//
//  CanyonViewModelTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer

@MainActor
class CanyonViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UserPreferencesStorage.clearFavorites()
    }
    
    func testInitialFavorite_true() async throws {
        // setup
        let canyon = Canyon()
        let service = MockRopeWikiService()
        service.mockCanyon = canyon
        let viewModel = CanyonViewModel(
            canyonId: canyon.id,
            canyonService: service,
            favoriteService: FavoriteService(),
            weatherViewModel: WeatherViewModel()
        )
        UserPreferencesStorage.addFavorite(canyon: canyon)
        
        // test
        await viewModel.refresh()
        
        let isFavorite = try XCTUnwrap(viewModel.isFavorite)
        XCTAssertEqual(isFavorite, true)
    }
    
    func testToggleFavorite() async throws {
        // setup
        let canyon = Canyon()
        let service = MockRopeWikiService()
        service.mockCanyon = canyon
        let viewModel = CanyonViewModel(
            canyonId: canyon.id,
            canyonService: service,
            favoriteService: FavoriteService(),
            weatherViewModel: WeatherViewModel()
        )
        
        // test
        await viewModel.refresh()
        XCTAssertEqual(viewModel.isFavorite, false)
        
        viewModel.toggleFavorite()
        XCTAssertEqual(viewModel.isFavorite, true)
        
        viewModel.toggleFavorite()
        XCTAssertEqual(viewModel.isFavorite, false)
    }
    
    func testCanyon_found() async {
        // setup
        let canyon = Canyon()
        let service = MockRopeWikiService()
        service.mockCanyon = canyon
        let viewModel = CanyonViewModel(
            canyonId: canyon.id,
            canyonService: service,
            favoriteService: FavoriteService(),
            weatherViewModel: WeatherViewModel()
        )
        
        // test
        await viewModel.refresh()
        XCTAssertEqual(viewModel.canyon?.id, canyon.id)
    }
    
    func testCanyon_notFound() async throws {
        // setup
        let canyon = Canyon()
        let service = MockRopeWikiService()
        service.mockCanyon = nil
        let viewModel = CanyonViewModel(
            canyonId: canyon.id,
            canyonService: service,
            favoriteService: FavoriteService(),
            weatherViewModel: WeatherViewModel()
        )
        
        // test
        await viewModel.refresh()
        XCTAssertNil(viewModel.canyon)
    }
}
   
