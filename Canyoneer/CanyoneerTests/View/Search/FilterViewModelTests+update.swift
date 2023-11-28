//
//  FilterViewModelTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer

class FilterViewModelUpdateTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserPreferencesStorage.clearFavorites()
    }
    
    func testStateReset() {
        // setup
        let viewModel = FilterViewModel()
        viewModel.reset()
        
        // observe the response
        let currentState = viewModel.currentState
        XCTAssertEqual(currentState.numRaps.min, 0)
        XCTAssertEqual(currentState.numRaps.max, 50)
        XCTAssertEqual(currentState.maxRap.min, 0)
        XCTAssertEqual(currentState.maxRap.max, 600)
        XCTAssertEqual(currentState.stars, [1,2,3,4,5])
        XCTAssertEqual(currentState.technicality, [1,2,3,4])
        XCTAssertEqual(currentState.water, ["A", "B", "C"])
        XCTAssertEqual(currentState.time, RomanNumeral.allCases)
        XCTAssertEqual(currentState.shuttleRequired, nil)
        XCTAssertEqual(currentState.seasons, Month.allCases)
    }
    
    func testStateChangeAll() {
        // setup
        let viewModel = FilterViewModel()
        
        // Modify filter
        viewModel.update(maxRap: (max: 200, min: 50))
        viewModel.update(numRaps: (max: 20, min: 5))
        viewModel.update(stars: ["4", "5"])
        viewModel.update(technicality: ["2", "3"])
        viewModel.update(water: ["A"])
        viewModel.update(time: ["III", "IV"])
        viewModel.update(shuttle: "Yes")
        viewModel.update(seasons: ["Feb", "Mar", "Apr"])
        
        let currentState = viewModel.currentState
        XCTAssertEqual(currentState.numRaps.min, 5)
        XCTAssertEqual(currentState.numRaps.max, 20)
        XCTAssertEqual(currentState.maxRap.min, 50)
        XCTAssertEqual(currentState.maxRap.max, 200)
        XCTAssertEqual(currentState.stars, [4,5])
        XCTAssertEqual(currentState.technicality, [2,3])
        XCTAssertEqual(currentState.water, ["A"])
        XCTAssertEqual(currentState.time, [RomanNumeral.three, RomanNumeral.four])
        XCTAssertEqual(currentState.shuttleRequired, true)
        XCTAssertEqual(currentState.seasons, [Month.february, Month.march, Month.april])
    }
}
