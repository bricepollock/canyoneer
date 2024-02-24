//  Created by Brice Pollock for Canyoneer on 12/20/23

import Foundation
import XCTest
@testable import Canyoneer

class FavoriteServiceTests: XCTestCase {
    func testMigration() async {
        // clean
        UserPreferencesStorage.clearFavorites()
        
        // Setup legacy DB
        let singleLegacy = LegacyCanyon.dummy()
        let legacy = [singleLegacy]
        UserPreferencesStorage.favorites.set(key: "canyon_favorite_list", value: legacy)
        
        // Migration needed
        XCTAssertTrue(UserPreferencesStorage.favoritesNeedMigration)
        
        // Mock canyon request
        let newCanyon = CanyonIndex(id: "120", name: singleLegacy.name, coordinate: singleLegacy.coordinate)
        let canyonManager = MockCanyonDataManager()
        canyonManager.mockCanyons = [newCanyon]
        
        // Perform migration
        let favoriteService = FavoriteService(canyonManager: canyonManager)
        await favoriteService.start()
                
        XCTAssertFalse(UserPreferencesStorage.favoritesNeedMigration)
        XCTAssertEqual(UserPreferencesStorage.allFavoriteIDs.first, newCanyon.id)
        
        // tear down
        UserPreferencesStorage.clearFavorites()
    }
}

