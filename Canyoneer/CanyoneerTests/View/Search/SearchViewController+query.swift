//
//  SearchViewController+query.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
import RxTest
@testable import Canyoneer


class SearchViewModelQueryTests: XCTestCase {
    var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        UserPreferencesStorage.clearFavorites()
    }
    
    func testReturnsFavorites() {
        // setup
        var canyon = Canyon.dummy()
        canyon.name = "Something else"
        let service = MockRopeWikiService()
        service.mockCanyons = [canyon, Canyon.dummy(), Canyon.dummy(), Canyon.dummy()]
        let viewModel = SearchViewModel(type: .string(query: "Moon"), canyonService: service)
        UserPreferencesStorage.addFavorite(canyon: canyon)
        
        // Create the observation of the affected streams
        let observer = scheduler.createObserver([SearchResult].self)
        let subscription = viewModel.results.subscribe(observer)
        
        // Create the event stream
        viewModel.refresh()
        scheduler.start()
        
        // observe the response
        let results = observer.events.map { $0.value.element }
        XCTAssertEqual(results.first??.count, 3)
        
        // clean up
        subscription.dispose()
    }
    
    func testTitle() {
        // setup
        let canyon = Canyon.dummy()
        let service = MockRopeWikiService()
        service.mockCanyons = [canyon, Canyon.dummy(), Canyon.dummy(), Canyon.dummy()]
        let viewModel = SearchViewModel(type: .string(query: "Moon"), canyonService: service)
        
        // Create the observation of the affected streams
        let observer = scheduler.createObserver(String.self)
        let subscription = viewModel.title.subscribe(observer)
        
        // Create the event stream
        viewModel.refresh()
        scheduler.start()
        
        // observe the response
        let results = observer.events.map { $0.value.element }
        XCTAssertEqual(results.first, "Search: Moon")
        
        // clean up
        subscription.dispose()
    }
}
