//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
@testable import Canyoneer

class MockCanyonDataManager: CanyonDataManaging {
    public var mockCanyons = [CanyonIndex]()
    func canyons() async -> [CanyonIndex] {
        return mockCanyons
    }
    
    public var mockCanyon: Canyon? = nil
    func canyon(for id: String) async throws -> Canyon {
        guard let mockCanyon else {
            throw GeneralError.notFound
        }
        return mockCanyon
    }
}
