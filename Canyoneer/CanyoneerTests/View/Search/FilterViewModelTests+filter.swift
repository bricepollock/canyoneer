//
//  FilterViewModelTests+search.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer

class FilterViewModelFilterTests: XCTestCase {
        
    func testDefaultFilter() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        let third = Canyon.dummy()
        let canyons = [first, second, third]
        
        let result = FilterViewModel.filter(canyons: canyons, against: FilterState.default)
        XCTAssertEqual(result.count, 3)
    }
    
    // MARK: NumRaps
    
    func testFilter_numRaps_high() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.numRaps = 100
        let canyons = [first, second, third]
        
        let result = FilterViewModel.filter(canyons: canyons, against: FilterState.default)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_numRaps_low() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.numRaps = 1
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.numRaps = (max: 20, min: 2)
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_numRaps_nil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.numRaps = nil
        let canyons = [first, second, third]
        
        let result = FilterViewModel.filter(canyons: canyons, against: FilterState.default)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_numRaps_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.numRaps = 12
        let canyons = [first, second, third]
        
        let result = FilterViewModel.filter(canyons: canyons, against: FilterState.default)
        XCTAssertEqual(result.count, 3)
    }
    
    // MARK: Max Rap
    
    func testFilter_maxRap_high() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.maxRapLength = 1000
        let canyons = [first, second, third]
        
        let result = FilterViewModel.filter(canyons: canyons, against: FilterState.default)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_maxRap_low() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.maxRapLength = 10
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.maxRap = (max: 300, min: 20)
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_maxRap_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.maxRapLength = 200
        let canyons = [first, second, third]
        
        let result = FilterViewModel.filter(canyons: canyons, against: FilterState.default)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_maxRaps_nil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.maxRapLength = nil
        let canyons = [first, second, third]
        
        let result = FilterViewModel.filter(canyons: canyons, against: FilterState.default)
        XCTAssertEqual(result.count, 2)
    }
    
    // MARK: Stars
    
    func testFilter_stars_one() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.quality = 4
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.stars = [3]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 0)
    }
    
    func testFilter_stars_many() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.quality = 2
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.stars = [3,4]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_stars_half() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.quality = 3.5
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.stars = [3]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 1) // just the third
    }
    
    func testFilter_stars_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.quality = 3
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.stars = [3,4]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 3)
    }
    
    // MARK: Technicality
    
    func testFilter_technicality_one() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.technicalDifficulty = 2
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.technicality = [3]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_technicality_many() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.technicalDifficulty = 4
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.technicality = [3,4]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_technicality_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.technicalDifficulty = 3
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.technicality = [3,4]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_technicality_nil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.technicalDifficulty = nil
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.technicality = [3]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 2)
    }
    
    // MARK: Water
    
    func testFilter_water_nil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.waterDifficulty = nil
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.water = ["A", "B", "C"]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_water_one() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.waterDifficulty = "A"
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.water = ["B"]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 0)
    }
    
    func testFilter_water_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.waterDifficulty = "A"
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.water = ["A", "B"]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 3)
    }
    
    // MARK: Time
    
    func testFilter_time_nil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.timeGrade = nil
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.time = [.three, .four]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 0)
    }
    
    func testFilter_time_miss() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.timeGrade = "II"
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.time = [.three, .four]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 0)
    }
    
    func testFilter_time_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.timeGrade = "IV"
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.time = [.three, .four]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 1)
    }
    
    // MARK: Shuttle
    
    
    func testFilter_shuttle_nil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.requiresShuttle = nil
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.shuttleRequired = false
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_shuttle_nil_stateNil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.requiresShuttle = nil
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.shuttleRequired = nil
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_shuttle_match_any() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.requiresShuttle = true
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.shuttleRequired = nil
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_shuttle_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.requiresShuttle = true
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.shuttleRequired = true
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 1) // the third
    }
    
    func testFilter_shuttle_miss() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.requiresShuttle = true
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.shuttleRequired = false
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 2)
    }
    
    // MARK: Seasons
    
    func testFilter_seasons_miss() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.bestSeasons = [.january, .february]
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.seasons = [.april]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_seasons_partMatch() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.bestSeasons = [.january, .february]
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.seasons = [.february, .april]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_seasons_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.bestSeasons = [.february, .april]
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.seasons = [.february, .april]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_seasons_empty() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.bestSeasons = []
        let canyons = [first, second, third]
        
        var state = FilterState.default
        state.seasons = [.february, .april]
        let result = FilterViewModel.filter(canyons: canyons, against: state)
        XCTAssertEqual(result.count, 2)
    }
}
