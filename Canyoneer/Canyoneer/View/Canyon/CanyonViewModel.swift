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
    public var singleCanyonViewModel: SingleCanyonMapViewModel?
    private let canyonManager: CanyonDataManaging
    private let locationService: LocationService
    private let favoriteService: FavoriteServing
    private let weatherViewModel: WeatherViewModel
    private let gpxService: GPXService
    private weak var mapDelegate: MainMapDelegate?
    
    init(
        canyonId: String,
        canyonManager: CanyonDataManaging,
        locationService: LocationService,
        favoriteService: FavoriteServing,
        weatherViewModel: WeatherViewModel,
        gpxService: GPXService = GPXService(),
        mapDelegate: MainMapDelegate?
    ) {
        self.canyonId = canyonId
        self.canyonManager = canyonManager
        self.locationService = locationService
        self.favoriteService = favoriteService
        self.weatherViewModel = weatherViewModel
        self.gpxService = gpxService
        self.mapDelegate = mapDelegate
    }
    
    // MARK: Actions
    public func refresh() async {
        isLoading = true
        defer { isLoading = false}
        do {
            let canyon = try await canyonManager.canyon(for: self.canyonId)
            self.canyon = canyon
            
            isFavorite = self.favoriteService.isFavorite(canyon: canyon)
            
            detailViewModel = CanyonDetailViewModel(canyon: canyon, weatherViewModel: weatherViewModel, mapDelegate: mapDelegate)
            self.singleCanyonViewModel = SingleCanyonMapViewModel(canyon: canyon)
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
