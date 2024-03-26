//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
import MapboxMaps
@testable import Canyoneer

@MainActor
class PolylineAnnotation_canyonLineTests: XCTestCase {
    func testIDCodeDecode() throws {
        let canyon = CanyonIndex()
        
        let feature = try XCTUnwrap(CoordinateFeature(name: "unknown type", type: .line, hexColor: "#0000ff", coordinates: [Coordinate(latitude: .zero, longitude: .zero)]))
        let annotation = PolylineAnnotation.makeCanyonLineAnnotation(feature: feature, in: canyon)
        XCTAssertEqual(canyon.id, annotation.canyonId)
    }
}
