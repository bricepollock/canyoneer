//  Created by Brice Pollock for Canyoneer on 3/8/24

import Foundation
import Combine
import SwiftUI
import CoreLocation

@MainActor
class ManyCanyonMapViewModel: ObservableObject {
    @Published var canyons: [CanyonIndex] = []
    public let mapOwner: AppleMapViewOwner
    public let mapView: AnyUIKitView
    public let showOverlays: Bool
    
    // FIXME: [ISSUE-6] Need to link this with mapOwner so we know whether we are close enough to the map to render topo lines
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
        
        self.mapOwner = AppleMapViewOwner(locationService: locationService, canyonManager: canyonManager)
        self.mapView = mapOwner.view
        
        
        self.mapOwner.initialize()
        self.updateInitialCamera()
        
        self.$canyons.sink { canyons in
            Task(priority: .userInitiated) {
                do {
                    try await self.render(canyons: canyons)
                } catch {
                    Global.logger.error(error)
                }
            }
        }.store(in: &bag)
        
        self.mapOwner.didRequestCanyon.sink {
            self.showCanyonWithID = $0
            self.showCanyonDetails = true
        }.store(in: &bag)

        Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await self.updateCamera(canyons: canyons)
            } catch {
                Global.logger.error(error)
            }
        }
        
        if applyFilters {
            // Update based upon state
            filterViewModel.$currentState.map { newState in
                CanyonFilterViewModel.filter(canyons: allCanyons, given: newState)
            }.assign(to: &$canyons)
        }
    }
    
    func didAppear() {
        mapOwner.deselectCanyons()
    }
    
    private func updateInitialCamera() {
        let utahCenter = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
        let center = UserDefaults.standard.lastViewCoordinate ?? utahCenter
        self.mapOwner.focusCameraOn(location: center)
    }
    
    // MARK: Render details of a group of canyons
    
    /// Complexity: 4*n, could maybe do an optimization of patching only on screen and otherwise group update
    private func render(canyons updated: [CanyonIndex]) async throws {
        Global.logger.debug("Rendering canyons: \(updated.count)")
        
        var updatedMap = [String: CanyonIndex]()
        updated.forEach { updatedMap[$0.id] = $0}
        
        let current = mapOwner.currentCanyons
        var currentMap = [String: CanyonIndex]()
        current.forEach { currentMap[$0.id] = $0}
                
        var removed = [String: CanyonIndex]()
        var added = [CanyonIndex]()
        var all = currentMap
        updated
            .filter { currentMap[$0.id] == nil }
            .forEach {
                all[$0.id] = $0
                added.append($0)
            }
        current
            .filter { updatedMap[$0.id] == nil }
            .forEach {
                all[$0.id] = nil
                removed[$0.id] = $0
            }
                
        // FIXME: We dropped support of TOPO lines on map to migrate to index file, when we address [ISSUE-6] we can use the mapbox tiles and avoid loading all KLM into memory which should allow us to put topo lines back on the map
//        self.mapOwner.removePolylines(for: Array(removed.values))
//        try await self.mapOwner.renderPolylines(for: added)
        
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
