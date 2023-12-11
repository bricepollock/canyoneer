//
//  MapListViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation

class MapListViewModel: ResultsViewModel {
    private enum Strings {
        static func map(count: Int) -> String {
            return "Map (\(count) Canyons)"
        }
    }
    
    private static let maxMap = 100
    
    init(
        canyonsOnMap: [CanyonIndex],
        filterViewModel: CanyonFilterViewModel,
        filterSheetViewModel: CanyonFilterSheetViewModel,
        weatherViewModel: WeatherViewModel,
        canyonService: RopeWikiServiceInterface,
        favoriteService: FavoriteService
    ) {
        let results = canyonsOnMap.map {
            return QueryResult(name: $0.name, canyonDetails: $0)
        }
        .prefix(Self.maxMap)
        
        super.init(
            applyFilters: true,
            filterViewModel: filterViewModel,
            filterSheetViewModel: filterSheetViewModel,
            weatherViewModel: weatherViewModel,
            canyonService: canyonService,
            favoriteService: favoriteService
        )
        
        self.title = Strings.map(count: results.count)
        self.updateResults(to: Array(results))
    }
}
