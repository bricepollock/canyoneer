//
//  CanyonDetailViewTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer

class CanyonDetailViewModelTests: XCTestCase {
   
    func testSummaryDetails_all() {
        var canyon = Canyon.dummy()
        canyon.risk = .x
        let expected = "3A II X 2r ↧220ft"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_noMax() {
        var canyon = Canyon.dummy()
        canyon.maxRapLength = nil
        let expected = "3A II 2r"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_noRaps() {
        var canyon = Canyon.dummy()
        canyon.numRaps = nil
        let expected = "3A II ↧220ft"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_noMax_noRaps() {
        var canyon = Canyon.dummy()
        canyon.maxRapLength = nil
        canyon.numRaps = nil
        let expected = "3A II"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_noMax_noRaps_noGrade() {
        var canyon = Canyon.dummy()
        canyon.maxRapLength = nil
        canyon.numRaps = nil
        canyon.timeGrade = nil
        let expected = "3A"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_onlyTechnical() {
        var canyon = Canyon.dummy()
        canyon.maxRapLength = nil
        canyon.numRaps = nil
        canyon.timeGrade = nil
        canyon.waterDifficulty = nil
        let expected = "3"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_onlyWater() {
        var canyon = Canyon.dummy()
        canyon.maxRapLength = nil
        canyon.numRaps = nil
        canyon.timeGrade = nil
        canyon.technicalDifficulty = nil
        let expected = "A"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
}
