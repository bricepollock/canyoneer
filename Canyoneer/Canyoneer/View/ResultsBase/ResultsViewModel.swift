//
//  ResultsViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import RxSwift

class ResultsViewModel {
    
    public let title: Observable<String>
    internal let titleSubject: PublishSubject<String>
    
    // used for what to show
    public var currentResults: [SearchResult] = []
    // used for base of the filtering
    public var initialResults: [SearchResult] = []
    // these are current results
    public let results: Observable<[SearchResult]>
    internal let resultsSubject: PublishSubject<[SearchResult]>
    
    public let loadingComponent = LoadingComponent()
    
    internal let bag = DisposeBag()
    public let type: SearchType
    
    // views that pass no search results are expected to use the refresh method to populate
    init(type: SearchType, results: [SearchResult]) {
        self.type = type
        
        self.resultsSubject = PublishSubject()
        self.results = self.resultsSubject.asObservable()
        
        self.titleSubject = PublishSubject()
        self.title = self.titleSubject.asObservable()
        
        self.initialResults = results
        self.currentResults = self.initialResults
        
        self.results.subscribeOnNext { [weak self] results in
            self?.currentResults = results
        }.disposed(by: self.bag)
    }
    
    // refresh the view if it has logic to do so. No-op for some results pages
    open func refresh() { }
    
    func updateFromFilter(with filtered: [SearchResult]) {
        self.currentResults = filtered
        self.resultsSubject.onNext(filtered)
    }
}
