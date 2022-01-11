//
//  FavoriteViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/11/22.
//

import Foundation
import UIKit

class FavoriteViewController: SearchViewController {
    
    init() {
        let favorites = UserPreferencesStorage.allFavorites
        let results = favorites.map {
            return SearchResult(name: $0.name, type: .canyon, canyonDetails: $0, regionDetails: nil)
        }
        let resultList = SearchResultList(searchString: "Favorites", result: results)
        super.init(result: resultList)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let favorites = UserPreferencesStorage.allFavorites
        let results = favorites.map {
            return SearchResult(name: $0.name, type: .canyon, canyonDetails: $0, regionDetails: nil)
        }
        self.renderResults(results: results)
    }
}
