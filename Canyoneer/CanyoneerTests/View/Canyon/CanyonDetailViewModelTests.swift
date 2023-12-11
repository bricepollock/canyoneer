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
        let canyon = Canyon(risk: .x)
        let expected = "3A II X 2r ↧220ft"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_noMax() {
        let canyon = Canyon(maxRapLength: nil)
        let expected = "3A II 2r"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_noRaps() {
        let canyon = Canyon(maxRaps: nil)
        let expected = "3A II ↧220ft"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_noMax_noRaps() {
        let canyon = Canyon(maxRaps: nil, maxRapLength: nil)
        let expected = "3A II"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_noMax_noRaps_noGrade() {
        let canyon = Canyon(timeGrade: nil, maxRaps: nil, maxRapLength: nil)
        let expected = "3A"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_onlyTechnical() {
        let canyon = Canyon(timeGrade: nil, waterDifficulty: nil, maxRaps: nil, maxRapLength: nil)
        let expected = "3"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_onlyWater() {
        let canyon = Canyon(technicalDifficulty: nil, timeGrade: nil, maxRaps: nil, maxRapLength: nil)
        let expected = "A"
        let result = canyon.technicalSummary
        XCTAssertEqual(expected, result)
    }
}
