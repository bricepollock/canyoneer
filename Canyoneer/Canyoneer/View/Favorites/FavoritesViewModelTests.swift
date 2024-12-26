//
//  SearchViewModel+favorite.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer
import CoreLocation

class MockMapDelegate: MainMapDelegate {
    public init() {}
    
    func updateCenter(to location: CLLocationCoordinate2D, animated: Bool) { }
}

@MainActor
class FavoritesViewModelTests: XCTestCase {
    var manager: MockCanyonDataManager!
    var favoriteService: MockFavoriteService!
    var locationService: LocationService!
    var viewModel: FavoriteListViewModel!
    
    override func setUp() {
        super.setUp()
        manager = MockCanyonDataManager()
        favoriteService = MockFavoriteService()
        locationService = LocationService()
        viewModel = FavoriteListViewModel(
            weatherViewModel: WeatherViewModel(),
            mapService: MapService(),
            canyonManager: manager,
            favoriteService: favoriteService,
            locationService: locationService,
            mapDelegate: MockMapDelegate()
        )
    }
    
    func testRefresh() async {
        // setup
        let canyon = Canyon()
        favoriteService.setFavorite(canyon: canyon, to: true)
        
        // test
        await viewModel.refresh()
        XCTAssertEqual(viewModel.results.count, 1)
        XCTAssertEqual(viewModel.title, "Favorites")
    }
}
