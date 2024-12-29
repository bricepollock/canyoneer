//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
@testable import Canyoneer

class ArrayCenterSortTests: XCTestCase {
    func testCenterSort_empty() {
        let array = [Int]()
        XCTAssertEqual(array.centerSort(), array)
    }
    
    func testCenterSort_single() {
        let array = [5]
        let expected = [5]
        XCTAssertEqual(array.centerSort(), expected)
    }
    
    func testCenterSort_two() {
        let array = [4, 5]
        let expected = [5, 4]
        XCTAssertEqual(array.centerSort(), expected)
    }
    
    func testCenterSort_three() {
        let array = [4, 5, 6]
        let expected = [5, 4, 6]
        XCTAssertEqual(array.centerSort(), expected)
    }
    
    func testCenterSort_many_even() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let expected = [6, 5, 7, 4, 8, 3, 9, 2, 10, 1]
        XCTAssertEqual(array.centerSort(), expected)
    }
    
    func testCenterSort_many_odd() {
        let array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let expected = [5, 4, 6, 3, 7, 2, 8, 1, 9, 0, 10]
        XCTAssertEqual(array.centerSort(), expected)
    }
}
   
