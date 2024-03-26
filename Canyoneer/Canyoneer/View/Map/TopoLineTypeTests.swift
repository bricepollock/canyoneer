//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest

@testable import Canyoneer

@MainActor
class TopoLineTypeTests: XCTestCase {
    func testUnknown() {
        let lineName = "any random name"
        let type = TopoLineType(string: lineName)
        XCTAssertEqual(type, .unknown)
    }
    
    func testDriving_upper() {
        let lineName = "any Drive descent"
        let type = TopoLineType(string: lineName)
        XCTAssertEqual(type, .driving)
    }
    
    func testApproach_upper() {
        let lineName = "any line Approach"
        let type = TopoLineType(string: lineName)
        XCTAssertEqual(type, .approach)
    }
    
    func testDescent_upper() {
        let lineName = "any Descent"
        let type = TopoLineType(string: lineName)
        XCTAssertEqual(type, .descent)
    }
    
    func testExit_upper() {
        let lineName = "this way to the Exit"
        let type = TopoLineType(string: lineName)
        XCTAssertEqual(type, .exit)
    }
}
