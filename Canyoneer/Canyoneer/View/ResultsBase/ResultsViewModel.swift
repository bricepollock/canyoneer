//
//  ResultsViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import Combine

class ResultsViewModel {
    @Published public var title: String?
    // used for what to show
    @Published public var currentResults: [SearchResult] = []
    // used for base of the filtering
    
    public var initialResults: [SearchResult] = []
    
    public let loadingComponent = LoadingComponent()
    
    public let type: SearchType
    
    // views that pass no search results are expected to use the refresh method to populate
    init(type: SearchType, results: [SearchResult]) {
        self.type = type
        
        self.initialResults = results
        self.currentResults = self.initialResults
    }
    
    // refresh the view if it has logic to do so. No-op for some results pages
    open func refresh() async { }
    
    func updateFromFilter(with filtered: [SearchResult]) {
        self.currentResults = filtered
    }
}
