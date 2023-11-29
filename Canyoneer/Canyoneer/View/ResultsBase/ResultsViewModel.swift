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
    
    public let canyonService: RopeWikiServiceInterface
    public let favoriteService: FavoriteService
    public let weatherViewModel: WeatherViewModel
    public let filterSheetViewModel: CanyonFilterSheetViewModel
    public let filterViewModel: CanyonFilterViewModel

    init(
        applyFilters: Bool,
        filterViewModel: CanyonFilterViewModel,
        weatherViewModel: WeatherViewModel,
        canyonService: RopeWikiServiceInterface,
        favoriteService: FavoriteService
    ) {
        self.title = ""
        self.unfilteredResults = []
        self.results = []
        self.filterViewModel = filterViewModel
        self.filterSheetViewModel = CanyonFilterSheetViewModel(filterViewModel: filterViewModel)
        self.weatherViewModel = weatherViewModel
        self.canyonService = canyonService
        self.favoriteService = favoriteService
        
        super.init()
        
        $unfilteredResults.map { unfiltered in
            guard applyFilters else {
                return unfiltered
            }
            return filterViewModel.filter(results: unfiltered)
        }.assign(to: &$results)
        
        // Update results when filters change
        if applyFilters {
            filterViewModel.$currentState
                .dropFirst() // only care about updates
                .compactMap { [weak self] _ in
                    guard let self else { return nil }
                    return self.filterViewModel.filter(results: self.unfilteredResults)
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
