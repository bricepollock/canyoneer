//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
@testable import Canyoneer

@MainActor
class CanyonAPIURLTests: XCTestCase {
    
    func testIndexURL() {
        let expected = "https://canyoneer--main.s3.us-west-1.amazonaws.com/v2/index.json"
        XCTAssertEqual(CanyonAPIURL.index.absoluteString, expected)
    }
    
    func testCanyonURL() {
        let expected = "https://canyoneer--main.s3.us-west-1.amazonaws.com/v2/details/101.json"
        let url = CanyonAPIURL.canyon(with: "101")
        XCTAssertEqual(url.absoluteString, expected)

    }
}
