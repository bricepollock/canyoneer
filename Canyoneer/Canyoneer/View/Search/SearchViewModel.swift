//
//  SearchViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import SwiftUI
import Combine

@MainActor
class SearchViewModel: ResultsViewModel {
    @Published public var query: String = ""
    
    public let nearMeViewModel: NearMeViewModel
    private let searchService: SearchServiceInterface
    
    private var bag = Set<AnyCancellable>()
    
    init(
        searchService: SearchServiceInterface,
        filterViewModel: CanyonFilterViewModel,
        weatherViewModel: WeatherViewModel,
        canyonService: RopeWikiServiceInterface,
        favoriteService: FavoriteService
    ) {
        self.searchService = searchService
        self.nearMeViewModel = NearMeViewModel(
            filerViewModel: filterViewModel,
            weatherViewModel: weatherViewModel,
            canyonService: canyonService,
            favoriteService: favoriteService,
            searchService: searchService
        )
        
        super.init(
            applyFilters: true,
            filterViewModel: filterViewModel,
            weatherViewModel: weatherViewModel,
            canyonService: canyonService,
            favoriteService: favoriteService
        )

        self.title = Strings.search
        
        $query.sink { [weak self] query in
            Task(priority: .userInitiated) { [weak self] in
                await self?.search(query: query)
            }
        }.store(in: &bag)
    }

    // MARK: Actions
        
    private func search(query: String) async {
        guard query.isEmpty == false else {
            updateResults(to: [])
            return
        }
        self.isLoading = true
        let response = await searchService.requestSearch(for: query)
        self.isLoading = false
        self.updateResults(to: response.results)
    }
    
    private enum Strings {
        static let search = "Search"
    }
}
