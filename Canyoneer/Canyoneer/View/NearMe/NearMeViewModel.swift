//
//  NearMeViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation

@MainActor
class NearMeViewModel: ResultsViewModel {
    private static let maxNearMe = 100
    
    public var mapViewModel: MapViewModel?
    private let searchService: SearchServiceInterface
    
    init(
        filterViewModel: CanyonFilterViewModel,
        weatherViewModel: WeatherViewModel,
        canyonService: CanyonAPIServing,
        favoriteService: FavoriteService,
        searchService: SearchServiceInterface
    ) {
        self.searchService = searchService
        super.init(
            applyFilters: true,
            filterViewModel: filterViewModel,
            filterSheetViewModel: CanyonFilterSheetViewModel(filterViewModel: filterViewModel),
            weatherViewModel: weatherViewModel,
            canyonService: canyonService,
            favoriteService: favoriteService
        )
    }
    
    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let resultList = try await self.searchService.nearMeSearch(limit: Self.maxNearMe)
            title = resultList.searchString
            self.updateResults(to: resultList.results)
            
            self.mapViewModel = MapViewModel(
                type: .apple,
                allCanyons: self.results.map { $0.canyonDetails },
                applyFilters: true,
                filterViewModel: filterViewModel,
                weatherViewModel: weatherViewModel,
                canyonService: canyonService,
                favoriteService: favoriteService
            )
        } catch {
            Global.logger.error(error)
        }
    }
}
