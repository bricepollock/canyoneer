//  Created by Brice Pollock for Canyoneer on 3/8/24

import Foundation
import Combine
import SwiftUI
import CoreLocation

@MainActor
class ManyCanyonMapViewModel: ObservableObject {
    private static let zoomLevelThresholdForTopoLines: Double = 10
    
    @Published var filteredCanyons: [CanyonIndex] = []
    public var visibleCanyons: [CanyonIndex] {
        var lookupMap = [String: String]()
        mapOwner.visibleCanyonIDs.forEach {
            lookupMap[$0] = $0
        }
        // FIXME: Pretty non-performant, could maybe be improved with ViewAnnotation with contains the canyon filter
        return filteredCanyons.filter {
            lookupMap[$0.id] != nil
        }
    }
    
    public let mapOwner: MapboxMap
    public let mapView: AnyUIKitView
    public let showOverlays: Bool
    
    @Published var showTopoLines: Bool = true
    @Published var canRenderTopoLines: Bool = false
    @Published var showCanyonDetails: Bool = false
    var showCanyonWithID: String?
        
    public let filterViewModel: CanyonFilterViewModel
    public let filterSheetViewModel: CanyonFilterSheetViewModel
    
    public let weatherViewModel: WeatherViewModel
    public let canyonManager: CanyonDataManaging
    public let favoriteService: FavoriteServing
    public let locationService: LocationService
    
    private let allCanyons: [CanyonIndex]
    private var bag = Set<AnyCancellable>()
    
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
        self.weatherViewModel = weatherViewModel
        self.canyonManager = canyonManager
        self.favoriteService = favoriteService
        self.locationService = locationService
        self.filterViewModel = filterViewModel
        self.filterSheetViewModel = CanyonFilterSheetViewModel(filterViewModel: filterViewModel)
        self.showOverlays = showOverlays
        
        self.mapOwner = MapboxMap(locationService: locationService)
        self.mapView = mapOwner.view
        
        self.mapOwner.initialize()
        self.updateInitialCamera()
        
        self.$filteredCanyons.sink { canyons in
            Task(priority: .userInitiated) {
                do {
                    try await self.renderCanyonPins(new: canyons, previous: self.filteredCanyons)
                } catch {
                    Global.logger.error(error)
                }
            }
        }.store(in: &bag)
        
        // Initialize canyons to render on map
        if applyFilters {
            // Update based upon state
            filterViewModel.$currentState.map { newState in
                CanyonFilterViewModel.filter(canyons: allCanyons, given: newState)
            }.assign(to: &$filteredCanyons)
        } else {
            filteredCanyons = allCanyons
        }
        
        self.mapOwner.didRequestCanyon.sink { [weak self] canyon in
            guard let self else { return }
            self.showCanyonWithID = canyon.id
            self.showCanyonDetails = true
        }.store(in: &bag)
        
        self.mapOwner.$zoomLevel.sink { [weak self] newLevel in
            guard let self else { return }
            // If we are close enough, then there is minimal performance overhead to render topo lines on client
            self.canRenderTopoLines = newLevel > Self.zoomLevelThresholdForTopoLines
        }.store(in: &bag)
        
        // Handle user-toggling to show canyon-lines
        $showTopoLines
            .sink { [weak self] showLines in
                guard let self else { return }
                if self.canRenderTopoLines {
                    if !showLines {
                        self.mapOwner.cachePolylines()
                    } else {
                        self.mapOwner.applyCache()
                        self.mapOwner.purgePolylineCache()
                    }
                } else {
                    self.mapOwner.purgePolylineCache()
                }
            }.store(in: &bag)
        
        // Update topo lines based upon camera changes
        $canRenderTopoLines
            .combineLatest(mapOwner.$visibleMap)
            .sink { [weak self] canRenderLines, _ in
                guard let self else { return }
                
                // TODO: To avoid this client-workaround we should probably build all the GPX lines, points, etc into Mapbox layers
                if canRenderLines, showTopoLines {
                    let visibleCanyonIDs = self.mapOwner.visibleCanyonIDs
                    Task(priority: .userInitiated) { [weak self] in
                        guard let self else { return }
                        
                        let visibleCanyons = try await self.canyonManager.canyons(for: visibleCanyonIDs)
                        self.mapOwner.renderPolylines(for: visibleCanyons)
                    }
                } else {
                    self.mapOwner.purgePolylineCache()
                    self.mapOwner.removeAllPolylines()
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
    
    func didAppear() {
        // FIXME: do something with selection state
//        mapOwner.deselectCanyons()
    }
    
    private func updateInitialCamera() {
        let utahCenter = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
        let center = UserDefaults.standard.lastViewCoordinate ?? utahCenter
        self.mapOwner.focusCameraOn(location: center)
    }
    
    // MARK: Render details of a group of canyons
    
    /// Complexity: 4*n, could maybe do an optimization of patching only on screen and otherwise group update
    private func renderCanyonPins(new: [CanyonIndex], previous: [CanyonIndex]) async throws {
        Global.logger.debug("Rendering canyons: \(new.count)")
        
        var updatedMap = [String: CanyonIndex]()
        new.forEach { updatedMap[$0.id] = $0}
        
        var currentMap = [String: CanyonIndex]()
        previous.forEach { currentMap[$0.id] = $0}
                
        var removed = [String: CanyonIndex]()
        var added = [CanyonIndex]()
        var all = currentMap
        new.filter { currentMap[$0.id] == nil }
            .forEach {
                all[$0.id] = $0
                added.append($0)
            }
        previous.filter { updatedMap[$0.id] == nil }
            .forEach {
                all[$0.id] = nil
                removed[$0.id] = $0
            }
        
        self.mapOwner.removeAnnotations(for: removed)
        self.mapOwner.addAnnotations(for: added)
    }
    
    private func updateCamera(canyons: [CanyonIndex]) async throws {
        // center location
        if canyons.isEmpty == false && canyons.count < 100 {
            self.mapOwner.focusCameraOn(location: canyons[0].coordinate.asCLObject)
        } else if let lastViewed = UserDefaults.standard.lastViewCoordinate {
            self.mapOwner.focusCameraOn(location: lastViewed)
        } else if locationService.isLocationEnabled() {
            let location = try await self.locationService.getCurrentLocation()
            self.mapOwner.focusCameraOn(location: location)
        }
    }
}
