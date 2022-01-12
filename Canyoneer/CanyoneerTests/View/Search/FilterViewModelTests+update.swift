//
//  FilterViewModelTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
import RxTest
@testable import Canyoneer

class FilterViewModelUpdateTests: XCTestCase {
    var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        UserPreferencesStorage.clearFavorites()
    }
    
    func testStateReset() {
        // setup
        let viewModel = FilterViewModel()
        
        // Create the observation of the affected streams
        let observer = scheduler.createObserver(FilterState.self)
        let subscription = viewModel.state.subscribe(observer)
        
        // Create the event stream
        viewModel.reset()
        scheduler.start()
        
        // observe the response
        guard let firstResponse = observer.events.map({ $0.value.element }).first, let firstResult = firstResponse else {
            XCTFail(); return
        }
        XCTAssertEqual(firstResult.numRaps.min, 0)
        XCTAssertEqual(firstResult.numRaps.max, 50)
        XCTAssertEqual(firstResult.maxRap.min, 0)
        XCTAssertEqual(firstResult.maxRap.max, 600)
        XCTAssertEqual(firstResult.stars, [1,2,3,4,5])
        XCTAssertEqual(firstResult.technicality, [1,2,3,4])
        XCTAssertEqual(firstResult.water, ["A", "B", "C"])
        XCTAssertEqual(firstResult.time, RomanNumeral.allCases)
        XCTAssertEqual(firstResult.shuttleRequired, nil)
        XCTAssertEqual(firstResult.seasons, Month.allCases)
        
        // clean up
        subscription.dispose()
    }
    
    func testStateChangeAll() {
        // setup
        let viewModel = FilterViewModel()
        
        // Create the observation of the affected streams
        let observer = scheduler.createObserver(FilterState.self)
        let subscription = viewModel.state.subscribe(observer)
        
        // Create the event stream
        viewModel.update(maxRap: (max: 200, min: 50))
        viewModel.update(numRaps: (max: 20, min: 5))
        viewModel.update(stars: ["4", "5"])
        viewModel.update(technicality: ["2", "3"])
        viewModel.update(water: ["A"])
        viewModel.update(time: ["III", "IV"])
        viewModel.update(shuttle: "Yes")
        viewModel.update(seasons: ["Feb", "Mar", "Apr"])
        
        scheduler.start()
        
        // observe the response
        let responses = observer.events.map({ $0.value.element })
        guard let lastResponse = responses.last,
              let lastResult = lastResponse else {
            XCTFail(); return
        }
        XCTAssertEqual(responses.count, 8) // each change updates the state
        XCTAssertEqual(lastResult.numRaps.min, 5)
        XCTAssertEqual(lastResult.numRaps.max, 20)
        XCTAssertEqual(lastResult.maxRap.min, 50)
        XCTAssertEqual(lastResult.maxRap.max, 200)
        XCTAssertEqual(lastResult.stars, [4,5])
        XCTAssertEqual(lastResult.technicality, [2,3])
        XCTAssertEqual(lastResult.water, ["A"])
        XCTAssertEqual(lastResult.time, [RomanNumeral.three, RomanNumeral.four])
        XCTAssertEqual(lastResult.shuttleRequired, true)
        XCTAssertEqual(lastResult.seasons, [Month.february, Month.march, Month.april])
        
        // clean up
        subscription.dispose()
    }
}
