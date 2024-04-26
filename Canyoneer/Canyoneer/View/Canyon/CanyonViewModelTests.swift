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
    var canyon: Canyon!
    var manager: MockCanyonDataManager!
    var favorite: MockFavoriteService!
    var weather: WeatherViewModel!
    var locationService: LocationService!
    var viewModel: CanyonViewModel!
    
    override func setUp() {
        super.setUp()
        
        canyon = Canyon()
        manager = MockCanyonDataManager()
        favorite = MockFavoriteService()
        weather = WeatherViewModel()
        locationService = LocationService()
        viewModel = CanyonViewModel(
            canyonId: canyon.id,
            canyonManager: manager,
            locationService: locationService,
            favoriteService: favorite,
            weatherViewModel: WeatherViewModel()
        )
    }
    
    func testInitialFavorite_true() async throws {
        // setup
        manager.mockCanyon = canyon
        favorite.setFavorite(canyon: canyon, to: true)
        
        // test
        await viewModel.refresh()
        
        let isFavorite = try XCTUnwrap(viewModel.isFavorite)
        XCTAssertEqual(isFavorite, true)
    }
    
    func testToggleFavorite() async throws {
        // setup
        manager.mockCanyon = canyon
        
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
        manager.mockCanyon = canyon
        
        // test
        await viewModel.refresh()
        XCTAssertEqual(viewModel.canyon?.id, canyon.id)
    }
    
    func testCanyon_notFound() async throws {
        // setup
        manager.mockCanyon = nil
        
        // test
        await viewModel.refresh()
        XCTAssertNil(viewModel.canyon)
    }
    
    func testMessage() {
        let canyon = Canyon(minRaps: 2, maxRaps: 2)
        let expected = "I found 'Moonflower Canyon 3A II 2r ↧220ft' on the 'Canyoneer' app. Check out the canyon on Ropewiki: http://ropewiki.com/Moonflower_Canyon"
        let result = CanyonViewModel.Strings.message(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testMessage_noUrl() {
        let canyon = Canyon(minRaps: 2, maxRaps: 2, url: nil)
        let expected = "I found 'Moonflower Canyon 3A II 2r ↧220ft' on the 'Canyoneer' app."
        let result = CanyonViewModel.Strings.message(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testBody() {
        let canyon = Canyon(minRaps: 2, maxRaps: 2)
        let expected = "I found 'Moonflower Canyon 3A II 2r ↧220ft' on the 'Canyoneer' app. Check out the canyon on Ropewiki: http://ropewiki.com/Moonflower_Canyon"
        let result = CanyonViewModel.Strings.body(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testBody_noUrl() {
        let canyon = Canyon(minRaps: 2, maxRaps: 2, url: nil)
        let expected = "I found 'Moonflower Canyon 3A II 2r ↧220ft' on the 'Canyoneer' app."
        let result = CanyonViewModel.Strings.body(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testSubject() {
        let name = "Moonflower Canyon"
        let expected = "Check out this cool canyon: Moonflower Canyon"
        let result = CanyonViewModel.Strings.subject(name: name)
        XCTAssertEqual(expected, result)
    }
}
   
