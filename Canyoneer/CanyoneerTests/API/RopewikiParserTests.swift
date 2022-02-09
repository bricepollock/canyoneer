//
//  RopewikiParserTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 2/6/22.
//

import Foundation
import XCTest
@testable import Canyoneer

class RopewikiParserTests: XCTestCase {
   
    func testParseBestSeasons_empty() {
        let test = ""
        let result = RopewikiParser.parseTimeOfYear(string: test)
        XCTAssertEqual(result.count, 0)
    }
    
    func testParseBestSeasons_some() {
        let test = ".X.,..X,X..,..X"
        let result = RopewikiParser.parseTimeOfYear(string: test)
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[safe: 0], .february)
        XCTAssertEqual(result[safe: 1], .june)
        XCTAssertEqual(result[safe: 2], .july)
        XCTAssertEqual(result[safe: 3], .december)
    }
    
    func testParseBestSeasons_all() {
        let test = "XXX,XXX,XXX,XXX"
        let result = RopewikiParser.parseTimeOfYear(string: test)
        XCTAssertEqual(result.count, 12)
        XCTAssertEqual(result[safe: 0], .january)
        XCTAssertEqual(result[safe: 1], .february)
        XCTAssertEqual(result[safe: 2], .march)
        XCTAssertEqual(result[safe: 3], .april)
        XCTAssertEqual(result[safe: 4], .may)
        XCTAssertEqual(result[safe: 5], .june)
        XCTAssertEqual(result[safe: 6], .july)
        XCTAssertEqual(result[safe: 7], .august)
        XCTAssertEqual(result[safe: 8], .september)
        XCTAssertEqual(result[safe: 9], .october)
        XCTAssertEqual(result[safe: 10], .november)
        XCTAssertEqual(result[safe: 11], .december)
    }
    
    func testParseBooleanString_yes() {
        let test = "yes"
        let result = RopewikiParser.parseBooleanString(test)
        XCTAssertEqual(result, true)
    }
    func testParseBooleanString_yes_cap() {
        let test = "Yes"
        let result = RopewikiParser.parseBooleanString(test)
        XCTAssertEqual(result, true)
    }
    func testParseBooleanString_no() {
        let test = "no"
        let result = RopewikiParser.parseBooleanString(test)
        XCTAssertEqual(result, false)
    }
    func testParseBooleanString_no_cap() {
        let test = "No"
        let result = RopewikiParser.parseBooleanString(test)
        XCTAssertEqual(result, false)
    }
    func testParseBooleanString_other() {
        let test = "somtimes"
        let result = RopewikiParser.parseBooleanString(test)
        XCTAssertEqual(result, nil)
    }
}
