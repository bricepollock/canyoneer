//
//  FilterViewModelTests+search.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer

@MainActor
class CanyonFilterViewModelTests: XCTestCase {
    func testDefaultFilter() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        let third = Canyon.dummy()
        let canyons = [first, second, third]
        
        let viewModel = CanyonFilterViewModel(initialState: .default)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 3)
    }
    
    // MARK: NumRaps
    
    func testFilter_numRaps_high() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.numRaps = 100
        let canyons = [first, second, third]
        
        let viewModel = CanyonFilterViewModel(initialState: .default)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_numRaps_low() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.numRaps = 1
        let canyons = [first, second, third]
        
        let state = FilterState(numRaps: Bounds(min: 2, max: 20))
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_numRaps_nil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.numRaps = nil
        let canyons = [first, second, third]
        
        let viewModel = CanyonFilterViewModel(initialState: .default)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_numRaps_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.numRaps = 12
        let canyons = [first, second, third]
        
        let viewModel = CanyonFilterViewModel(initialState: .default)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 3)
    }
    
    // MARK: Max Rap
    
    func testFilter_maxRap_high() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.maxRapLength = 1000
        let canyons = [first, second, third]
        
        let viewModel = CanyonFilterViewModel(initialState: .default)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_maxRap_low() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.maxRapLength = 10
        let canyons = [first, second, third]
        
        let state = FilterState(maxRap: Bounds(min: 20, max: 300))
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_maxRap_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.maxRapLength = 200
        let canyons = [first, second, third]
        
        let viewModel = CanyonFilterViewModel(initialState: .default)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_maxRaps_nil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.maxRapLength = nil
        let canyons = [first, second, third]
        
        let viewModel = CanyonFilterViewModel(initialState: .default)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 2)
    }
    
    // MARK: Stars
    
    func testFilter_stars_one() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.quality = 4
        let canyons = [first, second, third]
        
        let state = FilterState(stars: [3])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 0)
    }
    
    func testFilter_stars_many() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.quality = 2
        let canyons = [first, second, third]
        
        let state = FilterState(stars: [3,4])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_stars_half() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.quality = 3.5
        let canyons = [first, second, third]
        
        let state = FilterState(stars: [3])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 1) // just the third
    }
    
    func testFilter_stars_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.quality = 3
        let canyons = [first, second, third]
        
        let state = FilterState(stars: [3,4])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 3)
    }
    
    // MARK: Technicality
    
    func testFilter_technicality_one() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.technicalDifficulty = .two
        let canyons = [first, second, third]
        
        let state = FilterState(technicality: [.three])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_technicality_many() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.technicalDifficulty = .four
        let canyons = [first, second, third]
        
        let state = FilterState(technicality: [.three, .four])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_technicality_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.technicalDifficulty = .three
        let canyons = [first, second, third]
        
        let state = FilterState(technicality: [.three, .four])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_technicality_nil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.technicalDifficulty = nil
        let canyons = [first, second, third]
        
        let state = FilterState(technicality: [.three])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 2)
    }
    
    // MARK: Water
    
    func testFilter_water_nil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.waterDifficulty = nil
        let canyons = [first, second, third]
        
        let viewModel = CanyonFilterViewModel(initialState: .default)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_water_one() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.waterDifficulty = .a
        let canyons = [first, second, third]
        
        let state = FilterState(water: [.b])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 0)
    }
    
    func testFilter_water_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.waterDifficulty = .a
        let canyons = [first, second, third]
        
        let state = FilterState(water: [.a, .b])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 3)
    }
    
    // MARK: Time
    
    func testFilter_time_nil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.timeGrade = nil
        let canyons = [first, second, third]
        
        let state = FilterState(time: [.three, .four])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 0)
    }
    
    func testFilter_time_miss() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.timeGrade = .two
        let canyons = [first, second, third]
        
        let state = FilterState(time: [.three, .four])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 0)
    }
    
    func testFilter_time_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.timeGrade = .four
        let canyons = [first, second, third]
        
        let state = FilterState(time: [.three, .four])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 1)
    }
    
    // MARK: Shuttle
    
    func testFilter_shuttle_nil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.requiresShuttle = nil
        let canyons = [first, second, third]
        
        let state = FilterState(shuttleRequired: false)
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_shuttle_nil_stateNil() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.requiresShuttle = nil
        let canyons = [first, second, third]
        
        let state = FilterState(shuttleRequired: nil)
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_shuttle_match_any() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.requiresShuttle = true
        let canyons = [first, second, third]
        
        let state = FilterState(shuttleRequired: nil)
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_shuttle_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.requiresShuttle = true
        let canyons = [first, second, third]
        
        let state = FilterState(shuttleRequired: true)
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 1) // the third
    }
    
    func testFilter_shuttle_miss() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.requiresShuttle = true
        let canyons = [first, second, third]
        
        let state = FilterState(shuttleRequired: false)
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 2)
    }
    
    // MARK: Seasons
    
    func testFilter_seasons_miss() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.bestSeasons = [.january, .february]
        let canyons = [first, second, third]
        
        let state = FilterState(seasons: [.april])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 2)
    }
    
    func testFilter_seasons_partMatch() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.bestSeasons = [.january, .february]
        let canyons = [first, second, third]
        
        let state = FilterState(seasons: [.february, .april])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_seasons_match() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.bestSeasons = [.february, .april]
        let canyons = [first, second, third]
        
        let state = FilterState(seasons: [.february, .april])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 3)
    }
    
    func testFilter_seasons_empty() {
        let first = Canyon.dummy()
        let second = Canyon.dummy()
        var third = Canyon.dummy()
        third.bestSeasons = []
        let canyons = [first, second, third]
        
        let state = FilterState(seasons: [.february, .april])
        let viewModel = CanyonFilterViewModel(initialState: state)
        let result = viewModel.filter(canyons: canyons)
        XCTAssertEqual(result.count, 2)
    }
}
