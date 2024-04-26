//
//  Created by Brice Pollock on 11/19/23.
//

import Foundation
import XCTest
@testable import Canyoneer

class CanyonPreviewTests: XCTestCase {
    func testNumRaps_both() {
        let min: Int? = 11
        let max: Int? = 22
        let canyon = CanyonIndex(minRaps: min, maxRaps: max)
        XCTAssertEqual(canyon.numRappelsAsString, "11-22r")
    }
    
    func testNumRaps_both_same() {
        let min: Int? = 15
        let max: Int? = 15
        let canyon = CanyonIndex(minRaps: min, maxRaps: max)
        XCTAssertEqual(canyon.numRappelsAsString, "15r")
    }
    
    func testNumRaps_min() {
        let min: Int? = 11
        let max: Int? = nil
        let canyon = CanyonIndex(minRaps: min, maxRaps: max)
        XCTAssertEqual(canyon.numRappelsAsString, "11r")
    }
    
    func testNumRaps_max() {
        let min: Int? = nil
        let max: Int? = 22
        let canyon = CanyonIndex(minRaps: min, maxRaps: max)
        XCTAssertEqual(canyon.numRappelsAsString, "22r")
    }
    
    func testNumRaps_none() {
        let min: Int? = nil
        let max: Int? = nil
        let canyon = CanyonIndex(minRaps: min, maxRaps: max)
        XCTAssertNil(canyon.numRappelsAsString)
    }
}
   
