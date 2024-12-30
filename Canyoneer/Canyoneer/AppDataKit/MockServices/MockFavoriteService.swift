//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import Combine
@testable import Canyoneer

class MockFavoriteService: FavoriteServing {
    func start() async {}
    
    var allFavorites: [Canyon] = []
    func allFavorites() async -> [Canyon] {
        allFavorites
    }
    
    func isFavorite(canyon: FavoritableCanyon) -> Bool {
        allFavorites.contains { this in
            this.id == canyon.id
        }
    }
    
    func setFavorite(canyon: CanyonIndex, to isFavorite: Bool) {
        if isFavorite {
            allFavorites.append(Canyon(index: canyon))
        } else {
            allFavorites.removeAll { this in
                this.id == canyon.id
            }
        }
    }
    
    var favoriteStatusDidChange: PassthroughSubject<(canyon: CanyonIndex, isFavorite: Bool), Never> = PassthroughSubject()
}
