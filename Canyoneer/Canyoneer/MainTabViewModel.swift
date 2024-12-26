//  Created by Brice Pollock for Canyoneer on 12/25/24

import Foundation
import SwiftUI

@MainActor
class MainTabViewModel: ObservableObject {
    let tabs: [AppTab]
    let mapViewModel: ManyCanyonMapViewModel
    let favoriteViewModel: FavoriteListViewModel
    let searchViewModel: SearchViewModel
    
    init(
        allCanyons: [CanyonIndex],
        canyonManager: CanyonDataManaging,
        filterViewModel: CanyonFilterViewModel,
        weatherViewModel: WeatherViewModel,
        mapService: MapService,
        favoriteService: FavoriteServing,
        locationService: LocationService
    ) {
        self.tabs = AppTab.allCases.sorted { $0.index < $1.index }
        
        mapViewModel = ManyCanyonMapViewModel(
            allCanyons: allCanyons,
            applyFilters: true,
            showOverlays: true,
            filterViewModel: filterViewModel,
            weatherViewModel: weatherViewModel,
            canyonManager: canyonManager,
            favoriteService: favoriteService
        )
        favoriteViewModel = FavoriteListViewModel(
            weatherViewModel: weatherViewModel,
            mapService: mapService,
            canyonManager: canyonManager,
            favoriteService: favoriteService,
            locationService: locationService,
            mapDelegate: mapViewModel
        )
        
        searchViewModel = SearchViewModel(
            searchService: SearchService(canyonManager: canyonManager),
            filterViewModel: filterViewModel,
            weatherViewModel: weatherViewModel,
            canyonManager: canyonManager,
            favoriteService: favoriteService,
            locationService: locationService
        )
    }
}
