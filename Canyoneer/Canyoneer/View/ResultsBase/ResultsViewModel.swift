//
//  ResultsViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import Combine

class ResultsViewModel {
    
    public var title: AnyPublisher<String, Never> {
        self.titleSubject.eraseToAnyPublisher()
    }
    internal let titleSubject = PassthroughSubject<String, Never>()
    
    // used for what to show
    public var currentResults: [SearchResult] = []
    // used for base of the filtering
    public var initialResults: [SearchResult] = []
    // these are current results
    public var results: AnyPublisher<[SearchResult], Never> {
        self.resultsSubject.eraseToAnyPublisher()
    }
    internal let resultsSubject = PassthroughSubject<[SearchResult], Never>()
    
    public let loadingComponent = LoadingComponent()
    
    private var cancelables = [AnyCancellable]()
    public let type: SearchType
    
    // views that pass no search results are expected to use the refresh method to populate
    init(type: SearchType, results: [SearchResult]) {
        self.type = type
        
        self.initialResults = results
        self.currentResults = self.initialResults
        
        let resultCancelable = self.results.sink { [weak self] results in
            self?.currentResults = results
        }
        cancelables.append(resultCancelable)
    }
    
    // refresh the view if it has logic to do so. No-op for some results pages
    open func refresh() { }
    
    func updateFromFilter(with filtered: [SearchResult]) {
        self.currentResults = filtered
        self.resultsSubject.send(filtered)
    }
}
