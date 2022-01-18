//
//  SearchViewController+nearMe.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
import RxTest
@testable import Canyoneer


class SearchViewModelNearMeTests: XCTestCase {
    var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        UserPreferencesStorage.clearFavorites()
    }
    
    func testNearMe() {
        // setup
        var canyon = Canyon.dummy()
        canyon.name = "Something else"
        let service = MockSearchService(canyonService: MockRopeWikiService())
        let searchResults  = [canyon, Canyon.dummy(), Canyon.dummy(), Canyon.dummy()].map {
            return SearchResult(name: $0.name, type: .canyon, canyonDetails: $0, regionDetails: nil)
        }
        service.searchResults = SearchResultList(searchString: "Near Me", result: searchResults)
        let viewModel = SearchViewModel(type: .nearMe, searchService: service)
        
        // Create the observation of the affected streams
        let observer = scheduler.createObserver([SearchResult].self)
        let subscription = viewModel.results.subscribe(observer)
        
        // Create the event stream
        viewModel.refresh()
        scheduler.start()
        
        // observe the response
        let results = observer.events.map { $0.value.element }
        XCTAssertEqual(results.first??.count, 4)
        
        // clean up
        subscription.dispose()
    }
    
    func testTitle() {
        // setup
        let canyon = Canyon.dummy()
        let service = MockRopeWikiService()
        service.mockCanyons = [canyon, Canyon.dummy(), Canyon.dummy(), Canyon.dummy()]
        let viewModel = SearchViewModel(type: .nearMe, canyonService: service)
        
        // Create the observation of the affected streams
        let observer = scheduler.createObserver(String.self)
        let subscription = viewModel.title.subscribe(observer)
        
        // Create the event stream
        viewModel.refresh()
        scheduler.start()
        
        // observe the response
        let results = observer.events.map { $0.value.element }
        XCTAssertEqual(results.first, "Near Me (Top 100)")
        
        // clean up
        subscription.dispose()
    }
}
