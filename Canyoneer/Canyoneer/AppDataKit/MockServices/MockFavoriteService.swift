//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
@testable import Canyoneer

class MockFavoriteService: FavoriteServing {
    func start() async {}
    
    var allFavorites: [Canyon] = []
    func allFavorites() async -> [Canyon] {
        allFavorites
    }
    
    func isFavorite(canyon: Canyon) -> Bool {
        allFavorites.contains { this in
            this.id == canyon.id
        }
    }
    
    func setFavorite(canyon: Canyon, to isFavorite: Bool) {
        if isFavorite {
            allFavorites.append(canyon)
        } else {
            allFavorites.removeAll { this in
                this.id == canyon.id
            }
        }
    }
}
