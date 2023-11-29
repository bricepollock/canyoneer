//
//  CanyonViewModelTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer

extension TimeZone {
    static var pst: TimeZone {
        TimeZone(abbreviation: "PST")!
    }
}

@MainActor
class CanyonViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UserPreferencesStorage.clearFavorites()
    }
    
    func testSolarTime_lessThanHalf() {
        let sunrise = Date(timeIntervalSince1970: -TimeInterval.hour * 12.3)
        let sunset = Date(timeIntervalSince1970: TimeInterval.hour * 1.1)
        let result = CanyonViewModel.Strings.sunsetTimes(sunset: sunset, sunrise: sunrise, in: .pst)
        let expected = "Daylight: 3:42 AM - 5:06 PM (13 hours)"
        XCTAssertEqual(expected, result)
    }
    
    func testSolarTime_moreThanHalf() {
        let sunrise = Date(timeIntervalSince1970: -TimeInterval.hour * 12.3)
        let sunset = Date(timeIntervalSince1970: TimeInterval.hour * 1.9)
        let result = CanyonViewModel.Strings.sunsetTimes(sunset: sunset, sunrise: sunrise, in: .pst)
        let expected = "Daylight: 3:42 AM - 5:54 PM (14 hours)"
        XCTAssertEqual(expected, result)
    }
    
    func testInitialFavorite_true() async throws {
        // setup
        let canyon = Canyon.dummy()
        let service = MockRopeWikiService()
        service.mockCanyon = canyon
        let viewModel = CanyonViewModel(canyonId: canyon.id, service: service)
        UserPreferencesStorage.addFavorite(canyon: canyon)
        
        // test
        await viewModel.refresh()
        
        let isFavorite = try XCTUnwrap(viewModel.isFavorite)
        XCTAssertEqual(isFavorite, true)
    }
    
    func testToggleFavorite() async throws {
        // setup
        let canyon = Canyon.dummy()
        let service = MockRopeWikiService()
        service.mockCanyon = canyon
        let viewModel = CanyonViewModel(canyonId: canyon.id, service: service)
        
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
        let canyon = Canyon.dummy()
        let service = MockRopeWikiService()
        service.mockCanyon = canyon
        let viewModel = CanyonViewModel(canyonId: canyon.id, service: service)
        
        // test
        await viewModel.refresh()
        XCTAssertEqual(viewModel.canyon?.id, canyon.id)
    }
    
    func testCanyon_notFound() async throws {
        // setup
        let canyon = Canyon.dummy()
        let service = MockRopeWikiService()
        service.mockCanyon = nil
        let viewModel = CanyonViewModel(canyonId: canyon.id, service: service)
        
        // test
        await viewModel.refresh()
        XCTAssertNil(viewModel.canyon)
    }
}
   
