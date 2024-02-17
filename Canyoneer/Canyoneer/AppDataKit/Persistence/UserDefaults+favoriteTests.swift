//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
@testable import Canyoneer

@MainActor
class UserDefaults_FavoriteTests: XCTestCase {
    
    override func tearDown() {
        UserDefaults.standard.resetDefaults()
    }
    
    func testAddRemoveAll() {
        XCTAssertEqual(UserPreferencesStorage.allFavoriteIDs.count, 0)
        
        let first = Canyon(id: "101")
        UserPreferencesStorage.addFavorite(canyon: first)
        UserPreferencesStorage.addFavorite(canyon: Canyon(id: "102"))
        
        let all = UserPreferencesStorage.allFavoriteIDs
        XCTAssertEqual(all.count, 2)
        XCTAssertTrue(all.contains(first.id))
        XCTAssertTrue(UserPreferencesStorage.isFavorite(canyon: first))
        
        UserPreferencesStorage.removeFavorite(canyon: first)
        XCTAssertEqual(UserPreferencesStorage.allFavoriteIDs.count, 1)
        XCTAssertFalse(UserPreferencesStorage.isFavorite(canyon: first))
        
        UserPreferencesStorage.clearFavorites()
        XCTAssertEqual(UserPreferencesStorage.allFavoriteIDs.count, 0)
    }
    
    func testMigration() {
        XCTAssertEqual(UserPreferencesStorage.allFavoriteIDs.count, 0)
        
        // Setup legacy DB
        let singleLegacy = LegacyCanyon.dummy()
        let legacy = [singleLegacy]
        UserPreferencesStorage.favorites.set(key: "canyon_favorite_list", value: legacy)
        
        // Migration needed
        XCTAssertTrue(UserPreferencesStorage.favoritesNeedMigration)
        
        // Mock canyon request
        let newCanyon = CanyonIndex(id: "120", name: singleLegacy.name, coordinate: singleLegacy.coordinate)
        UserPreferencesStorage.migrateFavoritesIfNeeded(given: [newCanyon])
                
        XCTAssertFalse(UserPreferencesStorage.favoritesNeedMigration)
        XCTAssertEqual(UserPreferencesStorage.allFavoriteIDs.first, newCanyon.id)
        
        // tear down
        UserPreferencesStorage.clearFavorites()
    }
}
