//
//  CanyonDetailViewTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer

class CanyonDetailViewTests: XCTestCase {
   
    func testSummaryDetails_all() {
        var canyon = Canyon.dummy()
        canyon.risk = .x
        let expected = "3A II X 2r ↧220ft"
        let result = CanyonDetailView.Strings.summaryDetails(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_noMax() {
        var canyon = Canyon.dummy()
        canyon.maxRapLength = nil
        let expected = "3A II 2r"
        let result = CanyonDetailView.Strings.summaryDetails(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_noRaps() {
        var canyon = Canyon.dummy()
        canyon.numRaps = nil
        let expected = "3A II ↧220ft"
        let result = CanyonDetailView.Strings.summaryDetails(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_noMax_noRaps() {
        var canyon = Canyon.dummy()
        canyon.maxRapLength = nil
        canyon.numRaps = nil
        let expected = "3A II"
        let result = CanyonDetailView.Strings.summaryDetails(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_noMax_noRaps_noGrade() {
        var canyon = Canyon.dummy()
        canyon.maxRapLength = nil
        canyon.numRaps = nil
        canyon.timeGrade = nil
        let expected = "3A"
        let result = CanyonDetailView.Strings.summaryDetails(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_onlyTechnical() {
        var canyon = Canyon.dummy()
        canyon.maxRapLength = nil
        canyon.numRaps = nil
        canyon.timeGrade = nil
        canyon.waterDifficulty = nil
        let expected = "3"
        let result = CanyonDetailView.Strings.summaryDetails(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testSummaryDetails_onlyWater() {
        var canyon = Canyon.dummy()
        canyon.maxRapLength = nil
        canyon.numRaps = nil
        canyon.timeGrade = nil
        canyon.technicalDifficulty = nil
        let expected = "A"
        let result = CanyonDetailView.Strings.summaryDetails(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    // MARK: Test value pass throughs
    
    func testIntValue_nil() {
        let input: Int? = nil
        let expected = "--"
        let result = CanyonDetailView.Strings.intValue(int: input)
        XCTAssertEqual(expected, result)
    }
    
    func testIntValue_notNil() {
        let input: Int? = 1
        let expected = "1"
        let result = CanyonDetailView.Strings.intValue(int: input)
        XCTAssertEqual(expected, result)
    }
    
    func testIntValue_doubleDigit() {
        let input: Int? = 13
        let expected = "13"
        let result = CanyonDetailView.Strings.intValue(int: input)
        XCTAssertEqual(expected, result)
    }
    
    // bool
    func testBoolValue_nil() {
        let input: Bool? = nil
        let expected = "--"
        let result = CanyonDetailView.Strings.boolValue(bool: input)
        XCTAssertEqual(expected, result)
    }
    
    func testBoolValue_yes() {
        let input: Bool? = true
        let expected = "Yes"
        let result = CanyonDetailView.Strings.boolValue(bool: input)
        XCTAssertEqual(expected, result)
    }
    
    func testBoolValue_no() {
        let input: Bool? = false
        let expected = "No"
        let result = CanyonDetailView.Strings.boolValue(bool: input)
        XCTAssertEqual(expected, result)
    }
    
    // String
    func testStringValue_nil() {
        let input: String? = nil
        let expected = "--"
        let result = CanyonDetailView.Strings.stringValue(string: input)
        XCTAssertEqual(expected, result)
    }
    
    func testStringValue_notNil() {
        let input: String? = "Moonflower"
        let expected = "Moonflower"
        let result = CanyonDetailView.Strings.stringValue(string: input)
        XCTAssertEqual(expected, result)
    }
    
    // MARK: Stars
    
    func testStars_zero() {
        let quality: Float = 0
        let result = CanyonDetailView.stars(quality: quality)
        XCTAssertEqual(result.count, 0)
    }
    
    func testStars_one() {
        let quality: Float = 1
        let result = CanyonDetailView.stars(quality: quality)
        XCTAssertEqual(result.count, 1)
    }
    
    func testStars_one_one() {
        let quality: Float = 1.1
        let result = CanyonDetailView.stars(quality: quality)
        XCTAssertEqual(result.count, 1)
    }
    
    func testStars_one_five() {
        let quality: Float = 1.5
        let result = CanyonDetailView.stars(quality: quality)
        XCTAssertEqual(result.count, 2)
    }
    
    func testStars_one_nine() {
        let quality: Float = 1.9
        let result = CanyonDetailView.stars(quality: quality)
        XCTAssertEqual(result.count, 2)
    }
    
    func testStars_two() {
        let quality: Float = 2
        let result = CanyonDetailView.stars(quality: quality)
        XCTAssertEqual(result.count, 2)
    }
    
    func testStars_two_five() {
        let quality: Float = 2.5
        let result = CanyonDetailView.stars(quality: quality)
        XCTAssertEqual(result.count, 3)
    }
    
    func testStars_three() {
        let quality: Float = 3
        let result = CanyonDetailView.stars(quality: quality)
        XCTAssertEqual(result.count, 3)
    }
    
    func testStars_four() {
        let quality: Float = 4
        let result = CanyonDetailView.stars(quality: quality)
        XCTAssertEqual(result.count, 4)
    }
    
    func testStars_five() {
        let quality: Float = 5
        let result = CanyonDetailView.stars(quality: quality)
        XCTAssertEqual(result.count, 5)
    }
}
