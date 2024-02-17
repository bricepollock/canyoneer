//  Created by Brice Pollock on 1/12/22.

import Foundation
@testable import Canyoneer

class MockCanyonAPIService: CanyonAPIServing {
    public var mockIndex = CanyonIndexResponse(data: Data(), index: [])
    func canyonIndex() async throws -> CanyonIndexResponse {
        mockIndex
    }
    
    public var mockCanyons: [CanyonResponse] = [CanyonResponse(data: Data(), canyon: RopeWikiCanyon())]
    func canyons(for canyonsToFetch: [CanyonIndex], inBackground: Bool) async throws -> [CanyonResponse] {
        mockCanyons
    }
}


