//
//  FavoriteService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import RxSwift

class FavoriteService {
    
    func allFavorites() -> Single<[Canyon]> {
        return Single.just(UserPreferencesStorage.allFavorites)
    }
    
    func isFavorite(canyon: Canyon) -> Bool {
        return UserPreferencesStorage.isFavorite(canyon: canyon)
    }
    
    func setFavorite(canyon: Canyon, to isFavorite: Bool) {
        if isFavorite {
            UserPreferencesStorage.addFavorite(canyon: canyon)
        } else {
            UserPreferencesStorage.removeFavorite(canyon: canyon)
        }
    }
}