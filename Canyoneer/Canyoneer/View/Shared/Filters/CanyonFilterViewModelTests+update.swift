//
//  CanyonFilterViewModelTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
import Combine
@testable import Canyoneer

@MainActor
class CanyonFilterViewModelUpdateTests: XCTestCase {
    
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        bag = Set<AnyCancellable>()
    }
    
    // MARK: isActive
    
    @MainActor
    func testIsActive_init_default_update() async throws {
        let viewModel = CanyonFilterViewModel(initialState: .default)
        XCTAssertFalse(viewModel.areFiltersActive)
        
        // Test change to active
        let waitForActive = XCTestExpectation(description: "wait for active")
        viewModel.$areFiltersActive
            .dropFirst()
            .sink { isActive in
                if isActive {
                    waitForActive.fulfill()
                }
            }
            .store(in: &bag)
        
        viewModel.time = [.three, .four]
        await fulfillment(of: [waitForActive], timeout: 3)
        XCTAssertTrue(viewModel.areFiltersActive)
        
        // Test reset
        let waitForReset = XCTestExpectation(description: "wait for reset")
        viewModel.$areFiltersActive
            .dropFirst()
            .sink { isActive in
                if !isActive {
                    waitForReset.fulfill()
                }
            }
            .store(in: &bag)
        viewModel.reset()
        await fulfillment(of: [waitForReset], timeout: 3)
        XCTAssertFalse(viewModel.areFiltersActive)
    }
    
    @MainActor
    func testIsActive_init_reset() async {
        let state = FilterState(numRaps: Bounds(min: 3, max: 10))
        let viewModel = CanyonFilterViewModel(initialState: state)
        XCTAssertTrue(viewModel.areFiltersActive)
        
        // Test reset
        let waitForReset = XCTestExpectation(description: "wait for reset")
        viewModel.$areFiltersActive
            .dropFirst()
            .sink { isActive in
                if !isActive {
                    waitForReset.fulfill()
                }
            }
            .store(in: &bag)
        viewModel.reset()
        await fulfillment(of: [waitForReset], timeout: 3)
        XCTAssertFalse(viewModel.areFiltersActive)
    }
    
    // MARK: reset
    
    @MainActor
    func testState() {
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
    
    @MainActor
    func testStateChangeAll() async {
        // setup
        let viewModel = CanyonFilterViewModel(initialState: .default)
        
        // wait for all updates
        let seasonsApply: Set<Month> = [.february, .march, .april]
        let waitForFinalUpdate = XCTestExpectation(description: "wait for update")
        viewModel.$seasons
            .dropFirst()
            .sink { seasons in
                if seasons == seasonsApply  {
                    waitForFinalUpdate.fulfill()
                }
            }
            .store(in: &bag)
        
        // Modify filter
        viewModel.maxRap = Bounds(min: 50, max: 200)
        viewModel.numRaps = Bounds(min: 5, max: 20)
        viewModel.stars = [4, 5]
        viewModel.technicality = [.two, .three]
        viewModel.water = [.a]
        viewModel.time = [.three, .four]
        viewModel.shuttleRequired = true
        viewModel.seasons = seasonsApply
        await fulfillment(of: [waitForFinalUpdate], timeout: 3)
    
        // Test Update
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
        XCTAssertTrue(viewModel.areFiltersActive)
        
        // Test reset
        let waitForReset = XCTestExpectation(description: "wait for reset")
        viewModel.$areFiltersActive
            .dropFirst()
            .sink { isActive in
                if !isActive {
                    waitForReset.fulfill()
                }
            }
            .store(in: &bag)
        viewModel.reset()
        await fulfillment(of: [waitForReset], timeout: 3)
        XCTAssertFalse(viewModel.areFiltersActive)
    }
}
