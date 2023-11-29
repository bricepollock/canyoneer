//  Created by Brice Pollock for Canyoneer on 12/2/23

import Foundation
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @Published var isLoadingApp: Bool = true
    
    var tabViewModel: MainTabViewModel?
    
    // Top-level app dependencies
    private let canyonService: RopeWikiService
    private let filterViewModel: CanyonFilterViewModel
    private let weatherViewModel: WeatherViewModel
    private let mapService: MapService
    private let favoriteService: FavoriteService
    
    init() {
        canyonService = RopeWikiService()
        weatherViewModel =  WeatherViewModel()
        mapService =  MapService()
        favoriteService =  FavoriteService()
        
        // Right now we reset filter state on load
        filterViewModel = CanyonFilterViewModel(initialState: .default)
    }
    
    func loadApp() async {
        isLoadingApp = true
        
        // load the canyon data
        let allCanyons = await canyonService.canyons()

        tabViewModel = MainTabViewModel(
            allCanyons: allCanyons,
            canyonService: canyonService,
            filterViewModel: filterViewModel,
            weatherViewModel: weatherViewModel,
            mapService: mapService,
            favoriteService: favoriteService
        )
        isLoadingApp = false
    }
}
