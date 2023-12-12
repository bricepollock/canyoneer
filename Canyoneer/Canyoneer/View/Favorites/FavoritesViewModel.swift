//
//  FavoritesViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import SwiftUI

@MainActor
class FavoriteListViewModel: ResultsViewModel {
    @Published public var hasDownloadedAll: Bool
    @Published public var progress: Double
    @Published public var isDownloading: Bool = false
    
    @Published public var mapViewModel: MapViewModel?
    private let mapService: MapService
    
    private var favorites: [Canyon] = []
    
    init(
        weatherViewModel: WeatherViewModel,
        mapService: MapService,
        canyonService: RopeWikiServiceInterface,
        favoriteService: FavoriteService
    ) {
        self.hasDownloadedAll = false
        self.progress = 0

        self.mapService = mapService
        
        // Favorites has its own filter disconnected from map
        let filterViewModel = CanyonFilterViewModel(initialState: .default)
        
        super.init(
            applyFilters: true,
            filterViewModel: filterViewModel,
            filterSheetViewModel: CanyonFilterSheetViewModel(filterViewModel: filterViewModel),
            weatherViewModel: weatherViewModel,
            canyonService: canyonService,
            favoriteService: favoriteService
        )
        
        self.title = Strings.title
        
        self.mapService.$downloadPercentage
            .compactMap { $0 }
            .map {
                Global.logger.debug("Downloading percent: \($0)")
                return $0
            }
            .assign(to: &$progress)
    }
    
    public func refresh() async {
        isLoading = true
        defer { isLoading = false }
        favorites = self.favoriteService.allFavorites()

        let results = favorites.map {
            return QueryResult(name: $0.name, canyonDetails: $0.index)
        }
        self.updateResults(to: results)
        
        self.mapViewModel = MapViewModel(
            type: .apple,
            allCanyons: results.map { $0.canyonDetails },
            applyFilters: false,
            filterViewModel: filterViewModel,
            weatherViewModel: weatherViewModel,
            canyonService: canyonService,
            favoriteService: favoriteService
        )
        
        if favorites.isEmpty == false {
            do {
                hasDownloadedAll = try await self.mapService.hasDownloaded(all: favorites)
            } catch {
                Global.logger.error(error)
                hasDownloadedAll = false
            }
        }
    }
    
    func downloadCanyonMaps() async {
        guard !isDownloading else { return }
        isDownloading = true
        let startTime = Date()
        do {
            try await self.mapService.downloadTiles(for: self.favorites.compactMap { $0 })
            
            // We don't want to flash UI so we show download for a minimum amount of time
            let timeSinceShown = startTime.timeIntervalSinceNow // a negative number
            let timeRemaining = Constants.minTimeToShow + timeSinceShown
            
            if timeRemaining > 0 {
                // This no longer blocks thread with structured concurrency
                try await Task.sleep(for: .seconds(timeRemaining))
            }

            hasDownloadedAll = true
            Global.logger.info("Downloaded all Canyons")
        } catch {
            Global.logger.error(error)
        }
        
        isDownloading = false
    }
    
    private enum Constants {
        static let minTimeToShow: Double = 1
    }
    
    private enum Strings {
        static let title = "Favorites"
    }
}
