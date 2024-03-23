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
    
    @Published public var badgeProfile: Bool = false
    @Published public var mapViewModel: ManyCanyonMapViewModel?
    public let profileViewModel: ProfileViewModel
    private let mapService: MapService
    
    private var favorites: [Canyon] = []
    
    init(
        weatherViewModel: WeatherViewModel,
        mapService: MapService,
        canyonManager: CanyonDataManaging,
        favoriteService: FavoriteServing,
        locationService: LocationService,
        updateManager: UpdateManager = UpdateManager.shared
    ) {
        self.hasDownloadedAll = false
        self.progress = 0

        self.mapService = mapService
        self.profileViewModel = ProfileViewModel(updateManager: updateManager)
        
        // Favorites has its own filter disconnected from map
        let filterViewModel = CanyonFilterViewModel(initialState: .default)
        
        super.init(
            applyFilters: true,
            filterViewModel: filterViewModel,
            filterSheetViewModel: CanyonFilterSheetViewModel(filterViewModel: filterViewModel),
            weatherViewModel: weatherViewModel,
            canyonManager: canyonManager,
            favoriteService: favoriteService,
            locationService: locationService
        )
        
        self.title = Strings.title
        
        self.mapService.$downloadPercentage
            .compactMap { $0 }
            .map {
                Global.logger.debug("Downloading percent: \($0)")
                return $0
            }
            .assign(to: &$progress)
        
        updateManager.$serverHasDatabaseUpdate.assign(to: &$badgeProfile)
    }
    
    public func refresh() async {
        isLoading = true
        defer { isLoading = false }
        favorites = await self.favoriteService.allFavorites()

        let results = favorites.map {
            return QueryResult(name: $0.name, canyonDetails: $0.index)
        }
        self.updateResults(to: results)
        
        self.mapViewModel = ManyCanyonMapViewModel(
            allCanyons: results.map { $0.canyonDetails },
            applyFilters: false,
            filterViewModel: filterViewModel,
            weatherViewModel: weatherViewModel,
            canyonManager: canyonManager,
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
    
    /// Downloads further details for canyons
    /// * The topo map tile data for each canyon
    // TODO: Download images for the canyon
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
