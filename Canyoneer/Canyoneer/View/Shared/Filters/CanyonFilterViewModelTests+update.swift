//
//  CanyonFilterViewModelTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer

@MainActor
class CanyonFilterViewModelUpdateTests: XCTestCase {    
    func testStateReset() {
        // setup
        let viewModel = CanyonFilterViewModel(initialState: .default)
        
        // observe the response
        let currentState = viewModel.currentState
        XCTAssertEqual(currentState.numRaps.min, 0)
        XCTAssertEqual(currentState.numRaps.max, 50)
        XCTAssertEqual(currentState.maxRap.min, 0)
        XCTAssertEqual(Double(currentState.maxRap.max), 600)
        XCTAssertEqual(currentState.stars, [1,2,3,4,5])
        XCTAssertEqual(currentState.technicality, Set(TechnicalGrade.allCases))
        XCTAssertEqual(currentState.water, Set(WaterGrade.allCases))
        XCTAssertEqual(currentState.time, Set(TimeGrade.allCases))
        XCTAssertEqual(currentState.shuttleRequired, nil)
        XCTAssertEqual(currentState.seasons, Set(Month.allCases))
    }
    
    func testStateChangeAll() {
        // setup
        let viewModel = CanyonFilterViewModel(initialState: .default)
        
        // Modify filter
        viewModel.maxRap = Bounds(min: 50, max: 200)
        viewModel.numRaps = Bounds(min: 5, max: 20)
        viewModel.stars = [4, 5]
        viewModel.technicality = [.two, .three]
        viewModel.water = [.a]
        viewModel.time = [.three, .four]
        viewModel.shuttleRequired = true
        viewModel.seasons = [.february, .march, .april]
        
        let currentState = viewModel.currentState
        XCTAssertEqual(currentState.numRaps.min, 5)
        XCTAssertEqual(currentState.numRaps.max, 20)
        XCTAssertEqual(currentState.maxRap.min, 50)
        XCTAssertEqual(currentState.maxRap.max, 200)
        XCTAssertEqual(currentState.stars, [4,5])
        XCTAssertEqual(currentState.technicality, [.two, .three])
        XCTAssertEqual(currentState.water, [.a])
        XCTAssertEqual(currentState.time, [.three, .four])
        XCTAssertEqual(currentState.shuttleRequired, true)
        XCTAssertEqual(currentState.seasons, [Month.february, Month.march, Month.april])
    }
}
