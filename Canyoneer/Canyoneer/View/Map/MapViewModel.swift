//
//  MapViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Combine
import SwiftUI

enum CanyonMapType {
    case apple
    case mapbox
}

enum CanyonMapViewType {
    case apple(AnyUIKitView)
    case mapbox(AnyUIKitView)
}

@MainActor
class MapViewModel: ObservableObject {
    @Published var canyons: [CanyonIndex] = []
    public let mapView: CanyonMapViewType
    public let canyonMapViewOwner: any CanyonMap
    public let showOverlays: Bool
    
    @Published var showCanyonDetails: Bool = false
    var showCanyonWithID: String?
        
    public let filterViewModel: CanyonFilterViewModel
    public let filterSheetViewModel: CanyonFilterSheetViewModel
    
    public let weatherViewModel: WeatherViewModel
    public let canyonService: RopeWikiServiceInterface
    public let favoriteService: FavoriteService
    
    private let allCanyons: [CanyonIndex]
    private let locationService: LocationService
    private var bag = Set<AnyCancellable>()
    
    /// - Parameter applyFilters: Whether to apply filers to the canyons provided and when filters are updated
    init(
        type: CanyonMapType,
        allCanyons: [CanyonIndex],
        applyFilters: Bool,
        showOverlays: Bool = false,
        filterViewModel: CanyonFilterViewModel,
        weatherViewModel: WeatherViewModel,
        canyonService: RopeWikiServiceInterface,
        favoriteService: FavoriteService,
        locationService: LocationService = LocationService()
    ) {
        self.allCanyons = allCanyons
        self.weatherViewModel = weatherViewModel
        self.canyonService = canyonService
        self.favoriteService = favoriteService
        self.locationService = locationService
        self.filterViewModel = filterViewModel
        self.filterSheetViewModel = CanyonFilterSheetViewModel(filterViewModel: filterViewModel)
        self.showOverlays = showOverlays
        
        self.canyons = allCanyons
        switch type {
        case .apple:
            canyonMapViewOwner = AppleMapViewOwner()
        case .mapbox:
            canyonMapViewOwner = MapboxMapViewOwner()
        }
        self.mapView = canyonMapViewOwner.view
        self.canyonMapViewOwner.initialize()
        self.canyonMapViewOwner.updateInitialCamera()
        
        self.$canyons.sink { canyons in
            self.canyonMapViewOwner.render(canyons: canyons)
        }.store(in: &bag)
        
        self.canyonMapViewOwner.didRequestCanyon.sink {
            self.showCanyonWithID = $0
            self.showCanyonDetails = true
        }.store(in: &bag)

        Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await self.canyonMapViewOwner.updateCamera(canyons: canyons)
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
        canyonMapViewOwner.deselectCanyons()
    }
}
