//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import XCTest
@testable import Canyoneer

@MainActor
class FilterStateTests: XCTestCase {
    func testDefault() {
        let state = FilterState.default
        XCTAssertEqual(state.maxRap.min, 0)
        XCTAssertEqual(state.maxRap.max, 600)
        
        XCTAssertEqual(state.numRaps.min, 0)
        XCTAssertEqual(state.numRaps.max, 50)
        
        XCTAssertEqual(state.stars.count, 5)
        
        XCTAssertEqual(state.technicality.count, 4)
        XCTAssertEqual(state.water.count, 7)
        XCTAssertEqual(state.time.count, 6)
        XCTAssertNil(state.shuttleRequired)
        XCTAssertEqual(state.seasons.count, 12)
    }
    
    func testEqual_default() {
        let testState = FilterState()
        let defaultState = FilterState.default
        XCTAssertEqual(testState, defaultState)
    }
    
    func testEqual_maxRap() {
        let testState = FilterState(maxRap: Bounds(min: 0, max: 100))
        let defaultState = FilterState.default
        XCTAssertNotEqual(testState, defaultState)
    }
    
    func testEqual_numRaps() {
        let testState = FilterState(numRaps: Bounds(min: 0, max: 100))
        let defaultState = FilterState.default
        XCTAssertNotEqual(testState, defaultState)
    }
    
    func testEqual_stars() {
        let testState = FilterState(stars: [2,3])
        let defaultState = FilterState.default
        XCTAssertNotEqual(testState, defaultState)
    }
    
    func testEqual_technicality() {
        let testState = FilterState(technicality: [.four])
        let defaultState = FilterState.default
        XCTAssertNotEqual(testState, defaultState)
    }
    
    func testEqual_water() {
        let testState = FilterState(water: [.c1])
        let defaultState = FilterState.default
        XCTAssertNotEqual(testState, defaultState)
    }
    
    func testEqual_time() {
        let testState = FilterState(time: [.one])
        let defaultState = FilterState.default
        XCTAssertNotEqual(testState, defaultState)
    }
    
    func testEqual_shuttle() {
        let testState = FilterState(shuttleRequired: false)
        let defaultState = FilterState.default
        XCTAssertNotEqual(testState, defaultState)
    }
    
    func testEqual_seasons() {
        let testState = FilterState(seasons: [.june])
        let defaultState = FilterState.default
        XCTAssertNotEqual(testState, defaultState)
    }
}

