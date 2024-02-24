//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
@testable import Canyoneer

@MainActor
class UpdateManagerTests: XCTestCase {
    var defaults: UserDefaults!
    var canyonManager: MockCanyonDataUpdating!
    var updateManager: UpdateManager!
    
    override func setUp() {
        defaults = UserDefaults.standard
        canyonManager = MockCanyonDataUpdating()
        updateManager = UpdateManager(canyonManager: canyonManager)
    }
    
    override func tearDown() {
        defaults.resetDefaults()
    }
    
    func testNextScheduleDate_none() {
        XCTAssertNil(updateManager.nextScheduledUpdate)
    }
    
    func testNextScheduleDate_fail() {
        defaults.setLastUpdateFailure(error: .indexFileWrite(""))
        XCTAssertNil(updateManager.nextScheduledUpdate)
    }
    
    func testNextScheduleDate_success() {
        defaults.setLastUpdateSuccess()
        XCTAssertNotNil(updateManager.nextScheduledUpdate)
    }
    
    func testShouldCheckServer_noLastUpdate() {
        XCTAssertEqual(updateManager.shouldAutoCheckForUpdate(), true)
    }
    
    func testShouldCheckServer_error() {
        defaults.setLastUpdateFailure(error: .indexFileWrite(""))
        XCTAssertEqual(updateManager.shouldAutoCheckForUpdate(), true)
    }
    
    func testShouldCheckServer_overdue() {
        UserPreferencesStorage().set(key: "last_index_update", value: Date(timeIntervalSince1970: 0))
        XCTAssertEqual(updateManager.shouldAutoCheckForUpdate(), true)
    }
    
    func testShouldCheckServer_successNotOverdue() {
        defaults.setLastUpdateSuccess()
        XCTAssertEqual(updateManager.shouldAutoCheckForUpdate(), false)
    }
}
