//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
@testable import Canyoneer

extension UserDefaults {
    func resetDefaults() {
        let dictionary = self.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            self.removeObject(forKey: key)
        }
    }
}

@MainActor
class UserDefaults_lastUpdateTests: XCTestCase {
    
    override func tearDown() {
        UserDefaults.standard.resetDefaults()
    }
    
    func testLastUpdateSuccess() {
        let defaults = UserDefaults.standard
        defaults.setLastUpdateSuccess()
        
        XCTAssertEqual(defaults.lastUpdate?.status, IndexUpdateStatus.success)
        XCTAssertNotNil(defaults.lastSuccessfulUpdate)
    }
    
    func testLastUpdateFailure() {
        let defaults = UserDefaults.standard
        defaults.setLastUpdateFailure(error: .singleCanyonUpdate("single failure"))
        
        XCTAssertEqual(defaults.lastUpdate?.status, IndexUpdateStatus.failure(error: .singleCanyonUpdate("anything")))
        XCTAssertNil(defaults.lastSuccessfulUpdate)
    }
}
