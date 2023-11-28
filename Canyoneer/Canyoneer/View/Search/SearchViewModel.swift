//
//  SearchViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ResultsViewModel {
        
    enum Strings {
        static let search = "Search"
    }
    
    private let searchService: SearchServiceInterface        
    private var bag = Set<AnyCancellable>()
    
    init(
        canyonService: RopeWikiServiceInterface = RopeWikiService(),
        searchService: SearchServiceInterface? = nil
    ) {
        self.searchService = searchService ?? SearchService(canyonService: canyonService)
        super.init(type: .search, results: [])
    }

    // MARK: Actions
        
    public func search(query: String) async {
        self.loadingComponent.startLoading(loadingType: .inline)
        let response = await searchService.requestSearch(for: query)
        self.loadingComponent.stopLoading()
        self.initialResults = response.result
        self.currentResults = response.result
    }
    
    public func clearResults() {
        currentResults = []
    }
}
