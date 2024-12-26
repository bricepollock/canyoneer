//
//  ResultsViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import SwiftUI
import Combine

/// A base-class for result views that manages state
@MainActor class ResultsViewModel: NSObject, ObservableObject {
    /// Title of view
    /// Can change depending upon results
    @Published public var title: String
    
    /// Results shown in view, possibly filtered
    /// - Warning: Will update automatically when filters change if applied
    @Published public private(set) var results: [QueryResult]
    
    /// Keeps a copy of unfiltered results so we can apply different filter treatments to the same result-set
    @Published private var unfilteredResults: [QueryResult]
    
    /// Whether view is processing query
    @Published var isLoading: Bool = false
    
    public let canyonManager: CanyonDataManaging
    public let favoriteService: FavoriteServing
    public let locationService: LocationService
    public let weatherViewModel: WeatherViewModel
    public let filterSheetViewModel: CanyonFilterSheetViewModel
    public let filterViewModel: CanyonFilterViewModel
    public private(set) weak var mapDelegate: MainMapDelegate?

    /// - Parameter mapDelegate: Delegate for interacting with the map. If not nil then resulting `CanyonView`s will show a button to switch to map tab at the canyon's location
    init(
        applyFilters: Bool,
        filterViewModel: CanyonFilterViewModel,
        filterSheetViewModel: CanyonFilterSheetViewModel,
        weatherViewModel: WeatherViewModel,
        canyonManager: CanyonDataManaging,
        favoriteService: FavoriteServing,
        locationService: LocationService,
        mapDelegate: MainMapDelegate?
    ) {
        self.title = ""
        self.unfilteredResults = []
        self.results = []
        self.filterViewModel = filterViewModel
        self.filterSheetViewModel = filterSheetViewModel
        self.weatherViewModel = weatherViewModel
        self.canyonManager = canyonManager
        self.favoriteService = favoriteService
        self.locationService = locationService
        self.mapDelegate = mapDelegate
        
        super.init()
        
        $unfilteredResults.map { unfiltered in
            guard applyFilters else {
                return unfiltered
            }
            return filterViewModel.filter(results: unfiltered, with: filterViewModel.currentState)
        }.assign(to: &$results)
        
        // Update results when filters change
        if applyFilters {
            filterViewModel.$currentState
                .dropFirst() // only care about updates
                .compactMap { [weak self] state in
                    guard let self else { return nil }
                    let filtered = self.filterViewModel.filter(results: self.unfilteredResults, with: state)
                    Global.logger.debug("Filtered Favorites: \(filtered.count)/\(unfilteredResults.count)")
                    return filtered
                }
                .assign(to: &$results)
            
        }
    }
    
    func updateResults(to new: [QueryResult]) {
        unfilteredResults = new
    }
    
    func clear() {
        unfilteredResults = []
    }
}
