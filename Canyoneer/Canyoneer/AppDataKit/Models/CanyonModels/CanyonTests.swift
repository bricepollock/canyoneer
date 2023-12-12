//  Created by Brice Pollock for Canyoneer on 12/10/23

import Foundation
import XCTest
@testable import Canyoneer

class CanyonTests: XCTestCase {
    func testLegacyMigration() {
        let legacy = LegacyCanyon.dummy()
        let migration = Canyon(legacy: legacy)
        
        XCTAssertEqual(legacy.id, migration.id)
        XCTAssertEqual(legacy.bestSeasons, migration.bestSeasons)
        XCTAssertEqual(legacy.coordinate.latitude, migration.coordinate.latitude)
        XCTAssertEqual(legacy.coordinate.longitude, migration.coordinate.longitude)
        XCTAssertEqual(legacy.isRestricted, migration.isRestricted)
        XCTAssertEqual(legacy.maxRapLength, Int(migration.maxRapLength?.converted(to: .feet).value.rounded() ?? 0))
        XCTAssertEqual(legacy.name, migration.name)
        XCTAssertEqual(legacy.numRaps, migration.maxRaps)
        XCTAssertEqual(legacy.numRaps, migration.minRaps)
        XCTAssertEqual(legacy.requiresShuttle, migration.requiresShuttle)
        XCTAssertEqual(legacy.requiresPermit, migration.requiresPermits)
        XCTAssertEqual(legacy.ropeWikiURL, migration.ropeWikiURL)
        XCTAssertEqual(legacy.technicalDifficulty, migration.technicalDifficulty)
        XCTAssertEqual(legacy.risk, migration.risk)
        XCTAssertEqual(legacy.timeGrade, migration.timeGrade)
        XCTAssertEqual(legacy.waterDifficulty, migration.waterDifficulty)
        XCTAssertEqual(Double(legacy.quality), migration.quality)
        XCTAssertEqual(legacy.vehicleAccessibility, migration.vehicleAccessibility)
        XCTAssertEqual(legacy.description, migration.description)
    }
}

