//
//  FavoriteViewModelTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
import RxTest
@testable import Canyoneer

class FavoriteViewModelTests: XCTestCase {
    var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        UserPreferencesStorage.clearFavorites()
    }
    
    func testReturnsFavorites() {
        // setup
        let canyon = Canyon.dummy()
        let service = MockRopeWikiService()
        service.mockCanyons = [canyon, Canyon.dummy(), Canyon.dummy(), Canyon.dummy()]
        let viewModel = FavoriteViewModel(service: service)
        UserPreferencesStorage.addFavorite(canyon: canyon)
        
        // Create the observation of the affected streams
        let observer = scheduler.createObserver([Canyon].self)
        let subscription = viewModel.canyons.subscribe(observer)
        
        // Create the event stream
        viewModel.refresh()
        scheduler.start()
        
        // observe the response
        let results = observer.events.map { $0.value.element }
        XCTAssertEqual(results.count, 1)
        
        // clean up
        subscription.dispose()
    }
}
