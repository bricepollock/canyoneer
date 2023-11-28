//
//  FavoritesViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import Combine

@MainActor
class FavoritesViewModel: ResultsViewModel {
    enum Strings {
        static let title = "Favorites"
    }
    
    @Published public var hasDownloadedAll: Bool?
    @Published public var progress: Double?
    @Published public var isDownloading: Bool = false
    
    private let downloadLoader = LoadingComponent()
    private let favoriteService = FavoriteService()
    private let mapService = MapService.shared
    
    init() {
        super.init(type: .favorites, results: [])
        
        self.mapService.$downloadProgress
            .compactMap { $0?.fractionCompleted }
            .assign(to: &$progress)
    }
    
    public override func refresh() async {
        await super.refresh()
        self.title = Strings.title
        
        self.loadingComponent.startLoading(loadingType: .inline)
        let favorites = self.favoriteService.allFavorites()
        self.loadingComponent.stopLoading()

        let results = favorites.map {
            return SearchResult(name: $0.name, canyonDetails: $0)
        }
        self.initialResults = results
        self.currentResults = results
        
        if !favorites.isEmpty {
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
        do {
            try await self.mapService.downloadTiles(for: self.currentResults.compactMap { $0.canyonDetails })
            hasDownloadedAll = true
            Global.logger.info("Downloaded all Canyons")
        } catch {
            Global.logger.error(error)
        }
        
        isDownloading = false
    }
}
