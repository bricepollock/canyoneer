//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
@testable import Canyoneer

class MockCanyonDataUpdating: MockCanyonDataManager, CanyonDataUpdating {
    var requiresUpdate: DataUpdate?
    func canyonsRequiringUpdate() async throws -> DataUpdate? {
        requiresUpdate
    }
        
    func updateCanyons(from dataUpdate: DataUpdate, inBackground: Bool) async throws {
        
    }
}
