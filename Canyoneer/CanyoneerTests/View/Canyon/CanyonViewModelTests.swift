//
//  CanyonViewModelTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
import RxTest
@testable import Canyoneer

class CanyonViewModelTests: XCTestCase {
    var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        UserPreferencesStorage.clearFavorites()
    }
    
    func testSolarTime_lessThanHalf() {
        let sunrise = Date(timeIntervalSince1970: -TimeInterval.hour * 12.3)
        let sunset = Date(timeIntervalSince1970: TimeInterval.hour * 1.1)
        let result = CanyonViewModel.Strings.sunsetTimes(sunset: sunset, sunrise: sunrise)
        let expected = "Daylight: 3:42 AM - 5:06 PM (13 hours)"
        XCTAssertEqual(expected, result)
    }
    
    func testSolarTime_moreThanHalf() {
        let sunrise = Date(timeIntervalSince1970: -TimeInterval.hour * 12.3)
        let sunset = Date(timeIntervalSince1970: TimeInterval.hour * 1.9)
        let result = CanyonViewModel.Strings.sunsetTimes(sunset: sunset, sunrise: sunrise)
        let expected = "Daylight: 3:42 AM - 5:54 PM (14 hours)"
        XCTAssertEqual(expected, result)
    }
    
    func testInitialFavorite_true() {
        // setup
        let canyon = Canyon.dummy()
        let service = MockRopeWikiService()
        service.mockCanyon = canyon
        let viewModel = CanyonViewModel(canyonId: canyon.id, service: service)
        UserPreferencesStorage.addFavorite(canyon: canyon)
        
        // Create the observation of the affected streams
        let observer = scheduler.createObserver(Bool.self)
        let subscription = viewModel.isFavorite.subscribe(observer)
        
        // Create the event stream
        viewModel.refresh()
        scheduler.start()
        
        // observe the response
        let results = observer.events.map { $0.value.element }
        guard let isFavorite = results.first else { XCTFail(); return }
        XCTAssertEqual(isFavorite, true)
        
        // clean up
        subscription.dispose()
    }
    
    func testToggleFavorite() {
        // setup
        let canyon = Canyon.dummy()
        let service = MockRopeWikiService()
        service.mockCanyon = canyon
        let viewModel = CanyonViewModel(canyonId: canyon.id, service: service)
        
        // Create the observation of the affected streams
        let observer = scheduler.createObserver(Bool.self)
        let subscription = viewModel.isFavorite.subscribe(observer)
        
        // Create the event stream
        viewModel.refresh()
        viewModel.toggleFavorite()
        viewModel.toggleFavorite()
        scheduler.start()
        
        // observe the response
        let results = observer.events.map { $0.value.element }
        guard let initialResult = results[0] else { XCTFail(); return }
        guard let toggleOneResult = results[1] else { XCTFail(); return }
        guard let toggleTwoResult = results[2] else { XCTFail(); return }
        XCTAssertEqual(initialResult, false)
        XCTAssertEqual(toggleOneResult, true)
        XCTAssertEqual(toggleTwoResult, false)
        
        // clean up
        subscription.dispose()
    }
    
    func testCanyon_found() {
        // setup
        let canyon = Canyon.dummy()
        let service = MockRopeWikiService()
        service.mockCanyon = canyon
        let viewModel = CanyonViewModel(canyonId: canyon.id, service: service)
        
        // Create the observation of the affected streams
        let observer = scheduler.createObserver(Canyon.self)
        let subscription = viewModel.canyonObservable.subscribe(observer)
        
        // Create the event stream
        viewModel.refresh()
        scheduler.start()
        
        // observe the response
        let results = observer.events.map { $0.value.element }
        guard let canyonResult = results[0] else { XCTFail(); return }
        XCTAssertEqual(canyonResult.id, canyon.id)

        // clean up
        subscription.dispose()
    }
    
    func testCanyon_notFound() {
        // setup
        let canyon = Canyon.dummy()
        let service = MockRopeWikiService()
        service.mockCanyon = nil
        let viewModel = CanyonViewModel(canyonId: canyon.id, service: service)
        
        // Create the observation of the affected streams
        let observer = scheduler.createObserver(Canyon.self)
        let subscription = viewModel.canyonObservable.subscribe(observer)
        
        // Create the event stream
        viewModel.refresh()
        scheduler.start()
        
        // observe the response
        let results = observer.events.map { $0.value.element }
        XCTAssertEqual(results.count, 0) // we don't supply a nil canyon

        // clean up
        subscription.dispose()
    }
}
   
