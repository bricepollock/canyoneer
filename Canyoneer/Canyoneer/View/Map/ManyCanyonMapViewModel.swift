//  Created by Brice Pollock for Canyoneer on 3/8/24

import Foundation
import Combine
import SwiftUI
import CoreLocation

protocol MainMapDelegate: AnyObject {
    @MainActor
    func updateCenter(to location: CLLocationCoordinate2D, zoomLevel: CGFloat, animated: Bool)
}

@MainActor
class ManyCanyonMapViewModel: ObservableObject, MainMapDelegate {
    @Published var filteredCanyons: [CanyonIndex] = []
    public var visibleCanyons: [CanyonIndex] {
        var lookupMap = [String: String]()
        mapViewModel.visibleCanyonIDs().forEach {
            lookupMap[$0] = $0
        }
        // FIXME: Pretty non-performant, but ViewAnnotations have a numerical limit. Maybe a map-object filter is the most performant.
        return filteredCanyons.filter {
            lookupMap[$0.id] != nil
        }
    }
    
    public let mapViewModel: MapboxMapViewModel
    public let showOverlays: Bool
    
    @Published var showTopoLines: Bool = true
    @Published var canRenderTopoLines: Bool = false
    @Published var showCanyonDetails: Bool = false
    
    /// Whether any filters are currently active on map
    @Published var anyFiltersActive: Bool
    
    /// Whether the map is centered at current location
    @Published var isAtCurrentLocation: Bool = false
    /// The user location the last time the 'go to current location' button was tapped
    private var lastUserLocation: CLLocationCoordinate2D?
    
    var showCanyonWithID: String?
        
    public let filterViewModel: CanyonFilterViewModel
    public let filterSheetViewModel: CanyonFilterSheetViewModel
    
    public let weatherViewModel: WeatherViewModel
    public let canyonManager: CanyonDataManaging
    public let favoriteService: FavoriteServing
    public let locationService: LocationService
    
    private let allCanyons: [CanyonIndex]
    private let applyFilters: Bool
    private var hasSetupMap: Bool = false
    private var bag = Set<AnyCancellable>()
    private var currentRenderPolylineTask: Task<Void, Error>?
    
    /// - Parameter applyFilters: Whether to apply filers to the canyons provided and when filters are updated
    init(
        allCanyons: [CanyonIndex],
        applyFilters: Bool,
        showOverlays: Bool = false,
        filterViewModel: CanyonFilterViewModel,
        weatherViewModel: WeatherViewModel,
        canyonManager: CanyonDataManaging,
        favoriteService: FavoriteServing,
        locationService: LocationService = LocationService()
    ) {
        self.allCanyons = allCanyons
        self.applyFilters = applyFilters
        self.showOverlays = showOverlays
        self.anyFiltersActive = filterViewModel.areFiltersActive
        
        self.weatherViewModel = weatherViewModel
        self.canyonManager = canyonManager
        self.favoriteService = favoriteService
        self.locationService = locationService
        self.filterViewModel = filterViewModel
        self.filterSheetViewModel = CanyonFilterSheetViewModel(filterViewModel: filterViewModel)
        self.mapViewModel = MapboxMapViewModel(
            locationService: locationService,
            favoriteService: favoriteService
        )
        
        // Initialize canyons to render on map
        if applyFilters {
            // Update based upon state
            filterViewModel.$currentState.map { [weak self] newState in
                CanyonFilterViewModel.filter(canyons: self?.allCanyons ?? [], given: newState)
            }.assign(to: &$filteredCanyons)
        } else {
            filteredCanyons = allCanyons
        }
        
        // Initialize Current Location
        Task(priority: .high) {
            self.lastUserLocation = try? await locationService.getCurrentLocation()
        }
    }
    
    @MainActor
    func onAppear() {
        guard !hasSetupMap else { return }
        hasSetupMap = true
        
        self.mapViewModel.initialize()
        self.updateInitialCamera()
        
        filterViewModel.$areFiltersActive
            .assign(to: &$anyFiltersActive)
        
        self.$filteredCanyons
            .sink { [weak self] canyons in
                guard let self else { return }
                self.mapViewModel.updateCanyonPins(to: canyons)
        }.store(in: &bag)
        
        favoriteService.favoriteStatusDidChange.sink { [weak self] (canyon, _) in
            guard let self else { return }
            self.mapViewModel.updateCanyonPin(canyon)
        }.store(in: &bag)
        
        self.mapViewModel.didRequestCanyon.sink { [weak self] canyon in
            guard let self else { return }
            self.showCanyonWithID = canyon.id
            self.showCanyonDetails = true
        }.store(in: &bag)
        
        self.mapViewModel.$zoomLevel.sink { [weak self] newLevel in
            guard let self else { return }
            // If we are close enough, then there is minimal performance overhead to render topo lines on client
            self.canRenderTopoLines = newLevel > MapboxMapViewModel.zoomLevelThresholdForTopoLines
        }.store(in: &bag)
        
        // Observe the map state change to know whether centered on current location
        mapViewModel.$visibleMap
            .map { [weak self] _ in
                guard let self, let lastUserLocation else { return false }
                return mapViewModel.center.isClose(to: lastUserLocation)
            }
            .removeDuplicates()
            .assign(to: &$isAtCurrentLocation)
        
        
        // Handle user-toggling to show canyon-lines
        $showTopoLines
            .sink { [weak self] showLines in
                guard let self else { return }
                if self.canRenderTopoLines {
                    if !showLines {
                        self.mapViewModel.cachePolylines()
                        self.mapViewModel.removeAllPolylines()
                    } else {
                        self.mapViewModel.applyCache()
                        self.mapViewModel.purgePolylineCache()
                    }
                } else {
                    self.mapViewModel.removeAllPolylines()
                    self.mapViewModel.purgePolylineCache()
                }
            }.store(in: &bag)
        
        // Update topo lines based upon camera changes
        $canRenderTopoLines
            .combineLatest(mapViewModel.$visibleMap)
            .sink { [weak self] canRenderLines, _ in
                guard let self else { return }
                
                // TODO: To avoid this client-workaround we should probably build all the GPX lines, points, etc into Mapbox layers
                if canRenderLines, showTopoLines {
                    let visibleCanyonIDs = self.mapViewModel.renderAreaCanyonIDs()
                    currentRenderPolylineTask?.cancel()
                    self.currentRenderPolylineTask = Task(priority: .userInitiated) { [weak self] in
                        guard let self else { return }
                        
                        let visibleCanyons = try await self.canyonManager.canyons(for: visibleCanyonIDs)
                        try Task.checkCancellation()
                        self.mapViewModel.updatePolylines(to: visibleCanyons)
                    }
                } else {
                    currentRenderPolylineTask?.cancel()
                    self.mapViewModel.purgePolylineCache()
                    self.mapViewModel.removeAllPolylines()
                }
            }.store(in: &bag)
        
        // Possible race with filtered canyons
        Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await self.updateCamera(canyons: filteredCanyons)
            } catch {
                Global.logger.error(error)
            }
        }
    }
    
    @MainActor
    public func goToCurrentLocation() async {
        guard let currentLocation = try? await locationService.getCurrentLocation() else {
            return
        }
        self.lastUserLocation = currentLocation
        self.mapViewModel.focusCameraOn(location: currentLocation, animated: true)
    }
    
    @MainActor
    public func updateCenter(to location: CLLocationCoordinate2D, zoomLevel: CGFloat, animated: Bool) {
        guard hasSetupMap else {
            // If not setup yet, set this as the last viewport so we adopt it on first render
            UserDefaults.standard.setLastViewport(Viewport(center: location, zoomLevel: zoomLevel))
            return
        }
        self.mapViewModel.focusCameraOn(location: location, zoomLevel: zoomLevel, animated: animated)
    }
    
    private func updateInitialCamera() {
        guard let lastViewport = UserDefaults.standard.lastViewport else {
            let utahCenter = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
            self.mapViewModel.focusCameraOn(location: utahCenter, animated: false)
            return
        }
        
        self.mapViewModel.focusCameraOn(location: lastViewport.center, zoomLevel: lastViewport.zoomLevel, animated: false)
    }
    
    // MARK: Render details of a group of canyons
    
    private func updateCamera(canyons: [CanyonIndex]) async throws {
        // center location
        if canyons.isEmpty == false && canyons.count < 100 {
            self.mapViewModel.focusCameraOn(location: canyons[0].coordinate.asCLObject, animated: false)
        } else if let lastViewed = UserDefaults.standard.lastViewport {
            self.mapViewModel.focusCameraOn(location: lastViewed.center, zoomLevel: lastViewed.zoomLevel, animated: false)
        } else if locationService.isLocationEnabled() {
            let location = try await self.locationService.getCurrentLocation()
            self.mapViewModel.focusCameraOn(location: location, animated: false)
        }
    }
}
