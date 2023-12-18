//
//  CanyonViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import SwiftUI

@MainActor
class CanyonViewModel: NSObject, ObservableObject {
    @Published public var isLoading: Bool = false
    @Published public var canyon: Canyon?
    @Published public var detailViewModel: CanyonDetailViewModel?
    @Published public var isFavorite: Bool = false
    
    @Published public var showGPXShareSheet: Bool = false
    public var gpxFileURL: URL?
    
    // state
    private let canyonId: String
    
    // objects
    public var mapViewModel: CanyonDetailMapViewModel?
    private let canyonService: CanyonAPIServing
    private let favoriteService: FavoriteService
    private let weatherViewModel: WeatherViewModel
    private let gpxService: GPXService
    
    init(
        canyonId: String,
        canyonService: CanyonAPIServing,
        favoriteService: FavoriteService,
        weatherViewModel: WeatherViewModel,
        gpxService: GPXService = GPXService()
    ) {
        self.canyonId = canyonId
        self.canyonService = canyonService
        self.favoriteService = favoriteService
        self.weatherViewModel = weatherViewModel
        self.gpxService = gpxService
    }
    
    // MARK: Actions
    public func refresh() async {
        isLoading = true
        defer { isLoading = false}
        do {
            let canyon = try await canyonService.canyon(for: self.canyonId)
            self.canyon = canyon
            
            isFavorite = self.favoriteService.isFavorite(canyon: canyon)
            
            detailViewModel = CanyonDetailViewModel(canyon: canyon, weatherViewModel: weatherViewModel)
            self.mapViewModel = CanyonDetailMapViewModel(type: .mapbox, canyon: canyon)
        } catch {
            Global.logger.error(error)
        }
    }
    
    public func toggleFavorite() {
        guard let canyon = canyon else { return }
        
        let isFavorited = favoriteService.isFavorite(canyon: canyon)
        favoriteService.setFavorite(canyon: canyon, to: !isFavorited)
        isFavorite = !isFavorited
    }
    
    public func requestDownloadGPX() {
        guard let canyon = canyon else { return }
        isLoading = true
        defer { isLoading = false}

        guard let url = gpxService.gpxFileUrl(from: canyon) else {
            Global.logger.error("Could not create GPX file!")
            return
        }
        gpxFileURL = url
        showGPXShareSheet = true
    }
}
