//
//  CoordinateTests.swift
//  Canyoneer
//
//  Created by Brice Pollock on 11/19/23.
//

import Foundation
import XCTest
@testable import Canyoneer

class CoordinateTests: XCTestCase {
    func testString() {
        let coordinate = Coordinate(
            latitude: 36.3887494337,
            longitude: -116.6066334955
        )
        let expected = "36.38875, -116.60663"
        XCTAssertEqual(coordinate.asString, expected)
    }
    
    func testDistance() {
        let start = Coordinate(
            latitude: 36.3887494337,
            longitude: -116.6066334955
        )
        let end = Coordinate(
            latitude: 36.3886426482,
            longitude: -116.603619447
        )
        
        let expected: Double = 270.67738601693776 // meters
        XCTAssertEqual(start.distance(to: end).value, expected)
    }
}
   
