//  Created by Brice Pollock for Canyoneer on 12/5/23

import Foundation
import XCTest
@testable import Canyoneer

class DataTableViewModelTests: XCTestCase {
    func testIntValue_nil() {
        let input: Int? = nil
        let expected = "--"
        let result = DataTableViewModel.Strings.intValue(int: input)
        XCTAssertEqual(expected, result)
    }
    
    func testIntValue_notNil() {
        let input: Int? = 1
        let expected = "1"
        let result = DataTableViewModel.Strings.intValue(int: input)
        XCTAssertEqual(expected, result)
    }
    
    func testIntValue_doubleDigit() {
        let input: Int? = 13
        let expected = "13"
        let result = DataTableViewModel.Strings.intValue(int: input)
        XCTAssertEqual(expected, result)
    }
    
    // bool
    func testBoolValue_nil() {
        let input: Bool? = nil
        let expected = "--"
        let result = DataTableViewModel.Strings.boolValue(bool: input)
        XCTAssertEqual(expected, result)
    }
    
    func testBoolValue_yes() {
        let input: Bool? = true
        let expected = "Yes"
        let result = DataTableViewModel.Strings.boolValue(bool: input)
        XCTAssertEqual(expected, result)
    }
    
    func testBoolValue_no() {
        let input: Bool? = false
        let expected = "No"
        let result = DataTableViewModel.Strings.boolValue(bool: input)
        XCTAssertEqual(expected, result)
    }
    
    // String
    func testStringValue_nil() {
        let input: String? = nil
        let expected = "--"
        let result = DataTableViewModel.Strings.stringValue(string: input)
        XCTAssertEqual(expected, result)
    }
    
    func testStringValue_notNil() {
        let input: String? = "Moonflower"
        let expected = "Moonflower"
        let result = DataTableViewModel.Strings.stringValue(string: input)
        XCTAssertEqual(expected, result)
    }
}
