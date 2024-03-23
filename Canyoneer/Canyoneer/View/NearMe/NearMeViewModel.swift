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
    
    public var mapViewModel: ManyCanyonMapViewModel?
    private let searchService: SearchServiceInterface
    
    init(
        filterViewModel: CanyonFilterViewModel,
        weatherViewModel: WeatherViewModel,
        canyonManager: CanyonDataManaging,
        favoriteService: FavoriteServing,
        searchService: SearchServiceInterface,
        locationService: LocationService
    ) {
        self.searchService = searchService
        super.init(
            applyFilters: true,
            filterViewModel: filterViewModel,
            filterSheetViewModel: CanyonFilterSheetViewModel(filterViewModel: filterViewModel),
            weatherViewModel: weatherViewModel,
            canyonManager: canyonManager,
            favoriteService: favoriteService,
            locationService: locationService
        )
    }
    
    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let resultList = try await self.searchService.nearMeSearch(limit: Self.maxNearMe)
            title = resultList.searchString
            self.updateResults(to: resultList.results)
            
            self.mapViewModel = ManyCanyonMapViewModel(
                allCanyons: self.results.map { $0.canyonDetails },
                applyFilters: true,
                filterViewModel: filterViewModel,
                weatherViewModel: weatherViewModel,
                canyonManager: canyonManager,
                favoriteService: favoriteService
            )
        } catch {
            Global.logger.error(error)
        }
    }
}
