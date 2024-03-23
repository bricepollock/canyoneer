//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import XCTest
@testable import Canyoneer

@MainActor
class FilterStateTests: XCTestCase {
    func testDefault() {
        let state = FilterState.default
        XCTAssertEqual(state.maxRap.min, 0)
        XCTAssertEqual(state.maxRap.max, 600)
        
        XCTAssertEqual(state.numRaps.min, 0)
        XCTAssertEqual(state.numRaps.max, 50)
        
        XCTAssertEqual(state.stars.count, 5)
        
        XCTAssertEqual(state.technicality.count, 4)
        XCTAssertEqual(state.water.count, 7)
        XCTAssertEqual(state.time.count, 6)
        XCTAssertNil(state.shuttleRequired)
        XCTAssertEqual(state.seasons.count, 12)

    }
}

