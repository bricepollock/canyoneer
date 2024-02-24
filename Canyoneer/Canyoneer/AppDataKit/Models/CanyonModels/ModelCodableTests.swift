//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
@testable import Canyoneer

class ModelCodableTests: XCTestCase {
    func testLegacy() throws {
        let model = LegacyCanyon(
            id: "101",
            bestSeasons: [],
            coordinate: .init(latitude: 100, longitude: 100),
            name: "",
            quality: 3,
            description: "",
            geoWaypoints: [],
            geoLines: []
        )
        let data = try JSONEncoder().encode(model)
        let _ = try JSONDecoder().decode(LegacyCanyon.self, from: data)
    }
    
    func testRopeWikiCanyon() throws {
        let model = RopeWikiCanyon()
        let data = try JSONEncoder().encode(model)
        let _ = try JSONDecoder().decode(RopeWikiCanyon.self, from: data)
    }
    
    func testRopeWikiCanyonIndex() throws {
        let model = RopeWikiCanyonIndex()
        let data = try JSONEncoder().encode(model)
        let _ = try JSONDecoder().decode(RopeWikiCanyonIndex.self, from: data)
    }
}
   
