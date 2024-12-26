//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
@testable import Canyoneer

class DoubleDigitsTests: XCTestCase {
    func testNoDigits_roundUp() {
        let number: Double = 15.51
        let expected: Double = 16
        XCTAssertEqual(number.digits(0), expected)
    }
    
    func testNoDigits_roundDown() {
        let number: Double = 15.49
        let expected: Double = 15
        XCTAssertEqual(number.digits(0), expected)
    }
    
    func testOneDigit_roundUp() {
        let number: Double = 15.55
        let expected: Double = 15.6
        XCTAssertEqual(number.digits(1), expected)
    }
    
    func testOneDigit_roundDown() {
        let number: Double = 15.54
        let expected: Double = 15.5
        XCTAssertEqual(number.digits(1), expected)
    }
    
    func testFourDigit_roundUp() {
        let number: Double = 15.12345
        let expected: Double = 15.1235
        XCTAssertEqual(number.digits(4), expected)
    }
    
    func testFourDigit_roundDown() {
        let number: Double = 15.12344
        let expected: Double = 15.1234
        XCTAssertEqual(number.digits(4), expected)
    }
}
   
